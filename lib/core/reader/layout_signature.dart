import 'dart:convert';

import 'package:flutter/material.dart';

/// Everything that can affect how a chapter is measured. When any of these
/// values changes, cached pagination is discarded and the reader restores the
/// text anchor in the newly generated pages.
class LayoutSignature {
  const LayoutSignature({
    required this.fontFamily,
    required this.fontSize,
    required this.fontWeight,
    required this.lineHeight,
    required this.paragraphSpacing,
    required this.contentWidth,
    required this.contentHeight,
    required this.orientation,
    required this.textScaleFactor,
  });

  final String fontFamily;
  final double fontSize;
  final int fontWeight;
  final double lineHeight;
  final double paragraphSpacing;
  final double contentWidth;
  final double contentHeight;
  final String orientation;
  final double textScaleFactor;

  String get key => jsonEncode(toJson());

  Map<String, Object> toJson() => {
    'font_family': fontFamily,
    'font_size': fontSize,
    'font_weight': fontWeight,
    'line_height': lineHeight,
    'paragraph_spacing': paragraphSpacing,
    'content_width': contentWidth,
    'content_height': contentHeight,
    'orientation': orientation,
    'text_scale': textScaleFactor,
  };

  @override
  bool operator ==(Object other) =>
      other is LayoutSignature && other.key == key;

  @override
  int get hashCode => key.hashCode;

  static String orientationFor(BuildContext context) =>
      MediaQuery.orientationOf(context).name;
}
