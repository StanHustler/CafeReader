import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../app/providers.dart';
import '../../core/backup/backup_service.dart';
import '../../core/design/app_theme.dart';
import '../../data/local/book_import_service.dart';
import '../../domain/epub/txt_parser.dart';

class ImportPick {
  const ImportPick({required this.path, required this.format});
  final String path;
  final String format;
}

Future<ImportResult?> showBookImportFlow(
  BuildContext context,
  WidgetRef ref,
) async {
  final pick = await _pickBook(context);
  if (pick == null || !context.mounted) return null;
  final importService = ref.read(importServiceProvider);
  var encoding = TextEncodingChoice.auto;
  while (true) {
    if (!context.mounted) return null;
    final progress = ValueNotifier<ImportProgress>(
      const ImportProgress(
        stage: ImportStage.reading,
        message: 'Preparing import…',
      ),
    );
    var dialogOpen = true;
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => PopScope(
          canPop: false,
          child: _ImportProgressDialog(progress: progress),
        ),
      ),
    );
    try {
      final result = await importService.importFile(
        sourcePath: pick.path,
        format: pick.format,
        encoding: encoding,
        onProgress: (value) {
          progress.value = value;
        },
      );
      if (context.mounted && dialogOpen) {
        Navigator.of(context, rootNavigator: true).pop();
        dialogOpen = false;
      }
      progress.dispose();
      if (!context.mounted) return result;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.alreadyExisted
                ? 'Restored ${result.title} to your library.'
                : 'Imported ${result.title}: ${result.chapterCount} chapters, '
                      '${result.uniqueWordCount} unique words.',
          ),
        ),
      );
      return result;
    } on TextDecodeException catch (error) {
      if (context.mounted && dialogOpen) {
        Navigator.of(context, rootNavigator: true).pop();
        dialogOpen = false;
      }
      progress.dispose();
      if (!context.mounted) return null;
      final choice = await _chooseEncoding(context, error.message);
      if (choice == null) return null;
      encoding = choice;
      continue;
    } on AlreadyImportedException catch (error) {
      if (context.mounted && dialogOpen) {
        Navigator.of(context, rootNavigator: true).pop();
        dialogOpen = false;
      }
      progress.dispose();
      if (!context.mounted) return null;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Already in your library'),
          content: Text(error.toString()),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return null;
    } catch (error) {
      if (context.mounted && dialogOpen) {
        Navigator.of(context, rootNavigator: true).pop();
        dialogOpen = false;
      }
      progress.dispose();
      if (!context.mounted) return null;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Could not import this book'),
          content: Text(_humanError(error)),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return null;
    }
  }
}

Future<ImportPick?> _pickBook(BuildContext context) async {
  final choice = await showModalBottomSheet<String>(
    context: context,
    builder: (context) {
      final palette = CafePalette.of(context);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add a book',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              Text(
                'Your original file is kept in your local library.',
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: palette.inkMuted),
              ),
              const SizedBox(height: 20),
              _ImportTypeTile(
                icon: Icons.auto_stories_outlined,
                title: 'EPUB',
                subtitle: 'Chapters, cover, and table of contents',
                onTap: () => Navigator.pop(context, 'epub'),
              ),
              const SizedBox(height: 10),
              _ImportTypeTile(
                icon: Icons.description_outlined,
                title: 'Plain text',
                subtitle: 'TXT with UTF-8, UTF-16, or Western encoding',
                onTap: () => Navigator.pop(context, 'txt'),
              ),
            ],
          ),
        ),
      );
    },
  );
  if (choice == null || !context.mounted) return null;
  final file = await FilePicker.pickFile(
    dialogTitle: choice == 'epub' ? 'Choose an EPUB book' : 'Choose a TXT book',
    type: FileType.custom,
    allowedExtensions: [choice],
  );
  final path = file?.path;
  if (path == null) return null;
  final extension = p.extension(path).replaceFirst('.', '').toLowerCase();
  if (extension != 'epub' && extension != 'txt') {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose an .epub or .txt file.')),
      );
    }
    return null;
  }
  return ImportPick(path: path, format: extension);
}

Future<TextEncodingChoice?> _chooseEncoding(
  BuildContext context,
  String message,
) {
  return showDialog<TextEncodingChoice>(
    context: context,
    builder: (context) => SimpleDialog(
      title: const Text('Choose text encoding'),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
          child: Text(message),
        ),
        for (final entry in const [
          (TextEncodingChoice.utf8, 'UTF-8'),
          (TextEncodingChoice.utf16le, 'UTF-16 little endian'),
          (TextEncodingChoice.utf16be, 'UTF-16 big endian'),
          (TextEncodingChoice.latin1, 'Western (ISO-8859-1)'),
        ])
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, entry.$1),
            child: Text(entry.$2),
          ),
      ],
    ),
  );
}

String _humanError(Object error) {
  final text = error.toString();
  if (text.startsWith('Exception: ')) return text.substring(11);
  return text;
}

class _ImportTypeTile extends StatelessWidget {
  const _ImportTypeTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return Material(
      color: palette.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: palette.line),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: palette.surfaceMuted,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: palette.accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: palette.inkMuted),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: palette.inkMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImportProgressDialog extends StatelessWidget {
  const _ImportProgressDialog({required this.progress});
  final ValueNotifier<ImportProgress> progress;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ValueListenableBuilder<ImportProgress>(
          valueListenable: progress,
          builder: (context, value, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: palette.accentSoft,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.menu_book_outlined,
                        color: palette.accent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Importing book',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Text(
                  value.message,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: value.fraction,
                    minHeight: 6,
                    backgroundColor: palette.surfaceMuted,
                  ),
                ),
                if (value.total > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${value.current} / ${value.total}',
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: palette.inkMuted),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

Future<BackupArtifact?> createBackupWithProgress(
  BuildContext context,
  WidgetRef ref, {
  String? bookId,
}) async {
  final backupService = ref.read(backupServiceProvider);
  final progress = ValueNotifier<String>('Preparing backup…');
  var dialogOpen = true;
  unawaited(
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('Creating backup'),
          content: ValueListenableBuilder<String>(
            valueListenable: progress,
            builder: (context, value, _) => Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 14),
                Expanded(child: Text(value)),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  try {
    progress.value = bookId == null
        ? 'Snapshotting library and books…'
        : 'Snapshotting book data…';
    final artifact = await backupService.createBackup(bookId: bookId);
    if (context.mounted && dialogOpen) {
      Navigator.of(context, rootNavigator: true).pop();
      dialogOpen = false;
    }
    await ref
        .read(settingsRepositoryProvider)
        .setMetadata(
          'last_backup_at',
          DateTime.now().toUtc().toIso8601String(),
        );
    return artifact;
  } catch (error) {
    if (context.mounted && dialogOpen) {
      Navigator.of(context, rootNavigator: true).pop();
      dialogOpen = false;
    }
    if (context.mounted) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Backup failed'),
          content: Text(_humanError(error)),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
    return null;
  } finally {
    progress.dispose();
  }
}

Future<bool> saveFileWithPicker(
  BuildContext context,
  File source, {
  required String suggestedName,
  String extension = 'cfr',
}) async {
  try {
    final location = await getSaveLocation(
      suggestedName: suggestedName,
      acceptedTypeGroups: [
        XTypeGroup(label: 'CafeReader', extensions: [extension]),
      ],
    );
    if (location == null) return false;
    await source.copy(location.path);
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Saved to ${location.path}')));
    }
    return true;
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save file: ${_humanError(error)}')),
      );
    }
    return false;
  }
}
