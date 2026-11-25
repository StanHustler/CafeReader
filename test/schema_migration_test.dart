import 'dart:io';

import 'package:cafereader/core/database/app_database.dart';
import 'package:cafereader/data/local/snapshot_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Snapshot created by the schema 1 build. It still stores a `source` column on
/// word statuses, definitions, and word forms.
const _legacyFixture = 'test/fixtures/schema_v1.sqlite';

void main() {
  late Directory temp;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('cafereader-migration-test');
  });

  tearDown(() async {
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  test('schema 1 databases migrate to schema 4 without losing data', () async {
    final path = '${temp.path}/legacy.sqlite';
    await File(_legacyFixture).copy(path);

    final db = await AppDatabase.openAt(path);
    addTearDown(db.close);

    final status = await db.select(db.wordStatuses).getSingle();
    expect(status.status, 'LEARNING');
    expect(status.revision, 3);
    expect(status.updatedBy, 'old-device');

    final definition = await db.select(db.definitions).getSingle();
    expect(definition.meaning, 'a legacy meaning');
    expect(definition.example, 'a legacy example');
    expect(definition.revision, 2);

    final form = await db.select(db.wordForms).getSingle();
    expect(form.surfaceForm, 'legacies');
    expect(form.normalizedForm, 'legacy');

    for (final table in ['word_statuses', 'definitions', 'word_forms']) {
      final columns = await db
          .customSelect("SELECT name FROM pragma_table_info('$table')")
          .get();
      expect(
        columns.map((row) => row.read<String>('name')),
        isNot(contains('source')),
        reason: '$table should no longer store a source column',
      );
    }

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), 4);
    final metadata =
        await (db.select(db.appMetadata)
              ..where((table) => table.key.equals('database_schema_version')))
            .getSingle();
    expect(metadata.value, '4');
  });

  test('schema 1 snapshots still merge into schema 4', () async {
    final path = '${temp.path}/legacy-snapshot.sqlite';
    await File(_legacyFixture).copy(path);

    final target = AppDatabase.memory();
    addTearDown(target.close);
    final service = SnapshotService(target);
    final info = await service.inspect(path);
    expect(info.schemaVersion, 1);

    await service.mergeFromFile(path, currentDeviceId: 'target-device');

    final vocabulary = await (target.select(
      target.vocabulary,
    )..where((table) => table.id.equals('legacy-vocab'))).getSingle();
    expect(vocabulary.lemma, 'legacy');
    final status = await (target.select(
      target.wordStatuses,
    )..where((table) => table.vocabularyId.equals('legacy-vocab'))).getSingle();
    expect(status.status, 'LEARNING');
    expect(status.revision, 3);
    final definition = await (target.select(
      target.definitions,
    )..where((table) => table.vocabularyId.equals('legacy-vocab'))).getSingle();
    expect(definition.meaning, 'a legacy meaning');
    final form = await (target.select(
      target.wordForms,
    )..where((table) => table.vocabularyId.equals('legacy-vocab'))).getSingle();
    expect(form.surfaceForm, 'legacies');
  });

  test('schema 1 snapshots still replace schema 4 data', () async {
    final path = '${temp.path}/legacy-replace.sqlite';
    await File(_legacyFixture).copy(path);

    final target = AppDatabase.memory();
    addTearDown(target.close);
    final now = DateTime(2026, 2, 2, 12);
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

    await SnapshotService(target)
        .replaceFromFile(path, currentDeviceId: 'local-device');

    expect(await target.select(target.books).get(), isEmpty);
    final status = await (target.select(
      target.wordStatuses,
    )..where((table) => table.vocabularyId.equals('legacy-vocab'))).getSingle();
    expect(status.status, 'LEARNING');

    final device = await (target.select(
      target.appMetadata,
    )..where((table) => table.key.equals('device_id'))).getSingle();
    expect(device.value, 'local-device');
    final metadata =
        await (target.select(target.appMetadata)
              ..where((table) => table.key.equals('database_schema_version')))
            .getSingle();
    expect(metadata.value, '4');
  });
}
