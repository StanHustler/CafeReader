import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/backup/backup_service.dart';
import '../core/database/app_database.dart';
import '../core/sync/sync_controller.dart';
import '../core/sync/sync_engine.dart';
import '../data/import_export/csv_service.dart';
import '../data/local/book_import_service.dart';
import '../data/local/snapshot_service.dart';
import '../data/onedrive/onedrive_auth.dart';
import '../data/repository/dictionary_repository.dart';
import '../data/repository/library_repository.dart';
import '../data/repository/reader_repository.dart';
import '../data/repository/review_repository.dart';
import '../data/repository/settings_repository.dart';
import '../data/repository/vocabulary_repository.dart';
import 'app_services.dart';

final appServicesProvider = Provider<AppServices>(
  (ref) => throw StateError('AppServices must be overridden at bootstrap.'),
);

final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => ref.watch(appServicesProvider).database,
);
final libraryRepositoryProvider = Provider<LibraryRepository>(
  (ref) => ref.watch(appServicesProvider).library,
);
final dictionaryRepositoryProvider = Provider<DictionaryRepository>(
  (ref) => ref.watch(appServicesProvider).dictionary,
);
final vocabularyRepositoryProvider = Provider<VocabularyRepository>(
  (ref) => ref.watch(appServicesProvider).vocabulary,
);
final readerRepositoryProvider = Provider<ReaderRepository>(
  (ref) => ref.watch(appServicesProvider).reader,
);
final reviewRepositoryProvider = Provider<ReviewRepository>(
  (ref) => ref.watch(appServicesProvider).review,
);
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => ref.watch(appServicesProvider).settings,
);
final importServiceProvider = Provider<BookImportService>(
  (ref) => ref.watch(appServicesProvider).imports,
);
final backupServiceProvider = Provider<BackupService>(
  (ref) => ref.watch(appServicesProvider).backups,
);
final csvServiceProvider = Provider<CsvService>(
  (ref) => ref.watch(appServicesProvider).csv,
);
final snapshotServiceProvider = Provider<SnapshotService>(
  (ref) => ref.watch(appServicesProvider).snapshots,
);
final oneDriveAuthProvider = Provider<OneDriveAuthService>(
  (ref) => ref.watch(appServicesProvider).oneDriveAuth,
);
final syncEngineProvider = Provider<SyncEngine>(
  (ref) => ref.watch(appServicesProvider).syncEngine,
);
final syncControllerProvider = ChangeNotifierProvider<SyncController>((ref) {
  final controller = SyncController(ref.watch(appServicesProvider));
  controller.initialize();
  return controller;
});

final readerSettingsProvider = StreamProvider<ReaderSettings>((ref) {
  return ref.watch(settingsRepositoryProvider).watchReaderSettings();
});

final allSettingsProvider = StreamProvider<Map<String, String>>((ref) {
  return ref.watch(settingsRepositoryProvider).watchAll();
});

final fsrsSettingsProvider = StreamProvider<FsrsSettings>((ref) {
  return ref.watch(settingsRepositoryProvider).watchFsrsSettings();
});

/// How Learning words are marked in the reader, per appearance mode.
final wordMarkSettingsProvider = StreamProvider<WordMarkSettings>((ref) {
  return ref.watch(settingsRepositoryProvider).watchWordMarkSettings();
});

/// The app's light/dark appearance, shared by the shell and the reader.
final appAppearanceProvider = StreamProvider<AppAppearance>((ref) {
  return ref.watch(settingsRepositoryProvider).watchAppAppearance();
});

/// The library query and ordering that key [booksProvider].
class LibraryQuery {
  const LibraryQuery({
    this.query = '',
    this.sort = LibrarySort.recentlyRead,
    this.groupId,
    this.excludeGrouped = false,
  });

  final String query;
  final LibrarySort sort;

  /// When set, only books in this group are returned.
  final String? groupId;

  /// Hides books that belong to any group. Home uses this so grouped books
  /// live only inside their group.
  final bool excludeGrouped;

  @override
  bool operator ==(Object other) =>
      other is LibraryQuery &&
      other.query == query &&
      other.sort == sort &&
      other.groupId == groupId &&
      other.excludeGrouped == excludeGrouped;

  @override
  int get hashCode => Object.hash(query, sort, groupId, excludeGrouped);
}

final booksProvider = StreamProvider.autoDispose
    .family<List<BookListItem>, LibraryQuery>((ref, request) {
      return ref
          .watch(libraryRepositoryProvider)
          .watchLibrary(
            query: request.query,
            sort: request.sort,
            groupId: request.groupId,
            excludeGrouped: request.excludeGrouped,
          );
    });

final groupsProvider = StreamProvider.autoDispose<List<BookGroupSummary>>((
  ref,
) {
  return ref.watch(libraryRepositoryProvider).watchGroups();
});

final dictionariesProvider = StreamProvider.autoDispose<List<DictionarySource>>(
  (ref) {
    return ref.watch(dictionaryRepositoryProvider).watchDictionaries();
  },
);

final groupProvider = StreamProvider.autoDispose
    .family<BookGroupSummary?, String>((ref, groupId) {
      return ref.watch(libraryRepositoryProvider).watchGroup(groupId);
    });

final bookProvider = StreamProvider.autoDispose.family<Book?, String>((
  ref,
  bookId,
) {
  return ref.watch(libraryRepositoryProvider).watchBook(bookId);
});

final chaptersProvider = StreamProvider.autoDispose
    .family<List<ChapterListItem>, String>((ref, bookId) {
      return ref.watch(libraryRepositoryProvider).watchChapters(bookId);
    });

final chapterProvider = StreamProvider.autoDispose.family<Chapter?, String>((
  ref,
  chapterId,
) {
  return ref.watch(libraryRepositoryProvider).watchChapter(chapterId);
});

final vocabularyStatsProvider = StreamProvider<VocabularyStats>((ref) {
  return ref.watch(libraryRepositoryProvider).watchGlobalVocabularyStats();
});

final latestProgressProvider = StreamProvider.autoDispose
    .family<ReadingAnchor?, String>((ref, bookId) {
      return ref.watch(libraryRepositoryProvider).watchLatestProgress(bookId);
    });

final chapterStatsProvider = StreamProvider.autoDispose
    .family<ChapterVocabularyStats, String>((ref, chapterId) {
      return ref.watch(libraryRepositoryProvider).watchChapterStats(chapterId);
    });

final bookVocabularyStatsProvider = StreamProvider.autoDispose
    .family<ChapterVocabularyStats, String>((ref, bookId) {
      return ref
          .watch(libraryRepositoryProvider)
          .watchBookVocabularyStats(bookId);
    });

final chapterOccurrencesProvider = StreamProvider.autoDispose
    .family<List<ChapterOccurrence>, String>((ref, chapterId) {
      return ref
          .watch(vocabularyRepositoryProvider)
          .watchChapterOccurrences(chapterId);
    });

class DeckQuery {
  const DeckQuery({
    required this.state,
    this.query = '',
    this.bookId,
    this.sortByDue = false,
  });

  final VocabularyState state;
  final String query;
  final String? bookId;
  final bool sortByDue;

  @override
  bool operator ==(Object other) =>
      other is DeckQuery &&
      other.state == state &&
      other.query == query &&
      other.bookId == bookId &&
      other.sortByDue == sortByDue;

  @override
  int get hashCode => Object.hash(state, query, bookId, sortByDue);
}

final deckProvider = StreamProvider.autoDispose
    .family<List<DeckEntry>, DeckQuery>((ref, query) {
      return ref
          .watch(vocabularyRepositoryProvider)
          .watchDeck(
            state: query.state,
            query: query.query,
            bookId: query.bookId,
            sortByDue: query.sortByDue,
          );
    });

final deckTabProvider = StateProvider<VocabularyState>(
  (ref) => VocabularyState.learning,
);

final vocabularyStateProvider = StreamProvider.autoDispose
    .family<VocabularyState, String>((ref, vocabularyId) {
      return ref.watch(vocabularyRepositoryProvider).watchState(vocabularyId);
    });

final vocabularyProvider = StreamProvider.autoDispose
    .family<VocabularyData?, String>((ref, vocabularyId) {
      return ref
          .watch(vocabularyRepositoryProvider)
          .watchVocabulary(vocabularyId);
    });

final deckEntryProvider = FutureProvider.autoDispose.family<DeckEntry?, String>(
  (ref, vocabularyId) {
    return ref.watch(vocabularyRepositoryProvider).getDeckEntry(vocabularyId);
  },
);

final definitionsProvider = StreamProvider.autoDispose
    .family<List<Definition>, String>((ref, vocabularyId) {
      return ref
          .watch(vocabularyRepositoryProvider)
          .watchDefinitions(vocabularyId);
    });

final vocabularyFormsProvider = StreamProvider.autoDispose
    .family<List<WordForm>, String>((ref, vocabularyId) {
      return ref.watch(vocabularyRepositoryProvider).watchForms(vocabularyId);
    });

final vocabularyContextsProvider = StreamProvider.autoDispose
    .family<List<VocabularyContext>, String>((ref, vocabularyId) {
      return ref
          .watch(vocabularyRepositoryProvider)
          .watchContexts(vocabularyId);
    });

final dueCountProvider = StreamProvider.autoDispose<int>((ref) {
  return ref.watch(reviewRepositoryProvider).watchDueCount();
});

final dueItemsProvider = StreamProvider.autoDispose<List<ReviewItem>>((ref) {
  return ref.watch(reviewRepositoryProvider).watchDueItems();
});

final reviewHistoryProvider = StreamProvider.autoDispose
    .family<List<ReviewLog>, String>((ref, vocabularyId) {
      return ref.watch(reviewRepositoryProvider).watchHistory(vocabularyId);
    });

final fsrsCardProvider = StreamProvider.autoDispose.family<FsrsCard?, String>((
  ref,
  vocabularyId,
) {
  return ref.watch(reviewRepositoryProvider).watchCard(vocabularyId);
});
