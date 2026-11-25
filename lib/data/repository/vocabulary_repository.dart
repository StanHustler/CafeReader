import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../../core/reader/page_content.dart';
import '../../domain/lemmatizer/lemmatizer.dart';
import '../../domain/lemmatizer/tokenizer.dart';

enum VocabularyState {
  newWord('NEW', 'New'),
  learning('LEARNING', 'Learning'),
  known('KNOWN', 'Known');

  const VocabularyState(this.dbValue, this.label);
  final String dbValue;
  final String label;

  static VocabularyState fromDb(String value) {
    return switch (value.toUpperCase()) {
      'LEARNING' => learning,
      'KNOWN' => known,
      _ => newWord,
    };
  }
}

class DeckEntry {
  const DeckEntry({
    required this.vocabulary,
    required this.state,
    required this.occurrenceCount,
    required this.bookCount,
    this.definition,
    this.fsrsDue,
    this.fsrsState,
    this.reps = 0,
    this.lastReview,
  });

  final VocabularyData vocabulary;
  final VocabularyState state;
  final int occurrenceCount;
  final int bookCount;
  final String? definition;
  final DateTime? fsrsDue;
  final String? fsrsState;
  final int reps;
  final DateTime? lastReview;
}

class ChapterOccurrence {
  const ChapterOccurrence({
    required this.id,
    required this.surfaceForm,
    required this.paragraphIndex,
    required this.startOffset,
    required this.endOffset,
    required this.vocabularyId,
    required this.lemma,
    this.senseLabel,
    required this.state,
    required this.isManuallyCorrected,
  });

  final String id;
  final String surfaceForm;
  final int paragraphIndex;
  final int startOffset;
  final int endOffset;
  final String vocabularyId;
  final String lemma;
  final String? senseLabel;
  final VocabularyState state;
  final bool isManuallyCorrected;

  String get displayLemma => senseLabel == null || senseLabel!.isEmpty
      ? lemma
      : '$lemma · $senseLabel';
}

/// An occurrence that should be persisted when a word is added to Learning.
class PendingOccurrence {
  const PendingOccurrence({
    required this.chapterId,
    required this.paragraphIndex,
    required this.startOffset,
    required this.endOffset,
    required this.surfaceForm,
  });

  final String chapterId;
  final int paragraphIndex;
  final int startOffset;
  final int endOffset;
  final String surfaceForm;
}

/// The vocabulary entry behind a tapped surface form.
class WordLookup {
  const WordLookup({
    required this.vocabularyId,
    required this.lemma,
    required this.state,
    this.senseLabel,
  });

  final String vocabularyId;
  final String lemma;
  final String? senseLabel;
  final VocabularyState state;
}

/// Result of looking up a tapped word. [vocabularyId] is null when the word
/// has not been added to Learning or Known yet; such a word is implicitly New
/// and nothing is written until the reader chooses a deck state.
class SurfaceMatch {
  const SurfaceMatch({
    required this.surfaceForm,
    required this.lemma,
    this.vocabularyId,
    this.senseLabel,
    this.state,
  });

  final String surfaceForm;
  final String lemma;
  final String? vocabularyId;
  final String? senseLabel;
  final VocabularyState? state;

  bool get isPersisted => vocabularyId != null;
}

class VocabularyContext {
  const VocabularyContext({
    required this.occurrenceId,
    required this.bookId,
    required this.bookTitle,
    required this.chapterId,
    required this.chapterTitle,
    required this.chapterIndex,
    required this.paragraphIndex,
    required this.startOffset,
    required this.endOffset,
    required this.context,
  });

  final String occurrenceId;
  final String bookId;
  final String bookTitle;
  final String chapterId;
  final String chapterTitle;
  final int chapterIndex;
  final int paragraphIndex;
  final int startOffset;
  final int endOffset;
  final String context;
}

class VocabularyRepository {
  VocabularyRepository(this.db, this.lemmatizer, this.deviceId);

  final AppDatabase db;
  final Lemmatizer lemmatizer;
  final String deviceId;

  Stream<VocabularyState> watchState(String vocabularyId) {
    return (db.select(db.wordStatuses)
          ..where((table) => table.vocabularyId.equals(vocabularyId)))
        .watchSingleOrNull()
        .map((row) => VocabularyState.fromDb(row?.status ?? 'NEW'));
  }

  Future<VocabularyState> getState(String vocabularyId) async {
    final row =
        await (db.select(db.wordStatuses)
              ..where((table) => table.vocabularyId.equals(vocabularyId)))
            .getSingleOrNull();
    return VocabularyState.fromDb(row?.status ?? 'NEW');
  }

  Future<List<ChapterOccurrence>> getChapterOccurrences(
    String chapterId,
  ) async {
    final rows = await db
        .customSelect(_chapterOccurrencesSql, variables: [Variable(chapterId)])
        .get();
    return rows.map(_mapChapterOccurrence).toList();
  }

  Stream<List<ChapterOccurrence>> watchChapterOccurrences(String chapterId) {
    return db
        .customSelect(
          _chapterOccurrencesSql,
          variables: [Variable(chapterId)],
          readsFrom: {db.wordOccurrences, db.vocabulary, db.wordStatuses},
        )
        .watch()
        .map((rows) => rows.map(_mapChapterOccurrence).toList());
  }

  /// Builds the marks for a chapter without reading the persistent occurrence
  /// index. The chapter text is tokenized in memory and matched against
  /// vocabulary entries and word forms on demand. Tokens with no vocabulary
  /// entry are returned as [VocabularyState.newWord] so the reader can mark
  /// unknown words as well as Learning ones.
  Future<List<ChapterOccurrence>> getChapterWordMarks(Chapter chapter) async {
    const tokenizer = Tokenizer();
    final paragraphs = chapterParagraphs(chapter.content);
    final tokens = <_ChapterToken>[];
    for (
      var paragraphIndex = 0;
      paragraphIndex < paragraphs.length;
      paragraphIndex++
    ) {
      for (final token in tokenizer.tokenize(paragraphs[paragraphIndex])) {
        tokens.add(
          _ChapterToken(
            surface: token.surface,
            normalized: token.normalized,
            paragraphIndex: paragraphIndex,
            start: token.start,
            end: token.end,
          ),
        );
      }
    }
    if (tokens.isEmpty) return const [];

    final surfaces = {for (final token in tokens) token.normalized}.toList();
    final resolved = await _resolveSurfaces(surfaces);
    final saved = await _savedOccurrences(chapter.id);

    final marks = <ChapterOccurrence>[];
    for (final token in tokens) {
      final key = '${token.paragraphIndex}:${token.start}:${token.end}';
      final occurrence = saved[key];
      if (occurrence != null) {
        marks.add(
          ChapterOccurrence(
            id: occurrence.id,
            surfaceForm: token.surface,
            paragraphIndex: token.paragraphIndex,
            startOffset: token.start,
            endOffset: token.end,
            vocabularyId: occurrence.vocabularyId,
            lemma: occurrence.lemma,
            senseLabel: occurrence.senseLabel,
            state: occurrence.state,
            isManuallyCorrected: occurrence.isManuallyCorrected,
          ),
        );
        continue;
      }
      final word = resolved[token.normalized];
      marks.add(
        ChapterOccurrence(
          id: '',
          surfaceForm: token.surface,
          paragraphIndex: token.paragraphIndex,
          startOffset: token.start,
          endOffset: token.end,
          // Unknown words have no vocabulary row until the reader saves them.
          vocabularyId: word?.vocabularyId ?? '',
          lemma: word?.lemma ?? token.normalized,
          senseLabel: word?.senseLabel,
          state: word?.state ?? VocabularyState.newWord,
          isManuallyCorrected: false,
        ),
      );
    }
    return marks;
  }

  /// Looks up a tapped surface without writing anything. A word that is not
  /// in Learning or Known is implicitly New and gets no vocabulary row until
  /// the reader saves it.
  Future<SurfaceMatch> matchSurface(String surfaceForm) async {
    final normalized = Tokenizer.normalize(surfaceForm);
    if (normalized.isEmpty) {
      throw ArgumentError.value(surfaceForm, 'surfaceForm');
    }
    final existingForm = await _lookupForm(normalized);
    if (existingForm != null) {
      return SurfaceMatch(
        surfaceForm: normalized,
        lemma: existingForm.lemma,
        vocabularyId: existingForm.vocabularyId,
        senseLabel: existingForm.senseLabel,
        state: existingForm.state,
      );
    }
    final lemma = await _lemmaFor(normalized);
    final existingVocabulary = await _lookupLemma(lemma);
    if (existingVocabulary != null) {
      return SurfaceMatch(
        surfaceForm: normalized,
        lemma: existingVocabulary.lemma,
        vocabularyId: existingVocabulary.vocabularyId,
        senseLabel: existingVocabulary.senseLabel,
        state: existingVocabulary.state,
      );
    }
    return SurfaceMatch(surfaceForm: normalized, lemma: lemma);
  }

  /// Creates the vocabulary entry and word form for a matched surface. This
  /// is called only when the reader adds the word to Learning or Known.
  Future<String> ensureVocabulary(SurfaceMatch match) async {
    final normalized = Tokenizer.normalize(match.surfaceForm);
    final existing = match.vocabularyId;
    if (existing != null) {
      await _insertForm(existing, normalized);
      return existing;
    }
    final vocabularyId = const Uuid().v5(
      Namespace.url.value,
      'cafereader:vocab:en:${match.lemma}',
    );
    // Another device may have created the same lemma first.
    final raced = await _lookupById(vocabularyId);
    if (raced != null) {
      await _insertForm(raced.vocabularyId, normalized);
      return raced.vocabularyId;
    }
    final now = DateTime.now();
    await db
        .into(db.vocabulary)
        .insert(
          VocabularyCompanion.insert(
            id: vocabularyId,
            lemma: match.lemma,
            language: const Value('en'),
            createdAt: now,
            updatedAt: now,
          ),
          mode: InsertMode.insertOrIgnore,
        );
    await _insertForm(vocabularyId, normalized);
    return vocabularyId;
  }

  /// Persists the sentence location for a word that was just added to
  /// Learning. Repeated calls for the same position are idempotent.
  Future<String> recordOccurrence({
    required String bookId,
    required String vocabularyId,
    required PendingOccurrence pending,
  }) async {
    final now = DateTime.now();
    final id = const Uuid().v5(
      Namespace.url.value,
      'cafereader:occurrence:${pending.chapterId}:'
      '${pending.paragraphIndex}:${pending.startOffset}:'
      '${pending.endOffset}:'
      '${Tokenizer.normalize(pending.surfaceForm)}',
    );
    await db
        .into(db.wordOccurrences)
        .insert(
          WordOccurrencesCompanion.insert(
            id: id,
            bookId: bookId,
            chapterId: pending.chapterId,
            vocabularyId: vocabularyId,
            surfaceForm: pending.surfaceForm,
            paragraphIndex: pending.paragraphIndex,
            startOffset: pending.startOffset,
            endOffset: pending.endOffset,
            createdAt: now,
            updatedAt: now,
            updatedBy: Value(deviceId),
          ),
          mode: InsertMode.insertOrIgnore,
        );
    return id;
  }

  Future<Map<String, WordLookup>> _resolveSurfaces(
    List<String> surfaces,
  ) async {
    final resolved = <String, WordLookup>{};
    final scores = <String, double>{};
    for (final chunk in _chunks(surfaces, 400)) {
      final placeholders = List.filled(chunk.length, '?').join(',');
      final rows = await db
          .customSelect(
            '''
        SELECT f.surface_form, f.normalized_form, f.vocabulary_id, v.lemma,
          v.sense_label, COALESCE(s.status, 'NEW') AS status,
          f.is_primary, f.confidence
        FROM word_forms f
        JOIN vocabulary v ON v.id = f.vocabulary_id
        LEFT JOIN word_statuses s ON s.vocabulary_id = v.id
        WHERE f.surface_form IN ($placeholders)
          OR f.normalized_form IN ($placeholders)
        ''',
            variables: [...chunk.map(Variable.new), ...chunk.map(Variable.new)],
          )
          .get();
      final wanted = chunk.toSet();
      for (final row in rows) {
        final word = WordLookup(
          vocabularyId: row.read<String>('vocabulary_id'),
          lemma: row.read<String>('lemma'),
          senseLabel: row.read<String?>('sense_label'),
          state: VocabularyState.fromDb(row.read<String>('status')),
        );
        final primary = row.read<bool>('is_primary');
        final confidence = row.read<double>('confidence');
        final score = (primary ? 1.0 : 0.0) + confidence;
        for (final key in {
          row.read<String>('surface_form'),
          row.read<String>('normalized_form'),
        }) {
          if (!wanted.contains(key)) continue;
          if ((scores[key] ?? -1) >= score) continue;
          resolved[key] = word;
          scores[key] = score;
        }
      }
    }

    final lemmatizerEnabled =
        (await _setting('lemmatizer_enabled', 'true')).toLowerCase() != 'false';
    if (!lemmatizerEnabled) return resolved;

    final missing = surfaces.where((s) => !resolved.containsKey(s)).toList();
    if (missing.isEmpty) return resolved;
    final lemmaFor = <String, String>{
      for (final surface in missing)
        surface: lemmatizer.lemmatize(surface).lemma,
    };
    final lemmas = lemmaFor.values.toSet().toList();
    final byLemma = <String, WordLookup>{};
    for (final chunk in _chunks(lemmas, 400)) {
      final placeholders = List.filled(chunk.length, '?').join(',');
      final rows = await db.customSelect('''
        SELECT v.id, v.lemma, v.sense_label,
          COALESCE(s.status, 'NEW') AS status
        FROM vocabulary v
        LEFT JOIN word_statuses s ON s.vocabulary_id = v.id
        WHERE v.language = 'en' AND v.lemma IN ($placeholders)
        ORDER BY (v.sense_label IS NULL) DESC, v.created_at ASC
        ''', variables: chunk.map(Variable.new).toList()).get();
      for (final row in rows) {
        final lemma = row.read<String>('lemma');
        byLemma.putIfAbsent(
          lemma,
          () => WordLookup(
            vocabularyId: row.read<String>('id'),
            lemma: lemma,
            senseLabel: row.read<String?>('sense_label'),
            state: VocabularyState.fromDb(row.read<String>('status')),
          ),
        );
      }
    }
    for (final surface in missing) {
      final word = byLemma[lemmaFor[surface]];
      if (word != null) resolved[surface] = word;
    }
    return resolved;
  }

  Future<Map<String, _SavedOccurrence>> _savedOccurrences(
    String chapterId,
  ) async {
    final rows = await db
        .customSelect(
          '''
      SELECT o.id, o.paragraph_index, o.start_offset, o.end_offset,
        COALESCE(o.override_vocabulary_id, o.vocabulary_id) AS vocabulary_id,
        v.lemma, v.sense_label, COALESCE(s.status, 'NEW') AS status,
        o.is_manually_corrected
      FROM word_occurrences o
      JOIN vocabulary v
        ON v.id = COALESCE(o.override_vocabulary_id, o.vocabulary_id)
      LEFT JOIN word_statuses s
        ON s.vocabulary_id = COALESCE(o.override_vocabulary_id, o.vocabulary_id)
      WHERE o.chapter_id = ?
      ''',
          variables: [Variable(chapterId)],
        )
        .get();
    return {
      for (final row in rows)
        '${row.read<int>('paragraph_index')}:'
            '${row.read<int>('start_offset')}:'
            '${row.read<int>('end_offset')}': _SavedOccurrence(
          id: row.read<String>('id'),
          vocabularyId: row.read<String>('vocabulary_id'),
          lemma: row.read<String>('lemma'),
          senseLabel: row.read<String?>('sense_label'),
          state: VocabularyState.fromDb(row.read<String>('status')),
          isManuallyCorrected: row.read<bool>('is_manually_corrected'),
        ),
    };
  }

  Future<WordLookup?> _lookupForm(String normalized) async {
    final row = await db
        .customSelect(
          '''
      SELECT f.vocabulary_id, v.lemma, v.sense_label,
        COALESCE(s.status, 'NEW') AS status
      FROM word_forms f
      JOIN vocabulary v ON v.id = f.vocabulary_id
      LEFT JOIN word_statuses s ON s.vocabulary_id = v.id
      WHERE f.normalized_form = ? OR f.surface_form = ?
      ORDER BY f.is_primary DESC, f.confidence DESC
      LIMIT 1
      ''',
          variables: [Variable(normalized), Variable(normalized)],
        )
        .getSingleOrNull();
    if (row == null) return null;
    return WordLookup(
      vocabularyId: row.read<String>('vocabulary_id'),
      lemma: row.read<String>('lemma'),
      senseLabel: row.read<String?>('sense_label'),
      state: VocabularyState.fromDb(row.read<String>('status')),
    );
  }

  Future<WordLookup?> _lookupLemma(String lemma) async {
    final row = await db
        .customSelect(
          '''
      SELECT v.id, v.lemma, v.sense_label,
        COALESCE(s.status, 'NEW') AS status
      FROM vocabulary v
      LEFT JOIN word_statuses s ON s.vocabulary_id = v.id
      WHERE v.language = 'en' AND v.lemma = ?
      ORDER BY (v.sense_label IS NULL) DESC, v.created_at ASC
      LIMIT 1
      ''',
          variables: [Variable(lemma)],
        )
        .getSingleOrNull();
    if (row == null) return null;
    return WordLookup(
      vocabularyId: row.read<String>('id'),
      lemma: row.read<String>('lemma'),
      senseLabel: row.read<String?>('sense_label'),
      state: VocabularyState.fromDb(row.read<String>('status')),
    );
  }

  Future<WordLookup?> _lookupById(String vocabularyId) async {
    final row = await db
        .customSelect(
          '''
      SELECT v.id, v.lemma, v.sense_label,
        COALESCE(s.status, 'NEW') AS status
      FROM vocabulary v
      LEFT JOIN word_statuses s ON s.vocabulary_id = v.id
      WHERE v.id = ?
      ''',
          variables: [Variable(vocabularyId)],
        )
        .getSingleOrNull();
    if (row == null) return null;
    return WordLookup(
      vocabularyId: row.read<String>('id'),
      lemma: row.read<String>('lemma'),
      senseLabel: row.read<String?>('sense_label'),
      state: VocabularyState.fromDb(row.read<String>('status')),
    );
  }

  Future<void> _insertForm(String vocabularyId, String normalized) async {
    final now = DateTime.now();
    await db
        .into(db.wordForms)
        .insert(
          WordFormsCompanion.insert(
            id: const Uuid().v5(
              Namespace.url.value,
              'cafereader:form:$vocabularyId:$normalized',
            ),
            surfaceForm: normalized,
            normalizedForm: normalized,
            vocabularyId: vocabularyId,
            confidence: const Value(1),
            isVerified: const Value(true),
            isPrimary: const Value(true),
            createdAt: now,
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<String> _lemmaFor(String normalized) async {
    final lemmatizerEnabled =
        (await _setting('lemmatizer_enabled', 'true')).toLowerCase() != 'false';
    return lemmatizerEnabled
        ? lemmatizer.lemmatize(normalized).lemma
        : normalized;
  }

  Future<String> _setting(String key, String fallback) async {
    final row = await (db.select(
      db.appSettings,
    )..where((table) => table.key.equals(key))).getSingleOrNull();
    return row?.value ?? fallback;
  }

  static List<List<T>> _chunks<T>(List<T> values, int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < values.length; i += size) {
      chunks.add(values.sublist(i, (i + size).clamp(0, values.length)));
    }
    return chunks;
  }

  ChapterOccurrence _mapChapterOccurrence(QueryRow row) => ChapterOccurrence(
    id: row.read<String>('id'),
    surfaceForm: row.read<String>('surface_form'),
    paragraphIndex: row.read<int>('paragraph_index'),
    startOffset: row.read<int>('start_offset'),
    endOffset: row.read<int>('end_offset'),
    vocabularyId: row.read<String>('effective_vocabulary_id'),
    lemma: row.read<String>('lemma'),
    senseLabel: row.read<String?>('sense_label'),
    state: VocabularyState.fromDb(row.read<String>('status')),
    isManuallyCorrected: row.read<bool>('is_manually_corrected'),
  );

  static const String _chapterOccurrencesSql = '''
      SELECT o.id, o.surface_form, o.paragraph_index, o.start_offset, o.end_offset,
        COALESCE(o.override_vocabulary_id, o.vocabulary_id) AS effective_vocabulary_id,
        v.lemma, v.sense_label, COALESCE(s.status, 'NEW') AS status,
        o.is_manually_corrected
      FROM word_occurrences o
      JOIN vocabulary v ON v.id = COALESCE(o.override_vocabulary_id, o.vocabulary_id)
      LEFT JOIN word_statuses s
        ON s.vocabulary_id = COALESCE(o.override_vocabulary_id, o.vocabulary_id)
      WHERE o.chapter_id = ?
      ORDER BY o.paragraph_index, o.start_offset
    ''';

  Stream<List<DeckEntry>> watchDeck({
    required VocabularyState state,
    String query = '',
    String? bookId,
    bool sortByDue = false,
  }) {
    final sql = StringBuffer('''
      SELECT v.*, COALESCE(s.status, 'NEW') AS state,
        (SELECT COUNT(*) FROM word_occurrences o
          WHERE o.vocabulary_id = v.id AND o.override_vocabulary_id IS NULL)
        + (SELECT COUNT(*) FROM word_occurrences o
          WHERE o.override_vocabulary_id = v.id) AS occurrence_count,
        (SELECT COUNT(*) FROM (
          SELECT o.book_id FROM word_occurrences o
          WHERE o.vocabulary_id = v.id AND o.override_vocabulary_id IS NULL
          UNION
          SELECT o.book_id FROM word_occurrences o
          WHERE o.override_vocabulary_id = v.id)) AS book_count,
        (SELECT d.meaning FROM definitions d WHERE d.vocabulary_id = v.id
          ORDER BY d.updated_at DESC LIMIT 1) AS definition,
        f.due AS fsrs_due, f.state AS fsrs_state, COALESCE(f.reps, 0) AS reps,
        f.last_review AS last_review
      FROM vocabulary v
      LEFT JOIN word_statuses s ON s.vocabulary_id = v.id
      LEFT JOIN fsrs_cards f ON f.vocabulary_id = v.id
      WHERE COALESCE(s.status, 'NEW') = ?
    ''');
    final variables = <Variable<Object>>[Variable(state.dbValue)];
    if (query.trim().isNotEmpty) {
      sql.write(
        ' AND (v.lemma LIKE ? OR COALESCE(v.sense_label, \'\') LIKE ?)',
      );
      variables.add(Variable('%${query.trim()}%'));
      variables.add(Variable('%${query.trim()}%'));
    }
    if (bookId != null) {
      sql.write('''
        AND EXISTS (
          SELECT 1 FROM word_occurrences ob
          WHERE COALESCE(ob.override_vocabulary_id, ob.vocabulary_id) = v.id
            AND ob.book_id = ?
        )
      ''');
      variables.add(Variable(bookId));
    }
    if (sortByDue && state == VocabularyState.learning) {
      sql.write(' ORDER BY f.due IS NULL, f.due ASC, v.lemma ASC');
    } else {
      sql.write(' ORDER BY v.lemma COLLATE NOCASE ASC, v.sense_label ASC');
    }
    return db
        .customSelect(
          sql.toString(),
          variables: variables,
          readsFrom: {
            db.vocabulary,
            db.wordStatuses,
            db.wordOccurrences,
            db.definitions,
            db.fsrsCards,
          },
        )
        .watch()
        .map((rows) => rows.map(_mapDeckEntry).toList());
  }

  Future<DeckEntry?> getDeckEntry(String vocabularyId) async {
    const sql = '''
      SELECT v.*, COALESCE(s.status, 'NEW') AS state,
        (SELECT COUNT(*) FROM word_occurrences o
          WHERE o.vocabulary_id = v.id AND o.override_vocabulary_id IS NULL)
        + (SELECT COUNT(*) FROM word_occurrences o
          WHERE o.override_vocabulary_id = v.id) AS occurrence_count,
        (SELECT COUNT(*) FROM (
          SELECT o.book_id FROM word_occurrences o
          WHERE o.vocabulary_id = v.id AND o.override_vocabulary_id IS NULL
          UNION
          SELECT o.book_id FROM word_occurrences o
          WHERE o.override_vocabulary_id = v.id)) AS book_count,
        (SELECT d.meaning FROM definitions d WHERE d.vocabulary_id = v.id
          ORDER BY d.updated_at DESC LIMIT 1) AS definition,
        f.due AS fsrs_due, f.state AS fsrs_state, COALESCE(f.reps, 0) AS reps,
        f.last_review AS last_review
      FROM vocabulary v
      LEFT JOIN word_statuses s ON s.vocabulary_id = v.id
      LEFT JOIN fsrs_cards f ON f.vocabulary_id = v.id
      WHERE v.id = ?
    ''';
    final rows = await db
        .customSelect(sql, variables: [Variable(vocabularyId)])
        .get();
    if (rows.isEmpty) return null;
    return _mapDeckEntry(rows.first);
  }

  Stream<VocabularyData?> watchVocabulary(String vocabularyId) {
    return (db.select(
      db.vocabulary,
    )..where((table) => table.id.equals(vocabularyId))).watchSingleOrNull();
  }

  Future<VocabularyData?> getVocabulary(String vocabularyId) {
    return (db.select(
      db.vocabulary,
    )..where((table) => table.id.equals(vocabularyId))).getSingleOrNull();
  }

  Stream<List<WordForm>> watchForms(String vocabularyId) {
    return (db.select(db.wordForms)
          ..where((table) => table.vocabularyId.equals(vocabularyId))
          ..orderBy([(table) => OrderingTerm.asc(table.surfaceForm)]))
        .watch();
  }

  Future<List<Definition>> getDefinitions(String vocabularyId) {
    return (db.select(db.definitions)
          ..where((table) => table.vocabularyId.equals(vocabularyId))
          ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)]))
        .get();
  }

  Future<VocabularyData?> findVocabularyByLemma(String lemma) async {
    final rows =
        await (db.select(db.vocabulary)
              ..where(
                (table) =>
                    table.lemma.equals(lemma.toLowerCase()) &
                    table.language.equals('en'),
              )
              ..orderBy([(table) => OrderingTerm.asc(table.createdAt)]))
            .get();
    if (rows.isEmpty) return null;
    return rows.firstWhere(
      (row) => row.senseLabel == null,
      orElse: () => rows.first,
    );
  }

  Future<List<VocabularyData>> findVocabulariesByLemma(String lemma) {
    return (db.select(db.vocabulary)
          ..where(
            (table) =>
                table.lemma.equals(lemma.toLowerCase()) &
                table.language.equals('en'),
          )
          ..orderBy([(table) => OrderingTerm.asc(table.createdAt)]))
        .get();
  }

  Stream<List<Definition>> watchDefinitions(String vocabularyId) {
    return (db.select(db.definitions)
          ..where((table) => table.vocabularyId.equals(vocabularyId))
          ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)]))
        .watch();
  }

  Future<void> setState(String vocabularyId, VocabularyState state) async {
    if (state == VocabularyState.newWord) return;
    await db.transaction(() async {
      final existing =
          await (db.select(db.wordStatuses)
                ..where((table) => table.vocabularyId.equals(vocabularyId)))
              .getSingleOrNull();
      final now = DateTime.now();
      if (existing == null) {
        await db
            .into(db.wordStatuses)
            .insert(
              WordStatusesCompanion.insert(
                vocabularyId: vocabularyId,
                status: state.dbValue,
                updatedAt: now,
                updatedBy: Value(deviceId),
              ),
            );
      } else {
        await (db.update(
          db.wordStatuses,
        )..where((table) => table.vocabularyId.equals(vocabularyId))).write(
          WordStatusesCompanion(
            status: Value(state.dbValue),
            revision: Value(existing.revision + 1),
            updatedAt: Value(now),
            updatedBy: Value(deviceId),
          ),
        );
      }
      if (state != VocabularyState.learning) {
        // The card is retained so review history and scheduling survive
        // temporarily leaving the learning queue.
      }
    });
  }

  Future<void> addDefinition({
    required String vocabularyId,
    required String meaning,
    String? example,
  }) async {
    final trimmed = meaning.trim();
    if (trimmed.isEmpty) return;
    await db
        .into(db.definitions)
        .insert(
          DefinitionsCompanion.insert(
            id: const Uuid().v4(),
            vocabularyId: vocabularyId,
            meaning: trimmed,
            example: Value(example?.trim()),
            updatedAt: DateTime.now(),
            updatedBy: Value(deviceId),
          ),
        );
  }

  Future<void> deleteDefinition(String definitionId) async {
    await (db.delete(
      db.definitions,
    )..where((table) => table.id.equals(definitionId))).go();
  }

  Stream<List<VocabularyContext>> watchContexts(
    String vocabularyId, {
    int limit = 30,
  }) {
    const sql = '''
      SELECT o.id AS occurrence_id, o.book_id, b.title AS book_title,
        o.chapter_id, c.title AS chapter_title, c.chapter_index,
        o.paragraph_index, o.start_offset, o.end_offset, c.content
      FROM word_occurrences o
      JOIN books b ON b.id = o.book_id
      JOIN chapters c ON c.id = o.chapter_id
      WHERE COALESCE(o.override_vocabulary_id, o.vocabulary_id) = ?
        AND b.deleted_at IS NULL
      ORDER BY o.book_id, o.chapter_id, o.paragraph_index, o.start_offset
      LIMIT ?
    ''';
    return db
        .customSelect(
          sql,
          variables: [Variable(vocabularyId), Variable(limit)],
          readsFrom: {db.wordOccurrences, db.books, db.chapters},
        )
        .watch()
        .map(
          (rows) => rows.map((row) {
            final content = row.read<String>('content');
            final paragraphs = content.split('\n\n');
            final paragraphIndex = row.read<int>('paragraph_index');
            final start = row.read<int>('start_offset');
            final end = row.read<int>('end_offset');
            final paragraph = paragraphIndex < paragraphs.length
                ? paragraphs[paragraphIndex]
                : '';
            final from = (start - 80).clamp(0, paragraph.length);
            final to = (end + 90).clamp(0, paragraph.length);
            return VocabularyContext(
              occurrenceId: row.read<String>('occurrence_id'),
              bookId: row.read<String>('book_id'),
              bookTitle: row.read<String>('book_title'),
              chapterId: row.read<String>('chapter_id'),
              chapterTitle: row.read<String>('chapter_title'),
              chapterIndex: row.read<int>('chapter_index'),
              paragraphIndex: paragraphIndex,
              startOffset: start,
              endOffset: end,
              context:
                  '${from > 0 ? '…' : ''}${paragraph.substring(from, to)}${to < paragraph.length ? '…' : ''}',
            );
          }).toList(),
        );
  }

  Future<int> countInBook(String vocabularyId, String bookId) async {
    const sql = '''
      SELECT COUNT(*) AS c FROM word_occurrences
      WHERE COALESCE(override_vocabulary_id, vocabulary_id) = ?
        AND book_id = ?
    ''';
    final row = await db
        .customSelect(
          sql,
          variables: [Variable(vocabularyId), Variable(bookId)],
        )
        .getSingle();
    return row.read<int>('c');
  }

  /// Creates a distinct vocabulary sense. Two senses may share a lemma; they
  /// have independent global states.
  Future<String> createVocabulary({
    required String lemma,
    String? senseLabel,
    String language = 'en',
    String? definition,
    String? surfaceForm,
    bool addForm = true,
  }) async {
    final normalized = lemma.toLowerCase().trim();
    final id = const Uuid().v4();
    final now = DateTime.now();
    await db.transaction(() async {
      await db
          .into(db.vocabulary)
          .insert(
            VocabularyCompanion.insert(
              id: id,
              lemma: normalized,
              language: Value(language),
              senseLabel: Value(senseLabel?.trim()),
              createdAt: now,
              updatedAt: now,
            ),
          );
      if (addForm && surfaceForm != null && surfaceForm.trim().isNotEmpty) {
        await db
            .into(db.wordForms)
            .insert(
              WordFormsCompanion.insert(
                id: const Uuid().v4(),
                surfaceForm: surfaceForm.toLowerCase().trim(),
                normalizedForm: normalized,
                vocabularyId: id,
                confidence: const Value(1),
                isVerified: const Value(true),
                isPrimary: const Value(false),
                createdAt: now,
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }
      if (definition != null && definition.trim().isNotEmpty) {
        await db
            .into(db.definitions)
            .insert(
              DefinitionsCompanion.insert(
                id: const Uuid().v4(),
                vocabularyId: id,
                meaning: definition.trim(),
                updatedAt: now,
              ),
            );
      }
    });
    return id;
  }

  /// Applies an occurrence-level correction. Global form changes are a
  /// deliberately separate operation and never happen implicitly.
  Future<void> correctOccurrence({
    required String occurrenceId,
    required String newVocabularyId,
    CorrectionScope scope = CorrectionScope.occurrence,
  }) async {
    final occurrence = await (db.select(
      db.wordOccurrences,
    )..where((table) => table.id.equals(occurrenceId))).getSingleOrNull();
    if (occurrence == null) return;
    final now = DateTime.now();
    switch (scope) {
      case CorrectionScope.occurrence:
        await (db.update(
          db.wordOccurrences,
        )..where((table) => table.id.equals(occurrenceId))).write(
          WordOccurrencesCompanion(
            overrideVocabularyId: Value(newVocabularyId),
            isManuallyCorrected: const Value(true),
            revision: Value(occurrence.revision + 1),
            updatedAt: Value(now),
            updatedBy: Value(deviceId),
          ),
        );
      case CorrectionScope.book:
        await (db.update(db.wordOccurrences)..where(
              (table) =>
                  table.bookId.equals(occurrence.bookId) &
                  table.surfaceForm.equals(occurrence.surfaceForm),
            ))
            .write(
              WordOccurrencesCompanion(
                overrideVocabularyId: Value(newVocabularyId),
                isManuallyCorrected: const Value(true),
              ),
            );
      case CorrectionScope.globalForm:
        // Existing manual overrides stay intact. All automatically associated
        // occurrences of this surface form are moved to the selected sense.
        await db.transaction(() async {
          await (db.update(db.wordForms)..where(
                (table) => table.surfaceForm.equals(occurrence.surfaceForm),
              ))
              .write(const WordFormsCompanion(isPrimary: Value(false)));
          final existingForm =
              await (db.select(db.wordForms)..where(
                    (table) =>
                        table.surfaceForm.equals(occurrence.surfaceForm) &
                        table.vocabularyId.equals(newVocabularyId),
                  ))
                  .getSingleOrNull();
          if (existingForm == null) {
            await db
                .into(db.wordForms)
                .insert(
                  WordFormsCompanion.insert(
                    id: const Uuid().v4(),
                    surfaceForm: occurrence.surfaceForm,
                    normalizedForm: occurrence.surfaceForm.toLowerCase(),
                    vocabularyId: newVocabularyId,
                    confidence: const Value(1),
                    isVerified: const Value(true),
                    isPrimary: const Value(true),
                    createdAt: now,
                  ),
                );
          } else {
            await (db.update(
              db.wordForms,
            )..where((table) => table.id.equals(existingForm.id))).write(
              const WordFormsCompanion(
                isVerified: Value(true),
                isPrimary: Value(true),
              ),
            );
          }
          await (db.update(db.wordOccurrences)..where(
                (table) =>
                    table.surfaceForm.equals(occurrence.surfaceForm) &
                    table.isManuallyCorrected.equals(false),
              ))
              .write(
                WordOccurrencesCompanion(
                  vocabularyId: Value(newVocabularyId),
                  isManuallyCorrected: const Value(false),
                ),
              );
        });
    }
  }

  Future<List<String>> bookIdsForVocabulary(String vocabularyId) async {
    const sql = '''
      SELECT DISTINCT book_id FROM word_occurrences
      WHERE COALESCE(override_vocabulary_id, vocabulary_id) = ?
    ''';
    final rows = await db
        .customSelect(sql, variables: [Variable(vocabularyId)])
        .get();
    return rows.map((row) => row.read<String>('book_id')).toList();
  }

  List<LemmaHypothesis> lemmatizerCandidates(String surface) =>
      lemmatizer.candidatesFor(surface);

  DeckEntry _mapDeckEntry(QueryRow row) {
    final vocabulary = VocabularyData(
      id: row.read<String>('id'),
      lemma: row.read<String>('lemma'),
      language: row.read<String>('language'),
      senseLabel: row.read<String?>('sense_label'),
      createdAt: _date(row, 'created_at'),
      updatedAt: _date(row, 'updated_at'),
    );
    return DeckEntry(
      vocabulary: vocabulary,
      state: VocabularyState.fromDb(row.read<String>('state')),
      occurrenceCount: row.read<int>('occurrence_count'),
      bookCount: row.read<int>('book_count'),
      definition: row.read<String?>('definition'),
      fsrsDue: row.data['fsrs_due'] == null ? null : _date(row, 'fsrs_due'),
      fsrsState: row.read<String?>('fsrs_state'),
      reps: row.read<int>('reps'),
      lastReview: row.data['last_review'] == null
          ? null
          : _date(row, 'last_review'),
    );
  }

  DateTime _date(QueryRow row, String key) {
    final value = row.data[key];
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value * 1000);
    if (value is String) return DateTime.parse(value);
    throw StateError('Cannot read date column $key');
  }
}

class _ChapterToken {
  const _ChapterToken({
    required this.surface,
    required this.normalized,
    required this.paragraphIndex,
    required this.start,
    required this.end,
  });

  final String surface;
  final String normalized;
  final int paragraphIndex;
  final int start;
  final int end;
}

class _SavedOccurrence {
  const _SavedOccurrence({
    required this.id,
    required this.vocabularyId,
    required this.lemma,
    required this.state,
    required this.isManuallyCorrected,
    this.senseLabel,
  });

  final String id;
  final String vocabularyId;
  final String lemma;
  final String? senseLabel;
  final VocabularyState state;
  final bool isManuallyCorrected;
}

enum CorrectionScope { occurrence, book, globalForm }
