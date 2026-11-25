import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../app/providers.dart';
import '../../core/design/app_theme.dart';
import '../../core/design/common_widgets.dart';
import '../../data/local/dictionary_file_parser.dart';
import '../../data/repository/dictionary_repository.dart';
import '../settings/settings_widgets.dart';
import 'dictionary_icon.dart';

/// Opens the dictionary source manager: enable, disable or remove sources and
/// add new ones.
Future<void> showDictionaryManager(BuildContext context) {
  return _showSheet(context, const DictionaryManagerSheet());
}

/// Opens only the add-source actions. The Dictionary page's + bubble uses this
/// sheet; the settings bubble opens the full manager.
Future<void> showAddDictionarySheet(BuildContext context) {
  return _showSheet(
    context,
    const DictionaryManagerSheet(manageSources: false),
  );
}

Future<void> _showSheet(BuildContext context, Widget sheet) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => sheet,
  );
}

class DictionaryManagerSheet extends ConsumerStatefulWidget {
  const DictionaryManagerSheet({super.key, this.manageSources = true});

  /// When false only the "add source" actions are shown and the sheet closes
  /// after one source is created.
  final bool manageSources;

  @override
  ConsumerState<DictionaryManagerSheet> createState() =>
      _DictionaryManagerSheetState();
}

class _DictionaryManagerSheetState
    extends ConsumerState<DictionaryManagerSheet> {
  bool _busy = false;

  Future<void> _importLocal() async {
    final picked = await FilePicker.pickFile(
      dialogTitle: 'Choose a dictionary file',
      type: FileType.custom,
      allowedExtensions: ['json', 'csv', 'tsv', 'txt'],
    );
    final path = picked?.path;
    if (path == null || !mounted) return;
    setState(() => _busy = true);
    try {
      final content = utf8.decode(
        await File(path).readAsBytes(),
        allowMalformed: true,
      );
      final parsed = DictionaryFileParser.parse(
        content,
        fileName: p.basename(path),
      );
      final name = (parsed.name ?? p.basenameWithoutExtension(path)).trim();
      await ref
          .read(dictionaryRepositoryProvider)
          .importLocal(
            name: name,
            translations: parsed.entries,
            source: p.basename(path),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Imported ${parsed.entries.length} entries into $name.',
          ),
        ),
      );
      if (!widget.manageSources) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dictionary import failed: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _addOnline() async {
    final input = await showDialog<_OnlineDictionaryInput>(
      context: context,
      builder: (_) => const _OnlineDictionaryDialog(),
    );
    if (input == null || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(dictionaryRepositoryProvider)
          .addOnline(name: input.name, urlTemplate: input.urlTemplate);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added online dictionary “${input.name}”.')),
      );
      if (!widget.manageSources) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not add dictionary: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _setEnabled(DictionarySource source, bool enabled) async {
    await ref.read(dictionaryRepositoryProvider).setEnabled(source.id, enabled);
  }

  Future<void> _delete(DictionarySource source) async {
    final confirmed = await confirmAction(
      context,
      title: 'Remove “${source.name}”?',
      message: 'Its entries will be deleted from this device.',
      confirmLabel: 'Remove',
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    await ref.read(dictionaryRepositoryProvider).deleteDictionary(source.id);
  }

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    final dictionariesAsync = ref.watch(dictionariesProvider);
    final dictionaries = dictionariesAsync.valueOrNull ?? const [];
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.86,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.manageSources ? 'Dictionaries' : 'Add dictionary',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Done'),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                widget.manageSources
                    ? 'Search combines every enabled source. Local dictionaries '
                          'are stored in the database; online dictionaries are '
                          'queried when you look a word up.'
                    : 'Import a local file or connect an online source.',
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: palette.inkMuted, height: 1.45),
              ),
              if (_busy) ...[
                const SizedBox(height: 14),
                const LinearProgressIndicator(minHeight: 2),
              ],
              const SizedBox(height: 18),
              if (widget.manageSources)
                SettingsSection(
                  title: 'Sources',
                  children: [
                    if (dictionariesAsync.isLoading && dictionaries.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        child: Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    else if (dictionariesAsync.hasError)
                      SettingsInfoTile(
                        icon: Icons.error_outline,
                        title: 'Could not load dictionaries',
                        body: '${dictionariesAsync.error}',
                      )
                    else
                      for (final source in dictionaries)
                        _DictionaryRow(
                          source: source,
                          busy: _busy,
                          onEnabled: (value) => _setEnabled(source, value),
                          onDelete: source.kind == DictionaryKind.builtin
                              ? null
                              : () => _delete(source),
                        ),
                  ],
                ),
              SettingsSection(
                title: widget.manageSources ? 'Add a source' : 'Source type',
                children: [
                  SettingsActionTile(
                    icon: Icons.upload_file_outlined,
                    title: 'Import local dictionary',
                    subtitle:
                        'JSON, CSV or TSV with word and meaning columns. Entries '
                        'stay on this device.',
                    onTap: _busy ? null : _importLocal,
                  ),
                  SettingsActionTile(
                    icon: Icons.cloud_download_outlined,
                    title: 'Add online dictionary',
                    subtitle:
                        'A URL template containing {word}. JSON or plain text '
                        'responses are supported.',
                    onTap: _busy ? null : _addOnline,
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

class _DictionaryRow extends StatelessWidget {
  const _DictionaryRow({
    required this.source,
    required this.busy,
    required this.onEnabled,
    this.onDelete,
  });

  final DictionarySource source;
  final bool busy;
  final ValueChanged<bool> onEnabled;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          DictionaryIcon(kind: source.kind, size: 30),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  source.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: palette.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _subtitle(source),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.5, color: palette.inkMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(value: source.enabled, onChanged: busy ? null : onEnabled),
          if (onDelete != null)
            IconButton(
              tooltip: 'Remove dictionary',
              onPressed: busy ? null : onDelete,
              icon: Icon(
                Icons.delete_outline_rounded,
                size: 19,
                color: palette.inkMuted,
              ),
            ),
        ],
      ),
    );
  }

  static String _subtitle(DictionarySource source) {
    return switch (source.kind) {
      DictionaryKind.builtin => 'Built-in · bundled WordNet glosses',
      DictionaryKind.local =>
        'Local · ${source.entryCount} entries'
            '${source.source == null ? '' : ' · ${source.source}'}',
      DictionaryKind.online => 'Online · ${source.source ?? ''}',
    };
  }
}

class _OnlineDictionaryInput {
  const _OnlineDictionaryInput({required this.name, required this.urlTemplate});

  final String name;
  final String urlTemplate;
}

class _OnlineDictionaryDialog extends StatefulWidget {
  const _OnlineDictionaryDialog();

  @override
  State<_OnlineDictionaryDialog> createState() =>
      _OnlineDictionaryDialogState();
}

class _OnlineDictionaryDialogState extends State<_OnlineDictionaryDialog> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _url = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _url.dispose();
    super.dispose();
  }

  bool get _valid {
    final url = _url.text.trim();
    final uri = Uri.tryParse(url.replaceAll('{word}', 'test'));
    return _name.text.trim().isNotEmpty &&
        url.contains('{word}') &&
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https');
  }

  void _submit() {
    if (!_valid) return;
    Navigator.of(context).pop(
      _OnlineDictionaryInput(
        name: _name.text.trim(),
        urlTemplate: _url.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add online dictionary'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Name'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _url,
              decoration: const InputDecoration(
                labelText: 'URL template',
                hintText: 'https://example.com/define?word={word}',
                helperText:
                    'Use {word} where the searched word belongs. JSON or plain '
                    'text responses are supported.',
                helperMaxLines: 3,
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _valid ? _submit : null,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
