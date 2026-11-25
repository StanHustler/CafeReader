import 'package:cafereader/core/design/app_theme.dart';
import 'package:cafereader/core/design/subpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'standard subpage renders its header and pops with the back button',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: CafeTheme.build('light'),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SubpageScaffold(
                        title: 'Details',
                        child: Text('Body'),
                      ),
                    ),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Details'), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      expect(find.text('Open'), findsOneWidget);
    },
  );

  testWidgets(
    'compact subpage keeps a full-height body and honors disabled back',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: CafeTheme.build('light'),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SubpageScaffold(
                        title: 'Review',
                        style: SubpageHeaderStyle.compact,
                        scrollable: false,
                        backIcon: Icons.close,
                        backTooltip: 'Close review',
                        canGoBack: false,
                        actions: [Text('Limit 20')],
                        child: Center(child: Text('Session')),
                      ),
                    ),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Review'), findsOneWidget);
      expect(find.text('Session'), findsOneWidget);
      expect(find.text('Limit 20'), findsOneWidget);

      await tester.tap(find.byTooltip('Close review'));
      await tester.pumpAndSettle();
      expect(find.text('Session'), findsOneWidget);
    },
  );
}
