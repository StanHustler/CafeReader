import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:cafereader/core/backup/backup_service.dart';
import 'package:cafereader/core/database/app_database.dart';
import 'package:cafereader/core/util/app_storage.dart';
import 'package:cafereader/data/local/snapshot_service.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory temp;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('cafereader-backup-test');
  });

  tearDown(() async {
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  test('full backup can be inspected and restored with media', () async {
    final root = Directory('${temp.path}/app');
    final storage = AppStorage.at(root);
    await storage.ensureLayout();
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final now = DateTime(2026, 3, 1, 12);
    final relative = storage.bookRelativePath('book-1', 'txt');
    final sourceFile = File(storage.resolveStoredPath(relative));
    await sourceFile.parent.create(recursive: true);
    await sourceFile.writeAsString('Original book text');
    await db
        .into(db.books)
        .insert(
          BooksCompanion.insert(
            id: 'book-1',
            title: 'Backup Book',
            originalFilePath: relative,
            format: 'txt',
            importedAt: now,
            updatedAt: now,
          ),
        );
    final snapshots = SnapshotService(db);
    final service = BackupService(
      db: db,
      storage: storage,
      snapshots: snapshots,
      deviceId: 'device-test',
    );
    final artifact = await service.createBackup();
    final inspection = await service.inspectBackup(artifact.path);
    expect(inspection.backupType, 'full');
    expect(inspection.schemaVersion, 4);

    final extraRelative = storage.bookRelativePath('extra', 'txt');
    final extraFile = File(storage.resolveStoredPath(extraRelative));
    await extraFile.writeAsString('Extra book');
    await db
        .into(db.books)
        .insert(
          BooksCompanion.insert(
            id: 'extra',
            title: 'Extra',
            originalFilePath: extraRelative,
            format: 'txt',
            importedAt: now,
            updatedAt: now,
          ),
        );

    await service.restoreBackup(artifact.path);
    final books = await db.select(db.books).get();
    expect(books.map((book) => book.id), ['book-1']);
    expect(await sourceFile.exists(), isTrue);
    expect(await sourceFile.readAsString(), 'Original book text');
    expect(await extraFile.exists(), isFalse);
    final device = await (db.select(
      db.appMetadata,
    )..where((table) => table.key.equals('device_id'))).getSingleOrNull();
    expect(device?.value, isNotNull);
  });

  test(
    'restore rejects ZIP path traversal before writing outside staging',
    () async {
      final srcRoot = Directory('${temp.path}/src');
      final srcStorage = AppStorage.at(srcRoot);
      await srcStorage.ensureLayout();
      final sourceDb = AppDatabase.memory();
      await sourceDb
          .into(sourceDb.appMetadata)
          .insert(
            AppMetadataCompanion.insert(
              key: 'data_version',
              value: '1',
              updatedAt: DateTime.now(),
            ),
            mode: InsertMode.insertOrReplace,
          );
      final snapshotPath = '${temp.path}/valid.sqlite';
      await sourceDb.snapshotTo(snapshotPath);
      await sourceDb.close();
      final snapshotBytes = await File(snapshotPath).readAsBytes();
      final hash = sha256.convert(snapshotBytes).toString();

      final targetRoot = Directory('${temp.path}/target');
      final targetStorage = AppStorage.at(targetRoot);
      await targetStorage.ensureLayout();
      final targetDb = AppDatabase.memory();
      addTearDown(targetDb.close);
      final manifest = {
        'backup_format_version': 1,
        'app_name': 'CafeReader',
        'app_version': 'test',
        'database_schema_version': 4,
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'device_id': 'source',
        'backup_type': 'full',
        'files': [
          {
            'path': 'database/database.sqlite',
            'size': snapshotBytes.length,
            'sha256': hash,
          },
        ],
      };
      final archive = Archive()
        ..addFile(ArchiveFile.string('manifest.json', jsonEncode(manifest)))
        ..addFile(
          ArchiveFile(
            'database/database.sqlite',
            snapshotBytes.length,
            snapshotBytes,
          ),
        )
        ..addFile(ArchiveFile.string('../escaped.txt', 'must not be written'));
      final evilPath = '${temp.path}/evil.cfr';
      await File(evilPath)
          .writeAsBytes(ZipEncoder().encode(archive), flush: true);
      final service = BackupService(
        db: targetDb,
        storage: targetStorage,
        snapshots: SnapshotService(targetDb),
        deviceId: 'target',
      );
      await expectLater(
        () => service.restoreBackup(evilPath),
        throwsA(isA<BackupException>()),
      );
      expect(await File('${temp.path}/escaped.txt').exists(), isFalse);
    },
  );
}
