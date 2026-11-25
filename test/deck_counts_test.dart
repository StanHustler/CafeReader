import 'package:cafereader/core/database/app_database.dart';
import 'package:cafereader/data/repository/vocabulary_repository.dart';
import 'package:cafereader/domain/lemmatizer/lemmatizer.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late VocabularyRepository repository;
  final now = DateTime(2026, 7, 1, 9);

  setUp(() async {
    db = AppDatabase.memory();
    repository = VocabularyRepository(
      db,
      Lemmatizer(lexicon: const {}),
      'device-a',
    );
    for (final bookId in ['book-1', 'book-2']) {
      await db
          .into(db.books)
          .insert(
            BooksCompanion.insert(
              id: bookId,
              title: bookId,
              originalFilePath: 'books/$bookId.txt',
              format: 'txt',
              importedAt: now,
              updatedAt: now,
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
              content: 'text',
              contentHash: 'hash-$bookId',
              updatedAt: now,
            ),
          );
    }
    for (final entry in const [('v-word', 'word'), ('v-other', 'other')]) {
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
      await db
          .into(db.wordStatuses)
          .insert(
            WordStatusesCompanion.insert(
              vocabularyId: entry.$1,
              status: VocabularyState.known.dbValue,
              updatedAt: now,
              updatedBy: const Value('device-a'),
            ),
          );
    }
    var offset = 0;
    Future<void> occurrence({
      required String id,
      required String bookId,
      required String vocabularyId,
      String? overrideVocabularyId,
    }) async {
      await db
          .into(db.wordOccurrences)
          .insert(
            WordOccurrencesCompanion.insert(
              id: id,
              bookId: bookId,
              chapterId: 'chapter-$bookId',
              vocabularyId: vocabularyId,
              surfaceForm: 'word',
              paragraphIndex: 0,
              startOffset: offset,
              endOffset: offset + 4,
              overrideVocabularyId: Value(overrideVocabularyId),
              createdAt: now,
              updatedAt: now,
            ),
          );
      offset += 5;
    }

    await occurrence(id: 'o1', bookId: 'book-1', vocabularyId: 'v-word');
    await occurrence(id: 'o2', bookId: 'book-2', vocabularyId: 'v-word');
    // An occurrence automatically indexed as another lemma but corrected to
    // "word" counts for "word".
    await occurrence(
      id: 'o3',
      bookId: 'book-1',
      vocabularyId: 'v-other',
      overrideVocabularyId: 'v-word',
    );
    // An occurrence corrected away from "word" no longer counts for it.
    await occurrence(
      id: 'o4',
      bookId: 'book-1',
      vocabularyId: 'v-word',
      overrideVocabularyId: 'v-other',
    );
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'deck counts include overrides and exclude corrected-away rows',
    () async {
      final entries = await repository
          .watchDeck(state: VocabularyState.known)
          .first;
      final word = entries.firstWhere(
        (entry) => entry.vocabulary.id == 'v-word',
      );
      expect(word.occurrenceCount, 3);
      expect(word.bookCount, 2);

      final other = entries.firstWhere(
        (entry) => entry.vocabulary.id == 'v-other',
      );
      expect(other.occurrenceCount, 1);
      expect(other.bookCount, 1);

      final entry = await repository.getDeckEntry('v-word');
      expect(entry?.occurrenceCount, 3);
      expect(entry?.bookCount, 2);
    },
  );
}
