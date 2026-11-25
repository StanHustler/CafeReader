import 'package:cafereader/core/database/app_database.dart';
import 'package:cafereader/data/repository/vocabulary_repository.dart';
import 'package:cafereader/domain/lemmatizer/lemmatizer.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late VocabularyRepository repository;
  final now = DateTime(2026, 4, 1, 9);

  setUp(() async {
    db = AppDatabase.memory();
    repository = VocabularyRepository(
      db,
      Lemmatizer(lexicon: const {'see', 'saw'}),
      'device-a',
    );
    for (final entry in const [('see-v', 'see'), ('saw-v', 'saw')]) {
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
              status: entry.$1 == 'see-v' ? 'KNOWN' : 'NEW',
              updatedAt: now,
            ),
          );
    }
    for (final book in ['book-1', 'book-2']) {
      await db
          .into(db.books)
          .insert(
            BooksCompanion.insert(
              id: book,
              title: book,
              originalFilePath: 'books/$book.txt',
              format: 'txt',
              importedAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.chapters)
          .insert(
            ChaptersCompanion.insert(
              id: 'chapter-$book',
              bookId: book,
              title: 'Chapter',
              chapterIndex: 0,
              content: 'I saw it.',
              contentHash: 'hash-$book',
              updatedAt: now,
            ),
          );
    }
    for (final occurrence in const [
      ('o1', 'book-1', 'chapter-book-1', 2),
      ('o2', 'book-1', 'chapter-book-1', 2),
      ('o3', 'book-2', 'chapter-book-2', 2),
    ]) {
      await db
          .into(db.wordOccurrences)
          .insert(
            WordOccurrencesCompanion.insert(
              id: occurrence.$1,
              bookId: occurrence.$2,
              chapterId: occurrence.$3,
              vocabularyId: 'see-v',
              surfaceForm: 'saw',
              paragraphIndex: 0,
              startOffset: occurrence.$4,
              endOffset: occurrence.$4 + 3,
              createdAt: now,
              updatedAt: now,
            ),
          );
    }
  });

  tearDown(() async {
    await db.close();
  });

  Future<String?> effective(String occurrenceId) async {
    final rows = await db
        .customSelect(
          'SELECT COALESCE(override_vocabulary_id, vocabulary_id) AS vid '
          'FROM word_occurrences WHERE id = ?',
          variables: [Variable(occurrenceId)],
        )
        .getSingle();
    return rows.read<String?>('vid');
  }

  test('states are independent before and after a correction', () async {
    await repository.setState('see-v', VocabularyState.known);
    expect(await repository.getState('see-v'), VocabularyState.known);
    expect(await repository.getState('saw-v'), VocabularyState.newWord);
    await repository.setState('saw-v', VocabularyState.learning);
    expect(await repository.getState('see-v'), VocabularyState.known);
    expect(await repository.getState('saw-v'), VocabularyState.learning);
  });

  test('occurrence scope changes only one appearance', () async {
    await repository.correctOccurrence(
      occurrenceId: 'o1',
      newVocabularyId: 'saw-v',
      scope: CorrectionScope.occurrence,
    );
    expect(await effective('o1'), 'saw-v');
    expect(await effective('o2'), 'see-v');
    expect(await effective('o3'), 'see-v');
  });

  test('book scope changes the whole book but not other books', () async {
    await repository.correctOccurrence(
      occurrenceId: 'o2',
      newVocabularyId: 'saw-v',
      scope: CorrectionScope.book,
    );
    expect(await effective('o1'), 'saw-v');
    expect(await effective('o2'), 'saw-v');
    expect(await effective('o3'), 'see-v');
  });

  test(
    'global form scope moves automatic appearances and keeps manual ones',
    () async {
      await repository.correctOccurrence(
        occurrenceId: 'o1',
        newVocabularyId: 'saw-v',
        scope: CorrectionScope.occurrence,
      );
      await repository.correctOccurrence(
        occurrenceId: 'o3',
        newVocabularyId: 'saw-v',
        scope: CorrectionScope.globalForm,
      );
      expect(await effective('o1'), 'saw-v');
      expect(await effective('o2'), 'saw-v');
      expect(await effective('o3'), 'saw-v');
      final forms = await (db.select(
        db.wordForms,
      )..where((table) => table.surfaceForm.equals('saw'))).get();
      final primary = forms.where((form) => form.isPrimary).toList();
      expect(primary, hasLength(1));
      expect(primary.single.vocabularyId, 'saw-v');
      // A manual override on o1 remains explicitly marked and is not rewritten
      // by a later global change.
      final manual = await (db.select(
        db.wordOccurrences,
      )..where((table) => table.id.equals('o1'))).getSingle();
      expect(manual.isManuallyCorrected, isTrue);
      expect(manual.overrideVocabularyId, 'saw-v');
    },
  );
}
