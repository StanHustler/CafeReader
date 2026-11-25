import 'package:flutter/material.dart' show Brightness;
import 'package:flutter_test/flutter_test.dart';

import 'package:cafereader/core/design/app_theme.dart';

void main() {
  test('light app theme builds against the light palette', () {
    final theme = CafeTheme.build('light');
    expect(theme.useMaterial3, isTrue);
    expect(theme.extension<CafePalette>(), isNotNull);
    expect(theme.brightness, Brightness.light);
    expect(
      theme.extension<CafePalette>()?.colors.background,
      CafeTheme.light.background,
    );
  });

  test('dark app theme builds against the dark palette', () {
    final theme = CafeTheme.build('dark');
    expect(theme.brightness, Brightness.dark);
    expect(
      theme.extension<CafePalette>()?.colors.background,
      CafeTheme.dark.background,
    );
  });

  test('unknown appearance names fall back to light', () {
    final theme = CafeTheme.build('unknown');
    expect(theme.brightness, Brightness.light);
    expect(
      theme.extension<CafePalette>()?.colors.background,
      CafeTheme.light.background,
    );
  });

  test('e-ink mode overrides any appearance palette', () {
    final theme = CafeTheme.build('dark', einkMode: true);
    expect(theme.brightness, Brightness.light);
    expect(
      theme.extension<CafePalette>()?.colors.background,
      CafeTheme.eink.background,
    );
  });
}
