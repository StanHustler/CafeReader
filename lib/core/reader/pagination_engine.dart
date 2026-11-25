import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'page_content.dart';

/// Measures and paginates a chapter using Flutter's real text layout.
///
/// This class deliberately has no dependency on a widget's render state. The
/// chapter text, typography, and available content box are its only inputs.
class PaginationEngine {
  const PaginationEngine();

  List<PageContent> paginate({
    required String content,
    required TextStyle textStyle,
    required double width,
    required double height,
    required double paragraphSpacing,
    TextScaler textScaler = TextScaler.noScaling,
  }) {
    final paragraphs = chapterParagraphs(content);
    if (width <= 0 || height <= 0) {
      return [
        PageContent(
          index: 0,
          fragments: [
            for (var i = 0; i < paragraphs.length; i++)
              if (paragraphs[i].isNotEmpty)
                PageFragment(
                  paragraphIndex: i,
                  startOffset: 0,
                  endOffset: paragraphs[i].length,
                  text: paragraphs[i],
                ),
          ],
        ),
      ];
    }
    final pages = <PageContent>[];
    var paragraphIndex = 0;
    var offset = 0;
    final fontSize = textStyle.fontSize ?? 16;
    final minOrphanHeight =
        fontSize * (textStyle.height ?? 1.35) * textScaler.scale(1.0) * 1.4;

    double measure(String text) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: textStyle),
        textDirection: TextDirection.ltr,
        textScaler: textScaler,
      )..layout(maxWidth: width);
      final measured = painter.height;
      painter.dispose();
      return measured;
    }

    int fittingCharacters(String text, int from, double available) {
      if (available <= 0) return 0;
      if (measure(text.substring(from)) <= available) {
        return text.length - from;
      }
      var low = 1;
      var high = text.length - from;
      var best = 0;
      while (low <= high) {
        final mid = (low + high) >> 1;
        final measured = measure(text.substring(from, from + mid));
        if (measured <= available) {
          best = mid;
          low = mid + 1;
        } else {
          high = mid - 1;
        }
      }
      return best;
    }

    int wordBoundary(String text, int from, int candidateEnd) {
      if (candidateEnd >= text.length) return text.length;
      final lastSpace = text.lastIndexOf(RegExp(r'\s'), candidateEnd);
      if (lastSpace >= from) {
        var end = lastSpace;
        while (end > from && _isWhitespace(text.codeUnitAt(end - 1))) {
          end--;
        }
        if (end > from) return end;
      }
      // A single word longer than the page width. Split it rather than
      // looping forever; this is exceptional for English prose.
      return candidateEnd;
    }

    var safety = 0;
    while (paragraphIndex < paragraphs.length && safety++ < 100000) {
      final fragments = <PageFragment>[];
      var used = 0.0;
      var pageHasContent = false;
      while (paragraphIndex < paragraphs.length) {
        final paragraph = paragraphs[paragraphIndex];
        if (paragraph.isEmpty) {
          paragraphIndex++;
          offset = 0;
          continue;
        }
        if (offset >= paragraph.length) {
          paragraphIndex++;
          offset = 0;
          continue;
        }
        final spacer = pageHasContent ? paragraphSpacing : 0.0;
        final remaining = height - used - spacer;
        final fullHeight = measure(paragraph.substring(offset));
        if (fullHeight <= remaining) {
          fragments.add(
            PageFragment(
              paragraphIndex: paragraphIndex,
              startOffset: offset,
              endOffset: paragraph.length,
              text: paragraph.substring(offset),
            ),
          );
          used += spacer + fullHeight;
          pageHasContent = true;
          paragraphIndex++;
          offset = 0;
          continue;
        }
        if (remaining <= 0) break;
        // Avoid leaving a single isolated line at the bottom of a page when
        // this is only a fragment of a paragraph.
        if (pageHasContent && remaining < minOrphanHeight) break;
        final fit = fittingCharacters(paragraph, offset, remaining);
        if (fit <= 0) {
          if (pageHasContent) break;
          // Width smaller than a glyph: place one character to make progress.
          final end = math.min(offset + 1, paragraph.length);
          fragments.add(
            PageFragment(
              paragraphIndex: paragraphIndex,
              startOffset: offset,
              endOffset: end,
              text: paragraph.substring(offset, end),
            ),
          );
          offset = end;
          break;
        }
        final boundary = wordBoundary(paragraph, offset, offset + fit);
        if (boundary <= offset) {
          if (pageHasContent) break;
          offset += 1;
          continue;
        }
        fragments.add(
          PageFragment(
            paragraphIndex: paragraphIndex,
            startOffset: offset,
            endOffset: boundary,
            text: paragraph.substring(offset, boundary),
          ),
        );
        var nextOffset = boundary;
        while (nextOffset < paragraph.length &&
            _isWhitespace(paragraph.codeUnitAt(nextOffset))) {
          nextOffset++;
        }
        if (nextOffset >= paragraph.length) {
          paragraphIndex++;
          offset = 0;
        } else {
          offset = nextOffset;
        }
        break;
      }
      if (fragments.isEmpty) {
        // Safety net for pathological input.
        if (paragraphIndex < paragraphs.length) {
          final paragraph = paragraphs[paragraphIndex];
          final end = math.min(offset + 1, paragraph.length);
          fragments.add(
            PageFragment(
              paragraphIndex: paragraphIndex,
              startOffset: offset,
              endOffset: end,
              text: paragraph.substring(offset, end),
            ),
          );
          offset = end;
          if (offset >= paragraph.length) {
            paragraphIndex++;
            offset = 0;
          }
        } else {
          break;
        }
      }
      pages.add(PageContent(index: pages.length, fragments: fragments));
    }
    if (pages.isEmpty) {
      pages.add(const PageContent(index: 0, fragments: []));
    }
    return pages;
  }

  int pageForAnchor(List<PageContent> pages, int paragraph, int offset) {
    if (pages.isEmpty) return 0;
    for (final page in pages) {
      if (page.containsPosition(paragraph, offset)) return page.index;
    }
    // Anchor beyond the final page (e.g. content was replaced).
    if (_comparePosition(
          paragraph,
          offset,
          pages.last.endParagraph,
          pages.last.endOffset,
        ) >=
        0) {
      return pages.length - 1;
    }
    return 0;
  }

  static bool _isWhitespace(int codeUnit) =>
      codeUnit == 0x20 ||
      codeUnit == 0x09 ||
      codeUnit == 0x0A ||
      codeUnit == 0x0D ||
      codeUnit == 0x0C;

  static int _comparePosition(int p1, int o1, int p2, int o2) {
    if (p1 != p2) return p1.compareTo(p2);
    return o1.compareTo(o2);
  }
}
