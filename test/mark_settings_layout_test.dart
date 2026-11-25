import 'package:cafereader/app/providers.dart';
import 'package:cafereader/core/database/app_database.dart';
import 'package:cafereader/core/design/app_theme.dart';
import 'package:cafereader/data/repository/settings_repository.dart';
import 'package:cafereader/features/settings/mark_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('mark settings fit one screen without scrolling', (tester) async {
    tester.view.physicalSize = const Size(600, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final db = AppDatabase.memory();
    addTearDown(() async {
      await tester.runAsync(db.close);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(
            SettingsRepository(db, 'test-device'),
          ),
          wordMarkSettingsProvider.overrideWith(
            (ref) => Stream.value(WordMarkSettings.defaults),
          ),
        ],
        child: MaterialApp(
          theme: CafeTheme.build('light'),
          home: const MarkSettingsPage(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsNothing);

    // Switching appearance rebuilds the compact page without overflowing.
    await tester.tap(find.text('Night'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('NIGHT PREVIEW'), findsOneWidget);

    // Switching the edited category inside the single card also fits.
    await tester.tap(find.text('Learning'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Known'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 10));
  });
}
