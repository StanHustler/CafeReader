import 'dart:io';

import 'package:cafereader/app/app_services.dart';
import 'package:cafereader/app/providers.dart';
import 'package:cafereader/core/database/app_database.dart';
import 'package:cafereader/core/design/app_theme.dart';
import 'package:cafereader/core/util/app_storage.dart';
import 'package:cafereader/data/repository/library_repository.dart';
import 'package:cafereader/domain/lemmatizer/lexicon.dart';
import 'package:cafereader/features/home/home_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  final now = DateTime(2026, 9, 1, 12);

  setUp(() {
    db = AppDatabase.memory();
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('long press and right click build the selection header', (
    tester,
  ) async {
    await _pumpHome(
      tester,
      db,
      books: [
        _bookItem('book-1', 'Alpha', now),
        _bookItem('book-2', 'Beta', now),
        _bookItem('book-3', 'Gamma', now),
      ],
      groups: [_group(now)],
    );

    expect(find.text('My Books'), findsOneWidget);
    expect(find.text('Science fiction'), findsOneWidget);
    expect(find.text('2 books'), findsOneWidget);

    await tester.longPress(find.text('Science fiction'));
    await tester.pump();

    expect(find.text('My Books'), findsNothing);
    expect(find.text('Group'), findsNothing);
    expect(find.text('Ungroup'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsNothing);

    await tester.tap(find.text('Cancel'));
    await tester.pump();
    expect(find.text('My Books'), findsOneWidget);

    await tester.longPress(find.text('Alpha'));
    await tester.pump();

    expect(find.text('My Books'), findsNothing);
    expect(find.text('Group'), findsOneWidget);
    expect(find.text('Ungroup'), findsNothing);
    expect(find.text('Delete'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsNothing);

    await tester.tap(find.text('Beta'), buttons: kSecondaryButton);
    await tester.pump();
    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.text('Science fiction'), buttons: kSecondaryButton);
    await tester.pump();
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Group'), findsOneWidget);
    expect(find.text('Ungroup'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pump();

    expect(find.text('My Books'), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
  });

  testWidgets('Group can create a new group and leaves selection mode', (
    tester,
  ) async {
    await db
        .into(db.books)
        .insert(
          BooksCompanion.insert(
            id: 'book-1',
            title: 'Alpha',
            originalFilePath: 'books/book-1.txt',
            format: 'txt',
            importedAt: now,
            updatedAt: now,
          ),
        );
    await _pumpHome(
      tester,
      db,
      books: [_bookItem('book-1', 'Alpha', now)],
      groups: const [],
    );

    await tester.longPress(find.text('Alpha'));
    await tester.pump();
    await tester.tap(find.text('Group'));
    await tester.pumpAndSettle();

    expect(find.text('Add 1 book to a group'), findsOneWidget);
    expect(find.text('New group'), findsOneWidget);

    await tester.tap(find.text('New group'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Favorites');
    await tester.pump();
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    final groups = await db.select(db.bookGroups).get();
    expect(groups.single.name, 'Favorites');
    final memberships = await db.select(db.bookGroupBooks).get();
    expect(memberships.single.bookId, 'book-1');
    expect(find.text('My Books'), findsOneWidget);
  });
}

Future<void> _pumpHome(
  WidgetTester tester,
  AppDatabase db, {
  required List<BookListItem> books,
  required List<BookGroupSummary> groups,
}) async {
  tester.view.physicalSize = const Size(1200, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final services = AppServices(
    database: db,
    storage: AppStorage.at(
      Directory('${Directory.systemTemp.path}/cafereader-widget'),
    ),
    lexicon: LemmaLexicon(lemmas: const {'word'}),
    deviceId: 'test-device',
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appServicesProvider.overrideWithValue(services),
        booksProvider.overrideWith((ref, query) => Stream.value(books)),
        groupsProvider.overrideWith((ref) => Stream.value(groups)),
      ],
      child: MaterialApp(
        theme: CafeTheme.build('light'),
        home: const HomePage(),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

BookGroupSummary _group(DateTime now) {
  return BookGroupSummary(
    id: 'group-1',
    name: 'Science fiction',
    bookCount: 2,
    covers: const [],
    createdAt: now,
    updatedAt: now,
  );
}

BookListItem _bookItem(String id, String title, DateTime now) {
  return BookListItem(
    book: Book(
      id: id,
      title: title,
      author: null,
      description: null,
      coverPath: null,
      originalFilePath: 'books/$id.txt',
      format: 'txt',
      language: 'en',
      fileSha256: null,
      revision: 1,
      importedAt: now,
      updatedAt: now,
      deletedAt: null,
    ),
    chapterCount: 4,
  );
}
