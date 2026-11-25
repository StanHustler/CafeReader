import 'package:drift/drift.dart';

/// All tables that hold user data. Vocabulary state is deliberately global:
/// [WordStatuses] is keyed only by vocabulary id and has no book/chapter column.
class Books extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get author => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get coverPath => text().nullable()();
  TextColumn get originalFilePath => text()();
  TextColumn get format => text()();
  TextColumn get language => text().withDefault(const Constant('en'))();
  TextColumn get fileSha256 => text().nullable()();
  IntColumn get revision => integer().withDefault(const Constant(1))();
  TextColumn get updatedBy => text().nullable()();
  DateTimeColumn get importedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A user-created shelf of books. Groups are local organisation only: a book
/// keeps its own reading progress and may belong to any number of groups.
class BookGroups extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class BookGroupBooks extends Table {
  TextColumn get groupId => text().references(BookGroups, #id)();
  TextColumn get bookId => text().references(Books, #id)();
  DateTimeColumn get addedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {groupId, bookId};
}

/// A dictionary source shown in Settings → Dictionary.
///
/// Built-in sources read their entries from the bundled lexicon; local sources
/// store rows in [DictionaryEntries]; online sources keep a URL template and
/// are queried on demand.
class Dictionaries extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get kind => text()();
  TextColumn get source => text().nullable()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  IntColumn get entryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class DictionaryEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get dictionaryId => text().references(Dictionaries, #id)();
  TextColumn get lemma => text()();
  TextColumn get partOfSpeech => text().withDefault(const Constant(''))();
  TextColumn get meaning => text()();
  TextColumn get example => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {dictionaryId, lemma, partOfSpeech, meaning},
  ];
}

class Chapters extends Table {
  TextColumn get id => text()();
  TextColumn get bookId => text().references(Books, #id)();
  TextColumn get title => text()();
  IntColumn get chapterIndex => integer()();
  TextColumn get content => text()();
  TextColumn get contentHash => text()();
  IntColumn get revision => integer().withDefault(const Constant(1))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {bookId, chapterIndex},
  ];
}

class ReadingProgress extends Table {
  TextColumn get id => text()();
  TextColumn get bookId => text().references(Books, #id)();
  TextColumn get chapterId => text().references(Chapters, #id)();
  IntColumn get anchorParagraph => integer().withDefault(const Constant(0))();
  IntColumn get anchorOffset => integer().withDefault(const Constant(0))();
  IntColumn get cachedPageIndex => integer().withDefault(const Constant(0))();
  IntColumn get cachedPageCount => integer().withDefault(const Constant(1))();
  TextColumn get layoutSignature => text().nullable()();
  IntColumn get revision => integer().withDefault(const Constant(1))();
  TextColumn get updatedBy => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {bookId, chapterId},
  ];
}

class PaginationCaches extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get chapterId => text().references(Chapters, #id)();
  TextColumn get layoutSignature => text()();
  IntColumn get pageIndex => integer()();
  IntColumn get startParagraph => integer()();
  IntColumn get startOffset => integer()();
  IntColumn get endParagraph => integer()();
  IntColumn get endOffset => integer()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {chapterId, layoutSignature, pageIndex},
  ];
}

class Vocabulary extends Table {
  TextColumn get id => text()();
  TextColumn get lemma => text()();
  TextColumn get language => text().withDefault(const Constant('en'))();
  TextColumn get senseLabel => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class WordForms extends Table {
  TextColumn get id => text()();
  TextColumn get surfaceForm => text()();
  TextColumn get normalizedForm => text()();
  TextColumn get vocabularyId => text().references(Vocabulary, #id)();
  RealColumn get confidence => real().withDefault(const Constant(0.8))();
  BoolColumn get isVerified => boolean().withDefault(const Constant(false))();
  BoolColumn get isPrimary => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {surfaceForm, vocabularyId},
  ];
}

class WordOccurrences extends Table {
  TextColumn get id => text()();
  TextColumn get bookId => text().references(Books, #id)();
  TextColumn get chapterId => text().references(Chapters, #id)();
  TextColumn get vocabularyId => text().references(Vocabulary, #id)();
  TextColumn get surfaceForm => text()();
  IntColumn get paragraphIndex => integer()();
  IntColumn get startOffset => integer()();
  IntColumn get endOffset => integer()();
  TextColumn get overrideVocabularyId =>
      text().nullable().references(Vocabulary, #id)();
  BoolColumn get isManuallyCorrected =>
      boolean().withDefault(const Constant(false))();
  IntColumn get revision => integer().withDefault(const Constant(1))();
  TextColumn get updatedBy => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class WordStatuses extends Table {
  TextColumn get vocabularyId => text().references(Vocabulary, #id)();
  TextColumn get status => text()();
  IntColumn get revision => integer().withDefault(const Constant(1))();
  TextColumn get updatedBy => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {vocabularyId};
}

class Definitions extends Table {
  TextColumn get id => text()();
  TextColumn get vocabularyId => text().references(Vocabulary, #id)();
  TextColumn get language => text().withDefault(const Constant('en'))();
  TextColumn get meaning => text()();
  TextColumn get example => text().nullable()();
  IntColumn get revision => integer().withDefault(const Constant(1))();
  TextColumn get updatedBy => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class FsrsCards extends Table {
  TextColumn get vocabularyId => text().references(Vocabulary, #id)();
  TextColumn get state => text()();
  DateTimeColumn get due => dateTime()();
  RealColumn get stability => real().withDefault(const Constant(0))();
  RealColumn get difficulty => real().withDefault(const Constant(0))();
  IntColumn get elapsedDays => integer().withDefault(const Constant(0))();
  IntColumn get scheduledDays => integer().withDefault(const Constant(0))();
  IntColumn get reps => integer().withDefault(const Constant(0))();
  IntColumn get lapses => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastReview => dateTime().nullable()();
  IntColumn get revision => integer().withDefault(const Constant(1))();
  TextColumn get updatedBy => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {vocabularyId};
}

class ReviewLogs extends Table {
  TextColumn get id => text()();
  TextColumn get vocabularyId => text().references(Vocabulary, #id)();
  DateTimeColumn get reviewedAt => dateTime()();
  IntColumn get rating => integer()();
  TextColumn get stateBefore => text()();
  TextColumn get stateAfter => text()();
  RealColumn get stabilityBefore => real()();
  RealColumn get stabilityAfter => real()();
  IntColumn get intervalDays => integer()();
  DateTimeColumn get dueAfter => dateTime()();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}

class AppMetadata extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}

class SyncMetadata extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  DateTimeColumn get localUpdatedAt => dateTime()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  IntColumn get lastSyncedVersion => integer().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {entityType, entityId},
  ];
}
