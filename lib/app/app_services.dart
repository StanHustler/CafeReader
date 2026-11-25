import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../core/backup/backup_service.dart';
import '../core/database/app_database.dart';
import '../core/sync/sync_engine.dart';
import '../core/util/app_storage.dart';
import '../data/import_export/csv_service.dart';
import '../data/local/book_import_service.dart';
import '../data/local/snapshot_service.dart';
import '../data/onedrive/graph_client.dart';
import '../data/onedrive/onedrive_auth.dart';
import '../data/repository/dictionary_repository.dart';
import '../data/repository/library_repository.dart';
import '../data/repository/reader_repository.dart';
import '../data/repository/review_repository.dart';
import '../data/repository/settings_repository.dart';
import '../data/repository/vocabulary_repository.dart';
import '../domain/lemmatizer/lemmatizer.dart';
import '../domain/lemmatizer/lexicon.dart';

/// Long-lived application services created once at startup.
class AppServices {
  AppServices({
    required this.database,
    required this.storage,
    required this.lexicon,
    required this.deviceId,
  });

  final AppDatabase database;
  final AppStorage storage;
  final LemmaLexicon lexicon;
  final String deviceId;

  late final Lemmatizer lemmatizer = Lemmatizer(lexicon: lexicon.lemmas);
  late final SettingsRepository settings = SettingsRepository(
    database,
    deviceId,
  );
  late final LibraryRepository library = LibraryRepository(
    database,
    storage,
    deviceId,
  );
  late final VocabularyRepository vocabulary = VocabularyRepository(
    database,
    lemmatizer,
    deviceId,
  );
  late final DictionaryRepository dictionary = DictionaryRepository(database);
  late final ReaderRepository reader = ReaderRepository(database, deviceId);
  late final ReviewRepository review = ReviewRepository(
    database,
    vocabulary,
    deviceId,
  );
  late final SnapshotService snapshots = SnapshotService(database);
  late final BookImportService imports = BookImportService(
    db: database,
    storage: storage,
    deviceId: deviceId,
  );
  late final CsvService csv = CsvService(database);
  late final BackupService backups = BackupService(
    db: database,
    storage: storage,
    snapshots: snapshots,
    deviceId: deviceId,
  );
  late final OneDriveAuthService oneDriveAuth = OneDriveAuthService(settings);
  late final SyncEngine syncEngine = SyncEngine(
    db: database,
    storage: storage,
    snapshots: snapshots,
    graphFactory: () => GraphClient(oneDriveAuth.accessToken),
    settings: settings,
    deviceId: deviceId,
  );

  Map<String, List<DictionarySense>>? _loadedDictionary;

  Future<void> preloadDictionary() async {
    if (_loadedDictionary != null) return;
    final loader = lexicon.loadGlosses;
    if (loader == null) {
      _loadedDictionary = {};
      return;
    }
    final senses = await loader();
    final map = <String, List<DictionarySense>>{};
    for (final sense in senses) {
      map.putIfAbsent(sense.lemma, () => []).add(sense);
    }
    _loadedDictionary = map;
  }

  Future<List<DictionarySense>> builtinDefinitionsFor(String lemma) async {
    await preloadDictionary();
    return _loadedDictionary?[lemma.trim().toLowerCase()] ?? const [];
  }

  /// Definitions from the bundled lexicon plus every enabled local dictionary.
  /// Online dictionaries are reached explicitly from the Dictionary page so
  /// opening a word in the reader never waits on the network.
  Future<List<DictionarySense>> definitionsFor(String lemma) async {
    final includeBuiltin = await dictionary.builtinEnabled();
    final builtin = includeBuiltin
        ? await builtinDefinitionsFor(lemma)
        : const <DictionarySense>[];
    final local = await dictionary.localDefinitionsFor(lemma);
    return [
      ...builtin,
      for (final entry in local)
        DictionarySense(
          lemma: entry.lemma,
          partOfSpeech: entry.partOfSpeech,
          meaning: entry.meaning,
        ),
    ];
  }

  Future<Map<String, List<DictionarySense>>> allDictionarySenses() async {
    await preloadDictionary();
    return _loadedDictionary ?? const {};
  }

  static Future<AppServices> initialize({
    AppStorage? storageOverride,
    AppDatabase? databaseOverride,
    LemmaLexicon? lexiconOverride,
  }) async {
    final storage = storageOverride ?? await AppStorage.create();
    final database =
        databaseOverride ?? await AppDatabase.openAt(storage.databasePath);
    final lexicon = lexiconOverride ?? await LemmaLexicon.load();
    await database.customStatement('PRAGMA foreign_keys = ON');
    var deviceId = await _readMetadata(database, 'device_id');
    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await database
          .into(database.appMetadata)
          .insert(
            AppMetadataCompanion.insert(
              key: 'device_id',
              value: deviceId,
              updatedAt: DateTime.now(),
            ),
            mode: InsertMode.insertOrReplace,
          );
    }
    final services = AppServices(
      database: database,
      storage: storage,
      lexicon: lexicon,
      deviceId: deviceId,
    );
    await services.settings.ensureDefaults();
    return services;
  }

  static Future<String?> _readMetadata(AppDatabase db, String key) async {
    final row = await (db.select(
      db.appMetadata,
    )..where((table) => table.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> dispose() async {
    await database.close();
  }
}
