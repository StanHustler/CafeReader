import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/database/app_database.dart';
import '../../core/design/app_theme.dart';

import 'dart:math' as math;

import '../../core/design/common_widgets.dart';
import '../../core/design/page_layout.dart';
import '../../core/design/page_pager.dart';
import '../../core/design/subpage.dart';
import '../../data/repository/library_repository.dart';
import '../reader/reader_screen.dart';
import 'import_export_flow.dart';

class BookDetailPage extends ConsumerStatefulWidget {
  const BookDetailPage({super.key, required this.bookId});

  final String bookId;

  @override
  ConsumerState<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends ConsumerState<BookDetailPage> {
  /// First visible chapter page. The book summary stays fixed above it.
  int _chapterPage = 0;

  /// One chapter row plus its divider.
  static const double _chapterRowExtent = 65;

  /// Space kept clear at the bottom for the floating pager.
  static const double _pagerRoom = 64;

  /// Room for the Chapters heading above the rows.
  static const double _chapterHeaderRoom = 64;

  @override
  Widget build(BuildContext context) {
    final bookAsync = ref.watch(bookProvider(widget.bookId));
    final chaptersAsync = ref.watch(chaptersProvider(widget.bookId));
    final stats =
        ref.watch(bookVocabularyStatsProvider(widget.bookId)).valueOrNull ??
        const ChapterVocabularyStats();
    final progress = ref
        .watch(latestProgressProvider(widget.bookId))
        .valueOrNull;
    final book = bookAsync.valueOrNull;
    final chapters = chaptersAsync.valueOrNull ?? const <ChapterListItem>[];

    final chapterIndex = progress == null
        ? -1
        : chapters.indexWhere((chapter) => chapter.id == progress.chapterId);
    final pageFraction = progress == null || progress.cachedPageCount <= 0
        ? 0.0
        : (progress.cachedPageIndex + 1) / progress.cachedPageCount;
    final overall = chapters.isEmpty
        ? 0.0
        : (((chapterIndex < 0 ? 0 : chapterIndex) + pageFraction) /
                  chapters.length)
              .clamp(0.0, 1.0);

    return SubpageScaffold(
      title: book?.title ?? 'Book details',
      style: SubpageHeaderStyle.compact,
      scrollable: false,
      actions: [
        if (book != null) ...[
          IconButton(
            tooltip: 'Export book',
            onPressed: () => _exportBook(context, ref, book.title),
            icon: const Icon(Icons.ios_share_outlined, size: 20),
          ),
          PopupMenuButton<String>(
            tooltip: 'Book options',
            iconSize: 20,
            onSelected: (value) async {
              if (value == 'delete') {
                final confirmed = await confirmAction(
                  context,
                  title: 'Remove “${book.title}”?',
                  message: 'The book and its word index will be removed from this library. Your global vocabulary states are kept.',
                  confirmLabel: 'Remove book',
                  destructive: true,
                );
                if (confirmed) {
                  await ref.read(libraryRepositoryProvider).deleteBook(book.id);
                  if (context.mounted) Navigator.pop(context);
                }
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'delete', child: Text('Remove book')),
            ],
          ),
        ],
      ],
      child: bookAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Could not load book: $error')),
        data: (book) {
          if (book == null) {
            return const EmptyState(
              icon: Icons.menu_book_outlined,
              title: 'Book not found',
              message: 'It may have been removed from your library.',
            );
          }
          return _buildBookBody(
            context,
            book: book,
            stats: stats,
            overall: overall,
            chapters: chapters,
            loadingChapters: chaptersAsync.isLoading && chapters.isEmpty,
            hasProgress: progress != null,
          );
        },
      ),
    );
  }

  Widget _buildBookBody(
    BuildContext context, {
    required Book book,
    required ChapterVocabularyStats stats,
    required double overall,
    required List<ChapterListItem> chapters,
    required bool loadingChapters,
    required bool hasProgress,
  }) {
    final palette = CafePalette.of(context);
    final description = book.description?.trim();
    final hasDescription = description != null && description.isNotEmpty;
    return LayoutBuilder(
      builder: (context, constraints) {
        final column = PageColumn.fit(constraints.maxWidth);
        final horizontal = column.contentInset;
        final contentWidth = column.contentWidth;
        final narrow = contentWidth < 620;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            horizontal,
            PageGeometry.top,
            horizontal,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // The summary keeps its natural proportions but is capped so the
              // chapter browser always has room to breathe.
              Flexible(
                fit: FlexFit.loose,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: constraints.maxHeight * 0.52,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: contentWidth,
                      child: _BookHero(
                        book: book,
                        stats: stats,
                        overall: overall,
                        chapterCount: chapters.length,
                        hasProgress: hasProgress,
                        onRead: () => _openReader(context),
                        onAbout: hasDescription
                            ? () => _showAbout(context, description)
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, inner) {
                    final rows = math.max(
                      1,
                      ((inner.maxHeight - _pagerRoom - _chapterHeaderRoom) /
                              _chapterRowExtent)
                          .floor(),
                    );
                    final pageCount = chapters.isEmpty
                        ? 1
                        : ((chapters.length + rows - 1) ~/ rows);
                    final pageIndex = _chapterPage.clamp(0, pageCount - 1);
                    final start = pageIndex * rows;
                    final end = math.min(chapters.length, start + rows);
                    final pageChapters = chapters.isEmpty
                        ? const <ChapterListItem>[]
                        : chapters.sublist(start, end);

                    final Widget body;
                    if (loadingChapters) {
                      body = const Center(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 48),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else if (chapters.isEmpty) {
                      body = const Padding(
                        padding: EdgeInsets.only(bottom: 48),
                        child: EmptyState(
                          icon: Icons.format_list_bulleted,
                          title: 'No chapters yet',
                          message:
                              'This book has no chapter structure. Open it '
                              'with Continue reading instead.',
                        ),
                      );
                    } else {
                      body = Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SectionHeader(
                            title: 'Chapters',
                            subtitle:
                                '$start–$end of ${chapters.length} · '
                                'vocabulary updates live',
                            action: narrow ? null : const StatusLegend(),
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: palette.surface,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: palette.line),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                children: [
                                  for (
                                    var index = 0;
                                    index < pageChapters.length;
                                    index++
                                  )
                                    SizedBox(
                                      height: _chapterRowExtent,
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: _ChapterRow(
                                              chapter: pageChapters[index],
                                              onTap: () => _openReader(
                                                context,
                                                chapterId:
                                                    pageChapters[index].id,
                                              ),
                                            ),
                                          ),
                                          if (index < pageChapters.length - 1)
                                            Divider(
                                              height: 1,
                                              color: palette.line,
                                            ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return PageFlipOverlay(
                      pageIndex: pageIndex,
                      pageCount: pageCount,
                      onPrevious: pageIndex > 0
                          ? () => setState(() => _chapterPage = pageIndex - 1)
                          : null,
                      onNext: pageIndex < pageCount - 1
                          ? () => setState(() => _chapterPage = pageIndex + 1)
                          : null,
                      child: body,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAbout(BuildContext context, String description) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About this book'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 420),
          child: SingleChildScrollView(
            child: Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: CafePalette.of(context).inkMuted,
                height: 1.65,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _openReader(BuildContext context, {String? chapterId}) {
    // Reading opens above the shell; every other secondary page stays in the
    // tab's content pane so the sidebar remains visible.
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            ReaderScreen(bookId: widget.bookId, chapterId: chapterId),
      ),
    );
  }

  Future<void> _exportBook(
    BuildContext context,
    WidgetRef ref,
    String title,
  ) async {
    final artifact = await createBackupWithProgress(
      context,
      ref,
      bookId: widget.bookId,
    );
    if (artifact != null && context.mounted) {
      final cleaned = title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '').trim();
      await saveFileWithPicker(
        context,
        File(artifact.path),
        suggestedName: '${cleaned.isEmpty ? 'CafeReader book' : cleaned}.cfr',
      );
    }
  }
}

class _BookHero extends StatelessWidget {
  const _BookHero({
    required this.book,
    required this.stats,
    required this.overall,
    required this.chapterCount,
    required this.hasProgress,
    required this.onRead,
    this.onAbout,
  });

  final Book book;
  final ChapterVocabularyStats stats;
  final double overall;
  final int chapterCount;
  final bool hasProgress;
  final VoidCallback onRead;
  final VoidCallback? onAbout;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 620;
        final cover = BookCover(
          book: book,
          width: narrow ? 96 : 142,
          height: narrow ? 144 : 213,
          borderRadius: 12,
        );
        final info = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!narrow)
              Text(book.title, style: Theme.of(context).textTheme.displaySmall),
            if (!narrow) const SizedBox(height: 6),
            if (!narrow)
              Text(
                book.author ?? 'Unknown author',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: palette.inkMuted,
                  fontWeight: FontWeight.w400,
                ),
              ),
            if (!narrow) const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetaChip(label: book.format.toUpperCase()),
                _MetaChip(label: '$chapterCount chapters'),
                _MetaChip(label: '${formatCount(stats.total)} saved words'),
                _MetaChip(label: '${(overall * 100).round()}% read'),
              ],
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: overall,
                minHeight: 6,
                backgroundColor: palette.surfaceMuted,
              ),
            ),
            const SizedBox(height: 10),
            StatusBar(stats: stats),
            const SizedBox(height: 8),
            Row(
              children: [
                _CountLabel(
                  color: palette.ink,
                  label: 'Known',
                  count: stats.known,
                ),
                const SizedBox(width: 12),
                _CountLabel(
                  color: palette.ink,
                  label: 'Learning',
                  count: stats.learning,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: onRead,
                  icon: const Icon(Icons.menu_book_outlined, size: 18),
                  label: Text(
                    hasProgress ? 'Continue reading' : 'Start reading',
                  ),
                ),
                if (onAbout != null)
                  TextButton.icon(
                    onPressed: onAbout,
                    icon: const Icon(Icons.info_outline, size: 17),
                    label: const Text('About this book'),
                  ),
              ],
            ),
          ],
        );
        if (narrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  cover,
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          book.author ?? 'Unknown author',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: palette.inkMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              info,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            cover,
            const SizedBox(width: 28),
            Expanded(child: info),
          ],
        );
      },
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: palette.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.line),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: palette.inkMuted,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _CountLabel extends StatelessWidget {
  const _CountLabel({
    required this.color,
    required this.label,
    required this.count,
  });
  final Color color;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          '$label ${formatCount(count)}',
          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _ChapterRow extends StatelessWidget {
  const _ChapterRow({required this.chapter, required this.onTap});
  final ChapterListItem chapter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    final stats = chapter.stats;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: palette.surfaceMuted,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                '${chapter.chapterIndex + 1}',
                style: TextStyle(
                  fontFamily: 'Literata',
                  fontWeight: FontWeight.w700,
                  color: palette.inkMuted,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chapter.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(child: StatusBar(stats: stats, height: 4)),
                      const SizedBox(width: 10),
                      Text(
                        chapter.hasProgress
                            ? 'Page ${(chapter.pageIndex ?? 0) + 1}/${chapter.pageCount ?? 1}'
                            : '${formatCount(stats.total)} saved',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: palette.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${formatCount(stats.known)} K',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: palette.ink,
                  ),
                ),
                Text(
                  '${formatCount(stats.learning)} L',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: palette.ink,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: palette.inkMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
