import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../../core/reader/page_content.dart';
import '../../core/util/app_storage.dart';
import '../../domain/epub/book_parser.dart';
import '../../domain/epub/parsed_book.dart';
import '../../domain/epub/txt_parser.dart';
import '../../domain/lemmatizer/tokenizer.dart';

enum ImportStage { reading, parsing, indexing, saving, completed }

class ImportProgress {
  const ImportProgress({
    required this.stage,
    required this.message,
    this.current = 0,
    this.total = 0,
  });

  final ImportStage stage;
  final String message;
  final int current;
  final int total;

  double? get fraction => total > 0 ? current / total : null;
}

class ImportResult {
  const ImportResult({
    required this.bookId,
    required this.title,
    required this.chapterCount,
    required this.wordCount,
    required this.uniqueWordCount,
    required this.newVocabularyCount,
    required this.alreadyExisted,
  });

  final String bookId;
  final String title;
  final int chapterCount;
  final int wordCount;
  final int uniqueWordCount;
  final int newVocabularyCount;
  final bool alreadyExisted;
}

class AlreadyImportedException implements Exception {
  AlreadyImportedException(this.title);
  final String title;
  @override
  String toString() => '"$title" is already in your library.';
}

typedef ImportProgressCallback = void Function(ImportProgress progress);

class BookImportService {
  BookImportService({
    required this.db,
    required this.storage,
    required this.deviceId,
  });

  final AppDatabase db;
  final AppStorage storage;
  final String deviceId;
  final Tokenizer _tokenizer = const Tokenizer();
  final Uuid _uuid = const Uuid();

  Future<ImportResult> importFile({
    required String sourcePath,
    required String format,
    TextEncodingChoice encoding = TextEncodingChoice.auto,
    ImportProgressCallback? onProgress,
  }) async {
    final file = File(sourcePath);
    if (!await file.exists()) {
      throw FileSystemException('The selected file no longer exists.');
    }
    final size = await file.length();
    if (size == 0) {
      throw BookParseException('The selected file is empty.');
    }
    if (size > 500 * 1024 * 1024) {
      throw BookParseException('The selected file is too large.');
    }
    onProgress?.call(
      const ImportProgress(
        stage: ImportStage.reading,
        message: 'Reading file…',
      ),
    );
    final bytes = await file.readAsBytes();
    final sha = sha256.convert(bytes).toString();
    final bookId = _bookIdFromHash(sha);
    final existing = await (db.select(
      db.books,
    )..where((table) => table.id.equals(bookId))).getSingleOrNull();
    if (existing != null && existing.deletedAt == null) {
      throw AlreadyImportedException(existing.title);
    }

    final fallbackTitle = _titleFromFileName(sourcePath);
    onProgress?.call(
      const ImportProgress(
        stage: ImportStage.parsing,
        message: 'Parsing book…',
      ),
    );
    final normalizedFormat = format.toLowerCase();
    final ParsedBook parsed;
    if (normalizedFormat == 'epub') {
      parsed = EpubParser().parse(bytes, fallbackTitle: fallbackTitle);
    } else if (normalizedFormat == 'txt') {
      final text = const TextDecoderService().decode(bytes, encoding);
      parsed = const TxtParser().parse(text, fallbackTitle: fallbackTitle);
    } else {
      throw BookParseException('Unsupported book format: $format');
    }
    if (parsed.chapters.isEmpty) {
      throw BookParseException('This book contains no readable chapters.');
    }

    onProgress?.call(
      ImportProgress(
        stage: ImportStage.indexing,
        message: 'Preparing chapters…',
        current: 0,
        total: parsed.chapters.length,
      ),
    );

    final chapterRecords = <_ImportedChapter>[];
    for (var i = 0; i < parsed.chapters.length; i++) {
      final chapter = parsed.chapters[i];
      final chapterId = _uuid.v5(
        Namespace.url.value,
        'cafereader:chapter:$bookId:$i',
      );
      chapterRecords.add(
        _ImportedChapter(
          id: chapterId,
          title: chapter.title,
          index: i,
          content: chapter.content,
          hash: sha256.convert(utf8.encode(chapter.content)).toString(),
        ),
      );
    }

    final targetFile = File(storage.bookPath(bookId, normalizedFormat));
    String? coverTarget;
    if (parsed.coverBytes != null && parsed.coverBytes!.isNotEmpty) {
      final coverExt = parsed.coverExtension ?? 'jpg';
      coverTarget = storage.coverRelativePath(bookId, coverExt);
      await storage
          .fileForStoredPath(coverTarget)
          .writeAsBytes(parsed.coverBytes!, flush: true);
    }
    await targetFile.parent.create(recursive: true);
    if (!await targetFile.exists() ||
        await targetFile.length() != bytes.length) {
      await targetFile.writeAsBytes(bytes, flush: true);
    }

    try {
      final result = await db.transaction(() async {
        final bookNow = await (db.select(
          db.books,
        )..where((table) => table.id.equals(bookId))).getSingleOrNull();
        final now = DateTime.now();
        if (bookNow != null) {
          await (db.update(
            db.books,
          )..where((table) => table.id.equals(bookId))).write(
            BooksCompanion(
              deletedAt: const Value(null),
              updatedAt: Value(now),
              revision: Value(bookNow.revision + 1),
              originalFilePath: Value(
                storage.bookRelativePath(bookId, normalizedFormat),
              ),
              coverPath: Value(coverTarget),
            ),
          );
          return ImportResult(
            bookId: bookId,
            title: bookNow.title,
            chapterCount: chapterRecords.length,
            wordCount: 0,
            uniqueWordCount: 0,
            newVocabularyCount: 0,
            alreadyExisted: true,
          );
        }

        await db
            .into(db.books)
            .insert(
              BooksCompanion.insert(
                id: bookId,
                title: parsed.title.trim().isEmpty
                    ? fallbackTitle
                    : parsed.title,
                author: Value(parsed.author),
                description: Value(parsed.description),
                coverPath: Value(coverTarget),
                originalFilePath: storage.bookRelativePath(
                  bookId,
                  normalizedFormat,
                ),
                format: normalizedFormat,
                language: Value(
                  parsed.language.isEmpty ? 'en' : parsed.language,
                ),
                fileSha256: Value(sha),
                updatedBy: Value(deviceId),
                importedAt: now,
                updatedAt: now,
              ),
            );

        // Word statistics come from a single in-memory pass; no vocabulary or
        // occurrence rows are written at import time. Vocabulary entries are
        // created on demand when a word is first opened, and a sentence is
        // recorded only when the word is added to Learning.
        final allSurfaces = <String>{};
        var wordCount = 0;
        for (final chapter in chapterRecords) {
          for (final paragraph in chapterParagraphs(chapter.content)) {
            final tokens = _tokenizer.tokenize(paragraph);
            wordCount += tokens.length;
            for (final token in tokens) {
              allSurfaces.add(token.normalized);
            }
          }
        }

        for (var i = 0; i < chapterRecords.length; i++) {
          final chapter = chapterRecords[i];
          await db
              .into(db.chapters)
              .insert(
                ChaptersCompanion.insert(
                  id: chapter.id,
                  bookId: bookId,
                  title: chapter.title,
                  chapterIndex: chapter.index,
                  content: chapter.content,
                  contentHash: chapter.hash,
                  updatedAt: now,
                ),
              );
          onProgress?.call(
            ImportProgress(
              stage: ImportStage.saving,
              message: 'Saving chapter ${i + 1} of ${chapterRecords.length}…',
              current: i + 1,
              total: chapterRecords.length,
            ),
          );
        }

        return ImportResult(
          bookId: bookId,
          title: parsed.title,
          chapterCount: chapterRecords.length,
          wordCount: wordCount,
          uniqueWordCount: allSurfaces.length,
          newVocabularyCount: 0,
          alreadyExisted: false,
        );
      });
      onProgress?.call(
        const ImportProgress(
          stage: ImportStage.completed,
          message: 'Import complete.',
        ),
      );
      return result;
    } catch (error) {
      if (coverTarget != null) {
        final cover = storage.fileForStoredPath(coverTarget);
        if (await cover.exists()) await cover.delete();
      }
      rethrow;
    }
  }

  static String _bookIdFromHash(String sha) {
    final hex = sha.substring(0, 32);
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
        '${hex.substring(20, 32)}';
  }

  static String _titleFromFileName(String path) {
    final base = p
        .basenameWithoutExtension(path)
        .replaceAll(RegExp(r'[_-]+'), ' ');
    final trimmed = base.trim();
    return trimmed.isEmpty ? 'Untitled' : trimmed;
  }
}

class _ImportedChapter {
  const _ImportedChapter({
    required this.id,
    required this.title,
    required this.index,
    required this.content,
    required this.hash,
  });
  final String id;
  final String title;
  final int index;
  final String content;
  final String hash;
}

