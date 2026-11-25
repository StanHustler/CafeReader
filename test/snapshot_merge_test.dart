import 'dart:io';

import 'package:cafereader/core/database/app_database.dart';
import 'package:cafereader/data/local/snapshot_service.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory temp;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('cafereader-snapshot-test');
  });

  tearDown(() async {
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  test('merge is entity-level, deterministic, and keeps review logs', () async {
    final now = DateTime(2026, 2, 1, 12);
    final source = AppDatabase.memory();
    await _seedCommon(source, now);
    await source
        .into(source.books)
        .insert(
          BooksCompanion.insert(
            id: 'remote-book',
            title: 'Remote book',
            originalFilePath: 'books/remote-book.txt',
            format: 'txt',
            importedAt: now,
            updatedAt: now,
          ),
        );
    await source
        .into(source.books)
        .insert(
          BooksCompanion.insert(
            id: 'tombstoned-book',
            title: 'Tombstone',
            originalFilePath: 'books/tombstone.txt',
            format: 'txt',
            importedAt: now,
            updatedAt: now,
            deletedAt: Value(now),
            revision: const Value(2),
            updatedBy: const Value('remote'),
          ),
        );
    await source
        .into(source.vocabulary)
        .insert(
          VocabularyCompanion.insert(
            id: 'remote-vocab',
            lemma: 'remote',
            createdAt: now,
            updatedAt: now,
          ),
        );
    await source
        .into(source.wordStatuses)
        .insert(
          WordStatusesCompanion.insert(
            vocabularyId: 'remote-vocab',
            status: 'NEW',
            updatedAt: now,
          ),
        );
    // Same revision as local, but a lexicographically larger device id wins.
    await source
        .into(source.wordStatuses)
        .insert(
          WordStatusesCompanion.insert(
            vocabularyId: 'shared-vocab',
            status: 'KNOWN',
            revision: const Value(5),
            updatedBy: const Value('device-z'),
            updatedAt: now,
          ),
          mode: InsertMode.insertOrReplace,
        );
    await source
        .into(source.reviewLogs)
        .insert(
          ReviewLogsCompanion.insert(
            id: 'remote-log',
            vocabularyId: 'remote-vocab',
            reviewedAt: now,
            rating: 3,
            stateBefore: 'new',
            stateAfter: 'review',
            stabilityBefore: 0,
            stabilityAfter: 3,
            intervalDays: 3,
            dueAfter: now.add(const Duration(days: 3)),
          ),
        );
    final snapshotPath = '${temp.path}/remote.sqlite';
    await source.snapshotTo(snapshotPath);
    await source.close();

    final target = AppDatabase.memory();
    addTearDown(target.close);
    await _seedCommon(target, now);
    await target
        .into(target.wordStatuses)
        .insert(
          WordStatusesCompanion.insert(
            vocabularyId: 'shared-vocab',
            status: 'NEW',
            revision: const Value(5),
            updatedBy: const Value('device-a'),
            updatedAt: now.subtract(const Duration(days: 1)),
          ),
          mode: InsertMode.insertOrReplace,
        );
    await target
        .into(target.books)
        .insert(
          BooksCompanion.insert(
            id: 'tombstoned-book',
            title: 'Tombstone',
            originalFilePath: 'books/tombstone.txt',
            format: 'txt',
            importedAt: now,
            updatedAt: now,
          ),
        );
    await target
        .into(target.books)
        .insert(
          BooksCompanion.insert(
            id: 'local-book',
            title: 'Local book',
            originalFilePath: 'books/local-book.txt',
            format: 'txt',
            importedAt: now,
            updatedAt: now,
          ),
        );
    final service = SnapshotService(target);
    final info = await service.inspect(snapshotPath);
    expect(info.schemaVersion, 4);
    await service.mergeFromFile(snapshotPath, currentDeviceId: 'target-device');

    final books = await target.select(target.books).get();
    expect(
      books.map((book) => book.id),
      containsAll(['remote-book', 'local-book']),
    );
    final tombstone = books.firstWhere((book) => book.id == 'tombstoned-book');
    expect(tombstone.deletedAt, isNotNull);
    expect(tombstone.revision, 2);
    final shared = await (target.select(
      target.wordStatuses,
    )..where((table) => table.vocabularyId.equals('shared-vocab'))).getSingle();
    expect(shared.status, 'KNOWN');
    expect(shared.updatedBy, 'device-z');
    expect(
      await (target.select(
        target.vocabulary,
      )..where((table) => table.id.equals('remote-vocab'))).getSingleOrNull(),
      isNotNull,
    );
    expect(
      await (target.select(
        target.reviewLogs,
      )..where((table) => table.id.equals('remote-log'))).getSingleOrNull(),
      isNotNull,
    );
    final deviceRow = await (target.select(
      target.appMetadata,
    )..where((table) => table.key.equals('device_id'))).getSingleOrNull();
    expect(deviceRow?.value, 'target-device');
  });

  test(
    'full replace removes local-only entities but preserves this device id',
    () async {
      final now = DateTime(2026, 2, 2, 12);
      final source = AppDatabase.memory();
      await _seedCommon(source, now);
      await source
          .into(source.books)
          .insert(
            BooksCompanion.insert(
              id: 'source-only',
              title: 'Source',
              originalFilePath: 'books/source.txt',
              format: 'txt',
              importedAt: now,
              updatedAt: now,
            ),
          );
      final snapshotPath = '${temp.path}/replace.sqlite';
      await source.snapshotTo(snapshotPath);
      await source.close();

      final target = AppDatabase.memory();
      addTearDown(target.close);
      await target
          .into(target.books)
          .insert(
            BooksCompanion.insert(
              id: 'local-only',
              title: 'Local',
              originalFilePath: 'books/local.txt',
              format: 'txt',
              importedAt: now,
              updatedAt: now,
            ),
          );
      await target
          .into(target.appMetadata)
          .insert(
            AppMetadataCompanion.insert(
              key: 'device_id',
              value: 'local-device',
              updatedAt: now,
            ),
            mode: InsertMode.insertOrReplace,
          );
      await SnapshotService(target)
          .replaceFromFile(snapshotPath, currentDeviceId: 'local-device');
      final books = await target.select(target.books).get();
      expect(books.map((book) => book.id), contains('source-only'));
      expect(books.map((book) => book.id), isNot(contains('local-only')));
      final device = await (target.select(
        target.appMetadata,
      )..where((table) => table.key.equals('device_id'))).getSingle();
      expect(device.value, 'local-device');
    },
  );
}

Future<void> _seedCommon(AppDatabase db, DateTime now) async {
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
          status: 'NEW',
          updatedAt: now,
        ),
        mode: InsertMode.insertOrIgnore,
      );
  await db
      .into(db.appMetadata)
      .insert(
        AppMetadataCompanion.insert(
          key: 'device_id',
          value: 'source-device',
          updatedAt: now,
        ),
        mode: InsertMode.insertOrReplace,
      );
}
