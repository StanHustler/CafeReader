import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/design/app_theme.dart';
import '../../data/repository/library_repository.dart';

/// Opens the "add to group" chooser for the current selection.
///
/// Resolves to true once the books were added to an existing group or a newly
/// created one, so the caller can leave selection mode.
Future<bool> showAddToGroupSheet(
  BuildContext context, {
  required List<String> bookIds,
}) async {
  if (bookIds.isEmpty) return false;
  final result = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (_) => _AddToGroupSheet(bookIds: bookIds),
  );
  return result ?? false;
}

class _AddToGroupSheet extends ConsumerWidget {
  const _AddToGroupSheet({required this.bookIds});

  final List<String> bookIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = CafePalette.of(context);
    final groups = ref.watch(groupsProvider);
    final count = bookIds.length;
    final noun = count == 1 ? 'book' : 'books';
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 520),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 4),
                child: Text(
                  'Add $count $noun to a group',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Text(
                  'Choose an existing group or start a new one.',
                  style: TextStyle(fontSize: 12.5, color: palette.inkMuted),
                ),
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                leading: Icon(
                  Icons.create_new_folder_outlined,
                  size: 20,
                  color: palette.accent,
                ),
                title: const Text('New group'),
                subtitle: const Text('Name a new group for these books'),
                onTap: () => _createGroup(context, ref),
              ),
              groups.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                error: (error, _) => Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: Text(
                    'Could not load groups: $error',
                    style: TextStyle(fontSize: 12.5, color: palette.danger),
                  ),
                ),
                data: (items) {
                  if (items.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 4, 24, 4),
                        child: Text(
                          'Existing groups',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: palette.inkMuted,
                          ),
                        ),
                      ),
                      for (final group in items)
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                          ),
                          leading: Icon(
                            Icons.folder_outlined,
                            size: 20,
                            color: palette.inkMuted,
                          ),
                          title: Text(
                            group.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(_bookCountLabel(group.bookCount)),
                          onTap: () => _addToExisting(context, ref, group),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addToExisting(
    BuildContext context,
    WidgetRef ref,
    BookGroupSummary group,
  ) async {
    await _run(
      context,
      () => ref
          .read(libraryRepositoryProvider)
          .addBooksToGroup(group.id, bookIds),
      failure: 'Could not add books to “${group.name}”',
    );
  }

  Future<void> _createGroup(BuildContext context, WidgetRef ref) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const _CreateGroupDialog(),
    );
    if (name == null) return;
    if (!context.mounted) return;
    await _run(
      context,
      () => ref
          .read(libraryRepositoryProvider)
          .createGroup(name: name, bookIds: bookIds),
      failure: 'Could not create the group',
    );
  }

  Future<void> _run(
    BuildContext context,
    Future<Object?> Function() action, {
    required String failure,
  }) async {
    try {
      await action();
      if (context.mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$failure: $error')));
    }
  }
}

class _CreateGroupDialog extends StatefulWidget {
  const _CreateGroupDialog();

  @override
  State<_CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<_CreateGroupDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New group'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(hintText: 'Group name'),
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _controller.text.trim().isEmpty ? null : _submit,
          child: const Text('Create'),
        ),
      ],
    );
  }
}

String _bookCountLabel(int count) => '$count ${count == 1 ? 'book' : 'books'}';
