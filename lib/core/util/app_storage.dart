import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Owns all file-system locations used by the app. Keeping paths in one place
/// makes backup and sync logic deterministic and testable.
class AppStorage {
  AppStorage._(this.root);

  /// Constructor for integration tests and non-plugin embeddings.
  factory AppStorage.at(Directory root) => AppStorage._(root);

  final Directory root;

  static Future<AppStorage> create() async {
    final support = await getApplicationSupportDirectory();
    final root = Directory(p.join(support.path, 'CafeReader'));
    await root.create(recursive: true);
    final storage = AppStorage._(root);
    await storage.ensureLayout();
    return storage;
  }

  Directory get booksDir => Directory(p.join(root.path, 'books'));
  Directory get coversDir => Directory(p.join(root.path, 'covers'));
  Directory get backupsDir => Directory(p.join(root.path, 'backups'));
  Directory get stagingDir => Directory(p.join(root.path, 'staging'));
  Directory get databaseDir => root;
  String get databasePath => p.join(root.path, 'cafereader.sqlite');

  Future<void> ensureLayout() async {
    for (final dir in [booksDir, coversDir, backupsDir, stagingDir]) {
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    }
  }

  Future<Directory> freshStagingDir() async {
    if (await stagingDir.exists()) {
      await stagingDir.delete(recursive: true);
    }
    await stagingDir.create(recursive: true);
    return stagingDir;
  }

  String bookPath(String bookId, String extension) =>
      p.join(booksDir.path, '$bookId.${extension.replaceAll('.', '')}');

  String coverPath(String bookId, String extension) =>
      p.join(coversDir.path, '$bookId.${extension.replaceAll('.', '')}');

  /// Book rows store portable paths relative to [root], so backups and sync
  /// snapshots work when restored on another device.
  String bookRelativePath(String bookId, String extension) =>
      p.posix.join('books', '$bookId.${extension.replaceAll('.', '')}');

  String coverRelativePath(String bookId, String extension) =>
      p.posix.join('covers', '$bookId.${extension.replaceAll('.', '')}');

  String resolveStoredPath(String relativeOrAbsolute) {
    if (p.isAbsolute(relativeOrAbsolute)) return relativeOrAbsolute;
    return p.join(root.path, relativeOrAbsolute);
  }

  File fileForStoredPath(String relativeOrAbsolute) =>
      File(resolveStoredPath(relativeOrAbsolute));
}
