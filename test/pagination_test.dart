import 'package:cafereader/core/reader/page_content.dart';
import 'package:cafereader/core/reader/pagination_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const engine = PaginationEngine();
  const width = 320.0;
  const height = 430.0;
  const paragraphSpacing = 12.0;

  const normalStyle = TextStyle(
    fontFamily: 'Literata',
    fontSize: 18,
    height: 1.6,
    color: Colors.black,
  );
  const largeStyle = TextStyle(
    fontFamily: 'Literata',
    fontSize: 26,
    height: 1.8,
    color: Colors.black,
  );

  final paragraphs = List<String>.generate(24, (index) {
    return 'Paragraph ${index + 1}. The planet is surprisingly beautiful, and '
        'a quiet house waits beside a long road through the valley. '
        'Scarcely anyone notices the importance of ordinary words. '
        'Every page keeps a stable text anchor for the reader.';
  });
  final content = paragraphs.join('\n\n');

  test('pages never split an English word and fit the measured height', () {
    final pages = engine.paginate(
      content: content,
      textStyle: normalStyle,
      width: width,
      height: height,
      paragraphSpacing: paragraphSpacing,
    );
    expect(pages.length, greaterThan(2));
    for (final page in pages) {
      expect(page.fragments, isNotEmpty);
      var used = 0.0;
      for (var i = 0; i < page.fragments.length; i++) {
        final fragment = page.fragments[i];
        final painter = TextPainter(
          text: TextSpan(text: fragment.text, style: normalStyle),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: width);
        used += painter.height + (i == 0 ? 0 : paragraphSpacing);
        painter.dispose();
        if (fragment.endOffset < paragraphs[fragment.paragraphIndex].length) {
          final source = paragraphs[fragment.paragraphIndex];
          final next = source.substring(
            fragment.endOffset,
            fragment.endOffset + 1,
          );
          expect(
            next.trim().isEmpty,
            isTrue,
            reason: 'Page ends in the middle of a word: "${fragment.text}"',
          );
        }
      }
      expect(used, lessThanOrEqualTo(height + 0.5));
    }
    final reconstructed = pages
        .expand((page) => page.fragments.map((fragment) => fragment.text))
        .join(' ');
    expect(reconstructed, contains('planet is surprisingly beautiful'));
  });

  test('text anchor survives typography changes', () {
    final pages = engine.paginate(
      content: content,
      textStyle: normalStyle,
      width: width,
      height: height,
      paragraphSpacing: paragraphSpacing,
    );
    const anchorParagraph = 17;
    final anchor = paragraphs[anchorParagraph].indexOf('valley') + 2;
    final pageIndex = engine.pageForAnchor(pages, anchorParagraph, anchor);
    expect(pages[pageIndex].containsPosition(anchorParagraph, anchor), isTrue);

    final largerPages = engine.paginate(
      content: content,
      textStyle: largeStyle,
      width: width,
      height: height,
      paragraphSpacing: paragraphSpacing,
    );
    expect(largerPages.length, greaterThan(pages.length));
    final largerIndex = engine.pageForAnchor(
      largerPages,
      anchorParagraph,
      anchor,
    );
    expect(
      largerPages[largerIndex].containsPosition(anchorParagraph, anchor),
      isTrue,
    );
    expect(
      largerPages
          .expand((page) => page.fragments)
          .any((fragment) => fragment.paragraphIndex == anchorParagraph),
      isTrue,
    );
  });

  test('cache range reconstruction preserves page boundaries', () {
    final pages = engine.paginate(
      content: content,
      textStyle: normalStyle,
      width: width,
      height: height,
      paragraphSpacing: paragraphSpacing,
    );
    final source = chapterParagraphs(content);
    for (final page in pages) {
      final rebuilt = PageContent.fromParagraphRange(
        index: page.index,
        paragraphs: source,
        startParagraph: page.startParagraph,
        startOffset: page.startOffset,
        endParagraph: page.endParagraph,
        endOffset: page.endOffset,
      );
      expect(rebuilt.startParagraph, page.startParagraph);
      expect(rebuilt.startOffset, page.startOffset);
      expect(rebuilt.endParagraph, page.endParagraph);
      expect(rebuilt.endOffset, page.endOffset);
      expect(
        rebuilt.fragments.map((fragment) => fragment.text).join(),
        page.fragments.map((fragment) => fragment.text).join(),
      );
    }
  });
}
