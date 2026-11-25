import 'package:cafereader/core/database/app_database.dart';
import 'package:cafereader/data/repository/vocabulary_repository.dart';
import 'package:cafereader/domain/lemmatizer/lemmatizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late VocabularyRepository repository;
  final now = DateTime(2026, 7, 1, 9);

  setUp(() async {
    db = AppDatabase.memory();
    repository = VocabularyRepository(
      db,
      Lemmatizer(lexicon: const {'run', 'quiet', 'house'}),
      'device-a',
    );
    await db
        .into(db.books)
        .insert(
          BooksCompanion.insert(
            id: 'book-1',
            title: 'Book',
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
            title: 'Chapter',
            chapterIndex: 0,
            content: 'Running is quiet.\n\nA house runs too.',
            contentHash: 'hash-1',
            updatedAt: now,
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  test('matching a surface writes nothing', () async {
    final match = await repository.matchSurface('Running');
    expect(match.lemma, 'run');
    expect(match.vocabularyId, isNull);
    expect(await db.select(db.vocabulary).get(), isEmpty);
    expect(await db.select(db.wordForms).get(), isEmpty);
    expect(await db.select(db.wordStatuses).get(), isEmpty);
    expect(await db.select(db.wordOccurrences).get(), isEmpty);
  });

  test('saving creates one vocabulary entry and form', () async {
    final match = await repository.matchSurface('Running');
    final vocabularyId = await repository.ensureVocabulary(match);
    expect(vocabularyId, isNotEmpty);
    expect(await db.select(db.vocabulary).get(), hasLength(1));
    expect(await db.select(db.wordForms).get(), hasLength(1));
    // Saving is what creates the word; no status is written until the reader
    // explicitly chooses Learning or Known.
    expect(await db.select(db.wordStatuses).get(), isEmpty);

    final again = await repository.matchSurface('running');
    expect(again.vocabularyId, vocabularyId);
    final same = await repository.ensureVocabulary(again);
    expect(same, vocabularyId);
    expect(await db.select(db.vocabulary).get(), hasLength(1));
    expect(await db.select(db.wordForms).get(), hasLength(1));
  });

  test('chapter marks distinguish saved entries from new words', () async {
    final match = await repository.matchSurface('Running');
    final vocabularyId = await repository.ensureVocabulary(match);
    final chapter = await db.select(db.chapters).getSingle();
    final marks = await repository.getChapterWordMarks(chapter);

    final running = marks.firstWhere((mark) => mark.surfaceForm == 'Running');
    expect(running.vocabularyId, vocabularyId);

    // "quiet" has not been saved yet, so it is a new word with no entry. The
    // reader marks it as New rather than leaving it invisible.
    final quiet = marks.firstWhere((mark) => mark.surfaceForm == 'quiet');
    expect(quiet.state, VocabularyState.newWord);
    expect(quiet.vocabularyId, isEmpty);
  });

  test('lemmatized inflections share the vocabulary entry', () async {
    final match = await repository.matchSurface('runs');
    expect(match.lemma, 'run');
    await repository.ensureVocabulary(match);
    final chapter = await db.select(db.chapters).getSingle();
    final marks = await repository.getChapterWordMarks(chapter);
    expect(marks.any((mark) => mark.surfaceForm == 'Running'), isTrue);
    expect(marks.any((mark) => mark.surfaceForm == 'runs'), isTrue);
  });

  test('recorded occurrence appears in the book contexts', () async {
    final match = await repository.matchSurface('runs');
    final vocabularyId = await repository.ensureVocabulary(match);
    final occurrenceId = await repository.recordOccurrence(
      bookId: 'book-1',
      vocabularyId: vocabularyId,
      pending: const PendingOccurrence(
        chapterId: 'chapter-1',
        paragraphIndex: 1,
        startOffset: 8,
        endOffset: 12,
        surfaceForm: 'runs',
      ),
    );
    expect(occurrenceId, isNotEmpty);
    expect(await repository.countInBook(vocabularyId, 'book-1'), 1);

    final contexts = await repository.watchContexts(vocabularyId).first;
    expect(contexts, hasLength(1));
    expect(contexts.first.chapterTitle, 'Chapter');
    expect(contexts.first.context, contains('runs'));

    final chapter = await db.select(db.chapters).getSingle();
    final marks = await repository.getChapterWordMarks(chapter);
    final saved = marks.where((mark) => mark.id.isNotEmpty).toList();
    expect(saved, hasLength(1));
    expect(saved.first.paragraphIndex, 1);
  });
}
