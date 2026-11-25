import 'dart:io';

import 'package:cafereader/app/app_services.dart';
import 'package:cafereader/app/providers.dart';
import 'package:cafereader/core/database/app_database.dart';
import 'package:cafereader/core/design/app_theme.dart';
import 'package:cafereader/core/util/app_storage.dart';
import 'package:cafereader/domain/lemmatizer/lexicon.dart';
import 'package:cafereader/features/shell/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('secondary pages stay beside the sidebar', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // testWidgets installs a fake-async zone; real file IO and the database
    // must run through runAsync or their futures never complete.
    late final Directory temp;
    late final AppDatabase db;
    late final AppServices services;
    await tester.runAsync(() async {
      temp = await Directory.systemTemp.createTemp('cafereader-shell');
      final storage = AppStorage.at(temp);
      await storage.ensureLayout();
      db = AppDatabase.memory();
      services = AppServices(
        database: db,
        storage: storage,
        lexicon: LemmaLexicon(lemmas: const {'word'}),
        deviceId: 'test-device',
      );
      await db
          .into(db.books)
          .insert(
            BooksCompanion.insert(
              id: 'book-1',
              title: 'Alpha',
              originalFilePath: 'books/book-1.txt',
              format: 'txt',
              importedAt: DateTime(2026, 9, 1, 12),
              updatedAt: DateTime(2026, 9, 1, 12),
            ),
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

    expect(find.text('LIBRARY'), findsOneWidget);
    expect(find.text('Alpha'), findsOneWidget);

    await tester.tap(find.text('Alpha'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // The detail page is hosted in the content pane after the 226px sidebar;
    // the rail is still on screen.
    expect(find.text('Start reading'), findsOneWidget);
    expect(find.text('LIBRARY'), findsOneWidget);
    expect(tester.getTopLeft(find.byTooltip('Back')).dx, greaterThan(226));

    await tester.tap(find.byTooltip('Back'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('My Books'), findsOneWidget);

    // Dictionary is a first-class destination with a persistent search and
    // separate add and settings bubbles.
    await tester.tap(find.byIcon(Icons.translate_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Dictionary'), findsWidgets);
    expect(find.text('Look up a word'), findsWidgets);

    await tester.tap(find.byTooltip('Add dictionary'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Add dictionary'), findsOneWidget);
    expect(find.text('Import local dictionary'), findsOneWidget);
    expect(find.text('Add online dictionary'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.byTooltip('Manage dictionaries'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('WordNet 3.0'), findsOneWidget);
    expect(find.text('Import local dictionary'), findsOneWidget);
    expect(find.text('Add online dictionary'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Dispose the provider container inside the fake-async zone so Drift's
    // zero-duration stream-cancel timers drain before teardown.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 10));
  });
}
