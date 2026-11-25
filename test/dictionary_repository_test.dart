import 'package:cafereader/core/database/app_database.dart';
import 'package:cafereader/data/repository/dictionary_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DictionaryRepository repository;

  setUp(() {
    db = AppDatabase.memory();
    repository = DictionaryRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('the builtin dictionary is always listed first', () async {
    final sources = await repository.watchDictionaries().first;

    expect(sources, hasLength(1));
    expect(sources.single.id, DictionaryRepository.builtinId);
    expect(sources.single.kind, DictionaryKind.builtin);
    expect(sources.single.enabled, isTrue);
  });

  test(
    'imported local dictionaries support lookup, toggling and removal',
    () async {
      final id = await repository.importLocal(
        name: 'Test dictionary',
        source: 'test.csv',
        translations: const [
          DictionaryTranslation(lemma: 'cat', meaning: '猫', partOfSpeech: 'n.'),
          DictionaryTranslation(
            lemma: 'cat',
            meaning: '猫科动物',
            partOfSpeech: 'n.',
          ),
          DictionaryTranslation(lemma: 'run', meaning: '跑', partOfSpeech: 'v.'),
        ],
      );

      var sources = await repository.watchDictionaries().first;
      final local = sources.firstWhere((source) => source.id == id);
      expect(local.kind, DictionaryKind.local);
      expect(local.entryCount, 3);
      expect(local.source, 'test.csv');

      final cat = await repository.localLookups('CAT');
      expect(cat[id], hasLength(2));
      expect(await repository.localDefinitionsFor('cat'), hasLength(2));

      await repository.setEnabled(id, false);
      expect(await repository.localLookups('cat'), isEmpty);
      expect(await repository.localDefinitionsFor('cat'), isEmpty);

      await repository.setEnabled(id, true);
      expect(await repository.localDefinitionsFor('cat'), hasLength(2));

      sources = await repository.watchDictionaries().first;
      expect(sources.where((source) => source.id == id), hasLength(1));

      await repository.deleteDictionary(id);
      expect(await db.select(db.dictionaries).get(), hasLength(1));
      expect(await db.select(db.dictionaryEntries).get(), isEmpty);
    },
  );

  test('online dictionaries keep their URL template', () async {
    final id = await repository.addOnline(
      name: 'Remote',
      urlTemplate: 'https://example.com/define?word={word}',
    );

    final source = (await repository.watchDictionaries().first).firstWhere(
      (source) => source.id == id,
    );
    expect(source.kind, DictionaryKind.online);
    expect(source.source, contains('{word}'));
    expect(source.entryCount, 0);
  });

  test('builtin dictionaries cannot be deleted', () async {
    await repository.watchDictionaries().first;
    await repository.deleteDictionary(DictionaryRepository.builtinId);
    expect(await db.select(db.dictionaries).get(), hasLength(1));
  });
}
