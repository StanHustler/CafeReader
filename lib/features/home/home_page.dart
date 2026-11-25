import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/design/app_theme.dart';
import '../../core/design/common_widgets.dart';
import '../../core/design/page_pager.dart';
import '../../data/repository/library_repository.dart';
import '../library/group_books_page.dart';
import '../library/group_flow.dart';
import '../library/import_export_flow.dart';
import '../library/library_book_grid.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _searchOpen = false;
  String _query = '';
  LibrarySort _sort = LibrarySort.recentlyRead;
  final Set<String> _selectedBookIds = <String>{};
  final Set<String> _selectedGroupIds = <String>{};

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
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
    });
  }

  void _clearQuery() {
    _searchController.clear();
    setState(() => _query = '');
    _searchFocus.requestFocus();
  }

  void _beginSelection() {
    _searchController.clear();
    _searchFocus.unfocus();
  }

  /// Long-press or right-click starts selection mode with this item selected.
  void _selectBook(BookListItem item) {
    if (_selectedBookIds.contains(item.book.id)) return;
    _beginSelection();
    setState(() {
      _selectedBookIds.add(item.book.id);
      _query = '';
      _searchOpen = false;
    });
  }

  void _selectGroup(BookGroupSummary group) {
    if (_selectedGroupIds.contains(group.id)) return;
    _beginSelection();
    setState(() {
      _selectedGroupIds.add(group.id);
      _query = '';
      _searchOpen = false;
    });
  }

  void _toggleBookSelection(BookListItem item) {
    setState(() {
      if (!_selectedBookIds.remove(item.book.id)) {
        _selectedBookIds.add(item.book.id);
      }
    });
  }

  void _toggleGroupSelection(BookGroupSummary group) {
    setState(() {
      if (!_selectedGroupIds.remove(group.id)) {
        _selectedGroupIds.add(group.id);
      }
    });
  }

  void _cancelSelection() {
    _clearSelection();
  }

  void _clearSelection() {
    setState(() {
      _selectedBookIds.clear();
      _selectedGroupIds.clear();
    });
  }

  Future<void> _deleteSelected() async {
    final groupIds = List<String>.of(_selectedGroupIds);
    final bookIds = <String>{..._selectedBookIds};
    if (groupIds.isNotEmpty) {
      try {
        bookIds.addAll(
          await ref.read(libraryRepositoryProvider).bookIdsInGroups(groupIds),
        );
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not read group contents: $error')),
        );
        return;
      }
    }
    if (!mounted) return;
    final bookCount = bookIds.length;
    final groupCount = groupIds.length;
    if (bookCount == 0 && groupCount == 0) return;

    final parts = <String>[
      if (groupCount > 0) '$groupCount ${groupCount == 1 ? 'group' : 'groups'}',
      if (bookCount > 0) '$bookCount ${bookCount == 1 ? 'book' : 'books'}',
    ];
    final confirmed = await confirmAction(
      context,
      title: 'Remove ${parts.join(' and ')}?',
      message: groupCount > 0
          ? 'The selected groups and every book inside them will be removed from this library. Your global vocabulary states are kept.'
          : 'The selected books and their word indexes will be removed from this library. Your global vocabulary states are kept.',
      confirmLabel: 'Remove',
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    try {
      if (bookIds.isNotEmpty) {
        await ref.read(libraryRepositoryProvider).deleteBooks(bookIds);
      }
      if (groupIds.isNotEmpty) {
        await ref.read(libraryRepositoryProvider).deleteGroups(groupIds);
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not remove items: $error')));
      return;
    }
    if (!mounted) return;
    _clearSelection();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Removed ${parts.join(' and ')}')));
  }

  Future<void> _ungroupSelected() async {
    final groupIds = List<String>.of(_selectedGroupIds);
    if (groupIds.isEmpty) return;
    final count = groupIds.length;
    final confirmed = await confirmAction(
      context,
      title: 'Ungroup $count ${count == 1 ? 'group' : 'groups'}?',
      message: 'The groups will be removed and their books will return to your library.',
      confirmLabel: 'Ungroup',
    );
    if (!confirmed || !mounted) return;
    try {
      await ref.read(libraryRepositoryProvider).deleteGroups(groupIds);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not ungroup: $error')));
      return;
    }
    if (!mounted) return;
    _clearSelection();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ungrouped $count ${count == 1 ? 'group' : 'groups'}'),
      ),
    );
  }

  Future<void> _groupSelected() async {
    if (_selectedBookIds.isEmpty) return;
    final added = await showAddToGroupSheet(
      context,
      bookIds: List<String>.of(_selectedBookIds),
    );
    if (added && mounted) {
      _clearSelection();
    }
  }

  void _openGroup(BookGroupSummary group) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => BookGroupPage(groupId: group.id)),
    );
  }

  Future<void> _pickSort() async {
    final selected = await showModalBottomSheet<LibrarySort>(
      context: context,
      showDragHandle: true,
      builder: (_) => _SortSheet(current: _sort),
    );
    if (selected != null && selected != _sort && mounted) {
      setState(() => _sort = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: LibraryBookGrid(
        query: _query,
        sort: _sort,
        excludeGroupedBooks: true,
        selectedBookIds: _selectedBookIds,
        selectedGroupIds: _selectedGroupIds,
        onBookSelectRequest: _selectBook,
        onBookToggleSelection: _toggleBookSelection,
        onGroupSelectRequest: _selectGroup,
        onGroupToggleSelection: _toggleGroupSelection,
        onOpenGroup: _openGroup,
        headerBuilder: (context, compact) => _Header(
          compact: compact,
          searchOpen: _searchOpen,
          controller: _searchController,
          focusNode: _searchFocus,
          query: _query,
          sort: _sort,
          selectedBookCount: _selectedBookIds.length,
          selectedGroupCount: _selectedGroupIds.length,
          onImport: () => showBookImportFlow(context, ref),
          onToggleSearch: _toggleSearch,
          onQueryChanged: (value) => setState(() => _query = value),
          onClearQuery: _clearQuery,
          onSort: _pickSort,
          onGroup: _groupSelected,
          onUngroup: _ungroupSelected,
          onDelete: _deleteSelected,
          onCancelSelection: _cancelSelection,
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.compact,
    required this.searchOpen,
    required this.controller,
    required this.focusNode,
    required this.query,
    required this.sort,
    required this.selectedBookCount,
    required this.selectedGroupCount,
    required this.onImport,
    required this.onToggleSearch,
    required this.onQueryChanged,
    required this.onClearQuery,
    required this.onSort,
    required this.onGroup,
    required this.onUngroup,
    required this.onDelete,
    required this.onCancelSelection,
  });

  final bool compact;
  final bool searchOpen;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String query;
  final LibrarySort sort;
  final int selectedBookCount;
  final int selectedGroupCount;
  final VoidCallback onImport;
  final VoidCallback onToggleSearch;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClearQuery;
  final VoidCallback onSort;
  final VoidCallback onGroup;
  final VoidCallback onUngroup;
  final VoidCallback onDelete;
  final VoidCallback onCancelSelection;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    final selectionCount = selectedBookCount + selectedGroupCount;
    final selecting = selectionCount > 0;
    final title = Text(
      'My Books',
      style: Theme.of(context).textTheme.displayMedium?.copyWith(
        fontSize: compact ? 30 : 36,
        letterSpacing: -0.8,
        color: palette.ink,
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (selecting)
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: BubbleBar(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            '$selectionCount',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: palette.inkMuted,
                            ),
                          ),
                        ),
                        if (selectedBookCount > 0)
                          BubbleIconButton(
                            icon: Icons.folder_copy_outlined,
                            tooltip: 'Add selected books to a group',
                            label: 'Group',
                            dense: compact,
                            onTap: onGroup,
                          ),
                        if (selectedGroupCount > 0)
                          BubbleIconButton(
                            icon: Icons.folder_off_outlined,
                            tooltip:
                                'Return the selected groups’ books to Home',
                            label: 'Ungroup',
                            dense: compact,
                            onTap: onUngroup,
                          ),
                        BubbleIconButton(
                          icon: Icons.delete_outline_rounded,
                          tooltip: 'Remove selected items',
                          label: 'Delete',
                          dense: compact,
                          onTap: onDelete,
                        ),
                        BubbleIconButton(
                          icon: Icons.close_rounded,
                          tooltip: 'Exit selection',
                          label: 'Cancel',
                          dense: compact,
                          onTap: onCancelSelection,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else ...[
              Expanded(child: title),
              BubbleBar(
                children: [
                  BubbleIconButton(
                    icon: Icons.add_rounded,
                    tooltip: 'Import a book',
                    onTap: onImport,
                  ),
                  BubbleIconButton(
                    icon: Icons.search_rounded,
                    tooltip: searchOpen ? 'Close search' : 'Search library',
                    onTap: onToggleSearch,
                    selected: searchOpen,
                  ),
                  BubbleIconButton(
                    icon: Icons.sort_rounded,
                    tooltip: 'Sort books',
                    onTap: onSort,
                    selected: sort != LibrarySort.recentlyRead,
                  ),
                ],
              ),
            ],
          ],
        ),
        if (searchOpen && !selecting) ...[
          const SizedBox(height: 16),
          BubbleSearchField(
            controller: controller,
            focusNode: focusNode,
            hintText: 'Search by title or author',
            query: query,
            onChanged: onQueryChanged,
            onClear: onClearQuery,
          ),
        ],
      ],
    );
  }
}

class _SortSheet extends StatelessWidget {
  const _SortSheet({required this.current});

  final LibrarySort current;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 10),
            child: Text(
              'Sort books',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          for (final option in LibrarySort.values)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: Icon(
                _iconFor(option),
                size: 20,
                color: option == current ? palette.accent : palette.inkMuted,
              ),
              title: Text(option.label),
              trailing: option == current
                  ? Icon(Icons.check_rounded, size: 18, color: palette.accent)
                  : null,
              onTap: () => Navigator.pop(context, option),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  static IconData _iconFor(LibrarySort sort) => switch (sort) {
    LibrarySort.recentlyRead => Icons.history_rounded,
    LibrarySort.recentlyAdded => Icons.schedule_rounded,
    LibrarySort.title => Icons.sort_by_alpha_rounded,
    LibrarySort.author => Icons.person_outline_rounded,
  };
}
