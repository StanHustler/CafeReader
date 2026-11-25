import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/design/app_theme.dart';
import '../core/platform/window_chrome.dart';
import '../data/repository/settings_repository.dart';
import '../features/shell/app_shell.dart';
import 'providers.dart';

class CafeReaderApp extends ConsumerWidget {
  const CafeReaderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // One appearance covers the shell and the reading page.
    final appearance =
        ref.watch(appAppearanceProvider).valueOrNull ?? const AppAppearance();
    final eink = appearance.mode == AppAppearanceMode.eink;
    final themeMode = switch (appearance.mode) {
      AppAppearanceMode.light => ThemeMode.light,
      AppAppearanceMode.dark => ThemeMode.dark,
      AppAppearanceMode.auto => ThemeMode.system,
      AppAppearanceMode.eink => ThemeMode.light,
    };
    return MaterialApp(
      title: 'CafeReader',
      debugShowCheckedModeBanner: false,
      theme: CafeTheme.build('light', einkMode: eink),
      darkTheme: CafeTheme.build('dark', einkMode: eink),
      themeMode: themeMode,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        overscroll: false,
      ),
      builder: (context, child) {
        return WindowChromeSync(
          child: DesktopWindowFrame(
            child: MediaQuery.withClampedTextScaling(
              minScaleFactor: 0.85,
              maxScaleFactor: 1.6,
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
      home: const AppShell(),
    );
  }
}
