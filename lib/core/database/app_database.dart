import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Books,
    BookGroups,
    BookGroupBooks,
    Dictionaries,
    DictionaryEntries,
    Chapters,
    ReadingProgress,
    PaginationCaches,
    Vocabulary,
    WordForms,
    WordOccurrences,
    WordStatuses,
    Definitions,
    FsrsCards,
    ReviewLogs,
    AppSettings,
    AppMetadata,
    SyncMetadata,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  AppDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _createIndexes();
      await _seedMetadata();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // Schema 2 no longer records where a word status, definition, or word
        // form came from. Old snapshots still carry these columns; their
        // readers project only the columns that still exist.
        await m.dropColumn(wordForms, 'source');
        await m.dropColumn(wordStatuses, 'source');
        await m.dropColumn(definitions, 'source');
        await _writeSchemaVersion();
      }
      if (from < 3) {
        // Schema 3 adds user-created book groups.
        await m.createTable(bookGroups);
        await m.createTable(bookGroupBooks);
        await _writeSchemaVersion();
      }
      if (from < 4) {
        // Schema 4 adds importable local and online dictionaries.
        await m.createTable(dictionaries);
        await m.createTable(dictionaryEntries);
        await _writeSchemaVersion();
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA journal_mode = WAL');
      await customStatement('PRAGMA synchronous = NORMAL');
      // Indexes are created here as well so databases created by older builds
      // pick up new indexes without a schema version bump.
      await _createIndexes();
      // New is the implicit default state: a vocabulary entry without a status
      // row is New. Older builds stored explicit NEW rows; remove them so the
      // database only ever stores Learning and Known states.
      await _purgeImplicitNewStatuses();
    },
  );

  Future<void> _createIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_occurrences_book_chapter '
      'ON word_occurrences(book_id, chapter_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_occurrences_chapter_vocab '
      'ON word_occurrences(chapter_id, vocabulary_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_occurrences_vocab_override_book '
      'ON word_occurrences(vocabulary_id, override_vocabulary_id, book_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_occurrences_override_book '
      'ON word_occurrences(override_vocabulary_id, book_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_forms_normalized '
      'ON word_forms(normalized_form)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_forms_vocab ON word_forms(vocabulary_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_status_status ON word_statuses(status)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_fsrs_due ON fsrs_cards(due)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sync_status ON sync_metadata(sync_status)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_books_deleted ON books(deleted_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_chapters_book ON chapters(book_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_review_logs_vocab '
      'ON review_logs(vocabulary_id, reviewed_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_definitions_vocab '
      'ON definitions(vocabulary_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_reading_progress_book '
      'ON reading_progress(book_id, updated_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_book_group_books_group '
      'ON book_group_books(group_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_book_group_books_book '
      'ON book_group_books(book_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_dictionary_entries_lemma '
      'ON dictionary_entries(lemma COLLATE NOCASE, dictionary_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_dictionary_entries_dictionary '
      'ON dictionary_entries(dictionary_id)',
    );
  }

  Future<void> _purgeImplicitNewStatuses() async {
    await customStatement("DELETE FROM word_statuses WHERE status = 'NEW'");
  }

  Future<void> _writeSchemaVersion() async {
    await into(appMetadata).insert(
      AppMetadataCompanion.insert(
        key: 'database_schema_version',
        value: '$schemaVersion',
        updatedAt: DateTime.now(),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> _seedMetadata() async {
    final now = DateTime.now();
    await batch((batch) {
      batch.insertAll(appMetadata, [
        AppMetadataCompanion.insert(
          key: 'database_schema_version',
          value: '$schemaVersion',
          updatedAt: now,
        ),
        AppMetadataCompanion.insert(
          key: 'backup_format_version',
          value: '1',
          updatedAt: now,
        ),
        AppMetadataCompanion.insert(
          key: 'data_version',
          value: '1',
          updatedAt: now,
        ),
      ]);
    });
  }

  /// Produces a consistent SQLite snapshot, including committed WAL data.
  Future<void> snapshotTo(String path) async {
    await customStatement('PRAGMA wal_checkpoint(FULL)');
    final escaped = path.replaceAll("'", "''");
    await customStatement("VACUUM INTO '$escaped'");
  }

  /// Copies every application table from an attached snapshot into this
  /// database. Callers own the transaction.
  Future<void> replaceAllDataFromAttached(String schema) async {
    const tables = [
      'books',
      'book_groups',
      'book_group_books',
      'chapters',
      'reading_progress',
      'pagination_caches',
      'vocabulary',
      'word_forms',
      'word_occurrences',
      'word_statuses',
      'definitions',
      'fsrs_cards',
      'review_logs',
      'app_settings',
      'app_metadata',
      'sync_metadata',
      'dictionaries',
      'dictionary_entries',
    ];
    // Snapshots produced before schema 2 still have a `source` column in these
    // tables. Project the shared columns explicitly so both formats load.
    const explicitColumns = {
      'word_forms':
          'id, surface_form, normalized_form, vocabulary_id, confidence, '
          'is_verified, is_primary, created_at',
      'word_statuses':
          'vocabulary_id, status, revision, updated_by, updated_at',
      'definitions':
          'id, vocabulary_id, language, meaning, example, revision, '
          'updated_by, updated_at',
    };
    await customStatement('PRAGMA defer_foreign_keys = ON');
    final remoteTables = (await customSelect(
      "SELECT name FROM $schema.sqlite_master WHERE type = 'table'",
    ).get()).map((row) => row.read<String>('name')).toSet();
    for (final table in tables.reversed) {
      await customStatement('DELETE FROM main.$table');
    }
    for (final table in tables) {
      // Snapshots written before schema 3 do not contain the group tables.
      if (!remoteTables.contains(table)) continue;
      final columns = explicitColumns[table];
      if (columns == null) {
        await customStatement(
          'INSERT INTO main.$table SELECT * FROM $schema.$table',
        );
      } else {
        await customStatement(
          'INSERT INTO main.$table ($columns) '
          'SELECT $columns FROM $schema.$table',
        );
      }
    }
  }

  static Future<AppDatabase> open() async {
    final dir = await getApplicationSupportDirectory();
    final dbDir = Directory(p.join(dir.path, 'CafeReader'));
    await dbDir.create(recursive: true);
    return openAt(p.join(dbDir.path, 'cafereader.sqlite'));
  }

  static Future<AppDatabase> openAt(String path) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    return AppDatabase(
      NativeDatabase.createInBackground(
        file,
        setup: (db) {
          db.execute('PRAGMA journal_mode = WAL');
        },
      ),
    );
  }
}
