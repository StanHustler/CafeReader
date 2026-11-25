import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/design/app_theme.dart';
import '../core/platform/window_chrome.dart';
import 'app.dart';
import 'app_services.dart';
import 'providers.dart';

Widget _withWindowChrome(BuildContext context, Widget? child) {
  return WindowChromeSync(
    child: DesktopWindowFrame(child: child ?? const SizedBox.shrink()),
  );
}

class CafeReaderBootstrap extends StatefulWidget {
  const CafeReaderBootstrap({super.key});

  @override
  State<CafeReaderBootstrap> createState() => _CafeReaderBootstrapState();
}

class _CafeReaderBootstrapState extends State<CafeReaderBootstrap> {
  late Future<AppServices> _services;
  Object? _lastError;

  @override
  void initState() {
    super.initState();
    _services = _initialize();
  }

  Future<AppServices> _initialize() async {
    try {
      await _preloadFonts();
      return await AppServices.initialize();
    } catch (error) {
      _lastError = error;
      rethrow;
    }
  }

  Future<void> _preloadFonts() async {
    final loader = FontLoader('Literata');
    for (final asset in [
      'assets/fonts/Literata-Regular.ttf',
      'assets/fonts/Literata-SemiBold.ttf',
      'assets/fonts/Literata-Bold.ttf',
    ]) {
      loader.addFont(rootBundle.load(asset));
    }
    try {
      await loader.load();
    } catch (_) {
      // The declared asset font family still works if eager loading fails.
    }
  }

  void _retry() {
    setState(() {
      _lastError = null;
      _services = _initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppServices>(
      future: _services,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ProviderScope(
            overrides: [appServicesProvider.overrideWithValue(snapshot.data!)],
            child: const CafeReaderApp(),
          );
        }
        if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: CafeTheme.build('light'),
            builder: _withWindowChrome,
            home: Scaffold(
              body: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_cafe_outlined, size: 44),
                        const SizedBox(height: 18),
                        Text(
                          'CafeReader could not start',
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${_lastError ?? snapshot.error}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: _retry,
                          child: const Text('Try again'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: CafeTheme.build('light'),
          builder: _withWindowChrome,
          home: const _LaunchScreen(),
        );
      },
    );
  }
}

class _LaunchScreen extends StatelessWidget {
  const _LaunchScreen();

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                'assets/branding/icon.png',
                width: 64,
                height: 64,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'CafeReader',
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(fontFamily: 'Literata'),
            ),
            const SizedBox(height: 8),
            Text(
              'Opening your reading room…',
              style: TextStyle(color: palette.inkMuted, fontSize: 12),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 120,
              child: LinearProgressIndicator(
                minHeight: 3,
                backgroundColor: palette.surfaceMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
