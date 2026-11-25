import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../../domain/fsrs/fsrs_scheduler.dart';
import 'vocabulary_repository.dart';

class ReviewItem {
  const ReviewItem({
    required this.vocabulary,
    required this.card,
    required this.definition,
    required this.occurrenceCount,
    required this.bookCount,
  });

  final VocabularyData vocabulary;
  final FsrsCard card;
  final String? definition;
  final int occurrenceCount;
  final int bookCount;
}

class ReviewRepository {
  ReviewRepository(this.db, this.vocabularyRepository, this.deviceId);

  final AppDatabase db;
  final VocabularyRepository vocabularyRepository;
  final String deviceId;

  Future<void> addToLearning(String vocabularyId) async {
    await db.transaction(() async {
      final status =
          await (db.select(db.wordStatuses)
                ..where((table) => table.vocabularyId.equals(vocabularyId)))
              .getSingleOrNull();
      final now = DateTime.now();
      if (status == null) {
        await db
            .into(db.wordStatuses)
            .insert(
              WordStatusesCompanion.insert(
                vocabularyId: vocabularyId,
                status: VocabularyState.learning.dbValue,
                updatedAt: now,
                updatedBy: Value(deviceId),
              ),
            );
      } else {
        await (db.update(
          db.wordStatuses,
        )..where((table) => table.vocabularyId.equals(vocabularyId))).write(
          WordStatusesCompanion(
            status: Value(VocabularyState.learning.dbValue),
            revision: Value(status.revision + 1),
            updatedAt: Value(now),
            updatedBy: Value(deviceId),
          ),
        );
      }
      final card =
          await (db.select(db.fsrsCards)
                ..where((table) => table.vocabularyId.equals(vocabularyId)))
              .getSingleOrNull();
      if (card == null) {
        await db
            .into(db.fsrsCards)
            .insert(
              FsrsCardsCompanion.insert(
                vocabularyId: vocabularyId,
                state: FsrsState.newCard.value,
                due: now,
                updatedAt: now,
                updatedBy: Value(deviceId),
              ),
            );
      }
    });
  }

  Future<void> markKnown(String vocabularyId) async {
    await vocabularyRepository.setState(vocabularyId, VocabularyState.known);
  }

  Stream<FsrsCard?> watchCard(String vocabularyId) {
    return (db.select(db.fsrsCards)
          ..where((table) => table.vocabularyId.equals(vocabularyId)))
        .watchSingleOrNull();
  }

  Future<FsrsCard?> getCard(String vocabularyId) {
    return (db.select(db.fsrsCards)
          ..where((table) => table.vocabularyId.equals(vocabularyId)))
        .getSingleOrNull();
  }

  Future<List<ReviewItem>> getDueItems({int limit = 200}) async {
    final rows = await db
        .customSelect(
          _dueItemsSql,
          variables: [
            Variable(VocabularyState.learning.dbValue),
            Variable(limit),
          ],
        )
        .get();
    return rows.map(_mapReviewItem).toList();
  }

  Stream<List<ReviewItem>> watchDueItems({int limit = 200}) {
    return db
        .customSelect(
          _dueItemsSql,
          variables: [
            Variable(VocabularyState.learning.dbValue),
            Variable(limit),
          ],
          readsFrom: {
            db.fsrsCards,
            db.wordStatuses,
            db.vocabulary,
            db.definitions,
            db.wordOccurrences,
          },
        )
        .watch()
        .map((rows) => rows.map(_mapReviewItem).toList());
  }

  static const String _dueItemsSql = '''
      SELECT v.id, v.lemma, v.language, v.sense_label, v.created_at,
        v.updated_at, f.state, f.due, f.stability, f.difficulty,
        f.elapsed_days, f.scheduled_days, f.reps, f.lapses, f.last_review,
        f.revision AS card_revision, f.updated_at AS card_updated_at,
        (SELECT d.meaning FROM definitions d WHERE d.vocabulary_id = v.id
          ORDER BY d.updated_at DESC LIMIT 1) AS definition,
        (SELECT COUNT(*) FROM word_occurrences o
          WHERE COALESCE(o.override_vocabulary_id, o.vocabulary_id) = v.id)
          AS occurrence_count,
        (SELECT COUNT(DISTINCT o.book_id) FROM word_occurrences o
          WHERE COALESCE(o.override_vocabulary_id, o.vocabulary_id) = v.id)
          AS book_count
      FROM fsrs_cards f
      JOIN vocabulary v ON v.id = f.vocabulary_id
      JOIN word_statuses s ON s.vocabulary_id = v.id
      WHERE s.status = ?
        AND f.due <= CAST(strftime('%s','now') AS INTEGER)
      ORDER BY f.due ASC
      LIMIT ?
    ''';

  Stream<int> watchDueCount() {
    const sql = '''
      SELECT COUNT(*) AS c
      FROM fsrs_cards f
      JOIN word_statuses s ON s.vocabulary_id = f.vocabulary_id
      WHERE s.status = 'LEARNING'
        AND f.due <= CAST(strftime('%s','now') AS INTEGER)
    ''';
    return db
        .customSelect(sql, readsFrom: {db.fsrsCards, db.wordStatuses})
        .watch()
        .map((rows) => rows.isEmpty ? 0 : rows.first.read<int>('c'));
  }

  Stream<List<ReviewLog>> watchHistory(String vocabularyId) {
    return (db.select(db.reviewLogs)
          ..where((table) => table.vocabularyId.equals(vocabularyId))
          ..orderBy([(table) => OrderingTerm.desc(table.reviewedAt)]))
        .watch();
  }

  Future<FsrsScheduling> review({
    required String vocabularyId,
    required ReviewRating rating,
    double desiredRetention = 0.9,
  }) async {
    final now = DateTime.now();
    return db.transaction(() async {
      final card =
          await (db.select(db.fsrsCards)
                ..where((table) => table.vocabularyId.equals(vocabularyId)))
              .getSingleOrNull();
      if (card == null) {
        throw StateError('No FSRS card for vocabulary $vocabularyId');
      }
      final scheduler = FsrsScheduler(desiredRetention: desiredRetention);
      final scheduling = scheduler.schedule(
        rating: rating,
        state: FsrsState.fromValue(card.state),
        stability: card.stability,
        difficulty: card.difficulty,
        reps: card.reps,
        lapses: card.lapses,
        lastReview: card.lastReview,
        now: now,
      );
      await (db.update(
        db.fsrsCards,
      )..where((table) => table.vocabularyId.equals(vocabularyId))).write(
        FsrsCardsCompanion(
          state: Value(scheduling.state.value),
          due: Value(scheduling.due),
          stability: Value(scheduling.stability),
          difficulty: Value(scheduling.difficulty),
          elapsedDays: Value(scheduling.elapsedDays),
          scheduledDays: Value(scheduling.scheduledDays),
          reps: Value(scheduling.reps),
          lapses: Value(scheduling.lapses),
          lastReview: Value(now),
          revision: Value(card.revision + 1),
          updatedAt: Value(now),
          updatedBy: Value(deviceId),
        ),
      );
      await db
          .into(db.reviewLogs)
          .insert(
            ReviewLogsCompanion.insert(
              id: const Uuid().v4(),
              vocabularyId: vocabularyId,
              reviewedAt: now,
              rating: rating.value,
              stateBefore: card.state,
              stateAfter: scheduling.state.value,
              stabilityBefore: card.stability,
              stabilityAfter: scheduling.stability,
              intervalDays: scheduling.intervalDays,
              dueAfter: scheduling.due,
              deviceId: Value(deviceId),
            ),
          );
      return scheduling;
    });
  }

  Future<int> reviewedTodayCount() async {
    final start = DateTime.now();
    final startOfDay = DateTime(start.year, start.month, start.day);
    final row = await db
        .customSelect(
          'SELECT COUNT(*) AS c FROM review_logs WHERE reviewed_at >= ?',
          variables: [Variable(startOfDay.millisecondsSinceEpoch ~/ 1000)],
        )
        .getSingle();
    return row.read<int>('c');
  }

  Future<int> newReviewedTodayCount() async {
    final start = DateTime.now();
    final startOfDay = DateTime(start.year, start.month, start.day);
    final row = await db
        .customSelect(
          'SELECT COUNT(*) AS c FROM review_logs '
          'WHERE reviewed_at >= ? AND state_before = ?',
          variables: [
            Variable(startOfDay.millisecondsSinceEpoch ~/ 1000),
            Variable(FsrsState.newCard.value),
          ],
        )
        .getSingle();
    return row.read<int>('c');
  }

  ReviewItem _mapReviewItem(QueryRow row) {
    DateTime date(String key) {
      final value = row.data[key];
      if (value is DateTime) return value;
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value * 1000);
      }
      return DateTime.parse(value as String);
    }

    DateTime? nullableDate(String key) {
      if (row.data[key] == null) return null;
      return date(key);
    }

    final vocabulary = VocabularyData(
      id: row.read<String>('id'),
      lemma: row.read<String>('lemma'),
      language: row.read<String>('language'),
      senseLabel: row.read<String?>('sense_label'),
      createdAt: date('created_at'),
      updatedAt: date('updated_at'),
    );
    final card = FsrsCard(
      vocabularyId: vocabulary.id,
      state: row.read<String>('state'),
      due: date('due'),
      stability: row.read<double>('stability'),
      difficulty: row.read<double>('difficulty'),
      elapsedDays: row.read<int>('elapsed_days'),
      scheduledDays: row.read<int>('scheduled_days'),
      reps: row.read<int>('reps'),
      lapses: row.read<int>('lapses'),
      lastReview: nullableDate('last_review'),
      revision: row.read<int>('card_revision'),
      updatedAt: date('card_updated_at'),
    );
    return ReviewItem(
      vocabulary: vocabulary,
      card: card,
      definition: row.read<String?>('definition'),
      occurrenceCount: row.read<int>('occurrence_count'),
      bookCount: row.read<int>('book_count'),
    );
  }
}
