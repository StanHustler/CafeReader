import 'dart:io';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../../core/util/app_storage.dart';

/// Ordering options offered by the library header.
enum LibrarySort {
  recentlyRead('Recently read'),
  recentlyAdded('Recently added'),
  title('Title A–Z'),
  author('Author A–Z');

  const LibrarySort(this.label);

  final String label;
}

class BookListItem {
  const BookListItem({
    required this.book,
    required this.chapterCount,
    this.currentChapterTitle,
    this.currentChapterIndex,
    this.pageIndex = 0,
    this.pageCount = 1,
    this.lastReadAt,
  });

  final Book book;
  final int chapterCount;
  final String? currentChapterTitle;
  final int? currentChapterIndex;
  final int pageIndex;
  final int pageCount;
  final DateTime? lastReadAt;

  double get progress {
    if (chapterCount <= 0 ||
        lastReadAt == null ||
        currentChapterIndex == null) {
      return 0;
    }
    final index = currentChapterIndex!;
    final pageFraction = pageCount <= 0 ? 0.0 : (pageIndex + 1) / pageCount;
    return ((index + pageFraction) / chapterCount).clamp(0.0, 1.0);
  }
}

/// The minimum a group card needs to draw one of its four cover thumbnails.
class GroupCoverBook {
  const GroupCoverBook({
    required this.id,
    required this.title,
    required this.coverPath,
  });

  final String id;
  final String title;
  final String? coverPath;
}

/// A user-created group together with the numbers and covers its library card
/// needs. Members are ordered by when they were added, newest first.
class BookGroupSummary {
  const BookGroupSummary({
    required this.id,
    required this.name,
    required this.bookCount,
    required this.covers,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final int bookCount;
  final List<GroupCoverBook> covers;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class _GroupBuilder {
  _GroupBuilder({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<GroupCoverBook> covers = [];
  int bookCount = 0;
}

class ChapterListItem {
  const ChapterListItem({
    required this.id,
    required this.bookId,
    required this.title,
    required this.chapterIndex,
    required this.updatedAt,
    required this.stats,
    this.pageIndex,
    this.pageCount,
    this.hasProgress = false,
  });

  final String id;
  final String bookId;
  final String title;
  final int chapterIndex;
  final DateTime updatedAt;
  final ChapterVocabularyStats stats;
  final int? pageIndex;
  final int? pageCount;
  final bool hasProgress;
}

class ChapterVocabularyStats {
  const ChapterVocabularyStats({
    this.known = 0,
    this.learning = 0,
    this.total = 0,
  });

  final int known;
  final int learning;
  final int total;
}

class VocabularyStats {
  const VocabularyStats({this.known = 0, this.learning = 0, this.total = 0});

  final int known;
  final int learning;
  final int total;
}

class ReadingAnchor {
  const ReadingAnchor({
    required this.bookId,
    required this.chapterId,
    required this.anchorParagraph,
    required this.anchorOffset,
    required this.cachedPageIndex,
    required this.cachedPageCount,
    this.layoutSignature,
    required this.updatedAt,
  });

  final String bookId;
  final String chapterId;
  final int anchorParagraph;
  final int anchorOffset;
  final int cachedPageIndex;
  final int cachedPageCount;
  final String? layoutSignature;
  final DateTime updatedAt;
}

class LibraryRepository {
  LibraryRepository(this.db, this.storage, this.deviceId);

  final AppDatabase db;
  final AppStorage storage;
  final String deviceId;

  Stream<List<BookListItem>> watchLibrary({
    String query = '',
    LibrarySort sort = LibrarySort.recentlyRead,
    String? groupId,
    bool excludeGrouped = false,
  }) {
    final normalized = query.trim();
    final sql = StringBuffer('''
      SELECT b.*,
        (SELECT COUNT(*) FROM chapters cc WHERE cc.book_id = b.id) AS chapter_count,
        c.title AS current_chapter_title,
        c.chapter_index AS current_chapter_index,
        r.cached_page_index AS current_page_index,
        r.cached_page_count AS current_page_count,
        r.updated_at AS last_read_at
      FROM books b
      LEFT JOIN reading_progress r ON r.id = (
        SELECT id FROM reading_progress rp
        WHERE rp.book_id = b.id ORDER BY rp.updated_at DESC LIMIT 1
      )
      LEFT JOIN chapters c ON c.id = r.chapter_id
      WHERE b.deleted_at IS NULL
    ''');
    final variables = <Variable<Object>>[];
    if (normalized.isNotEmpty) {
      sql.write(' AND (b.title LIKE ? OR COALESCE(b.author, \'\') LIKE ?)');
      variables.add(Variable('%$normalized%'));
      variables.add(Variable('%$normalized%'));
    }
    if (groupId != null) {
      sql.write(
        ' AND EXISTS (SELECT 1 FROM book_group_books gb '
        'WHERE gb.group_id = ? AND gb.book_id = b.id)',
      );
      variables.add(Variable(groupId));
    } else if (excludeGrouped) {
      sql.write(
        ' AND NOT EXISTS (SELECT 1 FROM book_group_books gb '
        'WHERE gb.book_id = b.id)',
      );
    }
    sql.write(' ORDER BY ${_orderBy(sort)}');
    return db
        .customSelect(
          sql.toString(),
          variables: variables,
          readsFrom: {
            db.books,
            db.chapters,
            db.readingProgress,
            db.bookGroupBooks,
          },
        )
        .watch()
        .map((rows) => rows.map(_mapBookRow).toList());
  }

  /// Watches every group with its live book count and up to four covers for
  /// the library card. Soft-deleted books are ignored.
  Stream<List<BookGroupSummary>> watchGroups() {
    const sql = '''
      SELECT g.id AS group_id, g.name AS group_name,
        g.created_at AS group_created_at, g.updated_at AS group_updated_at,
        b.id AS book_id, b.title AS book_title, b.cover_path AS book_cover_path,
        m.added_at AS added_at
      FROM book_groups g
      LEFT JOIN book_group_books m ON m.group_id = g.id
      LEFT JOIN books b ON b.id = m.book_id AND b.deleted_at IS NULL
      ORDER BY g.updated_at DESC, g.name COLLATE NOCASE ASC, m.added_at DESC
    ''';
    return db
        .customSelect(
          sql,
          readsFrom: {db.bookGroups, db.bookGroupBooks, db.books},
        )
        .watch()
        .map(_mapGroupRows);
  }

  Stream<BookGroupSummary?> watchGroup(String groupId) {
    const sql = '''
      SELECT g.id AS group_id, g.name AS group_name,
        g.created_at AS group_created_at, g.updated_at AS group_updated_at,
        b.id AS book_id, b.title AS book_title, b.cover_path AS book_cover_path,
        m.added_at AS added_at
      FROM book_groups g
      LEFT JOIN book_group_books m ON m.group_id = g.id
      LEFT JOIN books b ON b.id = m.book_id AND b.deleted_at IS NULL
      WHERE g.id = ?
      ORDER BY m.added_at DESC
    ''';
    return db
        .customSelect(
          sql,
          variables: [Variable(groupId)],
          readsFrom: {db.bookGroups, db.bookGroupBooks, db.books},
        )
        .watch()
        .map((rows) {
          final groups = _mapGroupRows(rows);
          return groups.isEmpty ? null : groups.first;
        });
  }

  List<BookGroupSummary> _mapGroupRows(List<QueryRow> rows) {
    final builders = <String, _GroupBuilder>{};
    final order = <String>[];
    for (final row in rows) {
      final id = row.read<String>('group_id');
      final builder = builders.putIfAbsent(id, () {
        order.add(id);
        return _GroupBuilder(
          id: id,
          name: row.read<String>('group_name'),
          createdAt: _readDate(row, 'group_created_at'),
          updatedAt: _readDate(row, 'group_updated_at'),
        );
      });
      final bookId = row.read<String?>('book_id');
      if (bookId == null) continue;
      builder.bookCount++;
      if (builder.covers.length < 4) {
        builder.covers.add(
          GroupCoverBook(
            id: bookId,
            title: row.read<String>('book_title'),
            coverPath: row.read<String?>('book_cover_path'),
          ),
        );
      }
    }
    return [
      for (final id in order)
        BookGroupSummary(
          id: builders[id]!.id,
          name: builders[id]!.name,
          bookCount: builders[id]!.bookCount,
          covers: List.unmodifiable(builders[id]!.covers),
          createdAt: builders[id]!.createdAt,
          updatedAt: builders[id]!.updatedAt,
        ),
    ];
  }

  /// Creates a group and adds [bookIds] to it in one transaction.
  Future<String> createGroup({
    required String name,
    Iterable<String> bookIds = const [],
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Group name cannot be empty');
    }
    final now = DateTime.now();
    final groupId = const Uuid().v4();
    await db.transaction(() async {
      await db
          .into(db.bookGroups)
          .insert(
            BookGroupsCompanion.insert(
              id: groupId,
              name: trimmed,
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _insertGroupBooks(groupId, bookIds, now);
    });
    return groupId;
  }

  /// Adds books to an existing group. Books already in the group are ignored.
  Future<void> addBooksToGroup(String groupId, Iterable<String> bookIds) async {
    final now = DateTime.now();
    await db.transaction(() async {
      await _insertGroupBooks(groupId, bookIds, now);
      await (db.update(db.bookGroups)
            ..where((table) => table.id.equals(groupId)))
          .write(BookGroupsCompanion(updatedAt: Value(now)));
    });
  }

  Future<void> _insertGroupBooks(
    String groupId,
    Iterable<String> bookIds,
    DateTime now,
  ) async {
    final unique = bookIds.toSet();
    if (unique.isEmpty) return;
    await db.batch((batch) {
      batch.insertAll(db.bookGroupBooks, [
        for (final bookId in unique)
          BookGroupBooksCompanion.insert(
            groupId: groupId,
            bookId: bookId,
            addedAt: now,
          ),
      ], mode: InsertMode.insertOrIgnore);
    });
  }

  static String _orderBy(LibrarySort sort) => switch (sort) {
    LibrarySort.recentlyRead => 'COALESCE(r.updated_at, b.imported_at) DESC',
    LibrarySort.recentlyAdded => 'b.imported_at DESC',
    LibrarySort.title => 'b.title COLLATE NOCASE ASC',
    LibrarySort.author =>
      "COALESCE(b.author, '') COLLATE NOCASE ASC, b.title COLLATE NOCASE ASC",
  };

  Stream<Book?> watchBook(String bookId) {
    return (db.select(
          db.books,
        )..where((table) => table.id.equals(bookId) & table.deletedAt.isNull()))
        .watchSingleOrNull();
  }

  Future<Book?> getBook(String bookId) {
    return (db.select(
          db.books,
        )..where((table) => table.id.equals(bookId) & table.deletedAt.isNull()))
        .getSingleOrNull();
  }

  Stream<List<ChapterListItem>> watchChapters(String bookId) {
    const sql = '''
      SELECT c.id, c.book_id, c.title, c.chapter_index, c.updated_at,
        r.cached_page_index, r.cached_page_count,
        (SELECT COUNT(*) FROM (
          SELECT DISTINCT COALESCE(o.override_vocabulary_id, o.vocabulary_id) AS vid
          FROM word_occurrences o WHERE o.chapter_id = c.id
        ) d) AS total_count,
        (SELECT COUNT(*) FROM (
          SELECT DISTINCT COALESCE(o.override_vocabulary_id, o.vocabulary_id) AS vid
          FROM word_occurrences o WHERE o.chapter_id = c.id
        ) d LEFT JOIN word_statuses s ON s.vocabulary_id = d.vid
          WHERE COALESCE(s.status, 'NEW') = 'KNOWN') AS known_count,
        (SELECT COUNT(*) FROM (
          SELECT DISTINCT COALESCE(o.override_vocabulary_id, o.vocabulary_id) AS vid
          FROM word_occurrences o WHERE o.chapter_id = c.id
        ) d LEFT JOIN word_statuses s ON s.vocabulary_id = d.vid
          WHERE COALESCE(s.status, 'NEW') = 'LEARNING') AS learning_count,
        CASE WHEN r.id IS NULL THEN 0 ELSE 1 END AS has_progress
      FROM chapters c
      LEFT JOIN reading_progress r ON r.chapter_id = c.id
      WHERE c.book_id = ?
      ORDER BY c.chapter_index
    ''';
    return db
        .customSelect(
          sql,
          variables: [Variable(bookId)],
          readsFrom: {
            db.chapters,
            db.readingProgress,
            db.wordOccurrences,
            db.wordStatuses,
          },
        )
        .watch()
        .map((rows) => rows.map(_mapChapterRow).toList());
  }

  Future<List<Chapter>> getChapters(String bookId) {
    return (db.select(db.chapters)
          ..where((table) => table.bookId.equals(bookId))
          ..orderBy([(table) => OrderingTerm.asc(table.chapterIndex)]))
        .get();
  }

  Future<Chapter?> getChapter(String chapterId) {
    return (db.select(
      db.chapters,
    )..where((table) => table.id.equals(chapterId))).getSingleOrNull();
  }

  Stream<Chapter?> watchChapter(String chapterId) {
    return (db.select(
      db.chapters,
    )..where((table) => table.id.equals(chapterId))).watchSingleOrNull();
  }

  Stream<ChapterVocabularyStats> watchChapterStats(String chapterId) {
    const sql = '''
      SELECT
        COUNT(*) AS total_count,
        SUM(CASE WHEN COALESCE(s.status, 'NEW') = 'KNOWN' THEN 1 ELSE 0 END) AS known_count,
        SUM(CASE WHEN COALESCE(s.status, 'NEW') = 'LEARNING' THEN 1 ELSE 0 END) AS learning_count
      FROM (
        SELECT DISTINCT COALESCE(o.override_vocabulary_id, o.vocabulary_id) AS vid
        FROM word_occurrences o WHERE o.chapter_id = ?
      ) d
      LEFT JOIN word_statuses s ON s.vocabulary_id = d.vid
    ''';
    return db
        .customSelect(
          sql,
          variables: [Variable(chapterId)],
          readsFrom: {db.wordOccurrences, db.wordStatuses},
        )
        .watch()
        .map((rows) {
          if (rows.isEmpty) return const ChapterVocabularyStats();
          final row = rows.first;
          return ChapterVocabularyStats(
            total: row.read<int>('total_count'),
            known: row.read<int?>('known_count') ?? 0,
            learning: row.read<int?>('learning_count') ?? 0,
          );
        });
  }

  Stream<ChapterVocabularyStats> watchBookVocabularyStats(String bookId) {
    const sql = '''
      SELECT
        COUNT(*) AS total_count,
        SUM(CASE WHEN COALESCE(s.status, 'NEW') = 'KNOWN' THEN 1 ELSE 0 END) AS known_count,
        SUM(CASE WHEN COALESCE(s.status, 'NEW') = 'LEARNING' THEN 1 ELSE 0 END) AS learning_count
      FROM (
        SELECT DISTINCT COALESCE(o.override_vocabulary_id, o.vocabulary_id) AS vid
        FROM word_occurrences o
        JOIN chapters c ON c.id = o.chapter_id
        WHERE c.book_id = ?
      ) d
      LEFT JOIN word_statuses s ON s.vocabulary_id = d.vid
    ''';
    return db
        .customSelect(
          sql,
          variables: [Variable(bookId)],
          readsFrom: {db.chapters, db.wordOccurrences, db.wordStatuses},
        )
        .watch()
        .map((rows) {
          if (rows.isEmpty) return const ChapterVocabularyStats();
          final row = rows.first;
          return ChapterVocabularyStats(
            total: row.read<int>('total_count'),
            known: row.read<int?>('known_count') ?? 0,
            learning: row.read<int?>('learning_count') ?? 0,
          );
        });
  }

  Stream<VocabularyStats> watchGlobalVocabularyStats() {
    const sql = '''
      SELECT
        COUNT(*) AS total,
        SUM(CASE WHEN COALESCE(s.status, 'NEW') = 'KNOWN' THEN 1 ELSE 0 END) AS known,
        SUM(CASE WHEN COALESCE(s.status, 'NEW') = 'LEARNING' THEN 1 ELSE 0 END) AS learning
      FROM vocabulary v
      LEFT JOIN word_statuses s ON s.vocabulary_id = v.id
    ''';
    return db
        .customSelect(sql, readsFrom: {db.vocabulary, db.wordStatuses})
        .watch()
        .map((rows) {
          if (rows.isEmpty) return const VocabularyStats();
          final row = rows.first;
          return VocabularyStats(
            total: row.read<int>('total'),
            known: row.read<int?>('known') ?? 0,
            learning: row.read<int?>('learning') ?? 0,
          );
        });
  }

  Stream<ReadingAnchor?> watchLatestProgress(String bookId) {
    return (db.select(db.readingProgress)
          ..where((table) => table.bookId.equals(bookId))
          ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)])
          ..limit(1))
        .watchSingleOrNull()
        .map((row) => row == null ? null : _anchorFromRow(row));
  }

  Future<ReadingAnchor?> getLatestProgress(String bookId) async {
    final row =
        await (db.select(db.readingProgress)
              ..where((table) => table.bookId.equals(bookId))
              ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)])
              ..limit(1))
            .getSingleOrNull();
    return row == null ? null : _anchorFromRow(row);
  }

  Future<ReadingAnchor?> getProgressForChapter(
    String bookId,
    String chapterId,
  ) async {
    final row =
        await (db.select(db.readingProgress)..where(
              (table) =>
                  table.bookId.equals(bookId) &
                  table.chapterId.equals(chapterId),
            ))
            .getSingleOrNull();
    return row == null ? null : _anchorFromRow(row);
  }

  Future<void> saveProgress({
    required String bookId,
    required String chapterId,
    required int anchorParagraph,
    required int anchorOffset,
    required int pageIndex,
    required int pageCount,
    required String layoutSignature,
  }) async {
    await _writeProgress(
      bookId: bookId,
      chapterId: chapterId,
      anchorParagraph: anchorParagraph,
      anchorOffset: anchorOffset,
      pageIndex: pageIndex,
      pageCount: pageCount,
      layoutSignature: layoutSignature,
    );
  }

  Future<void> _writeProgress({
    required String bookId,
    required String chapterId,
    required int anchorParagraph,
    required int anchorOffset,
    required int pageIndex,
    required int pageCount,
    required String layoutSignature,
  }) async {
    final existing =
        await (db.select(db.readingProgress)..where(
              (table) =>
                  table.bookId.equals(bookId) &
                  table.chapterId.equals(chapterId),
            ))
            .getSingleOrNull();
    final now = DateTime.now();
    if (existing == null) {
      await db
          .into(db.readingProgress)
          .insert(
            ReadingProgressCompanion.insert(
              id: const Uuid().v4(),
              bookId: bookId,
              chapterId: chapterId,
              anchorParagraph: Value(anchorParagraph),
              anchorOffset: Value(anchorOffset),
              cachedPageIndex: Value(pageIndex),
              cachedPageCount: Value(pageCount),
              layoutSignature: Value(layoutSignature),
              updatedAt: now,
              updatedBy: Value(deviceId),
            ),
          );
    } else {
      await (db.update(
        db.readingProgress,
      )..where((table) => table.id.equals(existing.id))).write(
        ReadingProgressCompanion(
          anchorParagraph: Value(anchorParagraph),
          anchorOffset: Value(anchorOffset),
          cachedPageIndex: Value(pageIndex),
          cachedPageCount: Value(pageCount),
          layoutSignature: Value(layoutSignature),
          revision: Value(existing.revision + 1),
          updatedAt: Value(now),
          updatedBy: Value(deviceId),
        ),
      );
    }
  }

  Future<void> deleteBook(String bookId) async {
    final row = await (db.select(
      db.books,
    )..where((table) => table.id.equals(bookId))).getSingleOrNull();
    if (row == null) return;
    // A tombstone stays in the database so a later sync can propagate the
    // deletion. The original file is retained for restores.
    final now = DateTime.now();
    await db.transaction(() async {
      await (db.delete(
        db.bookGroupBooks,
      )..where((table) => table.bookId.equals(bookId))).go();
      await (db.update(
        db.books,
      )..where((table) => table.id.equals(bookId))).write(
        BooksCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          revision: Value(row.revision + 1),
          updatedBy: Value(deviceId),
        ),
      );
    });
  }

  Future<void> deleteBooks(Iterable<String> bookIds) async {
    for (final bookId in bookIds.toSet()) {
      await deleteBook(bookId);
    }
  }

  /// Book ids reached through the given groups. Used by group deletion so a
  /// removed group takes its books with it.
  Future<List<String>> bookIdsInGroups(Iterable<String> groupIds) async {
    final ids = groupIds.toSet();
    if (ids.isEmpty) return const [];
    final rows = await (db.select(
      db.bookGroupBooks,
    )..where((table) => table.groupId.isIn(ids))).get();
    return rows.map((row) => row.bookId).toSet().toList(growable: false);
  }

  /// Removes groups and their membership rows. The books themselves stay in
  /// the library, which makes them visible on Home again.
  Future<void> deleteGroups(Iterable<String> groupIds) async {
    final ids = groupIds.toSet();
    if (ids.isEmpty) return;
    await db.transaction(() async {
      await (db.delete(
        db.bookGroupBooks,
      )..where((table) => table.groupId.isIn(ids))).go();
      await (db.delete(
        db.bookGroups,
      )..where((table) => table.id.isIn(ids))).go();
    });
  }

  /// Permanently removes every book, word index, vocabulary entry, definition
  /// and review record from this device, together with book and cover files.
  /// App settings, device identity and .cfr backups are preserved.
  Future<void> deleteAllData() async {
    await db.transaction(() async {
      await db.delete(db.bookGroupBooks).go();
      await db.delete(db.bookGroups).go();
      await db.delete(db.dictionaryEntries).go();
      await db.delete(db.dictionaries).go();
      await db.delete(db.reviewLogs).go();
      await db.delete(db.fsrsCards).go();
      await db.delete(db.definitions).go();
      await db.delete(db.wordStatuses).go();
      await db.delete(db.wordOccurrences).go();
      await db.delete(db.wordForms).go();
      await db.delete(db.vocabulary).go();
      await db.delete(db.paginationCaches).go();
      await db.delete(db.readingProgress).go();
      await db.delete(db.chapters).go();
      await db.delete(db.books).go();
    });
    for (final dir in [storage.booksDir, storage.coversDir]) {
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
      await dir.create(recursive: true);
    }
  }

  Future<String?> filePathForBook(Book book) async {
    final path = storage.resolveStoredPath(book.originalFilePath);
    if (await File(path).exists()) {
      return path;
    }
    return null;
  }

  String? coverPathForBook(Book book) {
    final path = book.coverPath;
    if (path == null || path.isEmpty) return null;
    final resolved = storage.resolveStoredPath(path);
    if (File(resolved).existsSync()) return resolved;
    return null;
  }

  BookListItem _mapBookRow(QueryRow row) {
    final book = Book(
      id: row.read<String>('id'),
      title: row.read<String>('title'),
      author: row.read<String?>('author'),
      description: row.read<String?>('description'),
      coverPath: row.read<String?>('cover_path'),
      originalFilePath: row.read<String>('original_file_path'),
      format: row.read<String>('format'),
      language: row.read<String>('language'),
      fileSha256: row.read<String?>('file_sha256'),
      revision: row.read<int>('revision'),
      importedAt: _readDate(row, 'imported_at'),
      updatedAt: _readDate(row, 'updated_at'),
      deletedAt: row.data['deleted_at'] == null
          ? null
          : _readDate(row, 'deleted_at'),
    );
    return BookListItem(
      book: book,
      chapterCount: row.read<int>('chapter_count'),
      currentChapterTitle: row.read<String?>('current_chapter_title'),
      currentChapterIndex: row.read<int?>('current_chapter_index'),
      pageIndex: row.read<int?>('current_page_index') ?? 0,
      pageCount: row.read<int?>('current_page_count') ?? 1,
      lastReadAt: row.data['last_read_at'] == null
          ? null
          : _readDate(row, 'last_read_at'),
    );
  }

  ChapterListItem _mapChapterRow(QueryRow row) {
    return ChapterListItem(
      id: row.read<String>('id'),
      bookId: row.read<String>('book_id'),
      title: row.read<String>('title'),
      chapterIndex: row.read<int>('chapter_index'),
      updatedAt: _readDate(row, 'updated_at'),
      pageIndex: row.read<int?>('cached_page_index'),
      pageCount: row.read<int?>('cached_page_count'),
      hasProgress: (row.read<int?>('has_progress') ?? 0) == 1,
      stats: ChapterVocabularyStats(
        total: row.read<int>('total_count'),
        known: row.read<int?>('known_count') ?? 0,
        learning: row.read<int?>('learning_count') ?? 0,
      ),
    );
  }

  ReadingAnchor _anchorFromRow(ReadingProgressData row) => ReadingAnchor(
    bookId: row.bookId,
    chapterId: row.chapterId,
    anchorParagraph: row.anchorParagraph,
    anchorOffset: row.anchorOffset,
    cachedPageIndex: row.cachedPageIndex,
    cachedPageCount: row.cachedPageCount,
    layoutSignature: row.layoutSignature,
    updatedAt: row.updatedAt,
  );

  DateTime _readDate(QueryRow row, String key) {
    final value = row.data[key];
    if (value is DateTime) return value;
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value * 1000);
    }
    if (value is String) return DateTime.parse(value);
    throw StateError('Cannot read date column $key');
  }
}
