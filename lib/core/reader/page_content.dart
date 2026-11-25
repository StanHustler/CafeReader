/// Splits a stored chapter into its canonical paragraph sequence. Word
/// occurrence offsets are relative to these paragraphs, so every part of the
/// application must use this function or the same '\n\n' convention.
List<String> chapterParagraphs(String content) => content.split('\n\n');

class PageFragment {
  const PageFragment({
    required this.paragraphIndex,
    required this.startOffset,
    required this.endOffset,
    required this.text,
  });

  final int paragraphIndex;
  final int startOffset;
  final int endOffset;
  final String text;

  int get length => endOffset - startOffset;
}

class PageContent {
  const PageContent({required this.index, required this.fragments});

  final int index;
  final List<PageFragment> fragments;

  bool get isEmpty => fragments.isEmpty;

  int get startParagraph =>
      fragments.isEmpty ? 0 : fragments.first.paragraphIndex;
  int get startOffset => fragments.isEmpty ? 0 : fragments.first.startOffset;
  int get endParagraph => fragments.isEmpty ? 0 : fragments.last.paragraphIndex;
  int get endOffset => fragments.isEmpty ? 0 : fragments.last.endOffset;

  bool containsPosition(int paragraph, int offset) {
    if (fragments.isEmpty) return false;
    final afterStart =
        paragraph > startParagraph ||
        (paragraph == startParagraph && offset >= startOffset);
    final beforeEnd =
        paragraph < endParagraph ||
        (paragraph == endParagraph && offset < endOffset);
    return afterStart && beforeEnd;
  }

  static PageContent fromParagraphRange({
    required int index,
    required List<String> paragraphs,
    required int startParagraph,
    required int startOffset,
    required int endParagraph,
    required int endOffset,
  }) {
    final fragments = <PageFragment>[];
    final first = startParagraph.clamp(0, paragraphs.length - 1);
    final last = endParagraph.clamp(0, paragraphs.length - 1);
    for (var p = first; p <= last; p++) {
      final text = paragraphs[p];
      final from = p == first ? startOffset.clamp(0, text.length) : 0;
      final to = p == last ? endOffset.clamp(0, text.length) : text.length;
      if (to <= from) continue;
      fragments.add(
        PageFragment(
          paragraphIndex: p,
          startOffset: from,
          endOffset: to,
          text: text.substring(from, to),
        ),
      );
    }
    return PageContent(index: index, fragments: fragments);
  }
}
