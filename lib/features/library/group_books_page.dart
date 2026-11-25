import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/design/subpage.dart';
import 'library_book_grid.dart';

/// One group opened from its library card. Books are shown with the same grid
/// and pager as the home library.
class BookGroupPage extends ConsumerWidget {
  const BookGroupPage({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(groupProvider(groupId)).valueOrNull;
    return SubpageScaffold(
      showHeader: false,
      scrollable: false,
      child: LibraryBookGrid(
        groupId: groupId,
        showGroups: false,
        query: '',
        headerBuilder: (context, compact) => SubpageHeader(
          title: group?.name ?? 'Group',
          subtitle: group == null
              ? null
              : '${group.bookCount} ${group.bookCount == 1 ? 'book' : 'books'}',
          style: SubpageHeaderStyle.large,
          compact: compact,
        ),
      ),
    );
  }
}
