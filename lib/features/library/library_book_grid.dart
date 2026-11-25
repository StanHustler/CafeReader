import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/database/app_database.dart';
import '../../core/design/app_theme.dart';
import '../../core/design/common_widgets.dart';
import '../../core/design/page_layout.dart';
import '../../core/design/page_pager.dart';
import '../../data/repository/library_repository.dart';
import '../reader/reader_screen.dart';
import 'book_detail_page.dart';
import 'import_export_flow.dart';

/// The cover keeps a fixed 2:3 footprint on every platform. Only the number
/// of grid columns changes as the window grows, so covers never get scaled up
/// or stretched.
const double _bookCoverWidth = 120;
const double _bookCoverHeight = _bookCoverWidth * 3 / 2;
const double _bookCoverRadius = 6;

const double _gridCrossSpacing = 24;
const double _gridMainSpacing = 20;

/// Space below the cover reserved for the title and author lines.
/// It includes enough slack for moderate system text scaling.
const double _bookCardChromeHeight = 100;
const double _bookCardHeight = _bookCoverHeight + _bookCardChromeHeight;

/// The paged library body used by the Home destination.
///
/// The header stays fixed and the covers fill exactly one screenful. A
/// [PageFlipBar] floating in the bottom-right corner walks through the rest of
/// the library; nothing on the page scrolls.
///
/// [headerBuilder] receives the page's compact breakpoint so the header can
/// adapt its typography and controls.
class LibraryBookGrid extends ConsumerStatefulWidget {
  const LibraryBookGrid({
    super.key,
    required this.query,
    required this.headerBuilder,
    this.sort = LibrarySort.recentlyRead,
    this.groupId,
    this.showGroups = true,
    this.excludeGroupedBooks = false,
    this.selectedBookIds = const <String>{},
    this.selectedGroupIds = const <String>{},
    this.onBookSelectRequest,
    this.onBookToggleSelection,
    this.onGroupSelectRequest,
    this.onGroupToggleSelection,
    this.onOpenGroup,
  });

  final String query;
  final LibrarySort sort;
  final Widget Function(BuildContext context, bool compact) headerBuilder;

  /// When set, the grid lists only the books in this group.
  final String? groupId;

  /// Whether group cards are mixed into the grid ahead of the books.
  final bool showGroups;

  /// Hides books that were filed into a group. Home sets this so a grouped
  /// book only shows inside its group.
  final bool excludeGroupedBooks;

  /// Books that should render with a selection check.
  final Set<String> selectedBookIds;

  /// Groups that should render with a selection check.
  final Set<String> selectedGroupIds;

  /// Long-press or right-click on a book. Used to enter selection mode.
  final ValueChanged<BookListItem>? onBookSelectRequest;

  /// Tap on a book while selection mode is active.
  final ValueChanged<BookListItem>? onBookToggleSelection;

  /// Long-press or right-click on a group card.
  final ValueChanged<BookGroupSummary>? onGroupSelectRequest;

  /// Tap on a group card while selection mode is active.
  final ValueChanged<BookGroupSummary>? onGroupToggleSelection;

  /// Tap on a group card.
  final ValueChanged<BookGroupSummary>? onOpenGroup;

  @override
  ConsumerState<LibraryBookGrid> createState() => _LibraryBookGridState();
}

class _LibraryBookGridState extends ConsumerState<LibraryBookGrid> {
  int _page = 0;

  /// Space kept clear at the bottom for the floating pager.
  static const double _pagerRoom = 64;

  @override
  void didUpdateWidget(covariant LibraryBookGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query ||
        oldWidget.sort != widget.sort ||
        oldWidget.groupId != widget.groupId ||
        oldWidget.excludeGroupedBooks != widget.excludeGroupedBooks) {
      _page = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    final booksAsync = ref.watch(
      booksProvider(
        LibraryQuery(
          query: widget.query,
          sort: widget.sort,
          groupId: widget.groupId,
          excludeGrouped: widget.excludeGroupedBooks,
        ),
      ),
    );
    final groupsAsync = widget.showGroups ? ref.watch(groupsProvider) : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 700;

        // The grid resolves the shared column geometry directly: the covers
        // span the same column as every other page, from the title's left
        // edge to the bubble group's right edge.
        final column = PageColumn.fit(constraints.maxWidth);
        final horizontal = column.contentInset;
        final contentWidth = column.contentWidth;

        // Fit as many fixed-width covers as possible. Leftover width is spread
        // across the gutters instead of the outer margins, so the first cover
        // lines up under the title and the last one ends under the bubbles
        // while the covers stay 120px wide.
        final columns = math.max(
          1,
          ((contentWidth + _gridCrossSpacing) /
                  (_bookCoverWidth + _gridCrossSpacing))
              .floor(),
        );
        final crossSpacing = columns > 1
            ? (contentWidth - columns * _bookCoverWidth) / (columns - 1)
            : _gridCrossSpacing;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontal,
                PageGeometry.top,
                horizontal,
                22,
              ),
              child: widget.headerBuilder(context, compact),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, inner) {
                  // Whole rows that fit above the floating pager.
                  final rows = math.max(
                    1,
                    ((inner.maxHeight - _pagerRoom + _gridMainSpacing) /
                            (_bookCardHeight + _gridMainSpacing))
                        .floor(),
                  );
                  final perPage = math.max(1, columns * rows);
                  final items = booksAsync.valueOrNull;
                  final normalizedQuery = widget.query.trim().toLowerCase();
                  final allGroups =
                      groupsAsync?.valueOrNull ?? const <BookGroupSummary>[];
                  final groups = normalizedQuery.isEmpty
                      ? allGroups
                      : allGroups
                            .where(
                              (group) => group.name.toLowerCase().contains(
                                normalizedQuery,
                              ),
                            )
                            .toList(growable: false);
                  final entries = <_GridEntry>[
                    for (final group in groups) _GroupEntry(group),
                    if (items != null)
                      for (final item in items) _BookEntry(item),
                  ];
                  final pageCount = entries.isEmpty
                      ? 1
                      : ((entries.length + perPage - 1) ~/ perPage);
                  final pageIndex = _page.clamp(0, pageCount - 1);
                  final pageEntries = entries
                      .skip(pageIndex * perPage)
                      .take(perPage)
                      .toList(growable: false);

                  final Widget body;
                  if (booksAsync.hasError) {
                    body = Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'Could not load your library: ${booksAsync.error}',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: palette.danger),
                        ),
                      ),
                    );
                  } else if (items == null) {
                    body = const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  } else if (entries.isEmpty) {
                    if (widget.groupId != null) {
                      body = const _PageMessage(
                        icon: Icons.folder_open_outlined,
                        title: 'This group is empty',
                      );
                    } else if (widget.query.trim().isNotEmpty) {
                      body = _NoResults(query: widget.query);
                    } else {
                      body = _EmptyLibrary(
                        onImport: () => showBookImportFlow(context, ref),
                      );
                    }
                  } else {
                    final selectionActive =
                        widget.selectedBookIds.isNotEmpty ||
                        widget.selectedGroupIds.isNotEmpty;
                    Widget cellAt(int index) {
                      final entry = pageEntries[index];
                      if (entry is _GroupEntry) {
                        final toggleSelection = widget.onGroupToggleSelection;
                        final selectRequest = widget.onGroupSelectRequest;
                        return SizedBox(
                          width: _bookCoverWidth,
                          height: _bookCardHeight,
                          child: _GroupCard(
                            group: entry.group,
                            selected: widget.selectedGroupIds.contains(
                              entry.group.id,
                            ),
                            selectionActive: selectionActive,
                            onOpen:
                                widget.onOpenGroup == null || selectionActive
                                ? null
                                : () => widget.onOpenGroup!(entry.group),
                            onToggleSelection: toggleSelection == null
                                ? null
                                : () => toggleSelection(entry.group),
                            onSelectRequest: selectRequest == null
                                ? null
                                : () => selectRequest(entry.group),
                          ),
                        );
                      }
                      final item = (entry as _BookEntry).item;
                      final toggleSelection = widget.onBookToggleSelection;
                      final selectRequest = widget.onBookSelectRequest;
                      return SizedBox(
                        width: _bookCoverWidth,
                        height: _bookCardHeight,
                        child: _BookCard(
                          item: item,
                          selected: widget.selectedBookIds.contains(
                            item.book.id,
                          ),
                          selectionActive: selectionActive,
                          onOpenBook: () => _openDetail(context, item),
                          onRead: () => _openReader(context, item.book.id),
                          onToggleSelection: toggleSelection == null
                              ? null
                              : () => toggleSelection(item),
                          onSelectRequest: selectRequest == null
                              ? null
                              : () => selectRequest(item),
                        ),
                      );
                    }

                    body = Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontal,
                        0,
                        horizontal,
                        _pagerRoom,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var row = 0; row < rows; row++) ...[
                            if (row > 0)
                              const SizedBox(height: _gridMainSpacing),
                            SizedBox(
                              height: _bookCardHeight,
                              child: Row(
                                children: [
                                  for (
                                    var column = 0;
                                    column < columns;
                                    column++
                                  ) ...[
                                    if (column > 0)
                                      SizedBox(width: crossSpacing),
                                    if (row * columns + column <
                                        pageEntries.length)
                                      cellAt(row * columns + column)
                                    else
                                      const SizedBox(width: _bookCoverWidth),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  return PageFlipOverlay(
                    pageIndex: pageIndex,
                    pageCount: pageCount,
                    onPrevious: pageIndex > 0
                        ? () => setState(() => _page = pageIndex - 1)
                        : null,
                    onNext: pageIndex < pageCount - 1
                        ? () => setState(() => _page = pageIndex + 1)
                        : null,
                    // Right-align the pager with the header's bubble group and
                    // the shared content column.
                    right: horizontal,
                    child: body,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

void _openDetail(BuildContext context, BookListItem item) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BookDetailPage(bookId: item.book.id),
    ),
  );
}

void _openReader(BuildContext context, String bookId) {
  // Reading is the one secondary screen that stays immersive, so it is pushed
  // above the shell instead of into a tab's content pane.
  Navigator.of(
    context,
    rootNavigator: true,
  ).push(MaterialPageRoute<void>(builder: (_) => ReaderScreen(bookId: bookId)));
}

class _PageMessage extends StatelessWidget {
  const _PageMessage({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 56),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 34, color: palette.inkMuted),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return _PageMessage(
      icon: Icons.search_off,
      title: 'No books match “$query”',
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary({required this.onImport});

  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    return _PageMessage(
      icon: Icons.menu_book_outlined,
      title: 'Your library is empty',
    );
  }
}

sealed class _GridEntry {
  const _GridEntry();
}

class _GroupEntry extends _GridEntry {
  const _GroupEntry(this.group);
  final BookGroupSummary group;
}

class _BookEntry extends _GridEntry {
  const _BookEntry(this.item);
  final BookListItem item;
}

class _BookCard extends StatelessWidget {
  const _BookCard({
    required this.item,
    required this.selected,
    required this.selectionActive,
    required this.onOpenBook,
    required this.onRead,
    this.onToggleSelection,
    this.onSelectRequest,
  });

  final BookListItem item;
  final bool selected;
  final bool selectionActive;
  final VoidCallback onOpenBook;
  final VoidCallback onRead;
  final VoidCallback? onToggleSelection;
  final VoidCallback? onSelectRequest;

  void _handleTap(VoidCallback fallback) {
    if (selectionActive && onToggleSelection != null) {
      onToggleSelection!();
    } else {
      fallback();
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fixed footprint: the cover never depends on how much text follows.
        _HoverCover(
          book: item.book,
          selected: selected,
          onTap: () => _handleTap(onRead),
          onLongPress: onSelectRequest,
          onSecondaryTap: onSelectRequest,
        ),
        const SizedBox(height: 10),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _handleTap(onOpenBook),
          onLongPress: onSelectRequest,
          onSecondaryTap: onSelectRequest,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.book.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                  color: palette.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${(item.progress.clamp(0.0, 1.0) * 100).round()}%',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11.5, color: palette.inkMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HoverCover extends StatefulWidget {
  const _HoverCover({
    required this.book,
    required this.selected,
    required this.onTap,
    this.onLongPress,
    this.onSecondaryTap,
  });

  final Book book;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onSecondaryTap;

  @override
  State<_HoverCover> createState() => _HoverCoverState();
}

class _HoverCoverState extends State<_HoverCover> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        onSecondaryTap: widget.onSecondaryTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          width: _bookCoverWidth,
          height: _bookCoverHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_bookCoverRadius),
            boxShadow: [
              BoxShadow(
                color: palette.shadow,
                blurRadius: _hovered ? 18 : 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              BookCover(
                book: widget.book,
                width: _bookCoverWidth,
                height: _bookCoverHeight,
                borderRadius: _bookCoverRadius,
                border: Border.all(color: palette.ink.withValues(alpha: 0.07)),
              ),
              if (widget.selected) ...[
                IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(_bookCoverRadius),
                      border: Border.all(color: palette.accent, width: 2.5),
                    ),
                  ),
                ),
                Positioned(
                  top: 7,
                  right: 7,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: palette.accent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: palette.shadow,
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.group,
    required this.selected,
    required this.selectionActive,
    this.onOpen,
    this.onToggleSelection,
    this.onSelectRequest,
  });

  final BookGroupSummary group;
  final bool selected;
  final bool selectionActive;
  final VoidCallback? onOpen;
  final VoidCallback? onToggleSelection;
  final VoidCallback? onSelectRequest;

  void _handleTap() {
    if (selectionActive && onToggleSelection != null) {
      onToggleSelection!();
    } else {
      onOpen?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HoverGroupCover(
          group: group,
          selected: selected,
          onTap: _handleTap,
          onLongPress: onSelectRequest,
          onSecondaryTap: onSelectRequest,
        ),
        const SizedBox(height: 10),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _handleTap,
          onLongPress: onSelectRequest,
          onSecondaryTap: onSelectRequest,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                group.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                  color: palette.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _groupBookCountLabel(group.bookCount),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11.5, color: palette.inkMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HoverGroupCover extends StatefulWidget {
  const _HoverGroupCover({
    required this.group,
    required this.selected,
    required this.onTap,
    this.onLongPress,
    this.onSecondaryTap,
  });

  final BookGroupSummary group;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onSecondaryTap;

  @override
  State<_HoverGroupCover> createState() => _HoverGroupCoverState();
}

class _HoverGroupCoverState extends State<_HoverGroupCover> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        onSecondaryTap: widget.onSecondaryTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          width: _bookCoverWidth,
          height: _bookCoverHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_bookCoverRadius),
            boxShadow: [
              BoxShadow(
                color: palette.shadow,
                blurRadius: _hovered ? 18 : 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(_bookCoverRadius),
                child: DecoratedBox(
                  position: DecorationPosition.foreground,
                  decoration: BoxDecoration(
                    border: Border.all(color: palette.line),
                    borderRadius: BorderRadius.circular(_bookCoverRadius),
                  ),
                  child: _GroupCoverMosaic(covers: widget.group.covers),
                ),
              ),
              if (widget.selected) ...[
                IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(_bookCoverRadius),
                      border: Border.all(color: palette.accent, width: 2.5),
                    ),
                  ),
                ),
                Positioned(
                  top: 7,
                  right: 7,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: palette.accent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: palette.shadow,
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Four equal cover cells with rounded corners and breathing room, but no
/// dividers. Missing members leave a quiet empty well, so a group with one or
/// two books still reads as a cover-shaped object.
class _GroupCoverMosaic extends StatelessWidget {
  const _GroupCoverMosaic({required this.covers});

  final List<GroupCoverBook> covers;

  static const double _padding = 8;
  static const double _gap = 2;
  static const double _thumbRadius = 3;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    Widget cell(int index) {
      if (index >= covers.length) return const SizedBox.shrink();
      final book = covers[index];
      return CoverArt(
        title: book.title,
        coverPath: book.coverPath,
        borderRadius: _thumbRadius,
        border: Border.all(color: Colors.transparent),
      );
    }

    Widget gap({required bool vertical}) =>
        SizedBox(width: vertical ? _gap : null, height: vertical ? null : _gap);

    return ColoredBox(
      color: palette.surfaceMuted,
      child: Padding(
        padding: const EdgeInsets.all(_padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: cell(0)),
                  gap(vertical: true),
                  Expanded(child: cell(1)),
                ],
              ),
            ),
            gap(vertical: false),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: cell(2)),
                  gap(vertical: true),
                  Expanded(child: cell(3)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _groupBookCountLabel(int count) =>
    '$count ${count == 1 ? 'book' : 'books'}';
