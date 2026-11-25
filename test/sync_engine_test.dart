import 'dart:io';

import 'package:cafereader/core/database/app_database.dart';
import 'package:cafereader/core/sync/sync_engine.dart';
import 'package:cafereader/core/util/app_storage.dart';
import 'package:cafereader/data/local/snapshot_service.dart';
import 'package:cafereader/data/onedrive/graph_client.dart';
import 'package:cafereader/data/repository/settings_repository.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  test(
    'two devices merge entities and transfer book files through sync',
    () async {
      final temp = await Directory.systemTemp.createTemp(
        'cafereader-sync-test',
      );
      addTearDown(() async {
        if (await temp.exists()) await temp.delete(recursive: true);
      });
      final graph = _FakeGraph();
      final storageA = AppStorage.at(Directory('${temp.path}/a'));
      final storageB = AppStorage.at(Directory('${temp.path}/b'));
      await storageA.ensureLayout();
      await storageB.ensureLayout();
      final dbA = AppDatabase.memory();
      final dbB = AppDatabase.memory();
      addTearDown(dbA.close);
      addTearDown(dbB.close);
      final now = DateTime(2026, 6, 1, 9);
      await _seedDevice(
        dbA,
        storageA,
        bookId: 'book-a',
        title: 'Book A',
        deviceId: 'device-a',
        status: 'KNOWN',
        revision: 5,
        now: now,
        reviewLogId: 'log-a',
      );
      await _seedDevice(
        dbB,
        storageB,
        bookId: 'book-b',
        title: 'Book B',
        deviceId: 'device-b',
        status: 'LEARNING',
        revision: 3,
        now: now,
        reviewLogId: 'log-b',
      );
      final engineA = SyncEngine(
        db: dbA,
        storage: storageA,
        snapshots: SnapshotService(dbA),
        graphFactory: () => graph,
        settings: SettingsRepository(dbA, 'device-a'),
        deviceId: 'device-a',
      );
      final engineB = SyncEngine(
        db: dbB,
        storage: storageB,
        snapshots: SnapshotService(dbB),
        graphFactory: () => graph,
        settings: SettingsRepository(dbB, 'device-b'),
        deviceId: 'device-b',
      );

      await engineA.sync();
      expect(
        graph.files.keys,
        containsAll([
          'manifest.json',
          'database/snapshot.sqlite',
          'books/book-a.txt',
        ]),
      );
      expect(graph.files.containsKey('books/book-b.txt'), isFalse);

      await engineB.sync();
      expect(graph.files.keys, contains('books/book-b.txt'));
      expect(
        File(storageB.resolveStoredPath('books/book-a.txt')).existsSync(),
        isTrue,
      );

      await engineA.sync();
      expect(
        File(storageA.resolveStoredPath('books/book-b.txt')).existsSync(),
        isTrue,
      );

      final booksA = await dbA.select(dbA.books).get();
      final booksB = await dbB.select(dbB.books).get();
      expect(booksA.map((book) => book.id).toSet(), {'book-a', 'book-b'});
      expect(booksB.map((book) => book.id).toSet(), {'book-a', 'book-b'});
      final statusA =
          await (dbA.select(dbA.wordStatuses)
                ..where((table) => table.vocabularyId.equals('shared-vocab')))
              .getSingle();
      final statusB =
          await (dbB.select(dbB.wordStatuses)
                ..where((table) => table.vocabularyId.equals('shared-vocab')))
              .getSingle();
      expect(statusA.status, 'KNOWN');
      expect(statusB.status, 'KNOWN');
      final logsA = await dbA.select(dbA.reviewLogs).get();
      final logsB = await dbB.select(dbB.reviewLogs).get();
      expect(logsA.map((log) => log.id).toSet(), {'log-a', 'log-b'});
      expect(logsB.map((log) => log.id).toSet(), {'log-a', 'log-b'});
      final synced = await dbA.select(dbA.syncMetadata).get();
      expect(synced.map((row) => row.entityId).toSet(), {'book-a', 'book-b'});
      // A repeated sync is idempotent.
      await engineA.sync();
      expect(await dbA.select(dbA.books).get(), hasLength(2));
      expect(await dbA.select(dbA.reviewLogs).get(), hasLength(2));
    },
  );
}

Future<void> _seedDevice(
  AppDatabase db,
  AppStorage storage, {
  required String bookId,
  required String title,
  required String deviceId,
  required String status,
  required int revision,
  required DateTime now,
  required String reviewLogId,
}) async {
  final relative = storage.bookRelativePath(bookId, 'txt');
  final file = File(storage.resolveStoredPath(relative));
  await file.parent.create(recursive: true);
  await file.writeAsString('$title original content');
  await db
      .into(db.books)
      .insert(
        BooksCompanion.insert(
          id: bookId,
          title: title,
          originalFilePath: relative,
          format: 'txt',
          importedAt: now,
          updatedAt: now,
          updatedBy: Value(deviceId),
        ),
      );
  await db
      .into(db.chapters)
      .insert(
        ChaptersCompanion.insert(
          id: 'chapter-$bookId',
          bookId: bookId,
          title: 'Chapter',
          chapterIndex: 0,
          content: 'A $title chapter with words.',
          contentHash: 'hash-$bookId',
          updatedAt: now,
        ),
      );
  await db
      .into(db.vocabulary)
      .insert(
        VocabularyCompanion.insert(
          id: 'shared-vocab',
          lemma: 'shared',
          createdAt: now,
          updatedAt: now,
        ),
        mode: InsertMode.insertOrIgnore,
      );
  await db
      .into(db.wordStatuses)
      .insert(
        WordStatusesCompanion.insert(
          vocabularyId: 'shared-vocab',
          status: status,
          revision: Value(revision),
          updatedBy: Value(deviceId),
          updatedAt: now,
        ),
        mode: InsertMode.insertOrReplace,
      );
  await db
      .into(db.reviewLogs)
      .insert(
        ReviewLogsCompanion.insert(
          id: reviewLogId,
          vocabularyId: 'shared-vocab',
          reviewedAt: now,
          rating: 3,
          stateBefore: 'new',
          stateAfter: 'review',
          stabilityBefore: 0,
          stabilityAfter: 3,
          intervalDays: 3,
          dueAfter: now.add(const Duration(days: 3)),
          deviceId: Value(deviceId),
        ),
      );
}

class _FakeGraph implements GraphApi {
  final Map<String, List<int>> files = {};
  final Map<String, int> _versions = {};

  String _etag(String path) => '"v${_versions[path] ?? 0}"';

  @override
  Future<Map<String, dynamic>?> itemMetadata(String path) async {
    if (!files.containsKey(path)) return null;
    return {'eTag': _etag(path), 'size': files[path]!.length};
  }

  @override
  Future<CloudManifest?> downloadManifest(
    String path, {
    SyncCancellation? cancellation,
  }) async {
    final data = files[path];
    if (data == null) return null;
    return CloudManifest(bytes: List<int>.from(data), etag: _etag(path));
  }

  @override
  Future<bool> downloadToFile(
    String path,
    File destination, {
    SyncCancellation? cancellation,
    void Function(int received, int? total)? onProgress,
  }) async {
    cancellation?.throwIfCancelled();
    final data = files[path];
    if (data == null) return false;
    await destination.parent.create(recursive: true);
    await destination.writeAsBytes(data, flush: true);
    onProgress?.call(data.length, data.length);
    return true;
  }

  @override
  Future<void> uploadBytes(
    String path,
    List<int> bytes, {
    Map<String, String> extraHeaders = const {},
    SyncCancellation? cancellation,
  }) async {
    cancellation?.throwIfCancelled();
    final ifNoneMatch = extraHeaders['If-None-Match'];
    final ifMatch = extraHeaders['If-Match'];
    if (ifNoneMatch == '*' && files.containsKey(path)) {
      throw OneDriveException('Conditional write failed.', statusCode: 412);
    }
    if (ifMatch != null &&
        (!files.containsKey(path) || _etag(path) != ifMatch)) {
      throw OneDriveException('Conditional write failed.', statusCode: 412);
    }
    files[path] = List<int>.from(bytes);
    _versions[path] = (_versions[path] ?? 0) + 1;
  }

  @override
  Future<void> uploadFile(
    String path,
    File file, {
    SyncCancellation? cancellation,
    void Function(int sent, int total)? onProgress,
  }) async {
    final bytes = await file.readAsBytes();
    await uploadBytes(path, bytes, cancellation: cancellation);
    onProgress?.call(bytes.length, bytes.length);
  }
}
