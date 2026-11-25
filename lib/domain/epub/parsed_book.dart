import 'dart:typed_data';

class ParsedChapter {
  const ParsedChapter({required this.title, required this.content});

  final String title;
  final String content;
}

class ParsedBook {
  const ParsedBook({
    required this.title,
    this.author,
    this.description,
    this.language = 'en',
    required this.chapters,
    this.coverBytes,
    this.coverExtension,
  });

  final String title;
  final String? author;
  final String? description;
  final String language;
  final List<ParsedChapter> chapters;
  final Uint8List? coverBytes;
  final String? coverExtension;
}
