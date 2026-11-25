import 'dart:io';
import 'dart:ui' as ui;

import 'package:cafereader/app/app.dart';
import 'package:cafereader/app/app_services.dart';
import 'package:cafereader/app/providers.dart';
import 'package:cafereader/core/util/app_storage.dart';
import 'package:cafereader/data/repository/vocabulary_repository.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

Future<void> pumpUntil(
  WidgetTester tester,
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (condition()) return;
  }
  fail('Timed out waiting for a UI condition.');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('import, open, paginate, and confirm New words', (tester) async {
    final captureKey = GlobalKey();
    final screenshotDir = Directory(
      '${Directory.systemTemp.path}/cafereader-shots',
    );
    await screenshotDir.create(recursive: true);
    Future<void> capture(WidgetTester tester, String name) async {
      final boundary =
          captureKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      await File('${screenshotDir.path}/$name.png')
          .writeAsBytes(data!.buffer.asUint8List());
    }

    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final appRoot = await Directory.systemTemp.createTemp('cafereader-it-app');
    final storage = AppStorage.at(Directory('${appRoot.path}/app'));
    await storage.ensureLayout();
    final services = await AppServices.initialize(storageOverride: storage);
    final marker = DateTime.now().microsecondsSinceEpoch;
    final title = 'Integration Book $marker';
    var value = marker;
    final buffer = StringBuffer('qzx');
    for (var i = 0; i < 8; i++) {
      buffer.writeCharCode(97 + (value % 26));
      value ~/= 26;
    }
    final uniqueWord = buffer.toString();
    final directory = await Directory.systemTemp.createTemp('cafereader-it');
    final file = File('${directory.path}/$title.txt');
    await file.writeAsString(
      'Chapter 1: Alpha\n\n'
      'A quiet room. The $uniqueWord waited beside a small blue house. '
      'It was scarcely possible to ignore.\n\n'
      'Another paragraph continues the page with ordinary words and a little '
      'more meaning.\n\n'
      'Chapter 2: Beta\n\n'
      'The second chapter has its own calm sentences and a different idea.\n',
    );
    final result = await services.imports.importFile(
      sourcePath: file.path,
      format: 'txt',
    );
    expect(result.chapterCount, 2);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appServicesProvider.overrideWithValue(services)],
        child: RepaintBoundary(key: captureKey, child: const CafeReaderApp()),
      ),
    );
    await tester.pump();
    await pumpUntil(tester, () => find.text('My Books').evaluate().isNotEmpty);
    await tester.pump(const Duration(seconds: 1));
    if (find.text(title).evaluate().isEmpty) {
      await tester.dragUntilVisible(
        find.text(title),
        find.byType(CustomScrollView).first,
        const Offset(0, -300),
      );
    }
    expect(find.text(title), findsWidgets);
    await capture(tester, 'home');

    // Import stores chapters only; vocabulary is created when a word is
    // opened in the reader.
    final vocabularyAfterImport = await services.database
        .customSelect('SELECT COUNT(*) AS c FROM vocabulary')
        .getSingle();
    expect(vocabularyAfterImport.read<int>('c'), 0);

    await tester.tap(find.text(title).first);
    await tester.pump();
    await pumpUntil(
      tester,
      () => find.text('Start reading').evaluate().isNotEmpty,
    );
    await tester.pump(const Duration(milliseconds: 500));
    await capture(tester, 'book-detail');
    await tester.tap(find.text('Start reading'));
    await tester.pump();
    await pumpUntil(
      tester,
      () =>
          find.byKey(const ValueKey('reader-paragraph')).evaluate().isNotEmpty,
    );
    await tester.pump(const Duration(milliseconds: 300));
    await capture(tester, 'reader');
    expect(find.textContaining(uniqueWord, findRichText: true), findsWidgets);

    final paragraphFinder = find
        .byKey(const ValueKey('reader-paragraph'))
        .first;
    final renderParagraph = tester.renderObject<RenderParagraph>(
      paragraphFinder,
    );
    final plainText = renderParagraph.text.toPlainText();
    final quietIndex = plainText.indexOf('quiet');
    expect(quietIndex, greaterThanOrEqualTo(0));
    final caret = renderParagraph.getOffsetForCaret(
      ui.TextPosition(offset: quietIndex + 2),
      Rect.zero,
    );
    await tester.tapAt(
      renderParagraph.localToGlobal(caret + const Offset(3, 5)),
    );
    await tester.pump(const Duration(milliseconds: 500));
    await pumpUntil(tester, () => find.text('Meaning').evaluate().isNotEmpty);
    await capture(tester, 'reader-word-panel');
    // Adding from the reader records the sentence for In your books.
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('vocabulary-status')),
        matching: find.text('Learning'),
      ),
    );
    await tester.pump(const Duration(milliseconds: 700));
    await tester.tap(find.byTooltip('Close').first);
    await tester.pump(const Duration(milliseconds: 400));

    // Opening another word without choosing a state writes nothing.
    final houseParagraph = tester.renderObject<RenderParagraph>(
      find.byKey(const ValueKey('reader-paragraph')).first,
    );
    final houseText = houseParagraph.text.toPlainText();
    final houseIndex = houseText.indexOf('house');
    expect(houseIndex, greaterThanOrEqualTo(0));
    final houseCaret = houseParagraph.getOffsetForCaret(
      ui.TextPosition(offset: houseIndex + 2),
      Rect.zero,
    );
    await tester.tapAt(
      houseParagraph.localToGlobal(houseCaret + const Offset(3, 5)),
    );
    await tester.pump(const Duration(milliseconds: 500));
    await pumpUntil(tester, () => find.text('Meaning').evaluate().isNotEmpty);
    await tester.tap(find.byTooltip('Close').first);
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.byKey(const ValueKey('page-turn-right')));
    await tester.pump(const Duration(milliseconds: 300));
    await pumpUntil(
      tester,
      () =>
          find.byKey(const ValueKey('reader-paragraph')).evaluate().isNotEmpty,
    );
    await tester.pump(const Duration(milliseconds: 500));
    final quietStatus = await services.database
        .customSelect(
          "SELECT COALESCE(s.status, 'NEW') AS status FROM vocabulary v "
          "LEFT JOIN word_statuses s ON v.id = s.vocabulary_id "
          "WHERE v.lemma = 'quiet'",
        )
        .getSingle();
    expect(
      quietStatus.read<String>('status'),
      VocabularyState.learning.dbValue,
    );
    final houseCount = await services.database
        .customSelect(
          'SELECT COUNT(*) AS c FROM vocabulary WHERE lemma = ?',
          variables: [Variable('house')],
        )
        .getSingle();
    expect(houseCount.read<int>('c'), 0);
    await capture(tester, 'reader-next-chapter');

    await tester.tap(find.byTooltip('Back to library'));
    await tester.pump();
    await pumpUntil(tester, () => find.text('Chapters').evaluate().isNotEmpty);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pageBack();
    await tester.pump();
    await pumpUntil(tester, () => find.text('My Books').evaluate().isNotEmpty);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('Deck'));
    await tester.pump();
    await pumpUntil(tester, () => find.text('Your deck').evaluate().isNotEmpty);
    await capture(tester, 'deck');
    await tester.tap(find.byTooltip(RegExp('^Learning')));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byTooltip(RegExp('^Search')));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.enterText(find.byType(TextField).first, 'quiet');
    await tester.pump(const Duration(milliseconds: 500));
    await pumpUntil(tester, () => find.text('quiet').evaluate().isNotEmpty);
    await tester.tap(find.text('quiet').last);
    await tester.pump(const Duration(milliseconds: 500));
    await pumpUntil(tester, () => find.text('Meaning').evaluate().isNotEmpty);
    // The sentence was recorded when the word was added from the reader.
    expect(find.text('In your books'), findsOneWidget);
    await capture(tester, 'vocabulary-panel');
    final quietDeckStatus = await services.database
        .customSelect(
          "SELECT s.status FROM word_statuses s JOIN vocabulary v "
          "ON v.id = s.vocabulary_id WHERE v.lemma = 'quiet'",
        )
        .getSingle();
    expect(quietDeckStatus.read<String>('status'), 'LEARNING');
    await tester.tap(find.byTooltip('Close').first);
    await tester.pump(const Duration(milliseconds: 400));
    await pumpUntil(
      tester,
      () => find.byTooltip('Review 1 due').evaluate().isNotEmpty,
    );
    await tester.tap(find.byTooltip('Review 1 due'));
    await tester.pump(const Duration(milliseconds: 500));
    await pumpUntil(
      tester,
      () => find.text('Reveal meaning').evaluate().isNotEmpty,
    );
    await capture(tester, 'review-front');
    await tester.tap(find.text('Reveal meaning'));
    await tester.pump(const Duration(milliseconds: 400));
    await pumpUntil(tester, () => find.text('Good').evaluate().isNotEmpty);
    await capture(tester, 'review-answer');
    await tester.tap(find.text('Good'));
    await tester.pump(const Duration(milliseconds: 500));
    await pumpUntil(
      tester,
      () => find.text('A good session.').evaluate().isNotEmpty,
    );
    await capture(tester, 'review-complete');
    await tester.tap(find.text('Back to Deck'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('Settings'));
    await tester.pump();
    await pumpUntil(
      tester,
      () => find
          .text('Local-first by design. Your reading stays yours.')
          .evaluate()
          .isNotEmpty,
    );
    await tester.pump(const Duration(milliseconds: 500));
    await capture(tester, 'settings');
    await tester.tap(find.text('Data'));
    await tester.pump();
    await pumpUntil(
      tester,
      () => find.text('CafeReader archive (.cfr)').evaluate().isNotEmpty,
    );
    await tester.pump(const Duration(milliseconds: 500));
    await capture(tester, 'settings-data');
    await tester.pageBack();
    await tester.pump();
    await pumpUntil(
      tester,
      () => find
          .text('Local-first by design. Your reading stays yours.')
          .evaluate()
          .isNotEmpty,
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('OneDrive'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await capture(tester, 'settings-onedrive');
    await pumpUntil(
      tester,
      () => find
          .textContaining('Connect a Microsoft account')
          .evaluate()
          .isNotEmpty,
    );
    await tester.pageBack();
    await tester.pump();
    await pumpUntil(
      tester,
      () => find
          .text('Local-first by design. Your reading stays yours.')
          .evaluate()
          .isNotEmpty,
    );
    await tester.pump(const Duration(milliseconds: 400));

    await tester.pumpWidget(const SizedBox());
    await services.dispose();
    await directory.delete(recursive: true);
    await appRoot.delete(recursive: true);
    // ignore: avoid_print
    print('Screenshots: ${screenshotDir.path}');
  });
}
