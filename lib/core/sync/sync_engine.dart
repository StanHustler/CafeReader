import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../data/local/snapshot_service.dart';
import '../../data/onedrive/graph_client.dart';
import '../../data/repository/settings_repository.dart';
import '../database/app_database.dart';
import '../util/app_storage.dart';
import 'sync_manifest.dart';

enum SyncStage {
  idle,
  checking,
  downloading,
  merging,
  uploading,
  completed,
  failed,
  cancelled,
}

class SyncProgress {
  const SyncProgress({
    required this.stage,
    required this.message,
    this.current = 0,
    this.total = 0,
  });

  final SyncStage stage;
  final String message;
  final int current;
  final int total;

  double? get fraction => total > 0 ? (current / total).clamp(0.0, 1.0) : null;
}

class SyncResult {
  const SyncResult({
    required this.uploadedFiles,
    required this.downloadedFiles,
    required this.merged,
    required this.warnings,
    required this.completedAt,
  });

  final int uploadedFiles;
  final int downloadedFiles;
  final bool merged;
  final List<String> warnings;
  final DateTime completedAt;
}

class SyncEngine {
  SyncEngine({
    required this.db,
    required this.storage,
    required this.snapshots,
    required this.graphFactory,
    required this.settings,
    required this.deviceId,
  });

  final AppDatabase db;
  final AppStorage storage;
  final SnapshotService snapshots;
  final GraphApi Function() graphFactory;
  final SettingsRepository settings;
  final String deviceId;

  bool _running = false;
  bool get isRunning => _running;

  static const String _manifestPath = 'manifest.json';
  static const String _snapshotPath = 'database/snapshot.sqlite';

  Future<SyncResult> sync({
    SyncProgressCallback? onProgress,
    SyncCancellation? cancellation,
  }) async {
    if (_running) {
      throw OneDriveException('A sync is already in progress.');
    }
    _running = true;
    final token = cancellation ?? SyncCancellation();
    void report(
      SyncStage stage,
      String message, {
      int current = 0,
      int total = 0,
    }) {
      onProgress?.call(
        SyncProgress(
          stage: stage,
          message: message,
          current: current,
          total: total,
        ),
      );
    }

    final warnings = <String>[];
    final staging = Directory(
      p.join(storage.stagingDir.path, 'sync-${const Uuid().v4()}'),
    );
    try {
      await staging.create(recursive: true);
      report(SyncStage.checking, 'Checking Microsoft account…');
      final client = graphFactory();
      token.throwIfCancelled();

      for (var attempt = 0; attempt < 2; attempt++) {
        report(SyncStage.checking, 'Reading OneDrive manifest…');
        final remoteMeta = await client.itemMetadata(_manifestPath);
        final remoteEtag = remoteMeta?['eTag']?.toString();
        final remoteBytes = await client.downloadManifest(
          _manifestPath,
          cancellation: token,
        );
        SyncManifest? remoteManifest;
        if (remoteBytes != null) {
          try {
            remoteManifest = SyncManifest.parse(remoteBytes.bytes);
          } catch (_) {
            throw OneDriveException('The OneDrive sync manifest is invalid.');
          }
          if (remoteManifest.formatVersion >
              SyncManifest.currentFormatVersion) {
            throw OneDriveException(
              'The OneDrive data was created by a newer CafeReader version.',
            );
          }
          if (remoteManifest.schemaVersion < 1 ||
              remoteManifest.schemaVersion >
                  SnapshotService.currentSchemaVersion) {
            throw OneDriveException(
              'OneDrive data uses unsupported database schema '
              '${remoteManifest.schemaVersion}.',
            );
          }
          if (remoteManifest.database.path != _snapshotPath) {
            throw OneDriveException(
              'OneDrive manifest has an unsafe database path.',
            );
          }
        }

        var merged = false;
        var downloadedFiles = 0;
        if (remoteManifest != null) {
          report(SyncStage.downloading, 'Downloading remote data…');
          final remoteDb = File(p.join(staging.path, 'remote-$attempt.sqlite'));
          final downloaded = await client.downloadToFile(
            _snapshotPath,
            remoteDb,
            cancellation: token,
            onProgress: (received, total) {
              report(
                SyncStage.downloading,
                'Downloading remote data…',
                current: received,
                total: total ?? remoteManifest!.database.size,
              );
            },
          );
          if (!downloaded) {
            throw OneDriveException('OneDrive data snapshot is missing.');
          }
          await _verifyFile(remoteDb, remoteManifest.database);
          token.throwIfCancelled();
          report(SyncStage.merging, 'Merging data from other devices…');
          await snapshots.mergeFromFile(
            remoteDb.path,
            currentDeviceId: deviceId,
          );
          merged = true;
          downloadedFiles = await _downloadMissingMedia(
            client,
            remoteManifest,
            token,
            report,
            warnings,
          );
        }

        report(SyncStage.uploading, 'Preparing local files…');
        final localFiles = await _localFileEntries(warnings);
        token.throwIfCancelled();
        final filesToUpload = localFiles.where((entry) {
          final remote = remoteManifest?.files
              .where((candidate) => candidate.path == entry.path)
              .firstOrNull;
          return remote == null || remote.sha256 != entry.sha256;
        }).toList();
        final totalUploadBytes = filesToUpload.fold<int>(
          0,
          (sum, file) => sum + file.size,
        );
        var uploadedBytes = 0;
        for (final entry in filesToUpload) {
          token.throwIfCancelled();
          final source = File(storage.resolveStoredPath(entry.path));
          if (!await source.exists()) {
            warnings.add('Missing file skipped: ${entry.path}');
            continue;
          }
          await client.uploadFile(
            entry.path,
            source,
            cancellation: token,
            onProgress: (sent, total) {
              report(
                SyncStage.uploading,
                'Uploading ${entry.path.split('/').last}…',
                current: uploadedBytes + sent,
                total: totalUploadBytes,
              );
            },
          );
          uploadedBytes += entry.size;
        }

        report(SyncStage.uploading, 'Preparing database snapshot…');
        final snapshot = File(p.join(staging.path, 'upload-$attempt.sqlite'));
        await db.snapshotTo(snapshot.path);
        final snapshotSize = await snapshot.length();
        final snapshotHash = await _hashFile(snapshot);
        token.throwIfCancelled();

        // Detect a remote write that happened while we were preparing.
        final currentMeta = await client.itemMetadata(_manifestPath);
        final currentEtag = currentMeta?['eTag']?.toString();
        if (currentEtag != remoteEtag) {
          if (attempt == 1) {
            throw OneDriveException(
              'OneDrive changed during sync. Please run sync again.',
            );
          }
          continue;
        }

        report(
          SyncStage.uploading,
          'Uploading database snapshot…',
          current: 0,
          total: snapshotSize,
        );
        await client.uploadFile(
          _snapshotPath,
          snapshot,
          cancellation: token,
          onProgress: (sent, total) {
            report(
              SyncStage.uploading,
              'Uploading database snapshot…',
              current: sent,
              total: total,
            );
          },
        );

        final manifest = SyncManifest(
          formatVersion: SyncManifest.currentFormatVersion,
          schemaVersion: SnapshotService.currentSchemaVersion,
          generatedAt: DateTime.now().toUtc(),
          deviceId: deviceId,
          database: SyncFileEntry(
            path: _snapshotPath,
            size: snapshotSize,
            sha256: snapshotHash,
          ),
          files: localFiles,
        );
        report(SyncStage.uploading, 'Publishing sync manifest…');
        try {
          await client.uploadBytes(
            _manifestPath,
            manifest.encode(),
            extraHeaders: remoteEtag == null
                ? {'If-None-Match': '*'}
                : {'If-Match': remoteEtag},
            cancellation: token,
          );
        } on OneDriveException catch (error) {
          if (error.statusCode == 412 && attempt == 0) {
            continue;
          }
          rethrow;
        }

        await settings.set(
          'last_sync_at',
          DateTime.now().toUtc().toIso8601String(),
        );
        await settings.set('last_sync_result', 'success');
        await _markSynced();
        final result = SyncResult(
          uploadedFiles: filesToUpload.length,
          downloadedFiles: downloadedFiles,
          merged: merged,
          warnings: warnings,
          completedAt: DateTime.now(),
        );
        report(SyncStage.completed, 'Sync complete.');
        return result;
      }
      throw OneDriveException('Sync could not complete. Please try again.');
    } on SyncCancelledException {
      report(SyncStage.cancelled, 'Sync cancelled.');
      await settings.set('last_sync_result', 'cancelled');
      rethrow;
    } catch (error) {
      await settings.set('last_sync_result', 'failed');
      report(SyncStage.failed, 'Sync failed: $error');
      rethrow;
    } finally {
      _running = false;
      if (await staging.exists()) {
        await staging.delete(recursive: true);
      }
    }
  }

  Future<int> _downloadMissingMedia(
    GraphApi client,
    SyncManifest remoteManifest,
    SyncCancellation token,
    void Function(SyncStage, String, {int current, int total}) report,
    List<String> warnings,
  ) async {
    final books = await (db.select(
      db.books,
    )..where((table) => table.deletedAt.isNull())).get();
    final needed = <String, int>{};
    for (final book in books) {
      needed[book.originalFilePath] = 0;
      if (book.coverPath != null) {
        needed[book.coverPath!] = 0;
      }
    }
    final requiredFiles = <SyncFileEntry>[];
    for (final entry in needed.keys) {
      final remote = remoteManifest.files
          .where((candidate) => candidate.path == entry)
          .firstOrNull;
      if (remote == null) {
        warnings.add('Remote file unavailable: $entry');
        continue;
      }
      final local = File(storage.resolveStoredPath(entry));
      if (!await local.exists()) {
        requiredFiles.add(remote);
      }
    }
    final total = requiredFiles.fold<int>(0, (sum, file) => sum + file.size);
    var completed = 0;
    for (final entry in requiredFiles) {
      token.throwIfCancelled();
      if (!_isMediaPath(entry.path)) {
        throw OneDriveException('Unsafe remote file path in manifest.');
      }
      final destination = File(storage.resolveStoredPath(entry.path));
      final downloaded = await client.downloadToFile(
        entry.path,
        destination,
        cancellation: token,
        onProgress: (received, fileTotal) {
          report(
            SyncStage.downloading,
            'Downloading ${entry.path.split('/').last}…',
            current: completed + received,
            total: total,
          );
        },
      );
      if (!downloaded) {
        throw OneDriveException('Remote file disappeared: ${entry.path}');
      }
      await _verifyFile(destination, entry);
      completed += entry.size;
    }
    return requiredFiles.length;
  }

  Future<List<SyncFileEntry>> _localFileEntries(List<String> warnings) async {
    final books = await (db.select(
      db.books,
    )..where((table) => table.deletedAt.isNull())).get();
    final paths = <String>{};
    for (final book in books) {
      paths.add(book.originalFilePath);
      if (book.coverPath != null) paths.add(book.coverPath!);
    }
    final entries = <SyncFileEntry>[];
    for (final path in paths) {
      if (!_isMediaPath(path)) {
        warnings.add('Unsafe stored path skipped: $path');
        continue;
      }
      final file = File(storage.resolveStoredPath(path));
      if (!await file.exists()) {
        warnings.add('Local file missing: $path');
        continue;
      }
      entries.add(
        SyncFileEntry(
          path: path,
          size: await file.length(),
          sha256: await _hashFile(file),
        ),
      );
    }
    entries.sort((a, b) => a.path.compareTo(b.path));
    return entries;
  }

  Future<void> _verifyFile(File file, SyncFileEntry expected) async {
    final size = await file.length();
    if (size != expected.size) {
      await file.delete();
      throw OneDriveException(
        'File size verification failed: ${expected.path}',
      );
    }
    final hash = await _hashFile(file);
    if (hash != expected.sha256) {
      await file.delete();
      throw OneDriveException('File checksum failed: ${expected.path}');
    }
  }

  Future<String> _hashFile(File file) async {
    final digest = await sha256.bind(file.openRead()).first;
    return digest.toString();
  }

  Future<void> _markSynced() async {
    final now = DateTime.now();
    final books = await (db.select(
      db.books,
    )..where((table) => table.deletedAt.isNull())).get();
    await db.batch((batch) {
      for (final book in books) {
        batch.insert(
          db.syncMetadata,
          SyncMetadataCompanion.insert(
            id: 'book:${book.id}',
            entityType: 'book',
            entityId: book.id,
            localUpdatedAt: book.updatedAt,
            lastSyncedAt: Value(now),
            lastSyncedVersion: Value(book.revision),
            syncStatus: const Value('synced'),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  static bool _isMediaPath(String path) =>
      (path.startsWith('books/') || path.startsWith('covers/')) &&
      !path.contains('..') &&
      !path.contains('\\');
}

typedef SyncProgressCallback = void Function(SyncProgress progress);
