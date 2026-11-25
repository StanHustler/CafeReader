import 'dart:io';

import 'package:drift/drift.dart';
import 'package:sqlite3/sqlite3.dart' as raw;

import '../../core/database/app_database.dart';

class SnapshotInfo {
  const SnapshotInfo({
    required this.schemaVersion,
    required this.bookCount,
    required this.vocabularyCount,
    required this.reviewCount,
  });

  final int schemaVersion;
  final int bookCount;
  final int vocabularyCount;
  final int reviewCount;
}

class SnapshotException implements Exception {
  SnapshotException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Entity-level merge and full replacement for SQLite snapshots. The same
/// implementation is used by backup import and OneDrive sync, so both paths
/// obey identical conflict rules.
class SnapshotService {
  SnapshotService(this.db);

  final AppDatabase db;

  static const int currentSchemaVersion = 4;

  static const List<String> businessTables = [
    'books',
    'book_groups',
    'book_group_books',
    'dictionaries',
    'dictionary_entries',
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
  ];

  Future<SnapshotInfo> inspect(String path) async {
    if (!await File(path).exists()) {
      throw SnapshotException('Snapshot file does not exist.');
    }
    raw.Database? database;
    try {
      database = raw.sqlite3.open(path, mode: raw.OpenMode.readOnly);
      final version = database.select('PRAGMA user_version').first.values.first;
      final integrity = database
          .select('PRAGMA quick_check')
          .first
          .values
          .first
          .toString();
      if (integrity.toLowerCase() != 'ok') {
        throw SnapshotException('The snapshot database is damaged.');
      }
      final hasBooks =
          database
                  .select(
                    "SELECT COUNT(*) FROM sqlite_master "
                    "WHERE type='table' AND name='books'",
                  )
                  .first
                  .values
                  .first
              as int;
      if (hasBooks == 0) {
        throw SnapshotException(
          'The snapshot does not contain CafeReader data.',
        );
      }
      final schemaVersion = version as int;
      if (schemaVersion > currentSchemaVersion) {
        throw SnapshotException(
          'This backup was created by a newer version of CafeReader '
          '(database schema $schemaVersion).',
        );
      }
      if (schemaVersion < 1) {
        throw SnapshotException('Unsupported database schema version.');
      }
      int count(String table) {
        try {
          return database!
                  .select('SELECT COUNT(*) FROM $table')
                  .first
                  .values
                  .first
              as int;
        } catch (_) {
          return 0;
        }
      }

      return SnapshotInfo(
        schemaVersion: schemaVersion,
        bookCount: count('books'),
        vocabularyCount: count('vocabulary'),
        reviewCount: count('review_logs'),
      );
    } on SnapshotException {
      rethrow;
    } catch (error) {
      throw SnapshotException('Could not read the snapshot database: $error');
    } finally {
      database?.close();
    }
  }

  /// Merges every entity from [path] into the local database.
  ///
  /// Statuses and other mutable rows use a revision number, then a stable
  /// device-id tie break. This makes concurrent resolutions converge without
  /// trusting wall clocks. Review logs are unioned by id.
  Future<void> mergeFromFile(
    String path, {
    required String currentDeviceId,
  }) async {
    final localClientId = await _readLocalSetting('onedrive_client_id');
    final info = await inspect(path);
    if (info.schemaVersion < 1 || info.schemaVersion > currentSchemaVersion) {
      throw SnapshotException(
        'Snapshot database schema ${info.schemaVersion} is not supported.',
      );
    }
    await _attach(path, (alias) async {
      await db.transaction(() async {
        await db.customStatement('PRAGMA defer_foreign_keys = ON');
        await _merge(alias);
        await _purgeImplicitNewStatuses();
      });
    });
    await _preserveLocalIdentity(currentDeviceId, localClientId);
    await _notifyAllTables();
  }

  Future<void> replaceFromFile(
    String path, {
    required String currentDeviceId,
  }) async {
    final localClientId = await _readLocalSetting('onedrive_client_id');
    final info = await inspect(path);
    if (info.schemaVersion < 1 || info.schemaVersion > currentSchemaVersion) {
      throw SnapshotException(
        'This backup uses unsupported database schema '
        '${info.schemaVersion}.',
      );
    }
    await _attach(path, (alias) async {
      await db.transaction(() async {
        await db.customStatement('PRAGMA defer_foreign_keys = ON');
        await db.replaceAllDataFromAttached(alias);
        await _purgeImplicitNewStatuses();
      });
    });
    await _preserveLocalIdentity(currentDeviceId, localClientId);
    await _notifyAllTables();
  }

  /// Removes status rows that only encode the implicit New state. New is the
  /// default when no row exists, so these rows carry no information.
  Future<void> _purgeImplicitNewStatuses() async {
    await db.customStatement("DELETE FROM word_statuses WHERE status = 'NEW'");
  }

  Future<String?> _readLocalSetting(String key) async {
    final row = await (db.select(
      db.appSettings,
    )..where((table) => table.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> _preserveLocalIdentity(
    String currentDeviceId,
    String? localOneDriveClientId,
  ) async {
    final now = DateTime.now();
    if (localOneDriveClientId != null) {
      await db
          .into(db.appSettings)
          .insert(
            AppSettingsCompanion.insert(
              key: 'onedrive_client_id',
              value: localOneDriveClientId,
              updatedAt: now,
            ),
            mode: InsertMode.insertOrReplace,
          );
    }
    await db
        .into(db.appMetadata)
        .insert(
          AppMetadataCompanion.insert(
            key: 'device_id',
            value: currentDeviceId,
            updatedAt: now,
          ),
          mode: InsertMode.insertOrReplace,
        );
    await db
        .into(db.appMetadata)
        .insert(
          AppMetadataCompanion.insert(
            key: 'database_schema_version',
            value: '$currentSchemaVersion',
            updatedAt: now,
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<void> _attach(
    String path,
    Future<void> Function(String alias) action,
  ) async {
    final escaped = path.replaceAll("'", "''");
    try {
      await db.customStatement("ATTACH DATABASE '$escaped' AS remote");
      await action('remote');
    } finally {
      try {
        await db.customStatement('DETACH DATABASE remote');
      } catch (_) {
        // Detach can fail if an exception aborted the connection; the caller's
        // error is more relevant.
      }
    }
  }

  Future<void> _merge(String r) async {
    // Books.
    await db.customStatement(
      'INSERT OR IGNORE INTO main.books SELECT * FROM $r.books',
    );
    await db.customStatement('''
      UPDATE main.books AS b SET
        title = (SELECT title FROM $r.books x WHERE x.id = b.id),
        author = (SELECT author FROM $r.books x WHERE x.id = b.id),
        description = (SELECT description FROM $r.books x WHERE x.id = b.id),
        cover_path = (SELECT cover_path FROM $r.books x WHERE x.id = b.id),
        original_file_path = (SELECT original_file_path FROM $r.books x WHERE x.id = b.id),
        format = (SELECT format FROM $r.books x WHERE x.id = b.id),
        language = (SELECT language FROM $r.books x WHERE x.id = b.id),
        file_sha256 = (SELECT file_sha256 FROM $r.books x WHERE x.id = b.id),
        revision = (SELECT revision FROM $r.books x WHERE x.id = b.id),
        updated_by = (SELECT updated_by FROM $r.books x WHERE x.id = b.id),
        imported_at = (SELECT imported_at FROM $r.books x WHERE x.id = b.id),
        updated_at = (SELECT updated_at FROM $r.books x WHERE x.id = b.id),
        deleted_at = (SELECT deleted_at FROM $r.books x WHERE x.id = b.id)
      WHERE EXISTS (
        SELECT 1 FROM $r.books x WHERE x.id = b.id AND x.revision > b.revision
      )
    ''');

    // Groups arrived in schema 3. Older snapshots simply have no group tables.
    if (await _remoteHasTable(r, 'book_groups')) {
      await db.customStatement(
        'INSERT OR IGNORE INTO main.book_groups SELECT * FROM $r.book_groups',
      );
      await db.customStatement('''
        UPDATE main.book_groups AS g SET
          name = (SELECT name FROM $r.book_groups x WHERE x.id = g.id),
          updated_at = (SELECT updated_at FROM $r.book_groups x WHERE x.id = g.id)
        WHERE EXISTS (
          SELECT 1 FROM $r.book_groups x
          WHERE x.id = g.id AND x.updated_at > g.updated_at
        )
      ''');
    }
    if (await _remoteHasTable(r, 'book_group_books')) {
      await db.customStatement(
        'INSERT OR IGNORE INTO main.book_group_books '
        'SELECT * FROM $r.book_group_books',
      );
    }

    // Dictionaries arrived in schema 4. Entries from both devices are unioned;
    // metadata follows the newer updated_at.
    if (await _remoteHasTable(r, 'dictionaries')) {
      await db.customStatement(
        'INSERT OR IGNORE INTO main.dictionaries '
        'SELECT * FROM $r.dictionaries',
      );
      await db.customStatement('''
        UPDATE main.dictionaries AS d SET
          name = (SELECT name FROM $r.dictionaries x WHERE x.id = d.id),
          source = (SELECT source FROM $r.dictionaries x WHERE x.id = d.id),
          enabled = (SELECT enabled FROM $r.dictionaries x WHERE x.id = d.id),
          entry_count = (SELECT entry_count FROM $r.dictionaries x WHERE x.id = d.id),
          updated_at = (SELECT updated_at FROM $r.dictionaries x WHERE x.id = d.id)
        WHERE EXISTS (
          SELECT 1 FROM $r.dictionaries x
          WHERE x.id = d.id AND x.updated_at > d.updated_at
        )
      ''');
    }
    if (await _remoteHasTable(r, 'dictionary_entries')) {
      await db.customStatement(
        'INSERT OR IGNORE INTO main.dictionary_entries '
        'SELECT * FROM $r.dictionary_entries',
      );
    }

    // Chapters are immutable once imported, but revision protects future edits.
    await db.customStatement(
      'INSERT OR IGNORE INTO main.chapters SELECT * FROM $r.chapters',
    );
    await db.customStatement('''
      UPDATE main.chapters AS c SET
        title = (SELECT title FROM $r.chapters x WHERE x.id = c.id),
        content = (SELECT content FROM $r.chapters x WHERE x.id = c.id),
        content_hash = (SELECT content_hash FROM $r.chapters x WHERE x.id = c.id),
        revision = (SELECT revision FROM $r.chapters x WHERE x.id = c.id),
        updated_at = (SELECT updated_at FROM $r.chapters x WHERE x.id = c.id)
      WHERE EXISTS (
        SELECT 1 FROM $r.chapters x WHERE x.id = c.id AND x.revision > c.revision
      )
    ''');

    // Reading progress: unique by book+chapter, so match the natural key.
    await db.customStatement(
      'INSERT OR IGNORE INTO main.reading_progress SELECT * FROM $r.reading_progress',
    );
    await db.customStatement('''
      UPDATE main.reading_progress AS p SET
        anchor_paragraph = (SELECT anchor_paragraph FROM $r.reading_progress x
          WHERE x.book_id = p.book_id AND x.chapter_id = p.chapter_id),
        anchor_offset = (SELECT anchor_offset FROM $r.reading_progress x
          WHERE x.book_id = p.book_id AND x.chapter_id = p.chapter_id),
        cached_page_index = (SELECT cached_page_index FROM $r.reading_progress x
          WHERE x.book_id = p.book_id AND x.chapter_id = p.chapter_id),
        cached_page_count = (SELECT cached_page_count FROM $r.reading_progress x
          WHERE x.book_id = p.book_id AND x.chapter_id = p.chapter_id),
        layout_signature = (SELECT layout_signature FROM $r.reading_progress x
          WHERE x.book_id = p.book_id AND x.chapter_id = p.chapter_id),
        revision = (SELECT revision FROM $r.reading_progress x
          WHERE x.book_id = p.book_id AND x.chapter_id = p.chapter_id),
        updated_by = (SELECT updated_by FROM $r.reading_progress x
          WHERE x.book_id = p.book_id AND x.chapter_id = p.chapter_id),
        updated_at = (SELECT updated_at FROM $r.reading_progress x
          WHERE x.book_id = p.book_id AND x.chapter_id = p.chapter_id)
      WHERE EXISTS (
        SELECT 1 FROM $r.reading_progress x
        WHERE x.book_id = p.book_id AND x.chapter_id = p.chapter_id
          AND (
            x.revision > p.revision OR
            (x.revision = p.revision AND
              COALESCE(x.updated_by, '') > COALESCE(p.updated_by, ''))
          )
      )
    ''');

    // Pagination caches are reconstructible; local cache wins on collision.
    await db.customStatement(
      'INSERT OR IGNORE INTO main.pagination_caches SELECT * FROM $r.pagination_caches',
    );

    await db.customStatement(
      'INSERT OR IGNORE INTO main.vocabulary SELECT * FROM $r.vocabulary',
    );
    await db.customStatement('''
      UPDATE main.vocabulary AS v SET
        lemma = (SELECT lemma FROM $r.vocabulary x WHERE x.id = v.id),
        language = (SELECT language FROM $r.vocabulary x WHERE x.id = v.id),
        sense_label = (SELECT sense_label FROM $r.vocabulary x WHERE x.id = v.id),
        updated_at = (SELECT updated_at FROM $r.vocabulary x WHERE x.id = v.id)
      WHERE EXISTS (
        SELECT 1 FROM $r.vocabulary x
        WHERE x.id = v.id AND x.updated_at > v.updated_at
      )
    ''');

    // Schema 1 snapshots also carry a `source` column in these tables; only
    // copy the columns that still exist so old backups remain importable.
    await db.customStatement(
      'INSERT OR IGNORE INTO main.word_forms '
      '(id, surface_form, normalized_form, vocabulary_id, confidence, '
      'is_verified, is_primary, created_at) '
      'SELECT id, surface_form, normalized_form, vocabulary_id, confidence, '
      'is_verified, is_primary, created_at FROM $r.word_forms',
    );
    // A surface form must have at most one default mapping. If two devices
    // promoted different senses concurrently, converge on the smallest id.
    await db.customStatement('''
      UPDATE main.word_forms SET is_primary = 0
      WHERE is_primary = 1 AND id NOT IN (
        SELECT MIN(id) FROM main.word_forms
        WHERE is_primary = 1 GROUP BY surface_form
      )
    ''');

    await db.customStatement(
      'INSERT OR IGNORE INTO main.word_occurrences SELECT * FROM $r.word_occurrences',
    );
    await db.customStatement('''
      UPDATE main.word_occurrences AS o SET
        vocabulary_id = (SELECT vocabulary_id FROM $r.word_occurrences x WHERE x.id = o.id),
        override_vocabulary_id = (SELECT override_vocabulary_id FROM $r.word_occurrences x WHERE x.id = o.id),
        is_manually_corrected = (SELECT is_manually_corrected FROM $r.word_occurrences x WHERE x.id = o.id),
        revision = (SELECT revision FROM $r.word_occurrences x WHERE x.id = o.id),
        updated_by = (SELECT updated_by FROM $r.word_occurrences x WHERE x.id = o.id),
        updated_at = (SELECT updated_at FROM $r.word_occurrences x WHERE x.id = o.id)
      WHERE EXISTS (
        SELECT 1 FROM $r.word_occurrences x WHERE x.id = o.id AND (
          x.revision > o.revision OR
          (x.revision = o.revision AND
            COALESCE(x.updated_by, '') > COALESCE(o.updated_by, ''))
        )
      )
    ''');

    await db.customStatement(
      'INSERT OR IGNORE INTO main.word_statuses '
      '(vocabulary_id, status, revision, updated_by, updated_at) '
      'SELECT vocabulary_id, status, revision, updated_by, updated_at '
      'FROM $r.word_statuses',
    );
    await db.customStatement('''
      UPDATE main.word_statuses AS s SET
        status = (SELECT status FROM $r.word_statuses x
          WHERE x.vocabulary_id = s.vocabulary_id),
        revision = (SELECT revision FROM $r.word_statuses x
          WHERE x.vocabulary_id = s.vocabulary_id),
        updated_by = (SELECT updated_by FROM $r.word_statuses x
          WHERE x.vocabulary_id = s.vocabulary_id),
        updated_at = (SELECT updated_at FROM $r.word_statuses x
          WHERE x.vocabulary_id = s.vocabulary_id)
      WHERE EXISTS (
        SELECT 1 FROM $r.word_statuses x
        WHERE x.vocabulary_id = s.vocabulary_id AND (
          x.revision > s.revision OR
          (x.revision = s.revision AND
            COALESCE(x.updated_by, '') > COALESCE(s.updated_by, ''))
        )
      )
    ''');

    await db.customStatement(
      'INSERT OR IGNORE INTO main.definitions '
      '(id, vocabulary_id, language, meaning, example, revision, '
      'updated_by, updated_at) '
      'SELECT id, vocabulary_id, language, meaning, example, revision, '
      'updated_by, updated_at FROM $r.definitions',
    );
    await db.customStatement('''
      UPDATE main.definitions AS d SET
        meaning = (SELECT meaning FROM $r.definitions x WHERE x.id = d.id),
        example = (SELECT example FROM $r.definitions x WHERE x.id = d.id),
        revision = (SELECT revision FROM $r.definitions x WHERE x.id = d.id),
        updated_by = (SELECT updated_by FROM $r.definitions x WHERE x.id = d.id),
        updated_at = (SELECT updated_at FROM $r.definitions x WHERE x.id = d.id)
      WHERE EXISTS (
        SELECT 1 FROM $r.definitions x WHERE x.id = d.id AND (
          x.revision > d.revision OR
          (x.revision = d.revision AND
            COALESCE(x.updated_by, '') > COALESCE(d.updated_by, ''))
        )
      )
    ''');
    await db.customStatement('''
      DELETE FROM main.definitions
      WHERE id NOT IN (
        SELECT MIN(id) FROM main.definitions
        GROUP BY vocabulary_id, meaning
      )
    ''');

    await db.customStatement(
      'INSERT OR IGNORE INTO main.fsrs_cards SELECT * FROM $r.fsrs_cards',
    );
    await db.customStatement('''
      UPDATE main.fsrs_cards AS f SET
        state = (SELECT state FROM $r.fsrs_cards x WHERE x.vocabulary_id = f.vocabulary_id),
        due = (SELECT due FROM $r.fsrs_cards x WHERE x.vocabulary_id = f.vocabulary_id),
        stability = (SELECT stability FROM $r.fsrs_cards x WHERE x.vocabulary_id = f.vocabulary_id),
        difficulty = (SELECT difficulty FROM $r.fsrs_cards x WHERE x.vocabulary_id = f.vocabulary_id),
        elapsed_days = (SELECT elapsed_days FROM $r.fsrs_cards x WHERE x.vocabulary_id = f.vocabulary_id),
        scheduled_days = (SELECT scheduled_days FROM $r.fsrs_cards x WHERE x.vocabulary_id = f.vocabulary_id),
        reps = (SELECT reps FROM $r.fsrs_cards x WHERE x.vocabulary_id = f.vocabulary_id),
        lapses = (SELECT lapses FROM $r.fsrs_cards x WHERE x.vocabulary_id = f.vocabulary_id),
        last_review = (SELECT last_review FROM $r.fsrs_cards x WHERE x.vocabulary_id = f.vocabulary_id),
        revision = (SELECT revision FROM $r.fsrs_cards x WHERE x.vocabulary_id = f.vocabulary_id),
        updated_by = (SELECT updated_by FROM $r.fsrs_cards x WHERE x.vocabulary_id = f.vocabulary_id),
        updated_at = (SELECT updated_at FROM $r.fsrs_cards x WHERE x.vocabulary_id = f.vocabulary_id)
      WHERE EXISTS (
        SELECT 1 FROM $r.fsrs_cards x
        WHERE x.vocabulary_id = f.vocabulary_id AND (
          x.revision > f.revision OR
          (x.revision = f.revision AND
            COALESCE(x.updated_by, '') > COALESCE(f.updated_by, ''))
        )
      )
    ''');

    await db.customStatement(
      'INSERT OR IGNORE INTO main.review_logs SELECT * FROM $r.review_logs',
    );

    await db.customStatement(
      'INSERT OR IGNORE INTO main.app_settings SELECT * FROM $r.app_settings',
    );
    await db.customStatement('''
      UPDATE main.app_settings AS a SET
        value = (SELECT value FROM $r.app_settings x WHERE x.key = a.key),
        updated_at = (SELECT updated_at FROM $r.app_settings x WHERE x.key = a.key)
      WHERE EXISTS (
        SELECT 1 FROM $r.app_settings x
        WHERE x.key = a.key AND x.updated_at > a.updated_at
      )
    ''');

    await db.customStatement(
      'INSERT OR IGNORE INTO main.app_metadata SELECT * FROM $r.app_metadata',
    );
    await db.customStatement(
      'INSERT OR IGNORE INTO main.sync_metadata SELECT * FROM $r.sync_metadata',
    );
  }

  Future<bool> _remoteHasTable(String alias, String table) async {
    final rows = await db
        .customSelect(
          "SELECT name FROM $alias.sqlite_master "
          "WHERE type = 'table' AND name = ?",
          variables: [Variable(table)],
        )
        .get();
    return rows.isNotEmpty;
  }

  Future<void> _notifyAllTables() async {
    db.markTablesUpdated([
      db.books,
      db.bookGroups,
      db.bookGroupBooks,
      db.dictionaries,
      db.dictionaryEntries,
      db.chapters,
      db.readingProgress,
      db.paginationCaches,
      db.vocabulary,
      db.wordForms,
      db.wordOccurrences,
      db.wordStatuses,
      db.definitions,
      db.fsrsCards,
      db.reviewLogs,
      db.appSettings,
      db.appMetadata,
      db.syncMetadata,
    ]);
  }
}
