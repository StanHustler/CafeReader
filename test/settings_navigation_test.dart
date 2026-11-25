import 'dart:io';

import 'package:cafereader/app/app_services.dart';
import 'package:cafereader/app/providers.dart';
import 'package:cafereader/core/design/app_theme.dart';
import 'package:cafereader/core/database/app_database.dart';
import 'package:cafereader/core/util/app_storage.dart';
import 'package:cafereader/domain/lemmatizer/lexicon.dart';
import 'package:cafereader/features/shell/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('opening a settings option keeps the sidebar visible', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // testWidgets installs a fake-async zone; real file IO must run through
    // runAsync or the await never completes.
    late final Directory temp;
    late final AppDatabase db;
    late final AppServices services;
    await tester.runAsync(() async {
      temp = await Directory.systemTemp.createTemp('cafereader-settings');
      final storage = AppStorage.at(temp);
      await storage.ensureLayout();
      db = AppDatabase.memory();
      services = AppServices(
        database: db,
        storage: storage,
        lexicon: LemmaLexicon(lemmas: const {'word'}),
        deviceId: 'test-device',
      );
    });
    addTearDown(() async {
      await tester.runAsync(() async {
        await db.close();
        if (await temp.exists()) await temp.delete(recursive: true);
      });
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appServicesProvider.overrideWithValue(services)],
        child: MaterialApp(
          theme: CafeTheme.build('light'),
          home: const AppShell(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Open Settings from the navigation rail.
    await tester.tap(find.byIcon(Icons.tune_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('About CafeReader'), findsOneWidget);

    // Opening an option swaps the content pane, not the whole window.
    await tester.tap(find.text('About CafeReader'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Third-party licenses'), findsOneWidget);
    // The rail is still there, with Settings still marked as the active tab.
    expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
    expect(
      find.text('Local-first by design. Your reading stays yours.'),
      findsNothing,
    );

    // Back returns to the settings list.
    await tester.tap(find.byTooltip('Back'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('About CafeReader'), findsOneWidget);
    expect(find.byIcon(Icons.tune_rounded), findsOneWidget);

    // Dispose the ProviderScope inside the fake-async zone. Drift schedules a
    // zero-duration timer when a query stream closes; pumping here lets it run
    // instead of tripping the "timer is still pending" teardown assertion.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 10));
  });
}
