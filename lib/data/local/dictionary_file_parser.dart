import 'dart:convert';

import 'package:path/path.dart' as p;

import '../import_export/csv_service.dart';
import '../repository/dictionary_repository.dart';

class ParsedDictionary {
  const ParsedDictionary({required this.entries, this.name});

  final String? name;
  final List<DictionaryTranslation> entries;
}

/// Reads the two supported local dictionary formats.
///
/// JSON may be a word→definition map, a list of entry objects, or an object
/// with a `name` and `entries` list. CSV/TSV use `lemma` (or `word`) and
/// `meaning` (or `definition`) columns, with optional `pos` and `example`
/// columns. A headerless two-column file is treated as word, meaning.
class DictionaryFileParser {
  static ParsedDictionary parse(String content, {required String fileName}) {
    final text = content.startsWith('﻿') ? content.substring(1) : content;
    final lowerName = fileName.toLowerCase();
    final looksJson =
        lowerName.endsWith('.json') ||
        text.trimLeft().startsWith('{') ||
        text.trimLeft().startsWith('[');
    final parsed = looksJson
        ? _parseJson(text, fileName)
        : _parseDelimited(
            text,
            fileName,
            isTsv:
                lowerName.endsWith('.tsv') ||
                (text.contains('\t') && !text.contains(',')),
          );
    if (parsed.entries.isEmpty) {
      throw const FormatException('No dictionary entries were found.');
    }
    return parsed;
  }

  static ParsedDictionary _parseJson(String content, String fileName) {
    final decoded = jsonDecode(content);
    String? name;
    List<DictionaryTranslation> entries;
    if (decoded is List) {
      entries = _fromList(decoded);
    } else if (decoded is Map) {
      name = decoded['name']?.toString().trim();
      final listed = decoded['entries'] ?? decoded['words'];
      if (listed is List) {
        entries = _fromList(listed);
      } else if (listed is Map) {
        entries = _fromMap(listed);
      } else {
        entries = _fromMap(decoded);
      }
    } else {
      throw const FormatException('Unsupported dictionary JSON shape.');
    }
    return ParsedDictionary(
      name: name == null || name.isEmpty
          ? p.basenameWithoutExtension(fileName)
          : name,
      entries: _dedupe(entries),
    );
  }

  static ParsedDictionary _parseDelimited(
    String content,
    String fileName, {
    required bool isTsv,
  }) {
    final rows = isTsv
        ? [
            for (final line in const LineSplitter().convert(content))
              if (line.trim().isNotEmpty) line.split('\t'),
          ]
        : CsvService.parseCsv(content);
    if (rows.isEmpty) {
      throw const FormatException('Dictionary file is empty.');
    }
    final first = rows.first
        .map((value) => value.trim().toLowerCase())
        .toList();
    final hasHeader =
        (first.contains('lemma') || first.contains('word')) &&
        (first.contains('meaning') ||
            first.contains('definition') ||
            first.contains('translation'));
    int indexOf(List<String> names, int fallback) {
      for (final name in names) {
        final index = first.indexOf(name);
        if (index >= 0) return index;
      }
      return fallback;
    }

    final wordIndex = hasHeader ? indexOf(['lemma', 'word', 'term'], 0) : 0;
    final meaningIndex = hasHeader
        ? indexOf(['meaning', 'definition', 'translation'], 1)
        : 1;
    final posIndex = hasHeader
        ? indexOf(['pos', 'partofspeech', 'part_of_speech', 'type'], -1)
        : -1;
    final exampleIndex = hasHeader ? indexOf(['example', 'usage'], -1) : -1;

    String cell(List<String> row, int index) =>
        index >= 0 && index < row.length ? row[index].trim() : '';

    final entries = <DictionaryTranslation>[];
    for (final row in hasHeader ? rows.skip(1) : rows) {
      final word = cell(row, wordIndex);
      final meaning = cell(row, meaningIndex);
      if (word.isEmpty || meaning.isEmpty) continue;
      entries.add(
        DictionaryTranslation(
          lemma: word.toLowerCase(),
          meaning: meaning,
          partOfSpeech: cell(row, posIndex),
          example: cell(row, exampleIndex).isEmpty
              ? null
              : cell(row, exampleIndex),
        ),
      );
    }
    return ParsedDictionary(
      name: p.basenameWithoutExtension(fileName),
      entries: _dedupe(entries),
    );
  }

  static List<DictionaryTranslation> _fromList(List<dynamic> items) {
    final out = <DictionaryTranslation>[];
    for (final item in items) {
      if (item is String) continue;
      if (item is Map) {
        final word = ['lemma', 'word', 'term', 'headword']
            .map((key) => item[key])
            .whereType<String>()
            .firstWhere((value) => value.trim().isNotEmpty, orElse: () => '');
        if (word.isEmpty) continue;
        out.addAll(_translationsFor(word, item));
      }
    }
    return out;
  }

  static List<DictionaryTranslation> _fromMap(Map<dynamic, dynamic> map) {
    final out = <DictionaryTranslation>[];
    for (final entry in map.entries) {
      final word = entry.key.toString().trim();
      if (word.isEmpty || word == 'name' || word == 'entries') continue;
      final value = entry.value;
      if (value is String) {
        out.add(
          DictionaryTranslation(lemma: word.toLowerCase(), meaning: value),
        );
      } else if (value is List) {
        for (final item in value) {
          if (item is String) {
            out.add(
              DictionaryTranslation(lemma: word.toLowerCase(), meaning: item),
            );
          } else if (item is Map) {
            out.addAll(_translationsFor(word, item));
          }
        }
      } else if (value is Map) {
        out.addAll(_translationsFor(word, value));
      }
    }
    return out;
  }

  static List<DictionaryTranslation> _translationsFor(
    String word,
    Map<dynamic, dynamic> value,
  ) {
    final pos = ['partOfSpeech', 'part_of_speech', 'pos', 'type']
        .map((key) => value[key])
        .whereType<String>()
        .firstWhere((item) => item.trim().isNotEmpty, orElse: () => '');
    final example = value['example']?.toString();
    final direct = ['meaning', 'definition', 'translation', 'gloss', 'text']
        .map((key) => value[key])
        .whereType<String>()
        .firstWhere((item) => item.trim().isNotEmpty, orElse: () => '');
    if (direct.isNotEmpty) {
      return [
        DictionaryTranslation(
          lemma: word.toLowerCase(),
          meaning: direct.trim(),
          partOfSpeech: pos,
          example: example,
        ),
      ];
    }
    final nested = value['definitions'] ?? value['translations'];
    if (nested is List) {
      return [
        for (final item in nested)
          if (item is String && item.trim().isNotEmpty)
            DictionaryTranslation(
              lemma: word.toLowerCase(),
              meaning: item.trim(),
              partOfSpeech: pos,
              example: example,
            )
          else if (item is Map)
            ..._translationsFor(word, item),
      ];
    }
    return const [];
  }

  static List<DictionaryTranslation> _dedupe(
    List<DictionaryTranslation> entries,
  ) {
    final seen = <String>{};
    final out = <DictionaryTranslation>[];
    for (final entry in entries) {
      final lemma = entry.lemma.trim().toLowerCase();
      final meaning = entry.meaning.trim();
      if (lemma.isEmpty || meaning.isEmpty) continue;
      final key = '$lemma|${entry.partOfSpeech.trim()}|$meaning';
      if (!seen.add(key)) continue;
      out.add(
        DictionaryTranslation(
          lemma: lemma,
          meaning: meaning,
          partOfSpeech: entry.partOfSpeech.trim(),
          example: entry.example?.trim(),
        ),
      );
    }
    return out;
  }
}
