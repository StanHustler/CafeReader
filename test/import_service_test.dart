import 'dart:io';

import 'package:cafereader/core/database/app_database.dart';
import 'package:cafereader/core/util/app_storage.dart';
import 'package:cafereader/data/local/book_import_service.dart';
import 'package:cafereader/domain/epub/txt_parser.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late Directory temp;
  late AppStorage storage;
  late BookImportService service;

  setUp(() async {
    db = AppDatabase.memory();
    temp = await Directory.systemTemp.createTemp('cafereader-import-test');
    storage = AppStorage.at(Directory('${temp.path}/app'));
    await storage.ensureLayout();
    service = BookImportService(
      db: db,
      storage: storage,
      deviceId: 'device-a',
    );
  });

  tearDown(() async {
    await db.close();
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  test('imports TXT with deterministic ids and no vocabulary index', () async {
    final file = File('${temp.path}/My Book.txt');
    await file.writeAsString(
      'Chapter 1: Alpha\n\n'
      'A house stood quietly. The planet was quiet.\n'
      'Running was a word.\n\n'
      'Chapter 2: Beta\n\n'
      'A second chapter with words.\n',
    );
    final progress = <ImportStage>[];
    final result = await service.importFile(
      sourcePath: file.path,
      format: 'txt',
      onProgress: (value) => progress.add(value.stage),
    );
    expect(result.chapterCount, 2);
    expect(result.uniqueWordCount, greaterThan(5));
    expect(result.alreadyExisted, isFalse);
    expect(progress, contains(ImportStage.completed));

    final book = await db.select(db.books).getSingle();
    expect(book.title, 'My Book');
    expect(book.originalFilePath, startsWith('books/'));
    expect(
      File(storage.resolveStoredPath(book.originalFilePath)).existsSync(),
      isTrue,
    );
    final chapters = await (db.select(
      db.chapters,
    )..orderBy([(table) => OrderingTerm.asc(table.chapterIndex)])).get();
    expect(chapters, hasLength(2));
    expect(chapters.first.title, 'Chapter 1: Alpha');
    expect(chapters[1].title, 'Chapter 2: Beta');
    // Importing only stores the chapters; vocabulary and occurrence rows are
    // created lazily when the reader opens a word.
    expect(await db.select(db.wordOccurrences).get(), isEmpty);
    expect(await db.select(db.vocabulary).get(), isEmpty);
    expect(await db.select(db.wordForms).get(), isEmpty);
    expect(await db.select(db.wordStatuses).get(), isEmpty);

    await expectLater(
      () => service.importFile(sourcePath: file.path, format: 'txt'),
      throwsA(isA<AlreadyImportedException>()),
    );
    expect(await db.select(db.books).get(), hasLength(1));
    expect(await db.select(db.chapters).get(), hasLength(2));
  });

  test('import never writes vocabulary states', () async {
    final file = File('${temp.path}/Known Book.txt');
    await file.writeAsString('A house and a planet.\n\nThe word was quiet.\n');
    await service.importFile(sourcePath: file.path, format: 'txt');
    expect(await db.select(db.wordStatuses).get(), isEmpty);
    expect(await db.select(db.vocabulary).get(), isEmpty);
  });

  test('auto decoding refuses invalid UTF-8 but Latin-1 succeeds', () {
    final bytes = Uint8List.fromList([
      ...'A caf'.codeUnits,
      0xE9,
      ...'\n'.codeUnits,
    ]);
    expect(
      () => const TextDecoderService().decode(bytes, TextEncodingChoice.auto),
      throwsA(isA<TextDecodeException>()),
    );
    final decoded = const TextDecoderService().decode(
      bytes,
      TextEncodingChoice.latin1,
    );
    expect(decoded, contains('café'));
  });
}
