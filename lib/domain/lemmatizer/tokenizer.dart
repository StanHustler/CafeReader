/// A token in a piece of text. Offsets are UTF-16 offsets into the original
/// string, matching Dart string indexing.
class WordToken {
  const WordToken({
    required this.surface,
    required this.normalized,
    required this.start,
    required this.end,
  });

  final String surface;
  final String normalized;
  final int start;
  final int end;
}

class Tokenizer {
  static final RegExp _wordPattern = RegExp(r"[A-Za-z]+(?:['’][A-Za-z]+)*");

  const Tokenizer();

  List<WordToken> tokenize(String text) {
    final result = <WordToken>[];
    for (final match in _wordPattern.allMatches(text)) {
      final surface = match.group(0)!;
      result.add(
        WordToken(
          surface: surface,
          normalized: normalize(surface),
          start: match.start,
          end: match.end,
        ),
      );
    }
    return result;
  }

  static String normalize(String value) =>
      value.toLowerCase().replaceAll('’', "'").trim();
}
