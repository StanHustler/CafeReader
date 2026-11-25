import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../core/design/app_theme.dart';
import '../../core/design/common_widgets.dart';
import '../../core/design/page_layout.dart';
import '../../core/design/page_pager.dart';
import '../../data/repository/library_repository.dart';
import '../../data/repository/vocabulary_repository.dart';
import '../review/review_session_page.dart';
import '../vocabulary/vocabulary_panel.dart';

class DeckPage extends ConsumerStatefulWidget {
  const DeckPage({super.key});

  @override
  ConsumerState<DeckPage> createState() => _DeckPageState();
}

class _DeckPageState extends ConsumerState<DeckPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _searchOpen = false;
  String _query = '';
  String? _bookFilter;
  int _page = 0;

  /// One deck row including its divider. Rows never grow, so a whole number of
  /// them can be sized against the viewport without scrolling.
  static const double _rowExtent = 86;

  /// Space kept clear at the bottom for the floating pager.
  static const double _pagerRoom = 64;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _resetPage() => _page = 0;

  void _selectState(VocabularyState value) {
    if (ref.read(deckTabProvider) == value) return;
    ref.read(deckTabProvider.notifier).state = value;
    setState(_resetPage);
  }

  void _toggleSearch() {
    if (_searchOpen) {
      _closeSearch();
      return;
    }
    setState(() => _searchOpen = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocus.requestFocus();
    });
  }

  void _closeSearch() {
    _searchController.clear();
    _searchFocus.unfocus();
    setState(() {
      _query = '';
      _searchOpen = false;
      _resetPage();
    });
  }

  void _clearQuery() {
    _searchController.clear();
    setState(() {
      _query = '';
      _resetPage();
    });
    _searchFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    final state = ref.watch(deckTabProvider);
    final stats =
        ref.watch(vocabularyStatsProvider).valueOrNull ??
        const VocabularyStats();
    final dueCount = ref.watch(dueCountProvider).valueOrNull ?? 0;
    final books =
        ref.watch(booksProvider(const LibraryQuery())).valueOrNull ??
        const <BookListItem>[];
    final deckAsync = ref.watch(
      deckProvider(
        DeckQuery(
          state: state,
          query: _query,
          bookId: _bookFilter,
          sortByDue: state == VocabularyState.learning,
        ),
      ),
    );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final column = PageColumn.fit(constraints.maxWidth);
            final horizontal = column.contentInset;
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
                  _DeckHeader(
                    selected: state,
                    stats: stats,
                    dueCount: dueCount,
                    searchOpen: _searchOpen,
                    filterActive: _bookFilter != null,
                    onReview: () => _startReview(context),
                    onToggleSearch: _toggleSearch,
                    onFilter: () => _pickBookFilter(books),
                    onSelected: _selectState,
                  ),
                  const SizedBox(height: 20),
                  if (_searchOpen) ...[
                    BubbleSearchField(
                      controller: _searchController,
                      focusNode: _searchFocus,
                      hintText: 'Search ${state.label.toLowerCase()} words',
                      query: _query,
                      onChanged: (value) => setState(() {
                        _query = value;
                        _resetPage();
                      }),
                      onClear: _clearQuery,
                    ),
                    const SizedBox(height: 14),
                  ],
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, inner) {
                        final rows = math.max(
                          1,
                          ((inner.maxHeight - _pagerRoom) / _rowExtent).floor(),
                        );
                        final items = deckAsync.valueOrNull;
                        final pageCount = items == null || items.isEmpty
                            ? 1
                            : ((items.length + rows - 1) ~/ rows);
                        final pageIndex = _page.clamp(0, pageCount - 1);
                        final pageItems = items == null
                            ? const <DeckEntry>[]
                            : items
                                  .skip(pageIndex * rows)
                                  .take(rows)
                                  .toList(growable: false);

                        final Widget body;
                        if (deckAsync.hasError) {
                          body = Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Text(
                                'Could not load the deck: '
                                '${deckAsync.error}',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: palette.danger),
                              ),
                            ),
                          );
                        } else if (items == null) {
                          body = const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (items.isEmpty) {
                          body = EmptyState(
                            icon: _stateIcon(state),
                            title: _emptyTitle(state),
                          );
                        } else {
                          body = Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (
                                var index = 0;
                                index < pageItems.length;
                                index++
                              )
                                SizedBox(
                                  height: _rowExtent,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.topCenter,
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                              maxWidth:
                                                  PageGeometry.innerMaxWidth,
                                            ),
                                            child: _DeckRow(
                                              entry: pageItems[index],
                                              onTap: () => showVocabularyPanel(
                                                context,
                                                ref,
                                                match: SurfaceMatch(
                                                  surfaceForm: pageItems[index]
                                                      .vocabulary
                                                      .lemma,
                                                  lemma: pageItems[index]
                                                      .vocabulary
                                                      .lemma,
                                                  vocabularyId: pageItems[index]
                                                      .vocabulary
                                                      .id,
                                                  senseLabel: pageItems[index]
                                                      .vocabulary
                                                      .senseLabel,
                                                  state: pageItems[index].state,
                                                ),
                                              ),
                                              onAction: (action) =>
                                                  _handleAction(
                                                    context,
                                                    pageItems[index],
                                                    action,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (index < pageItems.length - 1)
                                        Align(
                                          alignment: Alignment.topCenter,
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                              maxWidth:
                                                  PageGeometry.innerMaxWidth,
                                            ),
                                            child: Divider(
                                              height: 1,
                                              thickness: 1,
                                              color: palette.line,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                            ],
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
                          // This overlay already lives inside the padded
                          // content column, so it sits flush with Home's pager.
                          right: 0,
                          child: body,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _startReview(BuildContext context) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const ReviewSessionPage()));
  }

  Future<void> _pickBookFilter(List<BookListItem> books) async {
    final choice = await showModalBottomSheet<_BookFilterChoice>(
      context: context,
      showDragHandle: true,
      builder: (_) => _BookFilterSheet(books: books, current: _bookFilter),
    );
    if (choice == null || !mounted) return;
    setState(() {
      _bookFilter = choice.bookId;
      _resetPage();
    });
  }

  Future<void> _handleAction(
    BuildContext context,
    DeckEntry entry,
    String action,
  ) async {
    final app = ref.read(appServicesProvider);
    switch (action) {
      case 'learning':
        await app.review.addToLearning(entry.vocabulary.id);
      case 'known':
        await app.review.markKnown(entry.vocabulary.id);
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Updated ${entry.vocabulary.lemma}.')),
      );
    }
  }

  String _emptyTitle(VocabularyState state) => switch (state) {
    VocabularyState.learning => 'Your review queue is clear',
    _ => 'No Known words yet',
  };

  IconData _stateIcon(VocabularyState state) => switch (state) {
    VocabularyState.learning => Icons.auto_stories_outlined,
    _ => Icons.check_circle_outline,
  };
}

class _DeckHeader extends StatelessWidget {
  const _DeckHeader({
    required this.selected,
    required this.stats,
    required this.dueCount,
    required this.searchOpen,
    required this.filterActive,
    required this.onReview,
    required this.onToggleSearch,
    required this.onFilter,
    required this.onSelected,
  });

  final VocabularyState selected;
  final VocabularyStats stats;
  final int dueCount;
  final bool searchOpen;
  final bool filterActive;
  final VoidCallback onReview;
  final VoidCallback onToggleSearch;
  final VoidCallback onFilter;
  final ValueChanged<VocabularyState> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        // Five bubbles plus the title do not fit on phone-width headers, so
        // the bar drops beneath the title instead of squeezing both.
        final narrow = constraints.maxWidth < 480;
        final title = Text(
          'Your deck',
          style: Theme.of(context).textTheme.displayMedium
              ?.copyWith(fontSize: narrow ? 30 : 36),
        );
        final bubbles = BubbleBar(
          children: [
            BubbleIconButton(
              icon: Icons.play_arrow_rounded,
              tooltip: dueCount == 0
                  ? 'No reviews due'
                  : 'Review $dueCount due',
              label: '$dueCount',
              onTap: dueCount == 0 ? null : onReview,
            ),
            BubbleIconButton(
              icon: Icons.search_rounded,
              tooltip: searchOpen ? 'Close search' : 'Search deck',
              onTap: onToggleSearch,
              selected: searchOpen,
            ),
            BubbleIconButton(
              icon: Icons.filter_list_rounded,
              tooltip: filterActive ? 'Change book filter' : 'Filter by book',
              onTap: onFilter,
              selected: filterActive,
            ),
            BubbleIconButton(
              icon: selected == VocabularyState.learning
                  ? Icons.auto_stories
                  : Icons.auto_stories_outlined,
              tooltip: 'Learning · ${formatCount(stats.learning)}',
              onTap: () => onSelected(VocabularyState.learning),
              selected: selected == VocabularyState.learning,
              selectedColor: palette.ink,
              selectedBackground: palette.ink.withValues(alpha: 0.14),
            ),
            BubbleIconButton(
              icon: selected == VocabularyState.known
                  ? Icons.check_circle
                  : Icons.check_circle_outline,
              tooltip: 'Known · ${formatCount(stats.known)}',
              onTap: () => onSelected(VocabularyState.known),
              selected: selected == VocabularyState.known,
              selectedColor: palette.ink,
              selectedBackground: palette.ink.withValues(alpha: 0.14),
            ),
          ],
        );
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: title),
            const SizedBox(width: 12),
            bubbles,
          ],
        );
      },
    );
  }
}

class _DeckRow extends StatelessWidget {
  const _DeckRow({
    required this.entry,
    required this.onTap,
    required this.onAction,
  });

  final DeckEntry entry;
  final VoidCallback onTap;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    final format = DateFormat.yMMMd().add_jm();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: palette.surfaceMuted,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 14, 4, 14),
          child: Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: statusColor(palette, entry.state),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            entry.vocabulary.lemma,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Literata',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.1,
                              color: palette.ink,
                            ),
                          ),
                        ),
                        if (entry.vocabulary.senseLabel != null &&
                            entry.vocabulary.senseLabel!.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Text(
                            '· ${entry.vocabulary.senseLabel}',
                            style: TextStyle(
                              fontSize: 11,
                              color: palette.inkMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      entry.definition ?? 'Tap to add a meaning',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: palette.inkMuted,
                        fontStyle: entry.definition == null
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '${entry.occurrenceCount} '
                          '${entry.occurrenceCount == 1 ? 'mention' : 'mentions'}',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: palette.inkMuted,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${entry.bookCount} '
                          '${entry.bookCount == 1 ? 'book' : 'books'}',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: palette.inkMuted,
                          ),
                        ),
                        if (entry.state == VocabularyState.learning &&
                            entry.fsrsDue != null) ...[
                          const SizedBox(width: 10),
                          Text(
                            'Due ${format.format(entry.fsrsDue!)}',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: palette.ink,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_horiz, color: palette.inkMuted, size: 18),
                onSelected: onAction,
                itemBuilder: (context) => [
                  if (entry.state != VocabularyState.known)
                    const PopupMenuItem(
                      value: 'known',
                      child: Text('Mark Known'),
                    ),
                  if (entry.state != VocabularyState.learning)
                    const PopupMenuItem(
                      value: 'learning',
                      child: Text('Add to Learning'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Distinguishes "All books" (a null [bookId]) from dismissing the sheet
/// (a null choice).
class _BookFilterChoice {
  const _BookFilterChoice(this.bookId);

  final String? bookId;
}

class _BookFilterSheet extends StatelessWidget {
  const _BookFilterSheet({required this.books, required this.current});

  final List<BookListItem> books;
  final String? current;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 10),
            child: Text(
              'Filter by book',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                _BookFilterTile(
                  title: 'All books',
                  icon: Icons.library_books_outlined,
                  selected: current == null,
                  onTap: () =>
                      Navigator.pop(context, const _BookFilterChoice(null)),
                ),
                for (final item in books)
                  _BookFilterTile(
                    title: item.book.title,
                    icon: Icons.menu_book_outlined,
                    selected: current == item.book.id,
                    onTap: () =>
                        Navigator.pop(context, _BookFilterChoice(item.book.id)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _BookFilterTile extends StatelessWidget {
  const _BookFilterTile({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(
        icon,
        size: 20,
        color: selected ? palette.accent : palette.inkMuted,
      ),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: selected
          ? Icon(Icons.check_rounded, size: 18, color: palette.accent)
          : null,
      onTap: onTap,
    );
  }
}
