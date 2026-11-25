import 'package:cafereader/core/database/app_database.dart';
import 'package:cafereader/data/repository/reader_repository.dart';
import 'package:cafereader/data/repository/vocabulary_repository.dart';
import 'package:cafereader/domain/lemmatizer/lemmatizer.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ReaderRepository reader;
  late VocabularyRepository vocabulary;
  final now = DateTime(2026, 1, 1, 12);

  setUp(() async {
    db = AppDatabase.memory();
    reader = ReaderRepository(db, 'device-a');
    vocabulary = VocabularyRepository(
      db,
      Lemmatizer(lexicon: const {}),
      'device-a',
    );
    await _seed(db, now);
  });

  tearDown(() async {
    await db.close();
  });

  test('turning a page writes progress without changing word states', () async {
    await reader.commitPageAdvance(
      bookId: 'book-1',
      chapterId: 'chapter-1',
      targetParagraph: 2,
      targetOffset: 0,
      targetPageIndex: 1,
      targetPageCount: 3,
      layoutSignature: 'layout-a',
    );
    final statuses = await db.select(db.wordStatuses).get();
    final byId = {for (final row in statuses) row.vocabularyId: row.status};
    expect(byId.containsKey('v-new'), isFalse);
    expect(byId['v-known'], VocabularyState.known.dbValue);
    expect(byId['v-learning'], VocabularyState.learning.dbValue);

    final progress = await db.select(db.readingProgress).getSingle();
    expect(progress.chapterId, 'chapter-1');
    expect(progress.anchorParagraph, 2);
    expect(progress.cachedPageIndex, 1);
    expect(progress.revision, 1);
  });

  test('saving progress or moving backwards never changes word states', () async {
    await reader.commitPageAdvance(
      bookId: 'book-1',
      chapterId: 'chapter-1',
      targetParagraph: 1,
      targetOffset: 0,
      targetPageIndex: 0,
      targetPageCount: 3,
      layoutSignature: 'layout-a',
    );
    var state = await vocabulary.getState('v-new');
    expect(state, VocabularyState.newWord);

    await reader.saveProgressOnly(
      bookId: 'book-1',
      chapterId: 'chapter-1',
      anchorParagraph: 3,
      anchorOffset: 4,
      pageIndex: 2,
      pageCount: 3,
      layoutSignature: 'layout-a',
    );
    state = await vocabulary.getState('v-new');
    expect(state, VocabularyState.newWord);
    final progress = await db.select(db.readingProgress).getSingle();
    expect(progress.anchorParagraph, 3);
    expect(progress.revision, 2);
  });

  test(
    'global state exists once and is shared by occurrences in two books',
    () async {
      await db
          .into(db.books)
          .insert(
            BooksCompanion.insert(
              id: 'book-2',
              title: 'Second book',
              originalFilePath: 'books/book-2.txt',
              format: 'txt',
              importedAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.chapters)
          .insert(
            ChaptersCompanion.insert(
              id: 'chapter-2',
              bookId: 'book-2',
              title: 'Another chapter',
              chapterIndex: 0,
              content: 'A shared word.',
              contentHash: 'hash-2',
              updatedAt: now,
            ),
          );
      await db
          .into(db.wordOccurrences)
          .insert(
            WordOccurrencesCompanion.insert(
              id: 'occ-shared-2',
              bookId: 'book-2',
              chapterId: 'chapter-2',
              vocabularyId: 'v-new',
              surfaceForm: 'new',
              paragraphIndex: 0,
              startOffset: 2,
              endOffset: 5,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await vocabulary.setState('v-new', VocabularyState.known);

      final statuses = await (db.select(
        db.wordStatuses,
      )..where((table) => table.vocabularyId.equals('v-new'))).get();
      expect(statuses, hasLength(1));
      expect(statuses.single.status, VocabularyState.known.dbValue);

      const expectedKnown = {'chapter-1': 2, 'chapter-2': 1};
      for (final chapterId in ['chapter-1', 'chapter-2']) {
        final row = await db
            .customSelect(
              'SELECT COUNT(DISTINCT COALESCE(o.override_vocabulary_id, o.vocabulary_id)) AS c '
              'FROM word_occurrences o JOIN word_statuses s '
              'ON s.vocabulary_id = COALESCE(o.override_vocabulary_id, o.vocabulary_id) '
              'WHERE o.chapter_id = ? AND s.status = ?',
              variables: [Variable(chapterId), Variable('KNOWN')],
            )
            .getSingle();
        expect(row.read<int>('c'), expectedKnown[chapterId]);
      }
    },
  );
}

Future<void> _seed(AppDatabase db, DateTime now) async {
  await db
      .into(db.books)
      .insert(
        BooksCompanion.insert(
          id: 'book-1',
          title: 'First book',
          originalFilePath: 'books/book-1.txt',
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
          title: 'Chapter one',
          chapterIndex: 0,
          content:
              'Scarcely a planet, but a surprise has importance in a house.',
          contentHash: 'hash-1',
          updatedAt: now,
        ),
      );
  for (final entry in const [
    ('v-new', 'scarcely', VocabularyState.newWord),
    ('v-known', 'planet', VocabularyState.known),
    ('v-learning', 'importance', VocabularyState.learning),
  ]) {
    await db
        .into(db.vocabulary)
        .insert(
          VocabularyCompanion.insert(
            id: entry.$1,
            lemma: entry.$2,
            createdAt: now,
            updatedAt: now,
          ),
        );
    // New is implicit: no status row is stored for it.
    if (entry.$3 != VocabularyState.newWord) {
      await db
          .into(db.wordStatuses)
          .insert(
            WordStatusesCompanion.insert(
              vocabularyId: entry.$1,
              status: entry.$3.dbValue,
              updatedAt: now,
              updatedBy: const Value('device-a'),
            ),
          );
    }
  }
  var start = 0;
  for (final entry in const [
    ('occ-1', 'v-new', 'Scarcely'),
    ('occ-2', 'v-known', 'planet'),
    ('occ-3', 'v-learning', 'importance'),
  ]) {
    await db
        .into(db.wordOccurrences)
        .insert(
          WordOccurrencesCompanion.insert(
            id: entry.$1,
            bookId: 'book-1',
            chapterId: 'chapter-1',
            vocabularyId: entry.$2,
            surfaceForm: entry.$3,
            paragraphIndex: 0,
            startOffset: start,
            endOffset: start + entry.$3.length,
            createdAt: now,
            updatedAt: now,
          ),
        );
    start += entry.$3.length + 1;
  }
}
