import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';

enum DictionaryKind {
  builtin('builtin', 'Built-in'),
  local('local', 'Local'),
  online('online', 'Online');

  const DictionaryKind(this.dbValue, this.label);

  final String dbValue;
  final String label;

  static DictionaryKind fromDb(String value) => switch (value) {
    'local' => local,
    'online' => online,
    _ => builtin,
  };
}

/// A dictionary source shown in the management list.
class DictionarySource {
  const DictionarySource({
    required this.id,
    required this.name,
    required this.kind,
    required this.source,
    required this.enabled,
    required this.entryCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DictionarySource.fromRow(Dictionary row) {
    return DictionarySource(
      id: row.id,
      name: row.name,
      kind: DictionaryKind.fromDb(row.kind),
      source: row.source,
      enabled: row.enabled,
      entryCount: row.entryCount,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  final String id;
  final String name;
  final DictionaryKind kind;

  /// The imported file name for local dictionaries, or the URL template for
  /// online dictionaries.
  final String? source;
  final bool enabled;
  final int entryCount;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class DictionaryTranslation {
  const DictionaryTranslation({
    required this.lemma,
    required this.meaning,
    this.partOfSpeech = '',
    this.example,
  });

  final String lemma;
  final String meaning;
  final String partOfSpeech;
  final String? example;
}

/// The result of asking one dictionary about one word.
class DictionaryLookup {
  const DictionaryLookup({
    required this.dictionary,
    this.translations = const [],
    this.error,
  });

  final DictionarySource dictionary;
  final List<DictionaryTranslation> translations;
  final String? error;
}

class DictionaryRepository {
  DictionaryRepository(this.db);

  final AppDatabase db;

  static const String builtinId = 'builtin-wordnet';
  static const String builtinName = 'WordNet 3.0';

  static const int _importChunkSize = 200;
  static const int _maxOnlineResults = 50;

  Future<void> ensureBuiltin() async {
    final now = DateTime.now();
    await db
        .into(db.dictionaries)
        .insert(
          DictionariesCompanion.insert(
            id: builtinId,
            name: builtinName,
            kind: DictionaryKind.builtin.dbValue,
            createdAt: now,
            updatedAt: now,
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Stream<List<DictionarySource>> watchDictionaries() async* {
    await ensureBuiltin();
    final query = db.select(db.dictionaries)
      ..orderBy([
        (table) => OrderingTerm.asc(table.kind),
        (table) => OrderingTerm.asc(table.name),
      ]);
    yield* query.watch().map(
      (rows) => rows.map(DictionarySource.fromRow).toList(growable: false),
    );
  }

  Future<bool> builtinEnabled() async {
    final row = await (db.select(
      db.dictionaries,
    )..where((table) => table.id.equals(builtinId))).getSingleOrNull();
    return row?.enabled ?? true;
  }

  /// Exact, case-insensitive lookups from every enabled local dictionary,
  /// grouped by dictionary id.
  Future<Map<String, List<DictionaryTranslation>>> localLookups(
    String word,
  ) async {
    final normalized = word.trim().toLowerCase();
    if (normalized.isEmpty) return const {};
    const sql = '''
      SELECT e.dictionary_id, e.lemma, e.part_of_speech, e.meaning, e.example
      FROM dictionary_entries e
      JOIN dictionaries d ON d.id = e.dictionary_id
      WHERE d.enabled = 1 AND d.kind = 'local'
        AND e.lemma = ? COLLATE NOCASE
      ORDER BY e.part_of_speech COLLATE NOCASE, e.id
    ''';
    final rows = await db
        .customSelect(
          sql,
          variables: [Variable(normalized)],
          readsFrom: {db.dictionaryEntries, db.dictionaries},
        )
        .get();
    final grouped = <String, List<DictionaryTranslation>>{};
    for (final row in rows) {
      grouped
          .putIfAbsent(row.read<String>('dictionary_id'), () => [])
          .add(
            DictionaryTranslation(
              lemma: row.read<String>('lemma'),
              partOfSpeech: row.read<String>('part_of_speech'),
              meaning: row.read<String>('meaning'),
              example: row.read<String?>('example'),
            ),
          );
    }
    return grouped;
  }

  /// Flat local definitions used when a word is opened in the reader.
  Future<List<DictionaryTranslation>> localDefinitionsFor(String word) async {
    final grouped = await localLookups(word);
    return [for (final entries in grouped.values) ...entries];
  }

  Future<List<DictionaryTranslation>> fetchOnline(
    DictionarySource dictionary,
    String word,
  ) async {
    final template = dictionary.source?.trim();
    if (template == null || template.isEmpty) {
      throw const FormatException('This online dictionary has no URL.');
    }
    if (!template.contains('{word}')) {
      throw const FormatException('The URL does not contain {word}.');
    }
    final uri = Uri.parse(
      template.replaceAll('{word}', Uri.encodeComponent(word.trim())),
    );
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      throw const FormatException('Only http and https URLs are supported.');
    }
    final response = await http
        .get(uri, headers: const {'Accept': 'application/json, text/plain'})
        .timeout(const Duration(seconds: 8));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw FormatException(
        'The dictionary returned HTTP ${response.statusCode}.',
      );
    }
    return _parseOnlineBody(response.body, word);
  }

  Future<String> importLocal({
    required String name,
    required List<DictionaryTranslation> translations,
    String? source,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Dictionary name is empty');
    }
    if (translations.isEmpty) {
      throw const FormatException('The dictionary contains no entries.');
    }
    final now = DateTime.now();
    final id = const Uuid().v4();
    await db.transaction(() async {
      await db
          .into(db.dictionaries)
          .insert(
            DictionariesCompanion.insert(
              id: id,
              name: trimmed,
              kind: DictionaryKind.local.dbValue,
              source: Value(source),
              entryCount: Value(translations.length),
              createdAt: now,
              updatedAt: now,
            ),
          );
      for (
        var start = 0;
        start < translations.length;
        start += _importChunkSize
      ) {
        final end = start + _importChunkSize < translations.length
            ? start + _importChunkSize
            : translations.length;
        final chunk = translations.sublist(start, end);
        await db.batch((batch) {
          batch.insertAll(db.dictionaryEntries, [
            for (final entry in chunk)
              DictionaryEntriesCompanion.insert(
                dictionaryId: id,
                lemma: entry.lemma.trim().toLowerCase(),
                partOfSpeech: Value(entry.partOfSpeech.trim()),
                meaning: entry.meaning.trim(),
                example: Value(
                  entry.example == null || entry.example!.trim().isEmpty
                      ? null
                      : entry.example!.trim(),
                ),
              ),
          ], mode: InsertMode.insertOrIgnore);
        });
      }
    });
    return id;
  }

  Future<String> addOnline({
    required String name,
    required String urlTemplate,
  }) async {
    final trimmedName = name.trim();
    final template = urlTemplate.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Dictionary name is empty');
    }
    if (!template.contains('{word}')) {
      throw const FormatException('The URL must contain {word}.');
    }
    final uri = Uri.tryParse(template.replaceAll('{word}', 'test'));
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      throw const FormatException('Enter a valid http or https URL.');
    }
    final now = DateTime.now();
    final id = const Uuid().v4();
    await db
        .into(db.dictionaries)
        .insert(
          DictionariesCompanion.insert(
            id: id,
            name: trimmedName,
            kind: DictionaryKind.online.dbValue,
            source: Value(template),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  }

  Future<void> setEnabled(String dictionaryId, bool enabled) async {
    await (db.update(
      db.dictionaries,
    )..where((table) => table.id.equals(dictionaryId))).write(
      DictionariesCompanion(
        enabled: Value(enabled),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteDictionary(String dictionaryId) async {
    if (dictionaryId == builtinId) return;
    await db.transaction(() async {
      await (db.delete(
        db.dictionaryEntries,
      )..where((table) => table.dictionaryId.equals(dictionaryId))).go();
      await (db.delete(
        db.dictionaries,
      )..where((table) => table.id.equals(dictionaryId))).go();
    });
  }

  List<DictionaryTranslation> _parseOnlineBody(String body, String word) {
    Object? decoded;
    try {
      decoded = jsonDecode(body);
    } catch (_) {
      decoded = null;
    }
    if (decoded != null) {
      final parsed = _translationsFromJson(decoded, word);
      if (parsed.isNotEmpty) return _dedupe(parsed);
    }
    return _dedupe([
      for (final line in const LineSplitter().convert(body))
        if (line.trim().isNotEmpty)
          DictionaryTranslation(lemma: word, meaning: line.trim()),
    ]);
  }

  List<DictionaryTranslation> _translationsFromJson(Object value, String word) {
    if (value is String) {
      return [DictionaryTranslation(lemma: word, meaning: value.trim())];
    }
    if (value is List) {
      return [for (final item in value) ..._translationsFromJson(item, word)];
    }
    if (value is! Map) return const [];
    for (final key in const [
      'translations',
      'definitions',
      'meanings',
      'entries',
      'results',
    ]) {
      final nested = value[key];
      if (nested != null) {
        final parsed = _translationsFromJson(nested, word);
        if (parsed.isNotEmpty) return parsed;
      }
    }
    final meaning =
        ['meaning', 'definition', 'translation', 'text', 'gloss', 'value']
            .map((key) => value[key])
            .whereType<String>()
            .map((s) => s.trim())
            .firstWhere((s) => s.isNotEmpty, orElse: () => '');
    if (meaning.isNotEmpty) {
      return [
        DictionaryTranslation(
          lemma: word,
          meaning: meaning,
          partOfSpeech:
              (value['partOfSpeech'] ?? value['pos'] ?? value['type'] ?? '')
                  .toString()
                  .trim(),
          example: value['example']?.toString(),
        ),
      ];
    }
    // A simple {word: "translation"} response, or one entry keyed by the word.
    final direct = value.entries.where(
      (entry) => entry.key.toString().toLowerCase().trim() == word,
    );
    for (final entry in direct) {
      final parsed = _translationsFromJson(entry.value, word);
      if (parsed.isNotEmpty) return parsed;
    }
    return const [];
  }

  List<DictionaryTranslation> _dedupe(List<DictionaryTranslation> entries) {
    final seen = <String>{};
    final out = <DictionaryTranslation>[];
    for (final entry in entries) {
      if (entry.meaning.trim().isEmpty) continue;
      final key =
          '${entry.meaning.trim().toLowerCase()}|'
          '${entry.partOfSpeech.trim().toLowerCase()}';
      if (!seen.add(key)) continue;
      out.add(entry);
      if (out.length >= _maxOnlineResults) break;
    }
    return out;
  }
}
