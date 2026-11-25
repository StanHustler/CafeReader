import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

class CafeColors {
  const CafeColors({
    required this.background,
    required this.sidebar,
    required this.surface,
    required this.surfaceMuted,
    required this.ink,
    required this.inkMuted,
    required this.accent,
    required this.accentSoft,
    required this.line,
    required this.danger,
    required this.shadow,
    required this.newWordMark,
    required this.newWordFocus,
    required this.learningMark,
    required this.learningFocus,
  });

  final Color background;
  final Color sidebar;
  final Color surface;
  final Color surfaceMuted;
  final Color ink;
  final Color inkMuted;
  final Color accent;
  final Color accentSoft;
  final Color line;
  final Color danger;
  final Color shadow;

  /// Default marks for New words: the fill colour and its hover/tap focus.
  final Color newWordMark;
  final Color newWordFocus;

  /// Default marks for Learning words.
  final Color learningMark;
  final Color learningFocus;
}

class CafeTheme {
  static const light = CafeColors(
    background: Color(0xFFFAFAFA),
    sidebar: Color(0xFFF0F0F1),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFF1F1F3),
    ink: Color(0xFF1A1A1A),
    inkMuted: Color(0xFF6E6E73),
    accent: Color(0xFF1A1A1A),
    accentSoft: Color(0xFFF0F0F1),
    line: Color(0xFFE5E5E7),
    danger: Color(0xFFB3261E),
    shadow: Color(0x14000000),
    newWordMark: Color(0xFFC6DFFF),
    newWordFocus: Color(0xFF56A1FF),
    learningMark: Color(0xFFFFF2AB),
    learningFocus: Color(0xFFFECC47),
  );

  static const dark = CafeColors(
    background: Color(0xFF171411),
    sidebar: Color(0xFF1E1A16),
    surface: Color(0xFF241F1A),
    surfaceMuted: Color(0xFF302923),
    ink: Color(0xFFEDE4D8),
    inkMuted: Color(0xFFB5A999),
    accent: Color(0xFFD8A97A),
    accentSoft: Color(0xFF4A3525),
    line: Color(0xFF453B31),
    danger: Color(0xFFE08A83),
    shadow: Color(0x66000000),
    newWordMark: Color(0xFF253952),
    newWordFocus: Color(0xFFA1CBFF),
    learningMark: Color(0xFF4B3B1C),
    learningFocus: Color(0xFFD5D8DC),
  );

  static const eink = CafeColors(
    background: Color(0xFFFFFFFF),
    sidebar: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFFFFFFF),
    ink: Color(0xFF000000),
    inkMuted: Color(0xFF3B3B3B),
    accent: Color(0xFF000000),
    accentSoft: Color(0xFFFFFFFF),
    line: Color(0xFF8A8A8A),
    danger: Color(0xFF000000),
    shadow: Color(0xFFFFFFFF),
    newWordMark: Color(0xFF000000),
    newWordFocus: Color(0xFF000000),
    learningMark: Color(0xFF000000),
    learningFocus: Color(0xFF000000),
  );

  static CafeColors colorsFor(String name, bool einkMode) {
    if (einkMode) return eink;
    return name == 'dark' ? dark : light;
  }

  static ThemeData build(String name, {bool einkMode = false}) {
    final colors = colorsFor(name, einkMode);
    final brightness = name == 'dark' && !einkMode
        ? Brightness.dark
        : Brightness.light;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: colors.accent,
      onPrimary: colors.surface,
      secondary: colors.ink,
      onSecondary: colors.surface,
      error: colors.danger,
      onError: colors.surface,
      surface: colors.surface,
      onSurface: colors.ink,
      surfaceContainerHighest: colors.surfaceMuted,
      onSurfaceVariant: colors.inkMuted,
      outline: colors.line,
      outlineVariant: colors.line,
      shadow: colors.shadow,
      scrim: colors.ink,
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.background,
      splashFactory: einkMode
          ? NoSplash.splashFactory
          : InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.android: einkMode
              ? const _NoTransitionsBuilder()
              : const ZoomPageTransitionsBuilder(),
          TargetPlatform.windows: einkMode
              ? const _NoTransitionsBuilder()
              : const FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: einkMode
              ? const _NoTransitionsBuilder()
              : const CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: einkMode
              ? const _NoTransitionsBuilder()
              : const FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
    final textTheme = base.textTheme.copyWith(
      displayLarge: base.textTheme.displayLarge?.copyWith(
        fontFamily: 'Literata',
        fontWeight: FontWeight.w700,
        color: colors.ink,
        letterSpacing: -1.2,
      ),
      displayMedium: base.textTheme.displayMedium?.copyWith(
        fontFamily: 'Literata',
        fontWeight: FontWeight.w700,
        color: colors.ink,
        letterSpacing: -0.8,
      ),
      displaySmall: base.textTheme.displaySmall?.copyWith(
        fontFamily: 'Literata',
        fontWeight: FontWeight.w700,
        color: colors.ink,
        letterSpacing: -0.6,
      ),
      headlineLarge: base.textTheme.headlineLarge?.copyWith(
        fontFamily: 'Literata',
        fontWeight: FontWeight.w700,
        color: colors.ink,
        letterSpacing: -0.4,
      ),
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
        fontFamily: 'Literata',
        fontWeight: FontWeight.w600,
        color: colors.ink,
        letterSpacing: -0.3,
      ),
      headlineSmall: base.textTheme.headlineSmall?.copyWith(
        fontFamily: 'Literata',
        fontWeight: FontWeight.w600,
        color: colors.ink,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontFamily: 'Literata',
        fontWeight: FontWeight.w600,
        color: colors.ink,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: colors.ink,
      ),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(
        color: colors.ink,
        height: 1.45,
      ),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(
        color: colors.ink,
        height: 1.4,
      ),
      bodySmall: base.textTheme.bodySmall?.copyWith(
        color: colors.inkMuted,
        height: 1.35,
      ),
      labelLarge: base.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    );
    return base.copyWith(
      textTheme: textTheme,
      extensions: [CafePalette(colors)],
      dividerColor: colors.line,
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(einkMode ? 6 : 12),
          side: BorderSide(color: colors.line, width: einkMode ? 1.4 : 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        surfaceTintColor: Colors.transparent,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        indicatorColor: Colors.transparent,
        elevation: 0,
        height: 62,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? colors.ink
                : colors.inkMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            size: 22,
            color: states.contains(WidgetState.selected)
                ? colors.ink
                : colors.inkMuted,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colors.sidebar,
        indicatorColor: Colors.transparent,
        selectedIconTheme: IconThemeData(color: colors.surface),
        unselectedIconTheme: IconThemeData(color: colors.inkMuted),
        selectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: colors.surface,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: colors.inkMuted,
          fontWeight: FontWeight.w500,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        showDragHandle: true,
        dragHandleColor: colors.line,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: colors.line),
        ),
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyMedium,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        hintStyle: TextStyle(color: colors.inkMuted, fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.accent, width: 1.2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.accent,
          foregroundColor: colors.surface,
          minimumSize: const Size(44, 40),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.ink,
          minimumSize: const Size(44, 40),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          side: BorderSide(color: colors.line, width: 1),
          textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.accent,
          textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: colors.surfaceMuted,
        selectedColor: colors.accentSoft,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        labelStyle: TextStyle(color: colors.ink, fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          side: WidgetStatePropertyAll(BorderSide(color: colors.line)),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colors.surfaceMuted;
            }
            return Colors.transparent;
          }),
          foregroundColor: WidgetStatePropertyAll(colors.ink),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          ),
        ),
      ),
      sliderTheme: base.sliderTheme.copyWith(
        activeTrackColor: colors.accent,
        inactiveTrackColor: colors.line,
        thumbColor: colors.accent,
        overlayColor: colors.accent.withValues(alpha: 0.12),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? colors.accent
              : colors.inkMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? colors.accentSoft
              : colors.surfaceMuted;
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.ink,
        contentTextStyle: TextStyle(color: colors.surface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.accent,
        linearTrackColor: colors.line,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colors.inkMuted,
        textColor: colors.ink,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }
}

class _NoTransitionsBuilder extends PageTransitionsBuilder {
  const _NoTransitionsBuilder();
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => child;
}

class CafePalette extends ThemeExtension<CafePalette> {
  const CafePalette(this.colors);

  final CafeColors colors;

  static CafeColors of(BuildContext context) =>
      Theme.of(context).extension<CafePalette>()?.colors ?? CafeTheme.light;

  @override
  CafePalette copyWith({CafeColors? colors}) =>
      CafePalette(colors ?? this.colors);

  @override
  CafePalette lerp(ThemeExtension<CafePalette>? other, double t) {
    if (other is! CafePalette) return this;
    return t < 0.5 ? this : other;
  }
}
