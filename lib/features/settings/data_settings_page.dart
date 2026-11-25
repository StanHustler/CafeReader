import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

import '../../app/providers.dart';
import '../../core/backup/backup_service.dart';
import '../../core/design/app_theme.dart';
import '../../core/design/common_widgets.dart';
import '../../data/import_export/csv_service.dart';
import '../library/import_export_flow.dart';
import 'settings_widgets.dart';

class DataSettingsPage extends ConsumerStatefulWidget {
  const DataSettingsPage({super.key});

  @override
  ConsumerState<DataSettingsPage> createState() => _DataSettingsPageState();
}

class _DataSettingsPageState extends ConsumerState<DataSettingsPage> {
  DateTime? _lastBackupAt;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadMetadata();
  }

  Future<void> _loadMetadata() async {
    final value = await ref
        .read(settingsRepositoryProvider)
        .getMetadata('last_backup_at');
    if (mounted && value != null) {
      setState(() => _lastBackupAt = DateTime.tryParse(value)?.toLocal());
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return SettingsScaffold(
      title: 'Data',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsHero(
            icon: Icons.inventory_2_outlined,
            title: 'CafeReader archive (.cfr)',
            body: _lastBackupAt == null
                ? 'No backup created yet. Create one to capture every book, '
                      'word state and review log in a single portable file.'
                : 'Last backup ${DateFormat.yMMMd().add_jm().format(_lastBackupAt!)}',
          ),
          const SizedBox(height: 24),
          SettingsSection(
            title: 'Backup and restore',
            description:
                'OneDrive sync and .cfr backup are independent. A full restore '
                'replaces local data after first creating a safety backup.',
            children: [
              SettingsActionTile(
                icon: Icons.archive_outlined,
                title: 'Create full backup',
                subtitle: 'Snapshot the database, book files, covers, reviews and settings.',
                onTap: _busy ? null : () => _createBackup(),
              ),
              SettingsActionTile(
                icon: Icons.settings_backup_restore,
                title: 'Restore full backup',
                subtitle:
                    'Replace all local data with a .cfr after validating its '
                    'manifest, checksums, schema and safety backup.',
                onTap: _busy ? null : () => _restore(merge: false),
              ),
              SettingsActionTile(
                icon: Icons.merge_type,
                title: 'Merge a .cfr into this library',
                subtitle:
                    'Add books and learning data from another device without '
                    'deleting local books or review history.',
                onTap: _busy ? null : () => _restore(merge: true),
              ),
              SettingsActionTile(
                icon: Icons.menu_book_outlined,
                title: 'Export a single book',
                subtitle:
                    'Package one book and its vocabulary trail as a .cfr.',
                onTap: _busy ? null : () => _exportSingleBook(),
              ),
            ],
          ),
          SettingsSection(
            title: 'Vocabulary spreadsheets',
            description:
                'CSV is UTF-8 with BOM. Fields: lemma, status, meaning, '
                'created_at, sense_label.',
            children: [
              SettingsActionTile(
                icon: Icons.file_download_outlined,
                title: 'Export vocabulary CSV',
                subtitle: 'All global states and their first definition.',
                onTap: _busy ? null : () => _exportCsv(),
              ),
              SettingsActionTile(
                icon: Icons.file_upload_outlined,
                title: 'Import vocabulary CSV',
                subtitle: 'Choose whether existing statuses are preserved or updated.',
                onTap: _busy ? null : () => _importCsv(),
              ),
              SettingsActionTile(
                icon: Icons.library_books_outlined,
                title: 'Import definitions for saved words',
                subtitle:
                    'Add meanings to vocabulary already in your library (CSV '
                    'or JSON: lemma, meaning, example).',
                onTap: _busy ? null : () => _importDictionary(),
              ),
            ],
          ),
          SettingsSection(
            title: 'Single-book import',
            children: [
              SettingsActionTile(
                icon: Icons.add_to_photos_outlined,
                title: 'Import a book archive',
                subtitle:
                    'Merge a single-book .cfr, or use “Merge a .cfr” above. '
                    'Re-importing books never duplicates stable book IDs.',
                onTap: _busy ? null : () => _restore(merge: true),
              ),
            ],
          ),
          SettingsSection(
            title: 'Delete data',
            description:
                'Permanently remove books, vocabulary and learning history from '
                'this device. App settings, device identity and .cfr backups are '
                'kept.',
            children: [
              SettingsActionTile(
                icon: Icons.delete_forever_outlined,
                title: 'Delete all library data',
                subtitle:
                    'Removes every book, word index, vocabulary state, definition '
                    'and review log. This cannot be undone.',
                destructive: true,
                onTap: _busy ? null : () => _deleteAllData(),
              ),
            ],
          ),
          Text(
            'Large backups are streamed to the file system. Restore validates '
            'SHA-256 hashes and rejects ZIP path traversal before touching your '
            'library.',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: palette.inkMuted, height: 1.5),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAllData() async {
    final confirmed = await confirmAction(
      context,
      title: 'Delete all library data?',
      message:
          'Every book, word index, vocabulary state, definition and review log '
          'will be permanently removed from this device. App settings and existing '
          '.cfr backups are kept. This cannot be undone. If OneDrive sync is '
          'enabled, the remote snapshot can restore the data on the next sync.',
      confirmLabel: 'Delete everything',
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    setState(() => _busy = true);
    try {
      await _withBlockingDialog(
        'Deleting data…',
        () => ref.read(libraryRepositoryProvider).deleteAllData(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All library data deleted.')),
      );
    } catch (error) {
      if (mounted) await _showError('Delete failed', error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _createBackup() async {
    final artifact = await createBackupWithProgress(context, ref);
    if (artifact == null || !mounted) return;
    await saveFileWithPicker(
      context,
      File(artifact.path),
      suggestedName: p.basename(artifact.path),
    );
    await _loadMetadata();
  }

  Future<void> _exportSingleBook() async {
    final books = await ref
        .read(libraryRepositoryProvider)
        .watchLibrary()
        .first;
    if (!mounted) return;
    if (books.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('There are no books to export.')),
      );
      return;
    }
    final bookId = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      builder: (context) {
        final palette = CafePalette.of(context);
        return FractionallySizedBox(
          heightFactor: 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 14),
                child: Text(
                  'Export a book',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: books.length,
                  itemBuilder: (context, index) => ListTile(
                    title: Text(books[index].book.title),
                    subtitle: Text(
                      books[index].book.author ?? 'Unknown author',
                      style: TextStyle(color: palette.inkMuted),
                    ),
                    onTap: () => Navigator.pop(context, books[index].book.id),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (bookId == null || !mounted) return;
    final artifact = await createBackupWithProgress(
      context,
      ref,
      bookId: bookId,
    );
    if (artifact == null || !mounted) return;
    final title = books.firstWhere((item) => item.book.id == bookId).book.title;
    await saveFileWithPicker(
      context,
      File(artifact.path),
      suggestedName:
          '${title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '').trim()}.cfr',
    );
  }

  Future<void> _restore({required bool merge}) async {
    final picked = await FilePicker.pickFile(
      dialogTitle: merge
          ? 'Choose a .cfr to merge'
          : 'Choose a .cfr to restore',
      type: FileType.custom,
      allowedExtensions: ['cfr'],
    );
    final path = picked?.path;
    if (path == null || !mounted) return;
    BackupInspection inspection;
    try {
      setState(() => _busy = true);
      inspection = await _withBlockingDialog(
        'Validating backup…',
        () => ref.read(backupServiceProvider).inspectBackup(path),
      );
    } catch (error) {
      if (mounted) {
        setState(() => _busy = false);
        await _showError('Could not read backup', error);
      }
      return;
    }
    if (!mounted) return;
    setState(() => _busy = false);
    final date = DateFormat.yMMMd().add_jm().format(
      inspection.createdAt.toLocal(),
    );
    final confirmed = await confirmAction(
      context,
      title: merge
          ? 'Merge backup into this library?'
          : 'Replace all local data?',
      message: merge
          ? 'This .cfr was created $date with CafeReader ${inspection.appVersion}. '
                'Books, vocabulary, statuses and review logs will be merged by '
                'their stable IDs. Local-only data is kept.'
          : 'This .cfr was created $date with CafeReader ${inspection.appVersion}. '
                'All current books, vocabulary and review data will be replaced. '
                'CafeReader will first create a safety backup in the app data folder.',
      confirmLabel: merge ? 'Merge backup' : 'Restore and replace',
      destructive: !merge,
    );
    if (!confirmed || !mounted) return;
    setState(() => _busy = true);
    try {
      await _withBlockingDialog(
        merge ? 'Merging backup…' : 'Restoring backup…',
        () async {
          await ref
              .read(backupServiceProvider)
              .restoreBackup(path, merge: merge);
          return true;
        },
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(merge ? 'Backup merged.' : 'Backup restored.')),
      );
    } catch (error) {
      if (mounted) await _showError('Restore failed', error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _exportCsv() async {
    try {
      final content = await ref.read(csvServiceProvider).exportVocabulary();
      final dir = await Directory.systemTemp.createTemp('cafereader-csv');
      final file = File(p.join(dir.path, 'CafeReader-vocabulary.csv'));
      await file.writeAsString(content, flush: true);
      if (!mounted) return;
      await saveFileWithPicker(
        context,
        file,
        suggestedName: 'CafeReader-vocabulary.csv',
        extension: 'csv',
      );
      await dir.delete(recursive: true);
    } catch (error) {
      if (mounted) await _showError('CSV export failed', error);
    }
  }

  Future<void> _importCsv() async {
    final picked = await FilePicker.pickFile(
      dialogTitle: 'Choose a vocabulary CSV',
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    final path = picked?.path;
    if (path == null || !mounted) return;
    final policy = await showDialog<CsvConflictPolicy>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Existing words'),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              'How should words that already exist be handled?',
              style: TextStyle(color: CafePalette.of(context).inkMuted),
            ),
          ),
          SimpleDialogOption(
            onPressed: () =>
                Navigator.pop(context, CsvConflictPolicy.keepExisting),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Keep their current states'),
              subtitle: Text('Still add any new definitions from the file.'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () =>
                Navigator.pop(context, CsvConflictPolicy.updateStatus),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Apply states from the CSV'),
              subtitle: Text('Learning words receive FSRS cards if missing.'),
            ),
          ),
        ],
      ),
    );
    if (policy == null || !mounted) return;
    try {
      setState(() => _busy = true);
      final content = utf8.decode(
        await File(path).readAsBytes(),
        allowMalformed: true,
      );
      final result = await _withBlockingDialog(
        'Importing vocabulary…',
        () => ref
            .read(csvServiceProvider)
            .importVocabulary(content, policy: policy),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Imported ${result.imported} rows · '
            '${result.updated} status updates · '
            '${result.createdVocabulary} new entries · '
            '${result.skipped} skipped.',
          ),
        ),
      );
    } catch (error) {
      if (mounted) await _showError('CSV import failed', error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _importDictionary() async {
    final picked = await FilePicker.pickFile(
      dialogTitle: 'Choose a dictionary CSV or JSON',
      type: FileType.custom,
      allowedExtensions: ['csv', 'json'],
    );
    final path = picked?.path;
    if (path == null || !mounted) return;
    final isJson = path.toLowerCase().endsWith('.json');
    try {
      setState(() => _busy = true);
      final content = utf8.decode(
        await File(path).readAsBytes(),
        allowMalformed: true,
      );
      final result = await _withBlockingDialog(
        'Importing definitions…',
        () => ref
            .read(csvServiceProvider)
            .importDictionary(content, isJson: isJson),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Added ${result.added} definitions · '
            '${result.skipped} duplicates skipped · '
            '${result.missingWords} words are not in your library.',
          ),
        ),
      );
    } catch (error) {
      if (mounted) await _showError('Dictionary import failed', error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<T> _withBlockingDialog<T>(
    String message,
    Future<T> Function() task,
  ) async {
    var open = true;
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => PopScope(
          canPop: false,
          child: AlertDialog(
            content: Row(
              children: [
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 16),
                Expanded(child: Text(message)),
              ],
            ),
          ),
        ),
      ),
    );
    try {
      return await task();
    } finally {
      if (mounted && open) {
        Navigator.of(context, rootNavigator: true).pop();
        open = false;
      }
    }
  }

  Future<void> _showError(String title, Object error) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text('$error')),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
