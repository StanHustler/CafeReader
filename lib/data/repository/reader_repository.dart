import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../../core/reader/page_content.dart';

/// Coordinates the database side of reading: pagination cache and the
/// transactional reading progress anchor.
class ReaderRepository {
  ReaderRepository(this.db, this.deviceId);

  final AppDatabase db;
  final String deviceId;

  Future<List<PageContent>?> loadPagination({
    required String chapterId,
    required String content,
    required String layoutSignature,
  }) async {
    final rows =
        await (db.select(db.paginationCaches)
              ..where(
                (table) =>
                    table.chapterId.equals(chapterId) &
                    table.layoutSignature.equals(layoutSignature),
              )
              ..orderBy([(table) => OrderingTerm.asc(table.pageIndex)]))
            .get();
    if (rows.isEmpty) return null;
    final paragraphs = chapterParagraphs(content);
    final pages = <PageContent>[];
    for (final row in rows) {
      pages.add(
        PageContent.fromParagraphRange(
          index: row.pageIndex,
          paragraphs: paragraphs,
          startParagraph: row.startParagraph,
          startOffset: row.startOffset,
          endParagraph: row.endParagraph,
          endOffset: row.endOffset,
        ),
      );
    }
    return pages;
  }

  Future<void> savePagination({
    required String chapterId,
    required String layoutSignature,
    required List<PageContent> pages,
  }) async {
    await db.transaction(() async {
      await (db.delete(db.paginationCaches)..where(
            (table) =>
                table.chapterId.equals(chapterId) &
                table.layoutSignature.equals(layoutSignature),
          ))
          .go();
      final now = DateTime.now();
      await db.batch((batch) {
        batch.insertAll(db.paginationCaches, [
          for (final page in pages)
            PaginationCachesCompanion.insert(
              chapterId: chapterId,
              layoutSignature: layoutSignature,
              pageIndex: page.index,
              startParagraph: page.startParagraph,
              startOffset: page.startOffset,
              endParagraph: page.endParagraph,
              endOffset: page.endOffset,
              createdAt: now,
            ),
        ]);
      });
    });
  }

  Future<void> clearPaginationForChapter(String chapterId) async {
    await (db.delete(
      db.paginationCaches,
    )..where((table) => table.chapterId.equals(chapterId))).go();
  }

  /// Advances the reading position.
  ///
  /// The caller must only update its page index after this future succeeds.
  Future<void> commitPageAdvance({
    required String bookId,
    required String chapterId,
    required int targetParagraph,
    required int targetOffset,
    required int targetPageIndex,
    required int targetPageCount,
    required String layoutSignature,
  }) {
    return db.transaction(() async {
      await _writeProgress(
        bookId: bookId,
        chapterId: chapterId,
        anchorParagraph: targetParagraph,
        anchorOffset: targetOffset,
        pageIndex: targetPageIndex,
        pageCount: targetPageCount,
        layoutSignature: layoutSignature,
      );
    });
  }

  Future<void> saveProgressOnly({
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
              id: '${bookId}_$chapterId',
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
}
