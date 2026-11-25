import 'package:cafereader/core/database/app_database.dart';
import 'package:cafereader/data/import_export/csv_service.dart';
import 'package:cafereader/data/repository/vocabulary_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CSV parser handles BOM, quotes, commas and newlines', () {
    final rows = CsvService.parseCsv(
      '﻿lemma,status,meaning\r\n'
      'run,Known,"to move, quickly"\r\n'
      'say,New,"a ""quoted"" line\nwith a break"\r\n',
    );
    expect(rows, hasLength(3));
    expect(rows[1], ['run', 'Known', 'to move, quickly']);
    expect(rows[2][2], 'a "quoted" line\nwith a break');
  });

  test(
    'vocabulary CSV preserves or updates existing global states by policy',
    () async {
      final db = AppDatabase.memory();
      addTearDown(db.close);
      final now = DateTime.now();
      await db
          .into(db.vocabulary)
          .insert(
            VocabularyCompanion.insert(
              id: 'run-id',
              lemma: 'run',
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.wordStatuses)
          .insert(
            WordStatusesCompanion.insert(
              vocabularyId: 'run-id',
              status: VocabularyState.newWord.dbValue,
              updatedAt: now,
            ),
          );
      final service = CsvService(db);
      const csv =
          '﻿lemma,status,meaning,created_at,sense_label\r\n'
          'run,Known,"move fast",2026-01-01T00:00:00Z,\r\n'
          'walk,Learning,"move on foot",2026-01-01T00:00:00Z,\r\n';
      final kept = await service.importVocabulary(
        csv,
        policy: CsvConflictPolicy.keepExisting,
      );
      expect(kept.createdVocabulary, 1);
      final runStatus = await (db.select(
        db.wordStatuses,
      )..where((table) => table.vocabularyId.equals('run-id'))).getSingle();
      expect(runStatus.status, VocabularyState.newWord.dbValue);
      final runDefinitions = await (db.select(
        db.definitions,
      )..where((table) => table.vocabularyId.equals('run-id'))).get();
      expect(runDefinitions.single.meaning, 'move fast');
      final walk = await (db.select(
        db.vocabulary,
      )..where((table) => table.lemma.equals('walk'))).getSingle();
      final walkStatus = await (db.select(
        db.wordStatuses,
      )..where((table) => table.vocabularyId.equals(walk.id))).getSingle();
      expect(walkStatus.status, VocabularyState.learning.dbValue);
      final walkCard =
          await (db.select(db.fsrsCards)
                ..where((table) => table.vocabularyId.equals(walk.id)))
              .getSingleOrNull();
      expect(walkCard, isNotNull);

      await service.importVocabulary(
        'lemma,status\nrun,Known\n',
        policy: CsvConflictPolicy.updateStatus,
      );
      final updated = await (db.select(
        db.wordStatuses,
      )..where((table) => table.vocabularyId.equals('run-id'))).getSingle();
      expect(updated.status, VocabularyState.known.dbValue);

      final exported = await service.exportVocabulary();
      expect(exported, startsWith('﻿lemma,status,meaning,created_at'));
      expect(exported, contains('walk'));
    },
  );

  test(
    'dictionary import adds definitions only to existing vocabulary',
    () async {
      final db = AppDatabase.memory();
      addTearDown(db.close);
      final now = DateTime.now();
      await db
          .into(db.vocabulary)
          .insert(
            VocabularyCompanion.insert(
              id: 'v1',
              lemma: 'cafe',
              createdAt: now,
              updatedAt: now,
            ),
          );
      final service = CsvService(db);
      final result = await service.importDictionary(
        '{"cafe":"a place for coffee","missing":"not in library"}',
        isJson: true,
      );
      expect(result.added, 1);
      expect(result.missingWords, 1);
      final definitions = await db.select(db.definitions).get();
      expect(definitions.single.meaning, 'a place for coffee');
    },
  );
}
