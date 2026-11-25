import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as raw;
import 'package:uuid/uuid.dart';

import '../../data/local/snapshot_service.dart';
import '../database/app_database.dart';
import '../util/app_storage.dart';

class BackupArtifact {
  const BackupArtifact({
    required this.path,
    required this.manifest,
    required this.totalBytes,
  });

  final String path;
  final Map<String, Object?> manifest;
  final int totalBytes;
}

class BackupInspection {
  const BackupInspection({
    required this.backupType,
    required this.createdAt,
    required this.appVersion,
    required this.schemaVersion,
    required this.bookCount,
    required this.fileCount,
    required this.totalBytes,
    this.bookId,
  });

  final String backupType;
  final DateTime createdAt;
  final String appVersion;
  final int schemaVersion;
  final int bookCount;
  final int fileCount;
  final int totalBytes;
  final String? bookId;
}

class BackupException implements Exception {
  BackupException(this.message);
  final String message;
  @override
  String toString() => message;
}

class BackupService {
  BackupService({
    required this.db,
    required this.storage,
    required this.snapshots,
    required this.deviceId,
  });

  final AppDatabase db;
  final AppStorage storage;
  final SnapshotService snapshots;
  final String deviceId;

  static const int backupFormatVersion = 1;

  Future<BackupArtifact> createBackup({String? bookId}) async {
    final staging = Directory(
      p.join(storage.stagingDir.path, 'backup-${const Uuid().v4()}'),
    );
    await staging.create(recursive: true);
    try {
      final databaseFile = File(
        p.join(staging.path, 'database', 'database.sqlite'),
      );
      await databaseFile.parent.create(recursive: true);
      await db.snapshotTo(databaseFile.path);
      if (bookId != null) {
        await _pruneSnapshotToBook(databaseFile.path, bookId);
      }

      final booksQuery = db.select(db.books);
      if (bookId != null) {
        booksQuery.where((table) => table.id.equals(bookId));
      } else {
        booksQuery.where((table) => table.deletedAt.isNull());
      }
      final books = await booksQuery.get();
      final files = <Map<String, Object?>>[];
      var totalBytes = 0;

      Future<void> addFile(String relativePath, File source) async {
        if (!await source.exists()) {
          throw BackupException('Missing book file: ${source.path}');
        }
        final target = File(p.join(staging.path, relativePath));
        await target.parent.create(recursive: true);
        await source.copy(target.path);
        final size = await target.length();
        final hash = await _hashFile(target);
        files.add({'path': relativePath, 'size': size, 'sha256': hash});
        totalBytes += size;
      }

      for (final book in books) {
        final bookSource = storage.fileForStoredPath(book.originalFilePath);
        await addFile(book.originalFilePath, bookSource);
        if (book.coverPath != null) {
          await addFile(
            book.coverPath!,
            storage.fileForStoredPath(book.coverPath!),
          );
        }
      }
      // Add the database last so its hash exists in the manifest.
      final dbSize = await databaseFile.length();
      final dbHash = await _hashFile(databaseFile);
      files.add({
        'path': 'database/database.sqlite',
        'size': dbSize,
        'sha256': dbHash,
      });
      totalBytes += dbSize;

      final manifest = <String, Object?>{
        'backup_format_version': backupFormatVersion,
        'app_name': 'CafeReader',
        'app_version': await _appVersion(),
        'database_schema_version': SnapshotService.currentSchemaVersion,
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'device_id': deviceId,
        'backup_type': bookId == null ? 'full' : 'single_book',
        'book_id': ?bookId,
        'files': files,
      };
      await File(p.join(staging.path, 'manifest.json')).writeAsString(
        const JsonEncoder.withIndent('  ').convert(manifest),
        flush: true,
      );
      ensureNoUnsafePaths(staging);

      final output = File(
        p.join(
          storage.backupsDir.path,
          'CafeReader-${_timestampName()}-${bookId == null ? 'full' : 'book'}.cfr',
        ),
      );
      await _zipDirectory(staging, output);
      return BackupArtifact(
        path: output.path,
        manifest: manifest,
        totalBytes: totalBytes,
      );
    } finally {
      if (await staging.exists()) {
        await staging.delete(recursive: true);
      }
    }
  }

  Future<BackupInspection> inspectBackup(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw BackupException('Backup file does not exist.');
    }
    final input = InputFileStream(file.path);
    try {
      final Archive archive;
      try {
        archive = ZipDecoder().decodeStream(input, verify: true);
      } catch (error) {
        throw BackupException('The .cfr file is not a valid archive.');
      }
      final manifestFile = archive.files
          .where((entry) => entry.name == 'manifest.json')
          .firstOrNull;
      if (manifestFile == null) {
        throw BackupException('Backup manifest is missing.');
      }
      final manifest = _decodeManifest(manifestFile.content);
      final validation = _validateManifest(manifest);
      final databaseEntry = archive.files
          .where((entry) => entry.name == 'database/database.sqlite')
          .firstOrNull;
      if (databaseEntry == null) {
        throw BackupException('Backup does not contain its database snapshot.');
      }
      return BackupInspection(
        backupType: validation.backupType,
        createdAt: validation.createdAt,
        appVersion: validation.appVersion,
        schemaVersion: validation.schemaVersion,
        bookCount: validation.bookCount,
        fileCount: archive.files.where((entry) => entry.isFile).length,
        totalBytes: archive.files
            .where((entry) => entry.isFile)
            .fold<int>(0, (sum, entry) => sum + entry.size),
        bookId: validation.bookId,
      );
    } finally {
      await input.close();
    }
  }

  Future<void> restoreBackup(String path, {bool merge = false}) async {
    final staging = Directory(
      p.join(storage.stagingDir.path, 'restore-${const Uuid().v4()}'),
    );
    await staging.create(recursive: true);
    final input = InputFileStream(path);
    try {
      final Archive archive;
      try {
        archive = ZipDecoder().decodeStream(input, verify: true);
      } catch (_) {
        throw BackupException('The .cfr file is not a valid archive.');
      }
      final manifestEntry = archive.files
          .where((entry) => entry.name == 'manifest.json')
          .firstOrNull;
      if (manifestEntry == null) {
        throw BackupException('Backup manifest is missing.');
      }
      final manifest = _decodeManifest(manifestEntry.content);
      _validateManifest(manifest);
      final declared = <String, Map<String, Object?>>{};
      final filesList = manifest['files'];
      if (filesList is! List) {
        throw BackupException('Backup manifest has no file list.');
      }
      for (final value in filesList) {
        if (value is! Map) continue;
        final entryPath = _safeRelativePath(value['path']?.toString() ?? '');
        declared[entryPath] = {
          'size': (value['size'] as num?)?.toInt() ?? -1,
          'sha256': value['sha256']?.toString() ?? '',
        };
      }
      if (!declared.containsKey('database/database.sqlite')) {
        throw BackupException('Backup database is not declared in manifest.');
      }
      final totalDeclared = declared.values.fold<int>(
        0,
        (sum, item) => sum + ((item['size'] as int?) ?? 0),
      );
      if (totalDeclared > 4 * 1024 * 1024 * 1024) {
        throw BackupException('Backup is too large to restore safely.');
      }
      if (archive.files.length > 50000) {
        throw BackupException('Backup contains too many files.');
      }

      for (final entry in archive.files) {
        if (!entry.isFile || entry.name == 'manifest.json') continue;
        final relative = _safeRelativePath(entry.name);
        if (relative.startsWith('database/') ||
            relative.startsWith('books/') ||
            relative.startsWith('covers/') ||
            relative.startsWith('metadata/') ||
            relative.startsWith('dictionaries/')) {
          final target = File(p.join(staging.path, relative));
          final canonical = p.canonicalize(target.path);
          if (!p.isWithin(p.canonicalize(staging.path), canonical)) {
            throw BackupException('Backup contains an unsafe file path.');
          }
          await target.parent.create(recursive: true);
          await target.writeAsBytes(entry.content, flush: true);
        }
      }

      // Verify declared hashes and sizes.
      for (final entry in declared.entries) {
        final target = File(p.join(staging.path, entry.key));
        if (!await target.exists()) {
          throw BackupException('Backup is missing ${entry.key}.');
        }
        final expectedSize = entry.value['size'] as int? ?? -1;
        final actualSize = await target.length();
        if (expectedSize >= 0 && expectedSize != actualSize) {
          throw BackupException('Backup file size check failed: ${entry.key}');
        }
        final expectedHash = entry.value['sha256']?.toString() ?? '';
        if (expectedHash.isNotEmpty) {
          final actualHash = await _hashFile(target);
          if (actualHash != expectedHash) {
            throw BackupException('Backup file checksum failed: ${entry.key}');
          }
        }
      }

      await input.close();
      final databasePath = p.join(staging.path, 'database', 'database.sqlite');
      final info = await snapshots.inspect(databasePath);
      if (info.schemaVersion < 1 ||
          info.schemaVersion > SnapshotService.currentSchemaVersion) {
        throw BackupException(
          'Backup schema ${info.schemaVersion} is not supported.',
        );
      }

      if (!merge) {
        // A destructive restore always leaves a complete, validated snapshot of
        // the current state in the app's backups folder.
        await createBackup();
        await _replaceMediaDirectories(staging, databasePath);
      } else {
        await _copyMissingMedia(staging);
        await snapshots.mergeFromFile(databasePath, currentDeviceId: deviceId);
      }
      await db
          .into(db.appMetadata)
          .insert(
            AppMetadataCompanion.insert(
              key: 'last_restore_at',
              value: DateTime.now().toUtc().toIso8601String(),
              updatedAt: DateTime.now(),
            ),
            mode: InsertMode.insertOrReplace,
          );
    } finally {
      try {
        await input.close();
      } catch (_) {}
      if (await staging.exists()) {
        await staging.delete(recursive: true);
      }
    }
  }

  Future<void> _replaceMediaDirectories(
    Directory staging,
    String databasePath,
  ) async {
    final oldBooks = Directory('${storage.booksDir.path}.old');
    final oldCovers = Directory('${storage.coversDir.path}.old');
    for (final dir in [oldBooks, oldCovers]) {
      if (await dir.exists()) await dir.delete(recursive: true);
    }
    var booksMoved = false;
    var coversMoved = false;
    var booksInstalled = false;
    var coversInstalled = false;
    try {
      if (await storage.booksDir.exists()) {
        await storage.booksDir.rename(oldBooks.path);
        booksMoved = true;
      }
      if (await storage.coversDir.exists()) {
        await storage.coversDir.rename(oldCovers.path);
        coversMoved = true;
      }
      final newBooks = Directory(p.join(staging.path, 'books'));
      final newCovers = Directory(p.join(staging.path, 'covers'));
      if (await newBooks.exists()) {
        await newBooks.rename(storage.booksDir.path);
      } else {
        await storage.booksDir.create(recursive: true);
      }
      booksInstalled = true;
      if (await newCovers.exists()) {
        await newCovers.rename(storage.coversDir.path);
      } else {
        await storage.coversDir.create(recursive: true);
      }
      coversInstalled = true;
      await snapshots.replaceFromFile(databasePath, currentDeviceId: deviceId);
      if (await oldBooks.exists()) await oldBooks.delete(recursive: true);
      if (await oldCovers.exists()) await oldCovers.delete(recursive: true);
    } catch (error) {
      if (booksInstalled && await storage.booksDir.exists()) {
        await storage.booksDir.delete(recursive: true);
      }
      if (coversInstalled && await storage.coversDir.exists()) {
        await storage.coversDir.delete(recursive: true);
      }
      if (booksMoved && await oldBooks.exists()) {
        await oldBooks.rename(storage.booksDir.path);
      }
      if (coversMoved && await oldCovers.exists()) {
        await oldCovers.rename(storage.coversDir.path);
      }
      throw BackupException(
        'Restore failed and local files were preserved: $error',
      );
    }
  }

  Future<void> _copyMissingMedia(Directory staging) async {
    for (final folder in ['books', 'covers']) {
      final sourceDir = Directory(p.join(staging.path, folder));
      if (!await sourceDir.exists()) continue;
      await for (final entity in sourceDir.list()) {
        if (entity is! File) continue;
        final name = p.basename(entity.path);
        if (name.contains('/') || name.contains('..')) {
          throw BackupException('Unsafe media file name in backup.');
        }
        final target = File(p.join(storage.root.path, folder, name));
        if (!await target.exists()) {
          await target.parent.create(recursive: true);
          await entity.copy(target.path);
        }
      }
    }
  }

  Future<void> _pruneSnapshotToBook(String path, String bookId) async {
    raw.Database? snapshot;
    try {
      snapshot = raw.sqlite3.open(path);
      snapshot.execute('PRAGMA foreign_keys = OFF');
      snapshot.execute('BEGIN IMMEDIATE');
      // Groups are library organisation rather than part of one book, so a
      // single-book backup carries no group rows at all.
      snapshot.execute('DELETE FROM book_group_books');
      snapshot.execute('DELETE FROM book_groups');
      // Dictionaries are global library data, not part of one book.
      snapshot.execute('DELETE FROM dictionary_entries');
      snapshot.execute('DELETE FROM dictionaries');
      snapshot.execute('DELETE FROM reading_progress WHERE book_id != ?', [
        bookId,
      ]);
      snapshot.execute(
        'DELETE FROM pagination_caches WHERE chapter_id NOT IN '
        '(SELECT id FROM chapters WHERE book_id = ?)',
        [bookId],
      );
      snapshot.execute('DELETE FROM word_occurrences WHERE book_id != ?', [
        bookId,
      ]);
      snapshot.execute('DELETE FROM chapters WHERE book_id != ?', [bookId]);
      snapshot.execute('DELETE FROM books WHERE id != ?', [bookId]);
      snapshot.execute('''
        CREATE TEMP TABLE keep_vocabulary AS
        SELECT DISTINCT COALESCE(override_vocabulary_id, vocabulary_id) AS id
        FROM word_occurrences
      ''');
      snapshot.execute(
        'DELETE FROM review_logs WHERE vocabulary_id NOT IN '
        '(SELECT id FROM keep_vocabulary)',
      );
      snapshot.execute(
        'DELETE FROM fsrs_cards WHERE vocabulary_id NOT IN '
        '(SELECT id FROM keep_vocabulary)',
      );
      snapshot.execute(
        'DELETE FROM definitions WHERE vocabulary_id NOT IN '
        '(SELECT id FROM keep_vocabulary)',
      );
      snapshot.execute(
        'DELETE FROM word_forms WHERE vocabulary_id NOT IN '
        '(SELECT id FROM keep_vocabulary)',
      );
      snapshot.execute(
        'DELETE FROM word_statuses WHERE vocabulary_id NOT IN '
        '(SELECT id FROM keep_vocabulary)',
      );
      snapshot.execute(
        'DELETE FROM vocabulary WHERE id NOT IN '
        '(SELECT id FROM keep_vocabulary)',
      );
      snapshot.execute('DROP TABLE keep_vocabulary');
      snapshot.execute('COMMIT');
      snapshot.execute('VACUUM');
    } catch (error) {
      try {
        snapshot?.execute('ROLLBACK');
      } catch (_) {}
      throw BackupException('Could not prepare single-book backup: $error');
    } finally {
      snapshot?.close();
    }
  }

  Future<void> _zipDirectory(Directory staging, File output) async {
    if (await output.exists()) await output.delete();
    final encoder = ZipFileEncoder();
    await encoder.zipDirectory(staging, filename: output.path);
  }

  Future<String> _hashFile(File file) async {
    final digest = await sha256.bind(file.openRead()).first;
    return digest.toString();
  }

  Future<String> _appVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return '${info.version}+${info.buildNumber}';
    } catch (_) {
      return '1.0.0';
    }
  }

  Map<String, Object?> _decodeManifest(List<int> bytes) {
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map) {
        throw const FormatException('Manifest must be an object.');
      }
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    } catch (_) {
      throw BackupException('Backup manifest is not valid JSON.');
    }
  }

  _ManifestValidation _validateManifest(Map<String, Object?> manifest) {
    if (manifest['app_name'] != 'CafeReader') {
      throw BackupException('This is not a CafeReader backup.');
    }
    final formatVersion =
        (manifest['backup_format_version'] as num?)?.toInt() ?? 0;
    if (formatVersion > backupFormatVersion) {
      throw BackupException(
        'This backup was created by a newer version of CafeReader.',
      );
    }
    if (formatVersion < 1) {
      throw BackupException('Unsupported backup format.');
    }
    final schemaVersion =
        (manifest['database_schema_version'] as num?)?.toInt() ?? 0;
    if (schemaVersion < 1 ||
        schemaVersion > SnapshotService.currentSchemaVersion) {
      throw BackupException(
        'Backup database schema $schemaVersion is not supported.',
      );
    }
    final created = DateTime.tryParse(manifest['created_at']?.toString() ?? '');
    if (created == null) {
      throw BackupException('Backup has an invalid creation time.');
    }
    final files = manifest['files'];
    if (files is! List || files.isEmpty) {
      throw BackupException('Backup has no file list.');
    }
    final backupType = manifest['backup_type']?.toString() ?? 'full';
    return _ManifestValidation(
      backupType: backupType,
      createdAt: created,
      appVersion: manifest['app_version']?.toString() ?? 'unknown',
      schemaVersion: schemaVersion,
      bookCount: backupType == 'single_book' ? 1 : 0,
      bookId: manifest['book_id']?.toString(),
    );
  }

  static String _safeRelativePath(String value) {
    final normalizedSlashes = value.replaceAll('\\', '/');
    if (normalizedSlashes.isEmpty ||
        normalizedSlashes.startsWith('/') ||
        RegExp(r'^[A-Za-z]:').hasMatch(normalizedSlashes)) {
      throw BackupException('Backup contains an unsafe path.');
    }
    final normalized = p.posix.normalize(normalizedSlashes);
    if (normalized == '..' ||
        normalized.startsWith('../') ||
        normalized.contains('/../')) {
      throw BackupException('Backup contains a path traversal entry.');
    }
    return normalized;
  }

  static void ensureNoUnsafePaths(Directory dir) {
    for (final entity in dir.listSync(recursive: true)) {
      final relative = p.relative(entity.path, from: dir.path);
      _safeRelativePath(relative);
    }
  }

  static String _timestampName() {
    final now = DateTime.now();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${now.year}${two(now.month)}${two(now.day)}-'
        '${two(now.hour)}${two(now.minute)}${two(now.second)}';
  }
}

class _ManifestValidation {
  const _ManifestValidation({
    required this.backupType,
    required this.createdAt,
    required this.appVersion,
    required this.schemaVersion,
    required this.bookCount,
    this.bookId,
  });
  final String backupType;
  final DateTime createdAt;
  final String appVersion;
  final int schemaVersion;
  final int bookCount;
  final String? bookId;
}
