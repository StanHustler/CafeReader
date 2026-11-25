import 'dart:io';

import 'package:cafereader/core/database/app_database.dart';
import 'package:cafereader/core/util/app_storage.dart';
import 'package:cafereader/data/repository/library_repository.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late Directory temp;
  late AppStorage storage;
  late LibraryRepository repository;
  final now = DateTime(2026, 5, 1, 12);

  setUp(() async {
    db = AppDatabase.memory();
    temp = await Directory.systemTemp.createTemp('cafereader-delete-test');
    storage = AppStorage.at(Directory('${temp.path}/app'));
    await storage.ensureLayout();
    repository = LibraryRepository(db, storage, 'device-a');
    await _seed(db, storage, now);
  });

  tearDown(() async {
    await db.close();
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  test(
    'deleteAllData removes library content and files but keeps settings',
    () async {
      expect(await db.select(db.books).get(), isNotEmpty);
      expect(await db.select(db.vocabulary).get(), isNotEmpty);
      expect(await db.select(db.wordStatuses).get(), isNotEmpty);
      expect(await db.select(db.reviewLogs).get(), isNotEmpty);
      expect(await db.select(db.dictionaries).get(), isNotEmpty);
      expect(await db.select(db.dictionaryEntries).get(), isNotEmpty);

      await repository.deleteAllData();

      for (final rows in [
        await db.select(db.books).get(),
        await db.select(db.chapters).get(),
        await db.select(db.readingProgress).get(),
        await db.select(db.paginationCaches).get(),
        await db.select(db.vocabulary).get(),
        await db.select(db.wordForms).get(),
        await db.select(db.wordOccurrences).get(),
        await db.select(db.wordStatuses).get(),
        await db.select(db.definitions).get(),
        await db.select(db.fsrsCards).get(),
        await db.select(db.reviewLogs).get(),
        await db.select(db.dictionaries).get(),
        await db.select(db.dictionaryEntries).get(),
      ]) {
        expect(rows, isEmpty);
      }

      expect(await storage.booksDir.list().toList(), isEmpty);
      expect(await storage.coversDir.list().toList(), isEmpty);
      expect(await storage.booksDir.exists(), isTrue);
      expect(await storage.coversDir.exists(), isTrue);

      final settings = await db.select(db.appSettings).get();
      expect(settings, isNotEmpty);
      final device = await (db.select(
        db.appMetadata,
      )..where((table) => table.key.equals('device_id'))).getSingle();
      expect(device.value, 'device-a');
    },
  );
}

Future<void> _seed(AppDatabase db, AppStorage storage, DateTime now) async {
  await db
      .into(db.appSettings)
      .insert(
        AppSettingsCompanion.insert(
          key: 'app_theme',
          value: 'light',
          updatedAt: now,
        ),
      );
  await db
      .into(db.appMetadata)
      .insert(
        AppMetadataCompanion.insert(
          key: 'device_id',
          value: 'device-a',
          updatedAt: now,
        ),
      );
  await db
      .into(db.dictionaries)
      .insert(
        DictionariesCompanion.insert(
          id: 'dict-1',
          name: 'Test dictionary',
          kind: 'local',
          entryCount: const Value(1),
          createdAt: now,
          updatedAt: now,
        ),
      );
  await db
      .into(db.dictionaryEntries)
      .insert(
        DictionaryEntriesCompanion.insert(
          dictionaryId: 'dict-1',
          lemma: 'word',
          meaning: 'definition',
          partOfSpeech: const Value('n.'),
        ),
      );

  await File(
    storage.resolveStoredPath(storage.bookRelativePath('book-1', 'txt')),
  ).writeAsString('book text');
  await File(
    storage.resolveStoredPath(storage.coverRelativePath('book-1', 'jpg')),
  ).writeAsString('cover');

  await db
      .into(db.books)
      .insert(
        BooksCompanion.insert(
          id: 'book-1',
          title: 'Book',
          originalFilePath: storage.bookRelativePath('book-1', 'txt'),
          coverPath: Value(storage.coverRelativePath('book-1', 'jpg')),
          format: 'txt',
          importedAt: now,
          updatedAt: now,
        ),
      );
  await db
      .into(db.chapters)
      .insert(
        ChaptersCompanion.insert(
          id: 'chapter-1',
          bookId: 'book-1',
          title: 'Chapter',
          chapterIndex: 0,
          content: 'A word.',
          contentHash: 'hash',
          updatedAt: now,
        ),
      );
  await db
      .into(db.readingProgress)
      .insert(
        ReadingProgressCompanion.insert(
          id: 'progress-1',
          bookId: 'book-1',
          chapterId: 'chapter-1',
          updatedAt: now,
        ),
      );
  await db
      .into(db.paginationCaches)
      .insert(
        PaginationCachesCompanion.insert(
          chapterId: 'chapter-1',
          layoutSignature: 'layout',
          pageIndex: 0,
          startParagraph: 0,
          startOffset: 0,
          endParagraph: 0,
          endOffset: 7,
          createdAt: now,
        ),
      );
  await db
      .into(db.vocabulary)
      .insert(
        VocabularyCompanion.insert(
          id: 'vocab-1',
          lemma: 'word',
          createdAt: now,
          updatedAt: now,
        ),
      );
  await db
      .into(db.wordForms)
      .insert(
        WordFormsCompanion.insert(
          id: 'form-1',
          surfaceForm: 'word',
          normalizedForm: 'word',
          vocabularyId: 'vocab-1',
          createdAt: now,
        ),
      );
  await db
      .into(db.wordOccurrences)
      .insert(
        WordOccurrencesCompanion.insert(
          id: 'occ-1',
          bookId: 'book-1',
          chapterId: 'chapter-1',
          vocabularyId: 'vocab-1',
          surfaceForm: 'word',
          paragraphIndex: 0,
          startOffset: 2,
          endOffset: 6,
          createdAt: now,
          updatedAt: now,
        ),
      );
  await db
      .into(db.wordStatuses)
      .insert(
        WordStatusesCompanion.insert(
          vocabularyId: 'vocab-1',
          status: 'LEARNING',
          updatedAt: now,
        ),
      );
  await db
      .into(db.definitions)
      .insert(
        DefinitionsCompanion.insert(
          id: 'def-1',
          vocabularyId: 'vocab-1',
          meaning: 'a meaning',
          updatedAt: now,
        ),
      );
  await db
      .into(db.fsrsCards)
      .insert(
        FsrsCardsCompanion.insert(
          vocabularyId: 'vocab-1',
          state: 'new',
          due: now,
          updatedAt: now,
        ),
      );
  await db
      .into(db.reviewLogs)
      .insert(
        ReviewLogsCompanion.insert(
          id: 'log-1',
          vocabularyId: 'vocab-1',
          reviewedAt: now,
          rating: 3,
          stateBefore: 'new',
          stateAfter: 'review',
          stabilityBefore: 0,
          stabilityAfter: 1,
          intervalDays: 1,
          dueAfter: now.add(const Duration(days: 1)),
        ),
      );
}
