import 'dart:convert';
import 'dart:typed_data';

import 'parsed_book.dart';

enum TextEncodingChoice { auto, utf8, utf16le, utf16be, latin1 }

class TextDecodeException implements Exception {
  TextDecodeException(this.message);
  final String message;
  @override
  String toString() => message;
}

class TextDecoderService {
  const TextDecoderService();

  String decode(Uint8List bytes, TextEncodingChoice choice) {
    if (bytes.isEmpty) return '';
    if (choice == TextEncodingChoice.auto) {
      if (_startsWith(bytes, [0xEF, 0xBB, 0xBF])) {
        return _stripBom(utf8.decode(bytes.sublist(3)));
      }
      if (_startsWith(bytes, [0xFF, 0xFE])) {
        return _decodeUtf16(bytes.sublist(2), littleEndian: true);
      }
      if (_startsWith(bytes, [0xFE, 0xFF])) {
        return _decodeUtf16(bytes.sublist(2), littleEndian: false);
      }
      try {
        return _stripBom(utf8.decode(bytes));
      } on FormatException {
        throw TextDecodeException(
          'This text is not valid UTF-8. Choose its encoding to continue.',
        );
      }
    }
    switch (choice) {
      case TextEncodingChoice.utf8:
        try {
          return _stripBom(utf8.decode(bytes));
        } on FormatException {
          throw TextDecodeException('The file is not valid UTF-8 text.');
        }
      case TextEncodingChoice.utf16le:
        return _decodeUtf16(bytes, littleEndian: true);
      case TextEncodingChoice.utf16be:
        return _decodeUtf16(bytes, littleEndian: false);
      case TextEncodingChoice.latin1:
        return latin1.decode(bytes);
      case TextEncodingChoice.auto:
        throw StateError('Auto handled above');
    }
  }

  String _decodeUtf16(Uint8List bytes, {required bool littleEndian}) {
    final units = <int>[];
    for (var i = 0; i + 1 < bytes.length; i += 2) {
      units.add(
        littleEndian
            ? bytes[i] | (bytes[i + 1] << 8)
            : (bytes[i] << 8) | bytes[i + 1],
      );
    }
    return String.fromCharCodes(units);
  }

  String _stripBom(String value) =>
      value.startsWith('﻿') ? value.substring(1) : value;

  bool _startsWith(Uint8List bytes, List<int> prefix) {
    if (bytes.length < prefix.length) return false;
    for (var i = 0; i < prefix.length; i++) {
      if (bytes[i] != prefix[i]) return false;
    }
    return true;
  }
}

class TxtParser {
  const TxtParser();

  ParsedBook parse(
    String text, {
    required String fallbackTitle,
    String? author,
  }) {
    final normalized = text
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceAll('\u0000', '');
    final lines = normalized.split('\n');
    final sections = <_TxtSection>[];
    _TxtSection? current;
    final buffer = <String>[];

    void finishSection() {
      final paragraphs = _paragraphsFromLines(buffer);
      if (paragraphs.isNotEmpty) {
        final fallback = sections.isEmpty
            ? fallbackTitle
            : 'Chapter ${sections.length + 1}';
        sections.add(
          _TxtSection(
            title: current?.title ?? fallback,
            paragraphs: paragraphs,
          ),
        );
      }
      buffer.clear();
    }

    for (final rawLine in lines) {
      final line = rawLine.trim();
      final heading = _isChapterHeading(line) ? line : null;
      if (heading != null) {
        finishSection();
        current = _TxtSection(
          title: _headingTitle(heading),
          paragraphs: const [],
        );
      } else {
        buffer.add(rawLine);
      }
    }
    finishSection();

    if (sections.isEmpty) {
      final paragraphs = _paragraphsFromLines(lines);
      if (paragraphs.isNotEmpty) {
        sections.add(_TxtSection(title: fallbackTitle, paragraphs: paragraphs));
      }
    }
    final chapters = sections
        .map(
          (section) => ParsedChapter(
            title: section.title,
            content: section.paragraphs.join('\n\n'),
          ),
        )
        .toList();
    if (chapters.isEmpty) {
      throw TextDecodeException('No readable text was found in this file.');
    }
    return ParsedBook(title: fallbackTitle, author: author, chapters: chapters);
  }

  List<String> _paragraphsFromLines(List<String> rawLines) {
    final paragraphs = <String>[];
    final current = <String>[];
    void flush() {
      final value = current.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();
      current.clear();
      if (value.isNotEmpty) paragraphs.add(value);
    }

    for (final raw in rawLines) {
      final line = raw.trim();
      if (line.isEmpty) {
        flush();
      } else {
        current.add(line);
      }
    }
    flush();
    return paragraphs;
  }

  bool _isChapterHeading(String line) {
    if (line.isEmpty || line.length > 80) return false;
    if (RegExp(
      r'^(chapter|part|book|section)\s+([0-9]+|[ivxlcdm]+|[a-z]+)\b.*$',
      caseSensitive: false,
    ).hasMatch(line)) {
      return true;
    }
    final lower = line.toLowerCase().replaceAll(RegExp(r'[:.]+$'), '');
    return const {
      'prologue',
      'epilogue',
      'introduction',
      'preface',
      'foreword',
      'afterword',
      'acknowledgements',
      'acknowledgments',
    }.contains(lower);
  }

  String _headingTitle(String line) {
    final cleaned = line.replaceAll(RegExp(r'\s+'), ' ').trim();
    return cleaned.length <= 80 ? cleaned : '${cleaned.substring(0, 77)}...';
  }
}

class _TxtSection {
  _TxtSection({required this.title, required this.paragraphs});
  final String title;
  final List<String> paragraphs;
}
