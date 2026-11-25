import 'dart:io';

import 'package:cafereader/core/database/app_database.dart';
import 'package:cafereader/core/util/app_storage.dart';
import 'package:cafereader/data/repository/library_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late Directory temp;
  late AppStorage storage;
  late LibraryRepository repository;
  final now = DateTime(2026, 8, 4, 12);

  setUp(() async {
    db = AppDatabase.memory();
    temp = await Directory.systemTemp.createTemp('cafereader-group-test');
    storage = AppStorage.at(Directory('${temp.path}/app'));
    await storage.ensureLayout();
    repository = LibraryRepository(db, storage, 'device-a');
    for (final id in ['book-1', 'book-2', 'book-3']) {
      await db
          .into(db.books)
          .insert(
            BooksCompanion.insert(
              id: id,
              title: 'Book $id',
              originalFilePath: storage.bookRelativePath(id, 'txt'),
              format: 'txt',
              importedAt: now,
              updatedAt: now,
            ),
          );
    }
  });

  tearDown(() async {
    await db.close();
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  test('createGroup trims its name and exposes members and covers', () async {
    final groupId = await repository.createGroup(
      name: '  Science fiction  ',
      bookIds: ['book-1', 'book-2', 'book-2'],
    );

    final groups = await repository.watchGroups().first;
    expect(groups, hasLength(1));
    final group = groups.single;
    expect(group.id, groupId);
    expect(group.name, 'Science fiction');
    expect(group.bookCount, 2);
    expect(
      group.covers.map((cover) => cover.id),
      unorderedEquals(['book-1', 'book-2']),
    );

    final books = await repository.watchLibrary(groupId: groupId).first;
    expect(
      books.map((item) => item.book.id),
      unorderedEquals(['book-1', 'book-2']),
    );
  });

  test(
    'grouped books leave Home and return when the group is removed',
    () async {
      final groupId = await repository.createGroup(
        name: 'Filed away',
        bookIds: ['book-1', 'book-2'],
      );

      final homeBooks = await repository
          .watchLibrary(excludeGrouped: true)
          .first;
      expect(homeBooks.map((item) => item.book.id), ['book-3']);

      expect(
        await repository.bookIdsInGroups([groupId]),
        unorderedEquals(['book-1', 'book-2']),
      );

      await repository.deleteGroups([groupId]);

      final after = await repository.watchLibrary(excludeGrouped: true).first;
      expect(
        after.map((item) => item.book.id),
        unorderedEquals(['book-1', 'book-2', 'book-3']),
      );
      expect(await db.select(db.bookGroups).get(), isEmpty);
      expect(await db.select(db.bookGroupBooks).get(), isEmpty);
    },
  );

  test('adding to an existing group is idempotent', () async {
    final groupId = await repository.createGroup(
      name: 'Weekend',
      bookIds: ['book-1'],
    );

    await repository.addBooksToGroup(groupId, ['book-2', 'book-2']);
    await repository.addBooksToGroup(groupId, ['book-1', 'book-2']);

    final group = (await repository.watchGroup(groupId).first)!;
    expect(group.bookCount, 2);
    expect(
      group.covers.map((cover) => cover.id),
      unorderedEquals(['book-1', 'book-2']),
    );
  });

  test('removed books leave group counts and listings', () async {
    final groupId = await repository.createGroup(
      name: 'Trial',
      bookIds: ['book-1', 'book-2'],
    );

    await repository.deleteBook('book-1');

    final group = (await repository.watchGroup(groupId).first)!;
    expect(group.bookCount, 1);
    expect(group.covers.single.id, 'book-2');
    final books = await repository.watchLibrary(groupId: groupId).first;
    expect(books.map((item) => item.book.id), ['book-2']);
    final memberships = await db.select(db.bookGroupBooks).get();
    expect(memberships.map((row) => row.bookId), isNot(contains('book-1')));
  });

  test('deleteAllData also clears groups', () async {
    await repository.createGroup(
      name: 'Everything',
      bookIds: ['book-1', 'book-2'],
    );

    await repository.deleteAllData();

    expect(await db.select(db.bookGroups).get(), isEmpty);
    expect(await db.select(db.bookGroupBooks).get(), isEmpty);
    expect(await repository.watchGroups().first, isEmpty);
  });
}
