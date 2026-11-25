import 'package:cafereader/core/database/app_database.dart';
import 'package:cafereader/data/repository/review_repository.dart';
import 'package:cafereader/data/repository/vocabulary_repository.dart';
import 'package:cafereader/domain/fsrs/fsrs_scheduler.dart';
import 'package:cafereader/domain/lemmatizer/lemmatizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const scheduler = FsrsScheduler();
  _extraTests();

  test('new cards follow rating-dependent intervals', () {
    final now = DateTime(2026, 1, 1, 9);
    final again = scheduler.schedule(
      rating: ReviewRating.again,
      state: FsrsState.newCard,
      stability: 0,
      difficulty: 0,
      reps: 0,
      lapses: 0,
      now: now,
    );
    final hard = scheduler.schedule(
      rating: ReviewRating.hard,
      state: FsrsState.newCard,
      stability: 0,
      difficulty: 0,
      reps: 0,
      lapses: 0,
      now: now,
    );
    final good = scheduler.schedule(
      rating: ReviewRating.good,
      state: FsrsState.newCard,
      stability: 0,
      difficulty: 0,
      reps: 0,
      lapses: 0,
      now: now,
    );
    final easy = scheduler.schedule(
      rating: ReviewRating.easy,
      state: FsrsState.newCard,
      stability: 0,
      difficulty: 0,
      reps: 0,
      lapses: 0,
      now: now,
    );

    expect(again.state, FsrsState.learning);
    expect(again.due.difference(now).inMinutes, lessThanOrEqualTo(11));
    expect(hard.state, FsrsState.learning);
    expect(good.state, FsrsState.review);
    expect(easy.state, FsrsState.review);
    expect(again.stability, lessThan(hard.stability));
    expect(hard.stability, lessThan(good.stability));
    expect(good.stability, lessThan(easy.stability));
    expect(good.due.isAfter(now), isTrue);
    expect(easy.due.isAfter(good.due), isTrue);
  });

  test(
    'successful review increases stability and keeps Learning user state',
    () {
      final now = DateTime(2026, 1, 10, 9);
      final lastReview = now.subtract(const Duration(days: 5));
      final result = scheduler.schedule(
        rating: ReviewRating.good,
        state: FsrsState.review,
        stability: 3,
        difficulty: 5,
        reps: 2,
        lapses: 0,
        lastReview: lastReview,
        now: now,
      );
      expect(result.reps, 3);
      expect(result.stability, greaterThan(3));
      expect(result.elapsedDays, 5);
      expect(result.due.isAfter(now), isTrue);
      expect(result.state, FsrsState.review);
      // There is deliberately no "Known" outcome in the FSRS model.
      expect(
        FsrsState.values.map((state) => state.value),
        isNot(contains('known')),
      );
    },
  );

  test(
    'Again enters relearning, increments lapses, and shortens the due time',
    () {
      final now = DateTime(2026, 1, 10, 9);
      final result = scheduler.schedule(
        rating: ReviewRating.again,
        state: FsrsState.review,
        stability: 12,
        difficulty: 4,
        reps: 4,
        lapses: 1,
        lastReview: now.subtract(const Duration(days: 10)),
        now: now,
      );
      expect(result.state, FsrsState.relearning);
      expect(result.lapses, 2);
      expect(result.stability, lessThanOrEqualTo(12));
      expect(result.due.difference(now).inMinutes, lessThanOrEqualTo(11));
    },
  );

  test('lower desired retention produces longer intervals', () {
    final now = DateTime(2026, 1, 10, 9);
    FsrsScheduling schedule(double retention) {
      return FsrsScheduler(desiredRetention: retention).schedule(
        rating: ReviewRating.good,
        state: FsrsState.review,
        stability: 20,
        difficulty: 5,
        reps: 2,
        lapses: 0,
        lastReview: now.subtract(const Duration(days: 10)),
        now: now,
      );
    }

    final relaxed = schedule(0.8);
    final strict = schedule(0.95);
    expect(relaxed.due.isAfter(strict.due), isTrue);
  });

  test(
    'learning words get cards and reviews never auto-promote to Known',
    () async {
      final db = AppDatabase.memory();
      addTearDown(db.close);
      final now = DateTime.now();
      await db
          .into(db.vocabulary)
          .insert(
            VocabularyCompanion.insert(
              id: 'v1',
              lemma: 'scarcely',
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.wordStatuses)
          .insert(
            WordStatusesCompanion.insert(
              vocabularyId: 'v1',
              status: VocabularyState.newWord.dbValue,
              updatedAt: now,
            ),
          );
      final vocabulary = VocabularyRepository(
        db,
        Lemmatizer(lexicon: const {}),
        'device-a',
      );
      final review = ReviewRepository(db, vocabulary, 'device-a');
      await review.addToLearning('v1');
      expect(await vocabulary.getState('v1'), VocabularyState.learning);
      final learningCard = await review.getCard('v1');
      expect(learningCard, isNotNull);

      final scheduling = await review.review(
        vocabularyId: 'v1',
        rating: ReviewRating.good,
        desiredRetention: 0.9,
      );
      expect(scheduling.due.isAfter(DateTime.now()), isTrue);
      expect(await vocabulary.getState('v1'), VocabularyState.learning);
      final logs = await db.select(db.reviewLogs).get();
      expect(logs, hasLength(1));
      expect(logs.single.stateBefore, FsrsState.newCard.value);
      expect(logs.single.rating, ReviewRating.good.value);

      await review.markKnown('v1');
      expect(await vocabulary.getState('v1'), VocabularyState.known);
      final cardAfterKnown = await review.getCard('v1');
      expect(cardAfterKnown, isNotNull);
      expect(cardAfterKnown!.reps, 1);
    },
  );
}

void _extraTests() {
  test('due count and due items streams react to Learning changes', () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final now = DateTime.now();
    await db
        .into(db.vocabulary)
        .insert(
          VocabularyCompanion.insert(
            id: 'stream-v',
            lemma: 'stream',
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db
        .into(db.wordStatuses)
        .insert(
          WordStatusesCompanion.insert(
            vocabularyId: 'stream-v',
            status: VocabularyState.newWord.dbValue,
            updatedAt: now,
          ),
        );
    final vocabulary = VocabularyRepository(
      db,
      Lemmatizer(lexicon: const {}),
      'device-a',
    );
    final review = ReviewRepository(db, vocabulary, 'device-a');
    final counts = <int>[];
    final itemsCounts = <int>[];
    final sub = review.watchDueCount().listen(counts.add);
    final itemSub = review.watchDueItems().listen(
      (items) => itemsCounts.add(items.length),
    );
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(counts.last, 0);
    await review.addToLearning('stream-v');
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(counts.last, 1);
    expect(itemsCounts.last, 1);
    await sub.cancel();
    await itemSub.cancel();
  });
}
