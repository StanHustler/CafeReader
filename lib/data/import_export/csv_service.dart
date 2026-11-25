import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../repository/vocabulary_repository.dart';

enum CsvConflictPolicy { keepExisting, updateStatus }

class CsvImportResult {
  const CsvImportResult({
    required this.imported,
    required this.updated,
    required this.skipped,
    required this.createdVocabulary,
  });

  final int imported;
  final int updated;
  final int skipped;
  final int createdVocabulary;
}

class DictionaryImportResult {
  const DictionaryImportResult({
    required this.added,
    required this.skipped,
    required this.missingWords,
  });

  final int added;
  final int skipped;
  final int missingWords;
}

class CsvService {
  CsvService(this.db);

  final AppDatabase db;

  Future<String> exportVocabulary() async {
    const sql = '''
      SELECT v.lemma, v.sense_label, COALESCE(s.status, 'NEW') AS status,
        COALESCE(s.updated_at, v.updated_at) AS updated_at,
        (SELECT d.meaning FROM definitions d WHERE d.vocabulary_id = v.id
          ORDER BY d.updated_at DESC LIMIT 1) AS meaning,
        v.created_at
      FROM vocabulary v
      LEFT JOIN word_statuses s ON s.vocabulary_id = v.id
      ORDER BY v.lemma COLLATE NOCASE, v.sense_label
    ''';
    final rows = await db.customSelect(sql).get();
    final out = StringBuffer('lemma,status,meaning,created_at,sense_label\r\n');
    for (final row in rows) {
      final createdAt = row.read<int>('created_at');
      out
        ..write(_escape(row.read<String>('lemma')))
        ..write(',')
        ..write(_escape(row.read<String>('status')))
        ..write(',')
        ..write(_escape(row.read<String?>('meaning') ?? ''))
        ..write(',')
        ..write(
          _escape(
            DateTime.fromMillisecondsSinceEpoch(createdAt * 1000)
                .toIso8601String(),
          ),
        )
        ..write(',')
        ..write(_escape(row.read<String?>('sense_label') ?? ''))
        ..write('\r\n');
    }
    // BOM helps spreadsheet applications detect UTF-8.
    return '﻿$out';
  }

  Future<CsvImportResult> importVocabulary(
    String csv, {
    CsvConflictPolicy policy = CsvConflictPolicy.keepExisting,
  }) async {
    final records = parseCsv(csv);
    if (records.isEmpty) {
      throw const FormatException('The CSV file is empty.');
    }
    final headers = records.first
        .map((header) => header.trim().toLowerCase())
        .toList();
    final lemmaIndex = headers.indexOf('lemma');
    if (lemmaIndex < 0) {
      throw const FormatException('CSV must contain a "lemma" column.');
    }
    final statusIndex = headers.indexOf('status');
    final meaningIndex = headers.indexOf('meaning');
    final createdAtIndex = headers.indexOf('created_at');
    final senseIndex = headers.indexOf('sense_label');
    var imported = 0;
    var updated = 0;
    var skipped = 0;
    var created = 0;
    final now = DateTime.now();
    await db.transaction(() async {
      for (final record in records.skip(1)) {
        if (record.isEmpty) continue;
        String cell(int index) =>
            index >= 0 && index < record.length ? record[index].trim() : '';
        final lemma = cell(lemmaIndex).toLowerCase();
        if (lemma.isEmpty) {
          skipped++;
          continue;
        }
        final meaning = cell(meaningIndex);
        final senseLabel = cell(senseIndex);
        final statusRaw = cell(statusIndex).toLowerCase();
        final state = switch (statusRaw) {
          'known' => VocabularyState.known,
          'learning' => VocabularyState.learning,
          'new' => VocabularyState.newWord,
          _ => null,
        };
        var vocabulary =
            await (db.select(db.vocabulary)
                  ..where(
                    (table) =>
                        table.lemma.equals(lemma) &
                        (senseLabel.isEmpty
                            ? table.senseLabel.isNull()
                            : table.senseLabel.equals(senseLabel)),
                  )
                  ..limit(1))
                .getSingleOrNull();
        if (vocabulary == null) {
          final id = const Uuid().v5(
            Namespace.url.value,
            'cafereader:vocab:en:$lemma',
          );
          final byId = await (db.select(
            db.vocabulary,
          )..where((table) => table.id.equals(id))).getSingleOrNull();
          if (byId != null) {
            vocabulary = byId;
          } else {
            await db
                .into(db.vocabulary)
                .insert(
                  VocabularyCompanion.insert(
                    id: id,
                    lemma: lemma,
                    senseLabel: Value(senseLabel.isEmpty ? null : senseLabel),
                    createdAt: now,
                    updatedAt: now,
                  ),
                );
            vocabulary = await (db.select(
              db.vocabulary,
            )..where((table) => table.id.equals(id))).getSingle();
            created++;
          }
        }
        final resolvedVocabulary = vocabulary;
        final currentStatus =
            await (db.select(db.wordStatuses)..where(
                  (table) => table.vocabularyId.equals(resolvedVocabulary.id),
                ))
                .getSingleOrNull();
        if (state == null) {
          skipped++;
        } else if (state == VocabularyState.newWord) {
          // New is the implicit default; only an explicit update request has
          // to remove a previously stored row.
          if (currentStatus != null &&
              policy == CsvConflictPolicy.updateStatus) {
            await (db.delete(db.wordStatuses)..where(
                  (table) => table.vocabularyId.equals(resolvedVocabulary.id),
                ))
                .go();
            updated++;
          } else {
            skipped++;
          }
        } else if (currentStatus == null) {
          await db
              .into(db.wordStatuses)
              .insert(
                WordStatusesCompanion.insert(
                  vocabularyId: resolvedVocabulary.id,
                  status: state.dbValue,
                  updatedAt: now,
                ),
                mode: InsertMode.insertOrIgnore,
              );
          updated++;
        } else if (policy == CsvConflictPolicy.updateStatus) {
          await (db.update(db.wordStatuses)..where(
                (table) => table.vocabularyId.equals(resolvedVocabulary.id),
              ))
              .write(
                WordStatusesCompanion(
                  status: Value(state.dbValue),
                  revision: Value(currentStatus.revision + 1),
                  updatedAt: Value(now),
                ),
              );
          updated++;
        } else {
          skipped++;
        }
        if (state == VocabularyState.learning) {
          final card =
              await (db.select(db.fsrsCards)..where(
                    (table) => table.vocabularyId.equals(resolvedVocabulary.id),
                  ))
                  .getSingleOrNull();
          if (card == null) {
            await db
                .into(db.fsrsCards)
                .insert(
                  FsrsCardsCompanion.insert(
                    vocabularyId: resolvedVocabulary.id,
                    state: 'new',
                    due: now,
                    updatedAt: now,
                  ),
                );
          }
        }
        if (meaning.isNotEmpty) {
          final duplicate =
              await (db.select(db.definitions)..where(
                    (table) =>
                        table.vocabularyId.equals(resolvedVocabulary.id) &
                        table.meaning.equals(meaning),
                  ))
                  .getSingleOrNull();
          if (duplicate == null) {
            await db
                .into(db.definitions)
                .insert(
                  DefinitionsCompanion.insert(
                    id: const Uuid().v4(),
                    vocabularyId: resolvedVocabulary.id,
                    meaning: meaning,
                    updatedAt: now,
                  ),
                );
          }
        }
        imported++;
        // createdAt is accepted as metadata but not used to rewrite history.
        if (createdAtIndex >= 0) cell(createdAtIndex);
      }
    });
    return CsvImportResult(
      imported: imported,
      updated: updated,
      skipped: skipped,
      createdVocabulary: created,
    );
  }

  Future<DictionaryImportResult> importDictionary(
    String pathOrContent, {
    bool isJson = false,
  }) async {
    final raw = pathOrContent;
    final entries = <_DictionaryEntry>[];
    if (isJson) {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        for (final entry in decoded.entries) {
          final lemma = entry.key.toString().toLowerCase().trim();
          final value = entry.value;
          if (lemma.isEmpty) continue;
          if (value is String) {
            entries.add(_DictionaryEntry(lemma: lemma, meaning: value));
          } else if (value is Map) {
            entries.add(
              _DictionaryEntry(
                lemma: lemma,
                meaning: (value['meaning'] ?? value['definition'] ?? '')
                    .toString(),
                example: value['example']?.toString(),
              ),
            );
          }
        }
      } else if (decoded is List) {
        for (final item in decoded) {
          if (item is! Map) continue;
          final lemma = (item['lemma'] ?? item['word'] ?? '').toString().trim();
          final meaning = (item['meaning'] ?? item['definition'] ?? '')
              .toString()
              .trim();
          if (lemma.isEmpty || meaning.isEmpty) continue;
          entries.add(
            _DictionaryEntry(
              lemma: lemma.toLowerCase(),
              meaning: meaning,
              example: item['example']?.toString(),
            ),
          );
        }
      } else {
        throw const FormatException('Unsupported dictionary JSON shape.');
      }
    } else {
      final records = parseCsv(raw);
      if (records.isEmpty) {
        throw const FormatException('Dictionary file is empty.');
      }
      final headers = records.first.map((h) => h.trim().toLowerCase()).toList();
      final lemmaIndex = headers.indexOf('lemma');
      final meaningIndex = headers.indexOf('meaning');
      if (lemmaIndex < 0 || meaningIndex < 0) {
        throw const FormatException(
          'Dictionary CSV needs "lemma" and "meaning" columns.',
        );
      }
      final exampleIndex = headers.indexOf('example');
      for (final row in records.skip(1)) {
        if (row.length <= lemmaIndex) continue;
        final lemma = row[lemmaIndex].trim().toLowerCase();
        final meaning = row[meaningIndex].trim();
        if (lemma.isEmpty || meaning.isEmpty) continue;
        entries.add(
          _DictionaryEntry(
            lemma: lemma,
            meaning: meaning,
            example: exampleIndex >= 0 && exampleIndex < row.length
                ? row[exampleIndex].trim()
                : null,
          ),
        );
      }
    }
    var added = 0;
    var skipped = 0;
    var missingWords = 0;
    final now = DateTime.now();
    await db.transaction(() async {
      for (final entry in entries) {
        final vocabulary =
            await (db.select(db.vocabulary)
                  ..where(
                    (table) =>
                        table.lemma.equals(entry.lemma) &
                        table.senseLabel.isNull(),
                  )
                  ..limit(1))
                .getSingleOrNull();
        if (vocabulary == null) {
          missingWords++;
          continue;
        }
        final duplicate =
            await (db.select(db.definitions)..where(
                  (table) =>
                      table.vocabularyId.equals(vocabulary.id) &
                      table.meaning.equals(entry.meaning),
                ))
                .getSingleOrNull();
        if (duplicate != null) {
          skipped++;
          continue;
        }
        await db
            .into(db.definitions)
            .insert(
              DefinitionsCompanion.insert(
                id: const Uuid().v4(),
                vocabularyId: vocabulary.id,
                meaning: entry.meaning,
                example: Value(entry.example),
                updatedAt: now,
              ),
            );
        added++;
      }
    });
    return DictionaryImportResult(
      added: added,
      skipped: skipped,
      missingWords: missingWords,
    );
  }

  static List<List<String>> parseCsv(String input) {
    final rows = <List<String>>[];
    var row = <String>[];
    final field = StringBuffer();
    var inQuotes = false;
    var i = 0;
    var text = input;
    if (text.startsWith('﻿')) text = text.substring(1);
    while (i < text.length) {
      final char = text[i];
      if (inQuotes) {
        if (char == '"') {
          if (i + 1 < text.length && text[i + 1] == '"') {
            field.write('"');
            i += 2;
            continue;
          }
          inQuotes = false;
        } else {
          field.write(char);
        }
      } else {
        if (char == '"') {
          inQuotes = true;
        } else if (char == ',') {
          row.add(field.toString());
          field.clear();
        } else if (char == '\n') {
          row.add(field.toString());
          field.clear();
          if (row.any((value) => value.isNotEmpty)) rows.add(row);
          row = <String>[];
        } else if (char == '\r') {
          // Consumed as part of CRLF.
        } else {
          field.write(char);
        }
      }
      i++;
    }
    row.add(field.toString());
    if (row.any((value) => value.isNotEmpty)) rows.add(row);
    return rows;
  }

  static String _escape(String value) {
    final safe = value.replaceAll('\r\n', '\n');
    if (safe.contains(',') ||
        safe.contains('"') ||
        safe.contains('\n') ||
        safe.contains('\r')) {
      return '"${safe.replaceAll('"', '""')}"';
    }
    return safe;
  }
}

class _DictionaryEntry {
  const _DictionaryEntry({
    required this.lemma,
    required this.meaning,
    this.example,
  });
  final String lemma;
  final String meaning;
  final String? example;
}
