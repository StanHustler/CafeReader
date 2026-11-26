import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';

/// How a word is marked inside book text.
enum WordMarkStyle {
  none('none', 'None'),
  border('border', 'Border'),
  fill('fill', 'Fill'),
  underlineSingle('single', 'Single'),
  underlineWavy('wavy', 'Wavy'),
  underlineDouble('double', 'Double'),
  underlineDashed('dashed', 'Dashed');

  const WordMarkStyle(this.storageValue, this.label);

  final String storageValue;
  final String label;

  bool get hasBorder => this == border || this == fill;

  bool get hasFill => this == fill;

  bool get isUnderline => switch (this) {
    WordMarkStyle.underlineSingle ||
    WordMarkStyle.underlineWavy ||
    WordMarkStyle.underlineDouble ||
    WordMarkStyle.underlineDashed => true,
    _ => false,
  };

  TextDecorationStyle get decorationStyle => switch (this) {
    WordMarkStyle.underlineWavy => TextDecorationStyle.wavy,
    WordMarkStyle.underlineDouble => TextDecorationStyle.double,
    WordMarkStyle.underlineDashed => TextDecorationStyle.dashed,
    _ => TextDecorationStyle.solid,
  };

  static WordMarkStyle fromStorage(String? value) => switch (value) {
    'border' => border,
    'fill' => fill,
    'single' || 'underline' => underlineSingle,
    'wavy' => underlineWavy,
    'double' => underlineDouble,
    'dashed' => underlineDashed,
    _ => none,
  };
}

/// One category's mark: its style plus the colours used for the mark itself
/// and for the focus box shown on hover or tap.
class WordMarkAppearance {
  const WordMarkAppearance({
    required this.style,
    required this.color,
    required this.focusColor,
  });

  final WordMarkStyle style;
  final Color color;
  final Color focusColor;

  WordMarkAppearance copyWith({
    WordMarkStyle? style,
    Color? color,
    Color? focusColor,
  }) {
    return WordMarkAppearance(
      style: style ?? this.style,
      color: color ?? this.color,
      focusColor: focusColor ?? this.focusColor,
    );
  }
}

/// A half-open `[start, end)` range of a paragraph that carries a mark.
class WordMarkRange {
  const WordMarkRange(this.start, this.end, this.style, this.color);

  final int start;
  final int end;
  final WordMarkStyle style;
  final Color color;

  @override
  bool operator ==(Object other) =>
      other is WordMarkRange &&
      other.start == start &&
      other.end == end &&
      other.style == style &&
      other.color == color;

  @override
  int get hashCode => Object.hash(start, end, style, color);
}

/// A focus border drawn around the word under the pointer or the last tapped
/// word.
class WordFocusRange {
  const WordFocusRange(this.start, this.end, this.color);

  final int start;
  final int end;
  final Color color;

  @override
  bool operator ==(Object other) =>
      other is WordFocusRange &&
      other.start == start &&
      other.end == end &&
      other.color == color;

  @override
  int get hashCode => Object.hash(start, end, color);
}

/// Renders a paragraph with per-range marks and optional focus boxes.
///
/// Underline marks are drawn with a text decoration, so they never affect
/// layout. Borders and fills are painted on top of / beneath the same text
/// run: adding real border spans would change glyph metrics and desynchronise
/// the reader's pagination, which measures plain text.
class MarkedParagraph extends StatelessWidget {
  const MarkedParagraph({
    super.key,
    required this.text,
    required this.style,
    required this.ranges,
    this.focusRanges = const [],
    this.textScaler = TextScaler.noScaling,
    this.richTextKey,
  });

  final String text;
  final TextStyle style;
  final List<WordMarkRange> ranges;
  final List<WordFocusRange> focusRanges;
  final TextScaler textScaler;

  /// Applied to the inner [RichText] so a `find.byKey` still resolves to a
  /// [RenderParagraph] when overlays sit above or below it.
  final Key? richTextKey;

  @override
  Widget build(BuildContext context) {
    final marks = _normalizeRanges(ranges, text.length);
    final focus = _normalizeFocus(focusRanges, text.length);

    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final range in marks) {
      if (range.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, range.start)));
      }
      spans.add(
        TextSpan(
          text: text.substring(range.start, range.end),
          style: range.style.isUnderline
              ? style.copyWith(
                  decoration: TextDecoration.underline,
                  decorationStyle: range.style.decorationStyle,
                  decorationColor: range.color,
                  decorationThickness: 1.4,
                )
              : null,
        ),
      );
      cursor = range.end;
    }
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }

    final richText = RichText(
      key: richTextKey,
      text: TextSpan(style: style, children: spans),
      textScaler: textScaler,
      textAlign: TextAlign.left,
    );

    final fills = [
      for (final range in marks)
        if (range.style.hasFill) range,
    ];
    final borders = [
      for (final range in marks)
        if (range.style.hasBorder) range,
    ];
    if (fills.isEmpty && borders.isEmpty && focus.isEmpty) {
      return richText;
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            if (fills.isNotEmpty)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _MarkFillPainter(
                      text: text,
                      style: style,
                      textScaler: textScaler,
                      ranges: fills,
                      maxWidth: constraints.maxWidth,
                    ),
                  ),
                ),
              ),
            richText,
            if (borders.isNotEmpty || focus.isNotEmpty)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _MarkStrokePainter(
                      text: text,
                      style: style,
                      textScaler: textScaler,
                      marks: borders,
                      focus: focus,
                      maxWidth: constraints.maxWidth,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Clips ranges to the text, drops empty ones, sorts them, and shortens an
  /// overlapping range so each character is styled once.
  static List<WordMarkRange> _normalizeRanges(
    List<WordMarkRange> ranges,
    int length,
  ) {
    final clipped = <WordMarkRange>[];
    for (final range in ranges) {
      if (range.style == WordMarkStyle.none) continue;
      final start = range.start.clamp(0, length);
      final end = range.end.clamp(0, length);
      if (end > start) {
        clipped.add(WordMarkRange(start, end, range.style, range.color));
      }
    }
    clipped.sort((a, b) => a.start.compareTo(b.start));
    final normalized = <WordMarkRange>[];
    var cursor = 0;
    for (final range in clipped) {
      final start = range.start > cursor ? range.start : cursor;
      if (range.end <= start) continue;
      normalized.add(WordMarkRange(start, range.end, range.style, range.color));
      cursor = range.end;
    }
    return normalized;
  }

  static List<WordFocusRange> _normalizeFocus(
    List<WordFocusRange> ranges,
    int length,
  ) {
    final clipped = <WordFocusRange>[];
    for (final range in ranges) {
      final start = range.start.clamp(0, length);
      final end = range.end.clamp(0, length);
      if (end > start) clipped.add(WordFocusRange(start, end, range.color));
    }
    clipped.sort((a, b) => a.start.compareTo(b.start));
    final normalized = <WordFocusRange>[];
    var cursor = 0;
    for (final range in clipped) {
      final start = range.start > cursor ? range.start : cursor;
      if (range.end <= start) continue;
      normalized.add(WordFocusRange(start, range.end, range.color));
      cursor = range.end;
    }
    return normalized;
  }
}

/// Computes the rounded boxes a word occupies. Shared by the fill and stroke
/// painters so both land on exactly the same geometry.
///
/// [leftLimit] / [rightLimit] keep the boxes inside the text content box. The
/// reader clips its text with a tight rect, so a mark that grew past the
/// column edge (the first or last word on a line) would lose its outer pixel.
List<RRect> _wordBoxes(
  TextPainter layout,
  int start,
  int end,
  double targetHeight, {
  double padding = 0.8,
  double radius = 3.5,
  double leftLimit = 0,
  double rightLimit = double.infinity,
}) {
  final boxes = layout.getBoxesForSelection(
    TextSelection(baseOffset: start, extentOffset: end),
  );
  final result = <RRect>[];
  for (final box in boxes) {
    final verticalInset = ((box.bottom - box.top - targetHeight) / 2).clamp(
      0.0,
      double.infinity,
    );
    final left = box.left - padding < leftLimit
        ? leftLimit
        : box.left - padding;
    final right = box.right + padding > rightLimit
        ? rightLimit
        : box.right + padding;
    if (right <= left) continue;
    final rect = Rect.fromLTRB(
      left,
      box.top + verticalInset - padding / 2,
      right,
      box.bottom - verticalInset + padding / 2,
    );
    result.add(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
  }
  return result;
}

TextPainter _layoutFor(
  String text,
  TextStyle style,
  TextScaler textScaler,
  double maxWidth,
) {
  return TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
    textScaler: textScaler,
  )..layout(maxWidth: maxWidth);
}

class _MarkFillPainter extends CustomPainter {
  const _MarkFillPainter({
    required this.text,
    required this.style,
    required this.textScaler,
    required this.ranges,
    required this.maxWidth,
  });

  final String text;
  final TextStyle style;
  final TextScaler textScaler;
  final List<WordMarkRange> ranges;
  final double maxWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (ranges.isEmpty || maxWidth <= 0) return;
    final layout = _layoutFor(text, style, textScaler, maxWidth);
    final fontSize = (style.fontSize ?? 14) * textScaler.scale(1.0);
    final targetHeight = fontSize * 1.18;
    for (final range in ranges) {
      // The chosen colour is the fill itself; text is painted above it, so
      // dark and light palettes stay readable on their own.
      final paint = Paint()..color = range.color;
      for (final box in _wordBoxes(
        layout,
        range.start,
        range.end,
        targetHeight,
        rightLimit: maxWidth,
      )) {
        canvas.drawRRect(box, paint);
      }
    }
    layout.dispose();
  }

  @override
  bool shouldRepaint(covariant _MarkFillPainter oldDelegate) =>
      oldDelegate.text != text ||
      oldDelegate.style != style ||
      oldDelegate.textScaler != textScaler ||
      oldDelegate.maxWidth != maxWidth ||
      !listEquals(oldDelegate.ranges, ranges);
}

class _MarkStrokePainter extends CustomPainter {
  const _MarkStrokePainter({
    required this.text,
    required this.style,
    required this.textScaler,
    required this.marks,
    required this.focus,
    required this.maxWidth,
  });

  final String text;
  final TextStyle style;
  final TextScaler textScaler;
  final List<WordMarkRange> marks;
  final List<WordFocusRange> focus;
  final double maxWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if ((marks.isEmpty && focus.isEmpty) || maxWidth <= 0) return;
    final layout = _layoutFor(text, style, textScaler, maxWidth);
    final fontSize = (style.fontSize ?? 14) * textScaler.scale(1.0);
    final targetHeight = fontSize * 1.18;

    for (final range in marks) {
      final paint = Paint()
        ..color = range.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1;
      for (final box in _wordBoxes(
        layout,
        range.start,
        range.end,
        targetHeight,
        leftLimit: 0.6,
        rightLimit: maxWidth - 0.6,
      )) {
        canvas.drawRRect(box, paint);
      }
    }
    for (final range in focus) {
      final paint = Paint()
        ..color = range.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.7;
      for (final box in _wordBoxes(
        layout,
        range.start,
        range.end,
        targetHeight,
        padding: 1.6,
        radius: 4.5,
        leftLimit: 0.9,
        rightLimit: maxWidth - 0.9,
      )) {
        canvas.drawRRect(box, paint);
      }
    }
    layout.dispose();
  }

  @override
  bool shouldRepaint(covariant _MarkStrokePainter oldDelegate) =>
      oldDelegate.text != text ||
      oldDelegate.style != style ||
      oldDelegate.textScaler != textScaler ||
      oldDelegate.maxWidth != maxWidth ||
      !listEquals(oldDelegate.marks, marks) ||
      !listEquals(oldDelegate.focus, focus);
}

/// Serialises a colour for the settings table as `#AARRGGBB`.
String colorToStorage(Color color) =>
    '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';

/// Parses `#AARRGGBB` or `#RRGGBB`, returning null when the value is unusable.
Color? tryColorFromStorage(String? value) {
  if (value == null) return null;
  var hex = value.trim();
  if (hex.startsWith('#')) hex = hex.substring(1);
  if (hex.length == 6) hex = 'FF$hex';
  if (hex.length != 8) return null;
  final parsed = int.tryParse(hex, radix: 16);
  return parsed == null ? null : Color(parsed);
}

/// Parses `#AARRGGBB` or `#RRGGBB`, falling back when the value is unusable.
Color colorFromStorage(String? value, Color fallback) =>
    tryColorFromStorage(value) ?? fallback;
