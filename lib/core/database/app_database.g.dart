// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BooksTable extends Books with TableInfo<$BooksTable, Book> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverPathMeta = const VerificationMeta(
    'coverPath',
  );
  @override
  late final GeneratedColumn<String> coverPath = GeneratedColumn<String>(
    'cover_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originalFilePathMeta = const VerificationMeta(
    'originalFilePath',
  );
  @override
  late final GeneratedColumn<String> originalFilePath = GeneratedColumn<String>(
    'original_file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
    'format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('en'),
  );
  static const VerificationMeta _fileSha256Meta = const VerificationMeta(
    'fileSha256',
  );
  @override
  late final GeneratedColumn<String> fileSha256 = GeneratedColumn<String>(
    'file_sha256',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
    'imported_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    author,
    description,
    coverPath,
    originalFilePath,
    format,
    language,
    fileSha256,
    revision,
    updatedBy,
    importedAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'books';
  @override
  VerificationContext validateIntegrity(
    Insertable<Book> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('cover_path')) {
      context.handle(
        _coverPathMeta,
        coverPath.isAcceptableOrUnknown(data['cover_path']!, _coverPathMeta),
      );
    }
    if (data.containsKey('original_file_path')) {
      context.handle(
        _originalFilePathMeta,
        originalFilePath.isAcceptableOrUnknown(
          data['original_file_path']!,
          _originalFilePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalFilePathMeta);
    }
    if (data.containsKey('format')) {
      context.handle(
        _formatMeta,
        format.isAcceptableOrUnknown(data['format']!, _formatMeta),
      );
    } else if (isInserting) {
      context.missing(_formatMeta);
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    }
    if (data.containsKey('file_sha256')) {
      context.handle(
        _fileSha256Meta,
        fileSha256.isAcceptableOrUnknown(data['file_sha256']!, _fileSha256Meta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_importedAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Book map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Book(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      coverPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_path'],
      ),
      originalFilePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_file_path'],
      )!,
      format: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format'],
      )!,
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      fileSha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_sha256'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      ),
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $BooksTable createAlias(String alias) {
    return $BooksTable(attachedDatabase, alias);
  }
}

class Book extends DataClass implements Insertable<Book> {
  final String id;
  final String title;
  final String? author;
  final String? description;
  final String? coverPath;
  final String originalFilePath;
  final String format;
  final String language;
  final String? fileSha256;
  final int revision;
  final String? updatedBy;
  final DateTime importedAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const Book({
    required this.id,
    required this.title,
    this.author,
    this.description,
    this.coverPath,
    required this.originalFilePath,
    required this.format,
    required this.language,
    this.fileSha256,
    required this.revision,
    this.updatedBy,
    required this.importedAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || coverPath != null) {
      map['cover_path'] = Variable<String>(coverPath);
    }
    map['original_file_path'] = Variable<String>(originalFilePath);
    map['format'] = Variable<String>(format);
    map['language'] = Variable<String>(language);
    if (!nullToAbsent || fileSha256 != null) {
      map['file_sha256'] = Variable<String>(fileSha256);
    }
    map['revision'] = Variable<int>(revision);
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    map['imported_at'] = Variable<DateTime>(importedAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  BooksCompanion toCompanion(bool nullToAbsent) {
    return BooksCompanion(
      id: Value(id),
      title: Value(title),
      author: author == null && nullToAbsent
          ? const Value.absent()
          : Value(author),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      coverPath: coverPath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverPath),
      originalFilePath: Value(originalFilePath),
      format: Value(format),
      language: Value(language),
      fileSha256: fileSha256 == null && nullToAbsent
          ? const Value.absent()
          : Value(fileSha256),
      revision: Value(revision),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      importedAt: Value(importedAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Book.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Book(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      author: serializer.fromJson<String?>(json['author']),
      description: serializer.fromJson<String?>(json['description']),
      coverPath: serializer.fromJson<String?>(json['coverPath']),
      originalFilePath: serializer.fromJson<String>(json['originalFilePath']),
      format: serializer.fromJson<String>(json['format']),
      language: serializer.fromJson<String>(json['language']),
      fileSha256: serializer.fromJson<String?>(json['fileSha256']),
      revision: serializer.fromJson<int>(json['revision']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      importedAt: serializer.fromJson<DateTime>(json['importedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'author': serializer.toJson<String?>(author),
      'description': serializer.toJson<String?>(description),
      'coverPath': serializer.toJson<String?>(coverPath),
      'originalFilePath': serializer.toJson<String>(originalFilePath),
      'format': serializer.toJson<String>(format),
      'language': serializer.toJson<String>(language),
      'fileSha256': serializer.toJson<String?>(fileSha256),
      'revision': serializer.toJson<int>(revision),
      'updatedBy': serializer.toJson<String?>(updatedBy),
      'importedAt': serializer.toJson<DateTime>(importedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Book copyWith({
    String? id,
    String? title,
    Value<String?> author = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<String?> coverPath = const Value.absent(),
    String? originalFilePath,
    String? format,
    String? language,
    Value<String?> fileSha256 = const Value.absent(),
    int? revision,
    Value<String?> updatedBy = const Value.absent(),
    DateTime? importedAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Book(
    id: id ?? this.id,
    title: title ?? this.title,
    author: author.present ? author.value : this.author,
    description: description.present ? description.value : this.description,
    coverPath: coverPath.present ? coverPath.value : this.coverPath,
    originalFilePath: originalFilePath ?? this.originalFilePath,
    format: format ?? this.format,
    language: language ?? this.language,
    fileSha256: fileSha256.present ? fileSha256.value : this.fileSha256,
    revision: revision ?? this.revision,
    updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
    importedAt: importedAt ?? this.importedAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Book copyWithCompanion(BooksCompanion data) {
    return Book(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      author: data.author.present ? data.author.value : this.author,
      description: data.description.present
          ? data.description.value
          : this.description,
      coverPath: data.coverPath.present ? data.coverPath.value : this.coverPath,
      originalFilePath: data.originalFilePath.present
          ? data.originalFilePath.value
          : this.originalFilePath,
      format: data.format.present ? data.format.value : this.format,
      language: data.language.present ? data.language.value : this.language,
      fileSha256: data.fileSha256.present
          ? data.fileSha256.value
          : this.fileSha256,
      revision: data.revision.present ? data.revision.value : this.revision,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Book(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('description: $description, ')
          ..write('coverPath: $coverPath, ')
          ..write('originalFilePath: $originalFilePath, ')
          ..write('format: $format, ')
          ..write('language: $language, ')
          ..write('fileSha256: $fileSha256, ')
          ..write('revision: $revision, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('importedAt: $importedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    author,
    description,
    coverPath,
    originalFilePath,
    format,
    language,
    fileSha256,
    revision,
    updatedBy,
    importedAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Book &&
          other.id == this.id &&
          other.title == this.title &&
          other.author == this.author &&
          other.description == this.description &&
          other.coverPath == this.coverPath &&
          other.originalFilePath == this.originalFilePath &&
          other.format == this.format &&
          other.language == this.language &&
          other.fileSha256 == this.fileSha256 &&
          other.revision == this.revision &&
          other.updatedBy == this.updatedBy &&
          other.importedAt == this.importedAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class BooksCompanion extends UpdateCompanion<Book> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> author;
  final Value<String?> description;
  final Value<String?> coverPath;
  final Value<String> originalFilePath;
  final Value<String> format;
  final Value<String> language;
  final Value<String?> fileSha256;
  final Value<int> revision;
  final Value<String?> updatedBy;
  final Value<DateTime> importedAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const BooksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.author = const Value.absent(),
    this.description = const Value.absent(),
    this.coverPath = const Value.absent(),
    this.originalFilePath = const Value.absent(),
    this.format = const Value.absent(),
    this.language = const Value.absent(),
    this.fileSha256 = const Value.absent(),
    this.revision = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BooksCompanion.insert({
    required String id,
    required String title,
    this.author = const Value.absent(),
    this.description = const Value.absent(),
    this.coverPath = const Value.absent(),
    required String originalFilePath,
    required String format,
    this.language = const Value.absent(),
    this.fileSha256 = const Value.absent(),
    this.revision = const Value.absent(),
    this.updatedBy = const Value.absent(),
    required DateTime importedAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       originalFilePath = Value(originalFilePath),
       format = Value(format),
       importedAt = Value(importedAt),
       updatedAt = Value(updatedAt);
  static Insertable<Book> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? author,
    Expression<String>? description,
    Expression<String>? coverPath,
    Expression<String>? originalFilePath,
    Expression<String>? format,
    Expression<String>? language,
    Expression<String>? fileSha256,
    Expression<int>? revision,
    Expression<String>? updatedBy,
    Expression<DateTime>? importedAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (author != null) 'author': author,
      if (description != null) 'description': description,
      if (coverPath != null) 'cover_path': coverPath,
      if (originalFilePath != null) 'original_file_path': originalFilePath,
      if (format != null) 'format': format,
      if (language != null) 'language': language,
      if (fileSha256 != null) 'file_sha256': fileSha256,
      if (revision != null) 'revision': revision,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (importedAt != null) 'imported_at': importedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BooksCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? author,
    Value<String?>? description,
    Value<String?>? coverPath,
    Value<String>? originalFilePath,
    Value<String>? format,
    Value<String>? language,
    Value<String?>? fileSha256,
    Value<int>? revision,
    Value<String?>? updatedBy,
    Value<DateTime>? importedAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return BooksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      coverPath: coverPath ?? this.coverPath,
      originalFilePath: originalFilePath ?? this.originalFilePath,
      format: format ?? this.format,
      language: language ?? this.language,
      fileSha256: fileSha256 ?? this.fileSha256,
      revision: revision ?? this.revision,
      updatedBy: updatedBy ?? this.updatedBy,
      importedAt: importedAt ?? this.importedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (coverPath.present) {
      map['cover_path'] = Variable<String>(coverPath.value);
    }
    if (originalFilePath.present) {
      map['original_file_path'] = Variable<String>(originalFilePath.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (fileSha256.present) {
      map['file_sha256'] = Variable<String>(fileSha256.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BooksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('description: $description, ')
          ..write('coverPath: $coverPath, ')
          ..write('originalFilePath: $originalFilePath, ')
          ..write('format: $format, ')
          ..write('language: $language, ')
          ..write('fileSha256: $fileSha256, ')
          ..write('revision: $revision, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('importedAt: $importedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookGroupsTable extends BookGroups
    with TableInfo<$BookGroupsTable, BookGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'book_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookGroup> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookGroup(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $BookGroupsTable createAlias(String alias) {
    return $BookGroupsTable(attachedDatabase, alias);
  }
}

class BookGroup extends DataClass implements Insertable<BookGroup> {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  const BookGroup({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BookGroupsCompanion toCompanion(bool nullToAbsent) {
    return BookGroupsCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory BookGroup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookGroup(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  BookGroup copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => BookGroup(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  BookGroup copyWithCompanion(BookGroupsCompanion data) {
    return BookGroup(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookGroup(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookGroup &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BookGroupsCompanion extends UpdateCompanion<BookGroup> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const BookGroupsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookGroupsCompanion.insert({
    required String id,
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<BookGroup> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookGroupsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return BookGroupsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookGroupsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookGroupBooksTable extends BookGroupBooks
    with TableInfo<$BookGroupBooksTable, BookGroupBook> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookGroupBooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES book_groups (id)',
    ),
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id)',
    ),
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [groupId, bookId, addedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'book_group_books';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookGroupBook> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {groupId, bookId};
  @override
  BookGroupBook map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookGroupBook(
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $BookGroupBooksTable createAlias(String alias) {
    return $BookGroupBooksTable(attachedDatabase, alias);
  }
}

class BookGroupBook extends DataClass implements Insertable<BookGroupBook> {
  final String groupId;
  final String bookId;
  final DateTime addedAt;
  const BookGroupBook({
    required this.groupId,
    required this.bookId,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['group_id'] = Variable<String>(groupId);
    map['book_id'] = Variable<String>(bookId);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  BookGroupBooksCompanion toCompanion(bool nullToAbsent) {
    return BookGroupBooksCompanion(
      groupId: Value(groupId),
      bookId: Value(bookId),
      addedAt: Value(addedAt),
    );
  }

  factory BookGroupBook.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookGroupBook(
      groupId: serializer.fromJson<String>(json['groupId']),
      bookId: serializer.fromJson<String>(json['bookId']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'groupId': serializer.toJson<String>(groupId),
      'bookId': serializer.toJson<String>(bookId),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  BookGroupBook copyWith({
    String? groupId,
    String? bookId,
    DateTime? addedAt,
  }) => BookGroupBook(
    groupId: groupId ?? this.groupId,
    bookId: bookId ?? this.bookId,
    addedAt: addedAt ?? this.addedAt,
  );
  BookGroupBook copyWithCompanion(BookGroupBooksCompanion data) {
    return BookGroupBook(
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookGroupBook(')
          ..write('groupId: $groupId, ')
          ..write('bookId: $bookId, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(groupId, bookId, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookGroupBook &&
          other.groupId == this.groupId &&
          other.bookId == this.bookId &&
          other.addedAt == this.addedAt);
}

class BookGroupBooksCompanion extends UpdateCompanion<BookGroupBook> {
  final Value<String> groupId;
  final Value<String> bookId;
  final Value<DateTime> addedAt;
  final Value<int> rowid;
  const BookGroupBooksCompanion({
    this.groupId = const Value.absent(),
    this.bookId = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookGroupBooksCompanion.insert({
    required String groupId,
    required String bookId,
    required DateTime addedAt,
    this.rowid = const Value.absent(),
  }) : groupId = Value(groupId),
       bookId = Value(bookId),
       addedAt = Value(addedAt);
  static Insertable<BookGroupBook> custom({
    Expression<String>? groupId,
    Expression<String>? bookId,
    Expression<DateTime>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (groupId != null) 'group_id': groupId,
      if (bookId != null) 'book_id': bookId,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookGroupBooksCompanion copyWith({
    Value<String>? groupId,
    Value<String>? bookId,
    Value<DateTime>? addedAt,
    Value<int>? rowid,
  }) {
    return BookGroupBooksCompanion(
      groupId: groupId ?? this.groupId,
      bookId: bookId ?? this.bookId,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookGroupBooksCompanion(')
          ..write('groupId: $groupId, ')
          ..write('bookId: $bookId, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DictionariesTable extends Dictionaries
    with TableInfo<$DictionariesTable, Dictionary> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DictionariesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _entryCountMeta = const VerificationMeta(
    'entryCount',
  );
  @override
  late final GeneratedColumn<int> entryCount = GeneratedColumn<int>(
    'entry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    kind,
    source,
    enabled,
    entryCount,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dictionaries';
  @override
  VerificationContext validateIntegrity(
    Insertable<Dictionary> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('entry_count')) {
      context.handle(
        _entryCountMeta,
        entryCount.isAcceptableOrUnknown(data['entry_count']!, _entryCountMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Dictionary map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Dictionary(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      ),
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      entryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entry_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DictionariesTable createAlias(String alias) {
    return $DictionariesTable(attachedDatabase, alias);
  }
}

class Dictionary extends DataClass implements Insertable<Dictionary> {
  final String id;
  final String name;
  final String kind;
  final String? source;
  final bool enabled;
  final int entryCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Dictionary({
    required this.id,
    required this.name,
    required this.kind,
    this.source,
    required this.enabled,
    required this.entryCount,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    map['enabled'] = Variable<bool>(enabled);
    map['entry_count'] = Variable<int>(entryCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DictionariesCompanion toCompanion(bool nullToAbsent) {
    return DictionariesCompanion(
      id: Value(id),
      name: Value(name),
      kind: Value(kind),
      source: source == null && nullToAbsent
          ? const Value.absent()
          : Value(source),
      enabled: Value(enabled),
      entryCount: Value(entryCount),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Dictionary.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Dictionary(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      source: serializer.fromJson<String?>(json['source']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      entryCount: serializer.fromJson<int>(json['entryCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'source': serializer.toJson<String?>(source),
      'enabled': serializer.toJson<bool>(enabled),
      'entryCount': serializer.toJson<int>(entryCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Dictionary copyWith({
    String? id,
    String? name,
    String? kind,
    Value<String?> source = const Value.absent(),
    bool? enabled,
    int? entryCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Dictionary(
    id: id ?? this.id,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    source: source.present ? source.value : this.source,
    enabled: enabled ?? this.enabled,
    entryCount: entryCount ?? this.entryCount,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Dictionary copyWithCompanion(DictionariesCompanion data) {
    return Dictionary(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      source: data.source.present ? data.source.value : this.source,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      entryCount: data.entryCount.present
          ? data.entryCount.value
          : this.entryCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Dictionary(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('source: $source, ')
          ..write('enabled: $enabled, ')
          ..write('entryCount: $entryCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    kind,
    source,
    enabled,
    entryCount,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Dictionary &&
          other.id == this.id &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.source == this.source &&
          other.enabled == this.enabled &&
          other.entryCount == this.entryCount &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DictionariesCompanion extends UpdateCompanion<Dictionary> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> kind;
  final Value<String?> source;
  final Value<bool> enabled;
  final Value<int> entryCount;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DictionariesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.source = const Value.absent(),
    this.enabled = const Value.absent(),
    this.entryCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DictionariesCompanion.insert({
    required String id,
    required String name,
    required String kind,
    this.source = const Value.absent(),
    this.enabled = const Value.absent(),
    this.entryCount = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       kind = Value(kind),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Dictionary> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? source,
    Expression<bool>? enabled,
    Expression<int>? entryCount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (source != null) 'source': source,
      if (enabled != null) 'enabled': enabled,
      if (entryCount != null) 'entry_count': entryCount,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DictionariesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? kind,
    Value<String?>? source,
    Value<bool>? enabled,
    Value<int>? entryCount,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return DictionariesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      source: source ?? this.source,
      enabled: enabled ?? this.enabled,
      entryCount: entryCount ?? this.entryCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (entryCount.present) {
      map['entry_count'] = Variable<int>(entryCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DictionariesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('source: $source, ')
          ..write('enabled: $enabled, ')
          ..write('entryCount: $entryCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DictionaryEntriesTable extends DictionaryEntries
    with TableInfo<$DictionaryEntriesTable, DictionaryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DictionaryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dictionaryIdMeta = const VerificationMeta(
    'dictionaryId',
  );
  @override
  late final GeneratedColumn<String> dictionaryId = GeneratedColumn<String>(
    'dictionary_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES dictionaries (id)',
    ),
  );
  static const VerificationMeta _lemmaMeta = const VerificationMeta('lemma');
  @override
  late final GeneratedColumn<String> lemma = GeneratedColumn<String>(
    'lemma',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partOfSpeechMeta = const VerificationMeta(
    'partOfSpeech',
  );
  @override
  late final GeneratedColumn<String> partOfSpeech = GeneratedColumn<String>(
    'part_of_speech',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _meaningMeta = const VerificationMeta(
    'meaning',
  );
  @override
  late final GeneratedColumn<String> meaning = GeneratedColumn<String>(
    'meaning',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exampleMeta = const VerificationMeta(
    'example',
  );
  @override
  late final GeneratedColumn<String> example = GeneratedColumn<String>(
    'example',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dictionaryId,
    lemma,
    partOfSpeech,
    meaning,
    example,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dictionary_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DictionaryEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('dictionary_id')) {
      context.handle(
        _dictionaryIdMeta,
        dictionaryId.isAcceptableOrUnknown(
          data['dictionary_id']!,
          _dictionaryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dictionaryIdMeta);
    }
    if (data.containsKey('lemma')) {
      context.handle(
        _lemmaMeta,
        lemma.isAcceptableOrUnknown(data['lemma']!, _lemmaMeta),
      );
    } else if (isInserting) {
      context.missing(_lemmaMeta);
    }
    if (data.containsKey('part_of_speech')) {
      context.handle(
        _partOfSpeechMeta,
        partOfSpeech.isAcceptableOrUnknown(
          data['part_of_speech']!,
          _partOfSpeechMeta,
        ),
      );
    }
    if (data.containsKey('meaning')) {
      context.handle(
        _meaningMeta,
        meaning.isAcceptableOrUnknown(data['meaning']!, _meaningMeta),
      );
    } else if (isInserting) {
      context.missing(_meaningMeta);
    }
    if (data.containsKey('example')) {
      context.handle(
        _exampleMeta,
        example.isAcceptableOrUnknown(data['example']!, _exampleMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {dictionaryId, lemma, partOfSpeech, meaning},
  ];
  @override
  DictionaryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DictionaryEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      dictionaryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dictionary_id'],
      )!,
      lemma: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lemma'],
      )!,
      partOfSpeech: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}part_of_speech'],
      )!,
      meaning: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning'],
      )!,
      example: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}example'],
      ),
    );
  }

  @override
  $DictionaryEntriesTable createAlias(String alias) {
    return $DictionaryEntriesTable(attachedDatabase, alias);
  }
}

class DictionaryEntry extends DataClass implements Insertable<DictionaryEntry> {
  final int id;
  final String dictionaryId;
  final String lemma;
  final String partOfSpeech;
  final String meaning;
  final String? example;
  const DictionaryEntry({
    required this.id,
    required this.dictionaryId,
    required this.lemma,
    required this.partOfSpeech,
    required this.meaning,
    this.example,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['dictionary_id'] = Variable<String>(dictionaryId);
    map['lemma'] = Variable<String>(lemma);
    map['part_of_speech'] = Variable<String>(partOfSpeech);
    map['meaning'] = Variable<String>(meaning);
    if (!nullToAbsent || example != null) {
      map['example'] = Variable<String>(example);
    }
    return map;
  }

  DictionaryEntriesCompanion toCompanion(bool nullToAbsent) {
    return DictionaryEntriesCompanion(
      id: Value(id),
      dictionaryId: Value(dictionaryId),
      lemma: Value(lemma),
      partOfSpeech: Value(partOfSpeech),
      meaning: Value(meaning),
      example: example == null && nullToAbsent
          ? const Value.absent()
          : Value(example),
    );
  }

  factory DictionaryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DictionaryEntry(
      id: serializer.fromJson<int>(json['id']),
      dictionaryId: serializer.fromJson<String>(json['dictionaryId']),
      lemma: serializer.fromJson<String>(json['lemma']),
      partOfSpeech: serializer.fromJson<String>(json['partOfSpeech']),
      meaning: serializer.fromJson<String>(json['meaning']),
      example: serializer.fromJson<String?>(json['example']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dictionaryId': serializer.toJson<String>(dictionaryId),
      'lemma': serializer.toJson<String>(lemma),
      'partOfSpeech': serializer.toJson<String>(partOfSpeech),
      'meaning': serializer.toJson<String>(meaning),
      'example': serializer.toJson<String?>(example),
    };
  }

  DictionaryEntry copyWith({
    int? id,
    String? dictionaryId,
    String? lemma,
    String? partOfSpeech,
    String? meaning,
    Value<String?> example = const Value.absent(),
  }) => DictionaryEntry(
    id: id ?? this.id,
    dictionaryId: dictionaryId ?? this.dictionaryId,
    lemma: lemma ?? this.lemma,
    partOfSpeech: partOfSpeech ?? this.partOfSpeech,
    meaning: meaning ?? this.meaning,
    example: example.present ? example.value : this.example,
  );
  DictionaryEntry copyWithCompanion(DictionaryEntriesCompanion data) {
    return DictionaryEntry(
      id: data.id.present ? data.id.value : this.id,
      dictionaryId: data.dictionaryId.present
          ? data.dictionaryId.value
          : this.dictionaryId,
      lemma: data.lemma.present ? data.lemma.value : this.lemma,
      partOfSpeech: data.partOfSpeech.present
          ? data.partOfSpeech.value
          : this.partOfSpeech,
      meaning: data.meaning.present ? data.meaning.value : this.meaning,
      example: data.example.present ? data.example.value : this.example,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DictionaryEntry(')
          ..write('id: $id, ')
          ..write('dictionaryId: $dictionaryId, ')
          ..write('lemma: $lemma, ')
          ..write('partOfSpeech: $partOfSpeech, ')
          ..write('meaning: $meaning, ')
          ..write('example: $example')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, dictionaryId, lemma, partOfSpeech, meaning, example);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DictionaryEntry &&
          other.id == this.id &&
          other.dictionaryId == this.dictionaryId &&
          other.lemma == this.lemma &&
          other.partOfSpeech == this.partOfSpeech &&
          other.meaning == this.meaning &&
          other.example == this.example);
}

class DictionaryEntriesCompanion extends UpdateCompanion<DictionaryEntry> {
  final Value<int> id;
  final Value<String> dictionaryId;
  final Value<String> lemma;
  final Value<String> partOfSpeech;
  final Value<String> meaning;
  final Value<String?> example;
  const DictionaryEntriesCompanion({
    this.id = const Value.absent(),
    this.dictionaryId = const Value.absent(),
    this.lemma = const Value.absent(),
    this.partOfSpeech = const Value.absent(),
    this.meaning = const Value.absent(),
    this.example = const Value.absent(),
  });
  DictionaryEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String dictionaryId,
    required String lemma,
    this.partOfSpeech = const Value.absent(),
    required String meaning,
    this.example = const Value.absent(),
  }) : dictionaryId = Value(dictionaryId),
       lemma = Value(lemma),
       meaning = Value(meaning);
  static Insertable<DictionaryEntry> custom({
    Expression<int>? id,
    Expression<String>? dictionaryId,
    Expression<String>? lemma,
    Expression<String>? partOfSpeech,
    Expression<String>? meaning,
    Expression<String>? example,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dictionaryId != null) 'dictionary_id': dictionaryId,
      if (lemma != null) 'lemma': lemma,
      if (partOfSpeech != null) 'part_of_speech': partOfSpeech,
      if (meaning != null) 'meaning': meaning,
      if (example != null) 'example': example,
    });
  }

  DictionaryEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? dictionaryId,
    Value<String>? lemma,
    Value<String>? partOfSpeech,
    Value<String>? meaning,
    Value<String?>? example,
  }) {
    return DictionaryEntriesCompanion(
      id: id ?? this.id,
      dictionaryId: dictionaryId ?? this.dictionaryId,
      lemma: lemma ?? this.lemma,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      meaning: meaning ?? this.meaning,
      example: example ?? this.example,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dictionaryId.present) {
      map['dictionary_id'] = Variable<String>(dictionaryId.value);
    }
    if (lemma.present) {
      map['lemma'] = Variable<String>(lemma.value);
    }
    if (partOfSpeech.present) {
      map['part_of_speech'] = Variable<String>(partOfSpeech.value);
    }
    if (meaning.present) {
      map['meaning'] = Variable<String>(meaning.value);
    }
    if (example.present) {
      map['example'] = Variable<String>(example.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DictionaryEntriesCompanion(')
          ..write('id: $id, ')
          ..write('dictionaryId: $dictionaryId, ')
          ..write('lemma: $lemma, ')
          ..write('partOfSpeech: $partOfSpeech, ')
          ..write('meaning: $meaning, ')
          ..write('example: $example')
          ..write(')'))
        .toString();
  }
}

class $ChaptersTable extends Chapters with TableInfo<$ChaptersTable, Chapter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChaptersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id)',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterIndexMeta = const VerificationMeta(
    'chapterIndex',
  );
  @override
  late final GeneratedColumn<int> chapterIndex = GeneratedColumn<int>(
    'chapter_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentHashMeta = const VerificationMeta(
    'contentHash',
  );
  @override
  late final GeneratedColumn<String> contentHash = GeneratedColumn<String>(
    'content_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    title,
    chapterIndex,
    content,
    contentHash,
    revision,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chapters';
  @override
  VerificationContext validateIntegrity(
    Insertable<Chapter> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('chapter_index')) {
      context.handle(
        _chapterIndexMeta,
        chapterIndex.isAcceptableOrUnknown(
          data['chapter_index']!,
          _chapterIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chapterIndexMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('content_hash')) {
      context.handle(
        _contentHashMeta,
        contentHash.isAcceptableOrUnknown(
          data['content_hash']!,
          _contentHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentHashMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {bookId, chapterIndex},
  ];
  @override
  Chapter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Chapter(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      chapterIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_index'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      contentHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_hash'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ChaptersTable createAlias(String alias) {
    return $ChaptersTable(attachedDatabase, alias);
  }
}

class Chapter extends DataClass implements Insertable<Chapter> {
  final String id;
  final String bookId;
  final String title;
  final int chapterIndex;
  final String content;
  final String contentHash;
  final int revision;
  final DateTime updatedAt;
  const Chapter({
    required this.id,
    required this.bookId,
    required this.title,
    required this.chapterIndex,
    required this.content,
    required this.contentHash,
    required this.revision,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['book_id'] = Variable<String>(bookId);
    map['title'] = Variable<String>(title);
    map['chapter_index'] = Variable<int>(chapterIndex);
    map['content'] = Variable<String>(content);
    map['content_hash'] = Variable<String>(contentHash);
    map['revision'] = Variable<int>(revision);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ChaptersCompanion toCompanion(bool nullToAbsent) {
    return ChaptersCompanion(
      id: Value(id),
      bookId: Value(bookId),
      title: Value(title),
      chapterIndex: Value(chapterIndex),
      content: Value(content),
      contentHash: Value(contentHash),
      revision: Value(revision),
      updatedAt: Value(updatedAt),
    );
  }

  factory Chapter.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Chapter(
      id: serializer.fromJson<String>(json['id']),
      bookId: serializer.fromJson<String>(json['bookId']),
      title: serializer.fromJson<String>(json['title']),
      chapterIndex: serializer.fromJson<int>(json['chapterIndex']),
      content: serializer.fromJson<String>(json['content']),
      contentHash: serializer.fromJson<String>(json['contentHash']),
      revision: serializer.fromJson<int>(json['revision']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookId': serializer.toJson<String>(bookId),
      'title': serializer.toJson<String>(title),
      'chapterIndex': serializer.toJson<int>(chapterIndex),
      'content': serializer.toJson<String>(content),
      'contentHash': serializer.toJson<String>(contentHash),
      'revision': serializer.toJson<int>(revision),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Chapter copyWith({
    String? id,
    String? bookId,
    String? title,
    int? chapterIndex,
    String? content,
    String? contentHash,
    int? revision,
    DateTime? updatedAt,
  }) => Chapter(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    title: title ?? this.title,
    chapterIndex: chapterIndex ?? this.chapterIndex,
    content: content ?? this.content,
    contentHash: contentHash ?? this.contentHash,
    revision: revision ?? this.revision,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Chapter copyWithCompanion(ChaptersCompanion data) {
    return Chapter(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      title: data.title.present ? data.title.value : this.title,
      chapterIndex: data.chapterIndex.present
          ? data.chapterIndex.value
          : this.chapterIndex,
      content: data.content.present ? data.content.value : this.content,
      contentHash: data.contentHash.present
          ? data.contentHash.value
          : this.contentHash,
      revision: data.revision.present ? data.revision.value : this.revision,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Chapter(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('title: $title, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('content: $content, ')
          ..write('contentHash: $contentHash, ')
          ..write('revision: $revision, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bookId,
    title,
    chapterIndex,
    content,
    contentHash,
    revision,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Chapter &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.title == this.title &&
          other.chapterIndex == this.chapterIndex &&
          other.content == this.content &&
          other.contentHash == this.contentHash &&
          other.revision == this.revision &&
          other.updatedAt == this.updatedAt);
}

class ChaptersCompanion extends UpdateCompanion<Chapter> {
  final Value<String> id;
  final Value<String> bookId;
  final Value<String> title;
  final Value<int> chapterIndex;
  final Value<String> content;
  final Value<String> contentHash;
  final Value<int> revision;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ChaptersCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.title = const Value.absent(),
    this.chapterIndex = const Value.absent(),
    this.content = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.revision = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChaptersCompanion.insert({
    required String id,
    required String bookId,
    required String title,
    required int chapterIndex,
    required String content,
    required String contentHash,
    this.revision = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       bookId = Value(bookId),
       title = Value(title),
       chapterIndex = Value(chapterIndex),
       content = Value(content),
       contentHash = Value(contentHash),
       updatedAt = Value(updatedAt);
  static Insertable<Chapter> custom({
    Expression<String>? id,
    Expression<String>? bookId,
    Expression<String>? title,
    Expression<int>? chapterIndex,
    Expression<String>? content,
    Expression<String>? contentHash,
    Expression<int>? revision,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (title != null) 'title': title,
      if (chapterIndex != null) 'chapter_index': chapterIndex,
      if (content != null) 'content': content,
      if (contentHash != null) 'content_hash': contentHash,
      if (revision != null) 'revision': revision,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChaptersCompanion copyWith({
    Value<String>? id,
    Value<String>? bookId,
    Value<String>? title,
    Value<int>? chapterIndex,
    Value<String>? content,
    Value<String>? contentHash,
    Value<int>? revision,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ChaptersCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      title: title ?? this.title,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      content: content ?? this.content,
      contentHash: contentHash ?? this.contentHash,
      revision: revision ?? this.revision,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (chapterIndex.present) {
      map['chapter_index'] = Variable<int>(chapterIndex.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (contentHash.present) {
      map['content_hash'] = Variable<String>(contentHash.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChaptersCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('title: $title, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('content: $content, ')
          ..write('contentHash: $contentHash, ')
          ..write('revision: $revision, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingProgressTable extends ReadingProgress
    with TableInfo<$ReadingProgressTable, ReadingProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id)',
    ),
  );
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
    'chapter_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES chapters (id)',
    ),
  );
  static const VerificationMeta _anchorParagraphMeta = const VerificationMeta(
    'anchorParagraph',
  );
  @override
  late final GeneratedColumn<int> anchorParagraph = GeneratedColumn<int>(
    'anchor_paragraph',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _anchorOffsetMeta = const VerificationMeta(
    'anchorOffset',
  );
  @override
  late final GeneratedColumn<int> anchorOffset = GeneratedColumn<int>(
    'anchor_offset',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _cachedPageIndexMeta = const VerificationMeta(
    'cachedPageIndex',
  );
  @override
  late final GeneratedColumn<int> cachedPageIndex = GeneratedColumn<int>(
    'cached_page_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _cachedPageCountMeta = const VerificationMeta(
    'cachedPageCount',
  );
  @override
  late final GeneratedColumn<int> cachedPageCount = GeneratedColumn<int>(
    'cached_page_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _layoutSignatureMeta = const VerificationMeta(
    'layoutSignature',
  );
  @override
  late final GeneratedColumn<String> layoutSignature = GeneratedColumn<String>(
    'layout_signature',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    chapterId,
    anchorParagraph,
    anchorOffset,
    cachedPageIndex,
    cachedPageCount,
    layoutSignature,
    revision,
    updatedBy,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('anchor_paragraph')) {
      context.handle(
        _anchorParagraphMeta,
        anchorParagraph.isAcceptableOrUnknown(
          data['anchor_paragraph']!,
          _anchorParagraphMeta,
        ),
      );
    }
    if (data.containsKey('anchor_offset')) {
      context.handle(
        _anchorOffsetMeta,
        anchorOffset.isAcceptableOrUnknown(
          data['anchor_offset']!,
          _anchorOffsetMeta,
        ),
      );
    }
    if (data.containsKey('cached_page_index')) {
      context.handle(
        _cachedPageIndexMeta,
        cachedPageIndex.isAcceptableOrUnknown(
          data['cached_page_index']!,
          _cachedPageIndexMeta,
        ),
      );
    }
    if (data.containsKey('cached_page_count')) {
      context.handle(
        _cachedPageCountMeta,
        cachedPageCount.isAcceptableOrUnknown(
          data['cached_page_count']!,
          _cachedPageCountMeta,
        ),
      );
    }
    if (data.containsKey('layout_signature')) {
      context.handle(
        _layoutSignatureMeta,
        layoutSignature.isAcceptableOrUnknown(
          data['layout_signature']!,
          _layoutSignatureMeta,
        ),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {bookId, chapterId},
  ];
  @override
  ReadingProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingProgressData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_id'],
      )!,
      anchorParagraph: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}anchor_paragraph'],
      )!,
      anchorOffset: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}anchor_offset'],
      )!,
      cachedPageIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cached_page_index'],
      )!,
      cachedPageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cached_page_count'],
      )!,
      layoutSignature: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}layout_signature'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ReadingProgressTable createAlias(String alias) {
    return $ReadingProgressTable(attachedDatabase, alias);
  }
}

class ReadingProgressData extends DataClass
    implements Insertable<ReadingProgressData> {
  final String id;
  final String bookId;
  final String chapterId;
  final int anchorParagraph;
  final int anchorOffset;
  final int cachedPageIndex;
  final int cachedPageCount;
  final String? layoutSignature;
  final int revision;
  final String? updatedBy;
  final DateTime updatedAt;
  const ReadingProgressData({
    required this.id,
    required this.bookId,
    required this.chapterId,
    required this.anchorParagraph,
    required this.anchorOffset,
    required this.cachedPageIndex,
    required this.cachedPageCount,
    this.layoutSignature,
    required this.revision,
    this.updatedBy,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['book_id'] = Variable<String>(bookId);
    map['chapter_id'] = Variable<String>(chapterId);
    map['anchor_paragraph'] = Variable<int>(anchorParagraph);
    map['anchor_offset'] = Variable<int>(anchorOffset);
    map['cached_page_index'] = Variable<int>(cachedPageIndex);
    map['cached_page_count'] = Variable<int>(cachedPageCount);
    if (!nullToAbsent || layoutSignature != null) {
      map['layout_signature'] = Variable<String>(layoutSignature);
    }
    map['revision'] = Variable<int>(revision);
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ReadingProgressCompanion toCompanion(bool nullToAbsent) {
    return ReadingProgressCompanion(
      id: Value(id),
      bookId: Value(bookId),
      chapterId: Value(chapterId),
      anchorParagraph: Value(anchorParagraph),
      anchorOffset: Value(anchorOffset),
      cachedPageIndex: Value(cachedPageIndex),
      cachedPageCount: Value(cachedPageCount),
      layoutSignature: layoutSignature == null && nullToAbsent
          ? const Value.absent()
          : Value(layoutSignature),
      revision: Value(revision),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      updatedAt: Value(updatedAt),
    );
  }

  factory ReadingProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingProgressData(
      id: serializer.fromJson<String>(json['id']),
      bookId: serializer.fromJson<String>(json['bookId']),
      chapterId: serializer.fromJson<String>(json['chapterId']),
      anchorParagraph: serializer.fromJson<int>(json['anchorParagraph']),
      anchorOffset: serializer.fromJson<int>(json['anchorOffset']),
      cachedPageIndex: serializer.fromJson<int>(json['cachedPageIndex']),
      cachedPageCount: serializer.fromJson<int>(json['cachedPageCount']),
      layoutSignature: serializer.fromJson<String?>(json['layoutSignature']),
      revision: serializer.fromJson<int>(json['revision']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookId': serializer.toJson<String>(bookId),
      'chapterId': serializer.toJson<String>(chapterId),
      'anchorParagraph': serializer.toJson<int>(anchorParagraph),
      'anchorOffset': serializer.toJson<int>(anchorOffset),
      'cachedPageIndex': serializer.toJson<int>(cachedPageIndex),
      'cachedPageCount': serializer.toJson<int>(cachedPageCount),
      'layoutSignature': serializer.toJson<String?>(layoutSignature),
      'revision': serializer.toJson<int>(revision),
      'updatedBy': serializer.toJson<String?>(updatedBy),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ReadingProgressData copyWith({
    String? id,
    String? bookId,
    String? chapterId,
    int? anchorParagraph,
    int? anchorOffset,
    int? cachedPageIndex,
    int? cachedPageCount,
    Value<String?> layoutSignature = const Value.absent(),
    int? revision,
    Value<String?> updatedBy = const Value.absent(),
    DateTime? updatedAt,
  }) => ReadingProgressData(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    chapterId: chapterId ?? this.chapterId,
    anchorParagraph: anchorParagraph ?? this.anchorParagraph,
    anchorOffset: anchorOffset ?? this.anchorOffset,
    cachedPageIndex: cachedPageIndex ?? this.cachedPageIndex,
    cachedPageCount: cachedPageCount ?? this.cachedPageCount,
    layoutSignature: layoutSignature.present
        ? layoutSignature.value
        : this.layoutSignature,
    revision: revision ?? this.revision,
    updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ReadingProgressData copyWithCompanion(ReadingProgressCompanion data) {
    return ReadingProgressData(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      anchorParagraph: data.anchorParagraph.present
          ? data.anchorParagraph.value
          : this.anchorParagraph,
      anchorOffset: data.anchorOffset.present
          ? data.anchorOffset.value
          : this.anchorOffset,
      cachedPageIndex: data.cachedPageIndex.present
          ? data.cachedPageIndex.value
          : this.cachedPageIndex,
      cachedPageCount: data.cachedPageCount.present
          ? data.cachedPageCount.value
          : this.cachedPageCount,
      layoutSignature: data.layoutSignature.present
          ? data.layoutSignature.value
          : this.layoutSignature,
      revision: data.revision.present ? data.revision.value : this.revision,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingProgressData(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('chapterId: $chapterId, ')
          ..write('anchorParagraph: $anchorParagraph, ')
          ..write('anchorOffset: $anchorOffset, ')
          ..write('cachedPageIndex: $cachedPageIndex, ')
          ..write('cachedPageCount: $cachedPageCount, ')
          ..write('layoutSignature: $layoutSignature, ')
          ..write('revision: $revision, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bookId,
    chapterId,
    anchorParagraph,
    anchorOffset,
    cachedPageIndex,
    cachedPageCount,
    layoutSignature,
    revision,
    updatedBy,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingProgressData &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.chapterId == this.chapterId &&
          other.anchorParagraph == this.anchorParagraph &&
          other.anchorOffset == this.anchorOffset &&
          other.cachedPageIndex == this.cachedPageIndex &&
          other.cachedPageCount == this.cachedPageCount &&
          other.layoutSignature == this.layoutSignature &&
          other.revision == this.revision &&
          other.updatedBy == this.updatedBy &&
          other.updatedAt == this.updatedAt);
}

class ReadingProgressCompanion extends UpdateCompanion<ReadingProgressData> {
  final Value<String> id;
  final Value<String> bookId;
  final Value<String> chapterId;
  final Value<int> anchorParagraph;
  final Value<int> anchorOffset;
  final Value<int> cachedPageIndex;
  final Value<int> cachedPageCount;
  final Value<String?> layoutSignature;
  final Value<int> revision;
  final Value<String?> updatedBy;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ReadingProgressCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.anchorParagraph = const Value.absent(),
    this.anchorOffset = const Value.absent(),
    this.cachedPageIndex = const Value.absent(),
    this.cachedPageCount = const Value.absent(),
    this.layoutSignature = const Value.absent(),
    this.revision = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadingProgressCompanion.insert({
    required String id,
    required String bookId,
    required String chapterId,
    this.anchorParagraph = const Value.absent(),
    this.anchorOffset = const Value.absent(),
    this.cachedPageIndex = const Value.absent(),
    this.cachedPageCount = const Value.absent(),
    this.layoutSignature = const Value.absent(),
    this.revision = const Value.absent(),
    this.updatedBy = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       bookId = Value(bookId),
       chapterId = Value(chapterId),
       updatedAt = Value(updatedAt);
  static Insertable<ReadingProgressData> custom({
    Expression<String>? id,
    Expression<String>? bookId,
    Expression<String>? chapterId,
    Expression<int>? anchorParagraph,
    Expression<int>? anchorOffset,
    Expression<int>? cachedPageIndex,
    Expression<int>? cachedPageCount,
    Expression<String>? layoutSignature,
    Expression<int>? revision,
    Expression<String>? updatedBy,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (chapterId != null) 'chapter_id': chapterId,
      if (anchorParagraph != null) 'anchor_paragraph': anchorParagraph,
      if (anchorOffset != null) 'anchor_offset': anchorOffset,
      if (cachedPageIndex != null) 'cached_page_index': cachedPageIndex,
      if (cachedPageCount != null) 'cached_page_count': cachedPageCount,
      if (layoutSignature != null) 'layout_signature': layoutSignature,
      if (revision != null) 'revision': revision,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadingProgressCompanion copyWith({
    Value<String>? id,
    Value<String>? bookId,
    Value<String>? chapterId,
    Value<int>? anchorParagraph,
    Value<int>? anchorOffset,
    Value<int>? cachedPageIndex,
    Value<int>? cachedPageCount,
    Value<String?>? layoutSignature,
    Value<int>? revision,
    Value<String?>? updatedBy,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ReadingProgressCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      chapterId: chapterId ?? this.chapterId,
      anchorParagraph: anchorParagraph ?? this.anchorParagraph,
      anchorOffset: anchorOffset ?? this.anchorOffset,
      cachedPageIndex: cachedPageIndex ?? this.cachedPageIndex,
      cachedPageCount: cachedPageCount ?? this.cachedPageCount,
      layoutSignature: layoutSignature ?? this.layoutSignature,
      revision: revision ?? this.revision,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (anchorParagraph.present) {
      map['anchor_paragraph'] = Variable<int>(anchorParagraph.value);
    }
    if (anchorOffset.present) {
      map['anchor_offset'] = Variable<int>(anchorOffset.value);
    }
    if (cachedPageIndex.present) {
      map['cached_page_index'] = Variable<int>(cachedPageIndex.value);
    }
    if (cachedPageCount.present) {
      map['cached_page_count'] = Variable<int>(cachedPageCount.value);
    }
    if (layoutSignature.present) {
      map['layout_signature'] = Variable<String>(layoutSignature.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingProgressCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('chapterId: $chapterId, ')
          ..write('anchorParagraph: $anchorParagraph, ')
          ..write('anchorOffset: $anchorOffset, ')
          ..write('cachedPageIndex: $cachedPageIndex, ')
          ..write('cachedPageCount: $cachedPageCount, ')
          ..write('layoutSignature: $layoutSignature, ')
          ..write('revision: $revision, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaginationCachesTable extends PaginationCaches
    with TableInfo<$PaginationCachesTable, PaginationCache> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaginationCachesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
    'chapter_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES chapters (id)',
    ),
  );
  static const VerificationMeta _layoutSignatureMeta = const VerificationMeta(
    'layoutSignature',
  );
  @override
  late final GeneratedColumn<String> layoutSignature = GeneratedColumn<String>(
    'layout_signature',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageIndexMeta = const VerificationMeta(
    'pageIndex',
  );
  @override
  late final GeneratedColumn<int> pageIndex = GeneratedColumn<int>(
    'page_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startParagraphMeta = const VerificationMeta(
    'startParagraph',
  );
  @override
  late final GeneratedColumn<int> startParagraph = GeneratedColumn<int>(
    'start_paragraph',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startOffsetMeta = const VerificationMeta(
    'startOffset',
  );
  @override
  late final GeneratedColumn<int> startOffset = GeneratedColumn<int>(
    'start_offset',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endParagraphMeta = const VerificationMeta(
    'endParagraph',
  );
  @override
  late final GeneratedColumn<int> endParagraph = GeneratedColumn<int>(
    'end_paragraph',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endOffsetMeta = const VerificationMeta(
    'endOffset',
  );
  @override
  late final GeneratedColumn<int> endOffset = GeneratedColumn<int>(
    'end_offset',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    chapterId,
    layoutSignature,
    pageIndex,
    startParagraph,
    startOffset,
    endParagraph,
    endOffset,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pagination_caches';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaginationCache> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('layout_signature')) {
      context.handle(
        _layoutSignatureMeta,
        layoutSignature.isAcceptableOrUnknown(
          data['layout_signature']!,
          _layoutSignatureMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_layoutSignatureMeta);
    }
    if (data.containsKey('page_index')) {
      context.handle(
        _pageIndexMeta,
        pageIndex.isAcceptableOrUnknown(data['page_index']!, _pageIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_pageIndexMeta);
    }
    if (data.containsKey('start_paragraph')) {
      context.handle(
        _startParagraphMeta,
        startParagraph.isAcceptableOrUnknown(
          data['start_paragraph']!,
          _startParagraphMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startParagraphMeta);
    }
    if (data.containsKey('start_offset')) {
      context.handle(
        _startOffsetMeta,
        startOffset.isAcceptableOrUnknown(
          data['start_offset']!,
          _startOffsetMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startOffsetMeta);
    }
    if (data.containsKey('end_paragraph')) {
      context.handle(
        _endParagraphMeta,
        endParagraph.isAcceptableOrUnknown(
          data['end_paragraph']!,
          _endParagraphMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_endParagraphMeta);
    }
    if (data.containsKey('end_offset')) {
      context.handle(
        _endOffsetMeta,
        endOffset.isAcceptableOrUnknown(data['end_offset']!, _endOffsetMeta),
      );
    } else if (isInserting) {
      context.missing(_endOffsetMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {chapterId, layoutSignature, pageIndex},
  ];
  @override
  PaginationCache map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaginationCache(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_id'],
      )!,
      layoutSignature: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}layout_signature'],
      )!,
      pageIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_index'],
      )!,
      startParagraph: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_paragraph'],
      )!,
      startOffset: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_offset'],
      )!,
      endParagraph: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_paragraph'],
      )!,
      endOffset: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_offset'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PaginationCachesTable createAlias(String alias) {
    return $PaginationCachesTable(attachedDatabase, alias);
  }
}

class PaginationCache extends DataClass implements Insertable<PaginationCache> {
  final int id;
  final String chapterId;
  final String layoutSignature;
  final int pageIndex;
  final int startParagraph;
  final int startOffset;
  final int endParagraph;
  final int endOffset;
  final DateTime createdAt;
  const PaginationCache({
    required this.id,
    required this.chapterId,
    required this.layoutSignature,
    required this.pageIndex,
    required this.startParagraph,
    required this.startOffset,
    required this.endParagraph,
    required this.endOffset,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['chapter_id'] = Variable<String>(chapterId);
    map['layout_signature'] = Variable<String>(layoutSignature);
    map['page_index'] = Variable<int>(pageIndex);
    map['start_paragraph'] = Variable<int>(startParagraph);
    map['start_offset'] = Variable<int>(startOffset);
    map['end_paragraph'] = Variable<int>(endParagraph);
    map['end_offset'] = Variable<int>(endOffset);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PaginationCachesCompanion toCompanion(bool nullToAbsent) {
    return PaginationCachesCompanion(
      id: Value(id),
      chapterId: Value(chapterId),
      layoutSignature: Value(layoutSignature),
      pageIndex: Value(pageIndex),
      startParagraph: Value(startParagraph),
      startOffset: Value(startOffset),
      endParagraph: Value(endParagraph),
      endOffset: Value(endOffset),
      createdAt: Value(createdAt),
    );
  }

  factory PaginationCache.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaginationCache(
      id: serializer.fromJson<int>(json['id']),
      chapterId: serializer.fromJson<String>(json['chapterId']),
      layoutSignature: serializer.fromJson<String>(json['layoutSignature']),
      pageIndex: serializer.fromJson<int>(json['pageIndex']),
      startParagraph: serializer.fromJson<int>(json['startParagraph']),
      startOffset: serializer.fromJson<int>(json['startOffset']),
      endParagraph: serializer.fromJson<int>(json['endParagraph']),
      endOffset: serializer.fromJson<int>(json['endOffset']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'chapterId': serializer.toJson<String>(chapterId),
      'layoutSignature': serializer.toJson<String>(layoutSignature),
      'pageIndex': serializer.toJson<int>(pageIndex),
      'startParagraph': serializer.toJson<int>(startParagraph),
      'startOffset': serializer.toJson<int>(startOffset),
      'endParagraph': serializer.toJson<int>(endParagraph),
      'endOffset': serializer.toJson<int>(endOffset),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PaginationCache copyWith({
    int? id,
    String? chapterId,
    String? layoutSignature,
    int? pageIndex,
    int? startParagraph,
    int? startOffset,
    int? endParagraph,
    int? endOffset,
    DateTime? createdAt,
  }) => PaginationCache(
    id: id ?? this.id,
    chapterId: chapterId ?? this.chapterId,
    layoutSignature: layoutSignature ?? this.layoutSignature,
    pageIndex: pageIndex ?? this.pageIndex,
    startParagraph: startParagraph ?? this.startParagraph,
    startOffset: startOffset ?? this.startOffset,
    endParagraph: endParagraph ?? this.endParagraph,
    endOffset: endOffset ?? this.endOffset,
    createdAt: createdAt ?? this.createdAt,
  );
  PaginationCache copyWithCompanion(PaginationCachesCompanion data) {
    return PaginationCache(
      id: data.id.present ? data.id.value : this.id,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      layoutSignature: data.layoutSignature.present
          ? data.layoutSignature.value
          : this.layoutSignature,
      pageIndex: data.pageIndex.present ? data.pageIndex.value : this.pageIndex,
      startParagraph: data.startParagraph.present
          ? data.startParagraph.value
          : this.startParagraph,
      startOffset: data.startOffset.present
          ? data.startOffset.value
          : this.startOffset,
      endParagraph: data.endParagraph.present
          ? data.endParagraph.value
          : this.endParagraph,
      endOffset: data.endOffset.present ? data.endOffset.value : this.endOffset,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaginationCache(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('layoutSignature: $layoutSignature, ')
          ..write('pageIndex: $pageIndex, ')
          ..write('startParagraph: $startParagraph, ')
          ..write('startOffset: $startOffset, ')
          ..write('endParagraph: $endParagraph, ')
          ..write('endOffset: $endOffset, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    chapterId,
    layoutSignature,
    pageIndex,
    startParagraph,
    startOffset,
    endParagraph,
    endOffset,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaginationCache &&
          other.id == this.id &&
          other.chapterId == this.chapterId &&
          other.layoutSignature == this.layoutSignature &&
          other.pageIndex == this.pageIndex &&
          other.startParagraph == this.startParagraph &&
          other.startOffset == this.startOffset &&
          other.endParagraph == this.endParagraph &&
          other.endOffset == this.endOffset &&
          other.createdAt == this.createdAt);
}

class PaginationCachesCompanion extends UpdateCompanion<PaginationCache> {
  final Value<int> id;
  final Value<String> chapterId;
  final Value<String> layoutSignature;
  final Value<int> pageIndex;
  final Value<int> startParagraph;
  final Value<int> startOffset;
  final Value<int> endParagraph;
  final Value<int> endOffset;
  final Value<DateTime> createdAt;
  const PaginationCachesCompanion({
    this.id = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.layoutSignature = const Value.absent(),
    this.pageIndex = const Value.absent(),
    this.startParagraph = const Value.absent(),
    this.startOffset = const Value.absent(),
    this.endParagraph = const Value.absent(),
    this.endOffset = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PaginationCachesCompanion.insert({
    this.id = const Value.absent(),
    required String chapterId,
    required String layoutSignature,
    required int pageIndex,
    required int startParagraph,
    required int startOffset,
    required int endParagraph,
    required int endOffset,
    required DateTime createdAt,
  }) : chapterId = Value(chapterId),
       layoutSignature = Value(layoutSignature),
       pageIndex = Value(pageIndex),
       startParagraph = Value(startParagraph),
       startOffset = Value(startOffset),
       endParagraph = Value(endParagraph),
       endOffset = Value(endOffset),
       createdAt = Value(createdAt);
  static Insertable<PaginationCache> custom({
    Expression<int>? id,
    Expression<String>? chapterId,
    Expression<String>? layoutSignature,
    Expression<int>? pageIndex,
    Expression<int>? startParagraph,
    Expression<int>? startOffset,
    Expression<int>? endParagraph,
    Expression<int>? endOffset,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chapterId != null) 'chapter_id': chapterId,
      if (layoutSignature != null) 'layout_signature': layoutSignature,
      if (pageIndex != null) 'page_index': pageIndex,
      if (startParagraph != null) 'start_paragraph': startParagraph,
      if (startOffset != null) 'start_offset': startOffset,
      if (endParagraph != null) 'end_paragraph': endParagraph,
      if (endOffset != null) 'end_offset': endOffset,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PaginationCachesCompanion copyWith({
    Value<int>? id,
    Value<String>? chapterId,
    Value<String>? layoutSignature,
    Value<int>? pageIndex,
    Value<int>? startParagraph,
    Value<int>? startOffset,
    Value<int>? endParagraph,
    Value<int>? endOffset,
    Value<DateTime>? createdAt,
  }) {
    return PaginationCachesCompanion(
      id: id ?? this.id,
      chapterId: chapterId ?? this.chapterId,
      layoutSignature: layoutSignature ?? this.layoutSignature,
      pageIndex: pageIndex ?? this.pageIndex,
      startParagraph: startParagraph ?? this.startParagraph,
      startOffset: startOffset ?? this.startOffset,
      endParagraph: endParagraph ?? this.endParagraph,
      endOffset: endOffset ?? this.endOffset,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (layoutSignature.present) {
      map['layout_signature'] = Variable<String>(layoutSignature.value);
    }
    if (pageIndex.present) {
      map['page_index'] = Variable<int>(pageIndex.value);
    }
    if (startParagraph.present) {
      map['start_paragraph'] = Variable<int>(startParagraph.value);
    }
    if (startOffset.present) {
      map['start_offset'] = Variable<int>(startOffset.value);
    }
    if (endParagraph.present) {
      map['end_paragraph'] = Variable<int>(endParagraph.value);
    }
    if (endOffset.present) {
      map['end_offset'] = Variable<int>(endOffset.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaginationCachesCompanion(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('layoutSignature: $layoutSignature, ')
          ..write('pageIndex: $pageIndex, ')
          ..write('startParagraph: $startParagraph, ')
          ..write('startOffset: $startOffset, ')
          ..write('endParagraph: $endParagraph, ')
          ..write('endOffset: $endOffset, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $VocabularyTable extends Vocabulary
    with TableInfo<$VocabularyTable, VocabularyData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VocabularyTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lemmaMeta = const VerificationMeta('lemma');
  @override
  late final GeneratedColumn<String> lemma = GeneratedColumn<String>(
    'lemma',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('en'),
  );
  static const VerificationMeta _senseLabelMeta = const VerificationMeta(
    'senseLabel',
  );
  @override
  late final GeneratedColumn<String> senseLabel = GeneratedColumn<String>(
    'sense_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    lemma,
    language,
    senseLabel,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vocabulary';
  @override
  VerificationContext validateIntegrity(
    Insertable<VocabularyData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('lemma')) {
      context.handle(
        _lemmaMeta,
        lemma.isAcceptableOrUnknown(data['lemma']!, _lemmaMeta),
      );
    } else if (isInserting) {
      context.missing(_lemmaMeta);
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    }
    if (data.containsKey('sense_label')) {
      context.handle(
        _senseLabelMeta,
        senseLabel.isAcceptableOrUnknown(data['sense_label']!, _senseLabelMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VocabularyData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VocabularyData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      lemma: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lemma'],
      )!,
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      senseLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sense_label'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $VocabularyTable createAlias(String alias) {
    return $VocabularyTable(attachedDatabase, alias);
  }
}

class VocabularyData extends DataClass implements Insertable<VocabularyData> {
  final String id;
  final String lemma;
  final String language;
  final String? senseLabel;
  final DateTime createdAt;
  final DateTime updatedAt;
  const VocabularyData({
    required this.id,
    required this.lemma,
    required this.language,
    this.senseLabel,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['lemma'] = Variable<String>(lemma);
    map['language'] = Variable<String>(language);
    if (!nullToAbsent || senseLabel != null) {
      map['sense_label'] = Variable<String>(senseLabel);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  VocabularyCompanion toCompanion(bool nullToAbsent) {
    return VocabularyCompanion(
      id: Value(id),
      lemma: Value(lemma),
      language: Value(language),
      senseLabel: senseLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(senseLabel),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory VocabularyData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VocabularyData(
      id: serializer.fromJson<String>(json['id']),
      lemma: serializer.fromJson<String>(json['lemma']),
      language: serializer.fromJson<String>(json['language']),
      senseLabel: serializer.fromJson<String?>(json['senseLabel']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'lemma': serializer.toJson<String>(lemma),
      'language': serializer.toJson<String>(language),
      'senseLabel': serializer.toJson<String?>(senseLabel),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  VocabularyData copyWith({
    String? id,
    String? lemma,
    String? language,
    Value<String?> senseLabel = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => VocabularyData(
    id: id ?? this.id,
    lemma: lemma ?? this.lemma,
    language: language ?? this.language,
    senseLabel: senseLabel.present ? senseLabel.value : this.senseLabel,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  VocabularyData copyWithCompanion(VocabularyCompanion data) {
    return VocabularyData(
      id: data.id.present ? data.id.value : this.id,
      lemma: data.lemma.present ? data.lemma.value : this.lemma,
      language: data.language.present ? data.language.value : this.language,
      senseLabel: data.senseLabel.present
          ? data.senseLabel.value
          : this.senseLabel,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VocabularyData(')
          ..write('id: $id, ')
          ..write('lemma: $lemma, ')
          ..write('language: $language, ')
          ..write('senseLabel: $senseLabel, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, lemma, language, senseLabel, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VocabularyData &&
          other.id == this.id &&
          other.lemma == this.lemma &&
          other.language == this.language &&
          other.senseLabel == this.senseLabel &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class VocabularyCompanion extends UpdateCompanion<VocabularyData> {
  final Value<String> id;
  final Value<String> lemma;
  final Value<String> language;
  final Value<String?> senseLabel;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const VocabularyCompanion({
    this.id = const Value.absent(),
    this.lemma = const Value.absent(),
    this.language = const Value.absent(),
    this.senseLabel = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VocabularyCompanion.insert({
    required String id,
    required String lemma,
    this.language = const Value.absent(),
    this.senseLabel = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       lemma = Value(lemma),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<VocabularyData> custom({
    Expression<String>? id,
    Expression<String>? lemma,
    Expression<String>? language,
    Expression<String>? senseLabel,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lemma != null) 'lemma': lemma,
      if (language != null) 'language': language,
      if (senseLabel != null) 'sense_label': senseLabel,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VocabularyCompanion copyWith({
    Value<String>? id,
    Value<String>? lemma,
    Value<String>? language,
    Value<String?>? senseLabel,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return VocabularyCompanion(
      id: id ?? this.id,
      lemma: lemma ?? this.lemma,
      language: language ?? this.language,
      senseLabel: senseLabel ?? this.senseLabel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (lemma.present) {
      map['lemma'] = Variable<String>(lemma.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (senseLabel.present) {
      map['sense_label'] = Variable<String>(senseLabel.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VocabularyCompanion(')
          ..write('id: $id, ')
          ..write('lemma: $lemma, ')
          ..write('language: $language, ')
          ..write('senseLabel: $senseLabel, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WordFormsTable extends WordForms
    with TableInfo<$WordFormsTable, WordForm> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordFormsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _surfaceFormMeta = const VerificationMeta(
    'surfaceForm',
  );
  @override
  late final GeneratedColumn<String> surfaceForm = GeneratedColumn<String>(
    'surface_form',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedFormMeta = const VerificationMeta(
    'normalizedForm',
  );
  @override
  late final GeneratedColumn<String> normalizedForm = GeneratedColumn<String>(
    'normalized_form',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vocabularyIdMeta = const VerificationMeta(
    'vocabularyId',
  );
  @override
  late final GeneratedColumn<String> vocabularyId = GeneratedColumn<String>(
    'vocabulary_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vocabulary (id)',
    ),
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.8),
  );
  static const VerificationMeta _isVerifiedMeta = const VerificationMeta(
    'isVerified',
  );
  @override
  late final GeneratedColumn<bool> isVerified = GeneratedColumn<bool>(
    'is_verified',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_verified" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isPrimaryMeta = const VerificationMeta(
    'isPrimary',
  );
  @override
  late final GeneratedColumn<bool> isPrimary = GeneratedColumn<bool>(
    'is_primary',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_primary" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    surfaceForm,
    normalizedForm,
    vocabularyId,
    confidence,
    isVerified,
    isPrimary,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'word_forms';
  @override
  VerificationContext validateIntegrity(
    Insertable<WordForm> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('surface_form')) {
      context.handle(
        _surfaceFormMeta,
        surfaceForm.isAcceptableOrUnknown(
          data['surface_form']!,
          _surfaceFormMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_surfaceFormMeta);
    }
    if (data.containsKey('normalized_form')) {
      context.handle(
        _normalizedFormMeta,
        normalizedForm.isAcceptableOrUnknown(
          data['normalized_form']!,
          _normalizedFormMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedFormMeta);
    }
    if (data.containsKey('vocabulary_id')) {
      context.handle(
        _vocabularyIdMeta,
        vocabularyId.isAcceptableOrUnknown(
          data['vocabulary_id']!,
          _vocabularyIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_vocabularyIdMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('is_verified')) {
      context.handle(
        _isVerifiedMeta,
        isVerified.isAcceptableOrUnknown(data['is_verified']!, _isVerifiedMeta),
      );
    }
    if (data.containsKey('is_primary')) {
      context.handle(
        _isPrimaryMeta,
        isPrimary.isAcceptableOrUnknown(data['is_primary']!, _isPrimaryMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {surfaceForm, vocabularyId},
  ];
  @override
  WordForm map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WordForm(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      surfaceForm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}surface_form'],
      )!,
      normalizedForm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_form'],
      )!,
      vocabularyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vocabulary_id'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      isVerified: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_verified'],
      )!,
      isPrimary: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_primary'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $WordFormsTable createAlias(String alias) {
    return $WordFormsTable(attachedDatabase, alias);
  }
}

class WordForm extends DataClass implements Insertable<WordForm> {
  final String id;
  final String surfaceForm;
  final String normalizedForm;
  final String vocabularyId;
  final double confidence;
  final bool isVerified;
  final bool isPrimary;
  final DateTime createdAt;
  const WordForm({
    required this.id,
    required this.surfaceForm,
    required this.normalizedForm,
    required this.vocabularyId,
    required this.confidence,
    required this.isVerified,
    required this.isPrimary,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['surface_form'] = Variable<String>(surfaceForm);
    map['normalized_form'] = Variable<String>(normalizedForm);
    map['vocabulary_id'] = Variable<String>(vocabularyId);
    map['confidence'] = Variable<double>(confidence);
    map['is_verified'] = Variable<bool>(isVerified);
    map['is_primary'] = Variable<bool>(isPrimary);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WordFormsCompanion toCompanion(bool nullToAbsent) {
    return WordFormsCompanion(
      id: Value(id),
      surfaceForm: Value(surfaceForm),
      normalizedForm: Value(normalizedForm),
      vocabularyId: Value(vocabularyId),
      confidence: Value(confidence),
      isVerified: Value(isVerified),
      isPrimary: Value(isPrimary),
      createdAt: Value(createdAt),
    );
  }

  factory WordForm.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WordForm(
      id: serializer.fromJson<String>(json['id']),
      surfaceForm: serializer.fromJson<String>(json['surfaceForm']),
      normalizedForm: serializer.fromJson<String>(json['normalizedForm']),
      vocabularyId: serializer.fromJson<String>(json['vocabularyId']),
      confidence: serializer.fromJson<double>(json['confidence']),
      isVerified: serializer.fromJson<bool>(json['isVerified']),
      isPrimary: serializer.fromJson<bool>(json['isPrimary']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'surfaceForm': serializer.toJson<String>(surfaceForm),
      'normalizedForm': serializer.toJson<String>(normalizedForm),
      'vocabularyId': serializer.toJson<String>(vocabularyId),
      'confidence': serializer.toJson<double>(confidence),
      'isVerified': serializer.toJson<bool>(isVerified),
      'isPrimary': serializer.toJson<bool>(isPrimary),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  WordForm copyWith({
    String? id,
    String? surfaceForm,
    String? normalizedForm,
    String? vocabularyId,
    double? confidence,
    bool? isVerified,
    bool? isPrimary,
    DateTime? createdAt,
  }) => WordForm(
    id: id ?? this.id,
    surfaceForm: surfaceForm ?? this.surfaceForm,
    normalizedForm: normalizedForm ?? this.normalizedForm,
    vocabularyId: vocabularyId ?? this.vocabularyId,
    confidence: confidence ?? this.confidence,
    isVerified: isVerified ?? this.isVerified,
    isPrimary: isPrimary ?? this.isPrimary,
    createdAt: createdAt ?? this.createdAt,
  );
  WordForm copyWithCompanion(WordFormsCompanion data) {
    return WordForm(
      id: data.id.present ? data.id.value : this.id,
      surfaceForm: data.surfaceForm.present
          ? data.surfaceForm.value
          : this.surfaceForm,
      normalizedForm: data.normalizedForm.present
          ? data.normalizedForm.value
          : this.normalizedForm,
      vocabularyId: data.vocabularyId.present
          ? data.vocabularyId.value
          : this.vocabularyId,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      isVerified: data.isVerified.present
          ? data.isVerified.value
          : this.isVerified,
      isPrimary: data.isPrimary.present ? data.isPrimary.value : this.isPrimary,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WordForm(')
          ..write('id: $id, ')
          ..write('surfaceForm: $surfaceForm, ')
          ..write('normalizedForm: $normalizedForm, ')
          ..write('vocabularyId: $vocabularyId, ')
          ..write('confidence: $confidence, ')
          ..write('isVerified: $isVerified, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    surfaceForm,
    normalizedForm,
    vocabularyId,
    confidence,
    isVerified,
    isPrimary,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordForm &&
          other.id == this.id &&
          other.surfaceForm == this.surfaceForm &&
          other.normalizedForm == this.normalizedForm &&
          other.vocabularyId == this.vocabularyId &&
          other.confidence == this.confidence &&
          other.isVerified == this.isVerified &&
          other.isPrimary == this.isPrimary &&
          other.createdAt == this.createdAt);
}

class WordFormsCompanion extends UpdateCompanion<WordForm> {
  final Value<String> id;
  final Value<String> surfaceForm;
  final Value<String> normalizedForm;
  final Value<String> vocabularyId;
  final Value<double> confidence;
  final Value<bool> isVerified;
  final Value<bool> isPrimary;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const WordFormsCompanion({
    this.id = const Value.absent(),
    this.surfaceForm = const Value.absent(),
    this.normalizedForm = const Value.absent(),
    this.vocabularyId = const Value.absent(),
    this.confidence = const Value.absent(),
    this.isVerified = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WordFormsCompanion.insert({
    required String id,
    required String surfaceForm,
    required String normalizedForm,
    required String vocabularyId,
    this.confidence = const Value.absent(),
    this.isVerified = const Value.absent(),
    this.isPrimary = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       surfaceForm = Value(surfaceForm),
       normalizedForm = Value(normalizedForm),
       vocabularyId = Value(vocabularyId),
       createdAt = Value(createdAt);
  static Insertable<WordForm> custom({
    Expression<String>? id,
    Expression<String>? surfaceForm,
    Expression<String>? normalizedForm,
    Expression<String>? vocabularyId,
    Expression<double>? confidence,
    Expression<bool>? isVerified,
    Expression<bool>? isPrimary,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (surfaceForm != null) 'surface_form': surfaceForm,
      if (normalizedForm != null) 'normalized_form': normalizedForm,
      if (vocabularyId != null) 'vocabulary_id': vocabularyId,
      if (confidence != null) 'confidence': confidence,
      if (isVerified != null) 'is_verified': isVerified,
      if (isPrimary != null) 'is_primary': isPrimary,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WordFormsCompanion copyWith({
    Value<String>? id,
    Value<String>? surfaceForm,
    Value<String>? normalizedForm,
    Value<String>? vocabularyId,
    Value<double>? confidence,
    Value<bool>? isVerified,
    Value<bool>? isPrimary,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return WordFormsCompanion(
      id: id ?? this.id,
      surfaceForm: surfaceForm ?? this.surfaceForm,
      normalizedForm: normalizedForm ?? this.normalizedForm,
      vocabularyId: vocabularyId ?? this.vocabularyId,
      confidence: confidence ?? this.confidence,
      isVerified: isVerified ?? this.isVerified,
      isPrimary: isPrimary ?? this.isPrimary,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (surfaceForm.present) {
      map['surface_form'] = Variable<String>(surfaceForm.value);
    }
    if (normalizedForm.present) {
      map['normalized_form'] = Variable<String>(normalizedForm.value);
    }
    if (vocabularyId.present) {
      map['vocabulary_id'] = Variable<String>(vocabularyId.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (isVerified.present) {
      map['is_verified'] = Variable<bool>(isVerified.value);
    }
    if (isPrimary.present) {
      map['is_primary'] = Variable<bool>(isPrimary.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordFormsCompanion(')
          ..write('id: $id, ')
          ..write('surfaceForm: $surfaceForm, ')
          ..write('normalizedForm: $normalizedForm, ')
          ..write('vocabularyId: $vocabularyId, ')
          ..write('confidence: $confidence, ')
          ..write('isVerified: $isVerified, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WordOccurrencesTable extends WordOccurrences
    with TableInfo<$WordOccurrencesTable, WordOccurrence> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordOccurrencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id)',
    ),
  );
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
    'chapter_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES chapters (id)',
    ),
  );
  static const VerificationMeta _vocabularyIdMeta = const VerificationMeta(
    'vocabularyId',
  );
  @override
  late final GeneratedColumn<String> vocabularyId = GeneratedColumn<String>(
    'vocabulary_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vocabulary (id)',
    ),
  );
  static const VerificationMeta _surfaceFormMeta = const VerificationMeta(
    'surfaceForm',
  );
  @override
  late final GeneratedColumn<String> surfaceForm = GeneratedColumn<String>(
    'surface_form',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paragraphIndexMeta = const VerificationMeta(
    'paragraphIndex',
  );
  @override
  late final GeneratedColumn<int> paragraphIndex = GeneratedColumn<int>(
    'paragraph_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startOffsetMeta = const VerificationMeta(
    'startOffset',
  );
  @override
  late final GeneratedColumn<int> startOffset = GeneratedColumn<int>(
    'start_offset',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endOffsetMeta = const VerificationMeta(
    'endOffset',
  );
  @override
  late final GeneratedColumn<int> endOffset = GeneratedColumn<int>(
    'end_offset',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _overrideVocabularyIdMeta =
      const VerificationMeta('overrideVocabularyId');
  @override
  late final GeneratedColumn<String> overrideVocabularyId =
      GeneratedColumn<String>(
        'override_vocabulary_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES vocabulary (id)',
        ),
      );
  static const VerificationMeta _isManuallyCorrectedMeta =
      const VerificationMeta('isManuallyCorrected');
  @override
  late final GeneratedColumn<bool> isManuallyCorrected = GeneratedColumn<bool>(
    'is_manually_corrected',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_manually_corrected" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    chapterId,
    vocabularyId,
    surfaceForm,
    paragraphIndex,
    startOffset,
    endOffset,
    overrideVocabularyId,
    isManuallyCorrected,
    revision,
    updatedBy,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'word_occurrences';
  @override
  VerificationContext validateIntegrity(
    Insertable<WordOccurrence> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('vocabulary_id')) {
      context.handle(
        _vocabularyIdMeta,
        vocabularyId.isAcceptableOrUnknown(
          data['vocabulary_id']!,
          _vocabularyIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_vocabularyIdMeta);
    }
    if (data.containsKey('surface_form')) {
      context.handle(
        _surfaceFormMeta,
        surfaceForm.isAcceptableOrUnknown(
          data['surface_form']!,
          _surfaceFormMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_surfaceFormMeta);
    }
    if (data.containsKey('paragraph_index')) {
      context.handle(
        _paragraphIndexMeta,
        paragraphIndex.isAcceptableOrUnknown(
          data['paragraph_index']!,
          _paragraphIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paragraphIndexMeta);
    }
    if (data.containsKey('start_offset')) {
      context.handle(
        _startOffsetMeta,
        startOffset.isAcceptableOrUnknown(
          data['start_offset']!,
          _startOffsetMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startOffsetMeta);
    }
    if (data.containsKey('end_offset')) {
      context.handle(
        _endOffsetMeta,
        endOffset.isAcceptableOrUnknown(data['end_offset']!, _endOffsetMeta),
      );
    } else if (isInserting) {
      context.missing(_endOffsetMeta);
    }
    if (data.containsKey('override_vocabulary_id')) {
      context.handle(
        _overrideVocabularyIdMeta,
        overrideVocabularyId.isAcceptableOrUnknown(
          data['override_vocabulary_id']!,
          _overrideVocabularyIdMeta,
        ),
      );
    }
    if (data.containsKey('is_manually_corrected')) {
      context.handle(
        _isManuallyCorrectedMeta,
        isManuallyCorrected.isAcceptableOrUnknown(
          data['is_manually_corrected']!,
          _isManuallyCorrectedMeta,
        ),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WordOccurrence map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WordOccurrence(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_id'],
      )!,
      vocabularyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vocabulary_id'],
      )!,
      surfaceForm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}surface_form'],
      )!,
      paragraphIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paragraph_index'],
      )!,
      startOffset: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_offset'],
      )!,
      endOffset: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_offset'],
      )!,
      overrideVocabularyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}override_vocabulary_id'],
      ),
      isManuallyCorrected: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_manually_corrected'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WordOccurrencesTable createAlias(String alias) {
    return $WordOccurrencesTable(attachedDatabase, alias);
  }
}

class WordOccurrence extends DataClass implements Insertable<WordOccurrence> {
  final String id;
  final String bookId;
  final String chapterId;
  final String vocabularyId;
  final String surfaceForm;
  final int paragraphIndex;
  final int startOffset;
  final int endOffset;
  final String? overrideVocabularyId;
  final bool isManuallyCorrected;
  final int revision;
  final String? updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  const WordOccurrence({
    required this.id,
    required this.bookId,
    required this.chapterId,
    required this.vocabularyId,
    required this.surfaceForm,
    required this.paragraphIndex,
    required this.startOffset,
    required this.endOffset,
    this.overrideVocabularyId,
    required this.isManuallyCorrected,
    required this.revision,
    this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['book_id'] = Variable<String>(bookId);
    map['chapter_id'] = Variable<String>(chapterId);
    map['vocabulary_id'] = Variable<String>(vocabularyId);
    map['surface_form'] = Variable<String>(surfaceForm);
    map['paragraph_index'] = Variable<int>(paragraphIndex);
    map['start_offset'] = Variable<int>(startOffset);
    map['end_offset'] = Variable<int>(endOffset);
    if (!nullToAbsent || overrideVocabularyId != null) {
      map['override_vocabulary_id'] = Variable<String>(overrideVocabularyId);
    }
    map['is_manually_corrected'] = Variable<bool>(isManuallyCorrected);
    map['revision'] = Variable<int>(revision);
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WordOccurrencesCompanion toCompanion(bool nullToAbsent) {
    return WordOccurrencesCompanion(
      id: Value(id),
      bookId: Value(bookId),
      chapterId: Value(chapterId),
      vocabularyId: Value(vocabularyId),
      surfaceForm: Value(surfaceForm),
      paragraphIndex: Value(paragraphIndex),
      startOffset: Value(startOffset),
      endOffset: Value(endOffset),
      overrideVocabularyId: overrideVocabularyId == null && nullToAbsent
          ? const Value.absent()
          : Value(overrideVocabularyId),
      isManuallyCorrected: Value(isManuallyCorrected),
      revision: Value(revision),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory WordOccurrence.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WordOccurrence(
      id: serializer.fromJson<String>(json['id']),
      bookId: serializer.fromJson<String>(json['bookId']),
      chapterId: serializer.fromJson<String>(json['chapterId']),
      vocabularyId: serializer.fromJson<String>(json['vocabularyId']),
      surfaceForm: serializer.fromJson<String>(json['surfaceForm']),
      paragraphIndex: serializer.fromJson<int>(json['paragraphIndex']),
      startOffset: serializer.fromJson<int>(json['startOffset']),
      endOffset: serializer.fromJson<int>(json['endOffset']),
      overrideVocabularyId: serializer.fromJson<String?>(
        json['overrideVocabularyId'],
      ),
      isManuallyCorrected: serializer.fromJson<bool>(
        json['isManuallyCorrected'],
      ),
      revision: serializer.fromJson<int>(json['revision']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookId': serializer.toJson<String>(bookId),
      'chapterId': serializer.toJson<String>(chapterId),
      'vocabularyId': serializer.toJson<String>(vocabularyId),
      'surfaceForm': serializer.toJson<String>(surfaceForm),
      'paragraphIndex': serializer.toJson<int>(paragraphIndex),
      'startOffset': serializer.toJson<int>(startOffset),
      'endOffset': serializer.toJson<int>(endOffset),
      'overrideVocabularyId': serializer.toJson<String?>(overrideVocabularyId),
      'isManuallyCorrected': serializer.toJson<bool>(isManuallyCorrected),
      'revision': serializer.toJson<int>(revision),
      'updatedBy': serializer.toJson<String?>(updatedBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WordOccurrence copyWith({
    String? id,
    String? bookId,
    String? chapterId,
    String? vocabularyId,
    String? surfaceForm,
    int? paragraphIndex,
    int? startOffset,
    int? endOffset,
    Value<String?> overrideVocabularyId = const Value.absent(),
    bool? isManuallyCorrected,
    int? revision,
    Value<String?> updatedBy = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => WordOccurrence(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    chapterId: chapterId ?? this.chapterId,
    vocabularyId: vocabularyId ?? this.vocabularyId,
    surfaceForm: surfaceForm ?? this.surfaceForm,
    paragraphIndex: paragraphIndex ?? this.paragraphIndex,
    startOffset: startOffset ?? this.startOffset,
    endOffset: endOffset ?? this.endOffset,
    overrideVocabularyId: overrideVocabularyId.present
        ? overrideVocabularyId.value
        : this.overrideVocabularyId,
    isManuallyCorrected: isManuallyCorrected ?? this.isManuallyCorrected,
    revision: revision ?? this.revision,
    updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WordOccurrence copyWithCompanion(WordOccurrencesCompanion data) {
    return WordOccurrence(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      vocabularyId: data.vocabularyId.present
          ? data.vocabularyId.value
          : this.vocabularyId,
      surfaceForm: data.surfaceForm.present
          ? data.surfaceForm.value
          : this.surfaceForm,
      paragraphIndex: data.paragraphIndex.present
          ? data.paragraphIndex.value
          : this.paragraphIndex,
      startOffset: data.startOffset.present
          ? data.startOffset.value
          : this.startOffset,
      endOffset: data.endOffset.present ? data.endOffset.value : this.endOffset,
      overrideVocabularyId: data.overrideVocabularyId.present
          ? data.overrideVocabularyId.value
          : this.overrideVocabularyId,
      isManuallyCorrected: data.isManuallyCorrected.present
          ? data.isManuallyCorrected.value
          : this.isManuallyCorrected,
      revision: data.revision.present ? data.revision.value : this.revision,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WordOccurrence(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('chapterId: $chapterId, ')
          ..write('vocabularyId: $vocabularyId, ')
          ..write('surfaceForm: $surfaceForm, ')
          ..write('paragraphIndex: $paragraphIndex, ')
          ..write('startOffset: $startOffset, ')
          ..write('endOffset: $endOffset, ')
          ..write('overrideVocabularyId: $overrideVocabularyId, ')
          ..write('isManuallyCorrected: $isManuallyCorrected, ')
          ..write('revision: $revision, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bookId,
    chapterId,
    vocabularyId,
    surfaceForm,
    paragraphIndex,
    startOffset,
    endOffset,
    overrideVocabularyId,
    isManuallyCorrected,
    revision,
    updatedBy,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordOccurrence &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.chapterId == this.chapterId &&
          other.vocabularyId == this.vocabularyId &&
          other.surfaceForm == this.surfaceForm &&
          other.paragraphIndex == this.paragraphIndex &&
          other.startOffset == this.startOffset &&
          other.endOffset == this.endOffset &&
          other.overrideVocabularyId == this.overrideVocabularyId &&
          other.isManuallyCorrected == this.isManuallyCorrected &&
          other.revision == this.revision &&
          other.updatedBy == this.updatedBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WordOccurrencesCompanion extends UpdateCompanion<WordOccurrence> {
  final Value<String> id;
  final Value<String> bookId;
  final Value<String> chapterId;
  final Value<String> vocabularyId;
  final Value<String> surfaceForm;
  final Value<int> paragraphIndex;
  final Value<int> startOffset;
  final Value<int> endOffset;
  final Value<String?> overrideVocabularyId;
  final Value<bool> isManuallyCorrected;
  final Value<int> revision;
  final Value<String?> updatedBy;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const WordOccurrencesCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.vocabularyId = const Value.absent(),
    this.surfaceForm = const Value.absent(),
    this.paragraphIndex = const Value.absent(),
    this.startOffset = const Value.absent(),
    this.endOffset = const Value.absent(),
    this.overrideVocabularyId = const Value.absent(),
    this.isManuallyCorrected = const Value.absent(),
    this.revision = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WordOccurrencesCompanion.insert({
    required String id,
    required String bookId,
    required String chapterId,
    required String vocabularyId,
    required String surfaceForm,
    required int paragraphIndex,
    required int startOffset,
    required int endOffset,
    this.overrideVocabularyId = const Value.absent(),
    this.isManuallyCorrected = const Value.absent(),
    this.revision = const Value.absent(),
    this.updatedBy = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       bookId = Value(bookId),
       chapterId = Value(chapterId),
       vocabularyId = Value(vocabularyId),
       surfaceForm = Value(surfaceForm),
       paragraphIndex = Value(paragraphIndex),
       startOffset = Value(startOffset),
       endOffset = Value(endOffset),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<WordOccurrence> custom({
    Expression<String>? id,
    Expression<String>? bookId,
    Expression<String>? chapterId,
    Expression<String>? vocabularyId,
    Expression<String>? surfaceForm,
    Expression<int>? paragraphIndex,
    Expression<int>? startOffset,
    Expression<int>? endOffset,
    Expression<String>? overrideVocabularyId,
    Expression<bool>? isManuallyCorrected,
    Expression<int>? revision,
    Expression<String>? updatedBy,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (chapterId != null) 'chapter_id': chapterId,
      if (vocabularyId != null) 'vocabulary_id': vocabularyId,
      if (surfaceForm != null) 'surface_form': surfaceForm,
      if (paragraphIndex != null) 'paragraph_index': paragraphIndex,
      if (startOffset != null) 'start_offset': startOffset,
      if (endOffset != null) 'end_offset': endOffset,
      if (overrideVocabularyId != null)
        'override_vocabulary_id': overrideVocabularyId,
      if (isManuallyCorrected != null)
        'is_manually_corrected': isManuallyCorrected,
      if (revision != null) 'revision': revision,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WordOccurrencesCompanion copyWith({
    Value<String>? id,
    Value<String>? bookId,
    Value<String>? chapterId,
    Value<String>? vocabularyId,
    Value<String>? surfaceForm,
    Value<int>? paragraphIndex,
    Value<int>? startOffset,
    Value<int>? endOffset,
    Value<String?>? overrideVocabularyId,
    Value<bool>? isManuallyCorrected,
    Value<int>? revision,
    Value<String?>? updatedBy,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return WordOccurrencesCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      chapterId: chapterId ?? this.chapterId,
      vocabularyId: vocabularyId ?? this.vocabularyId,
      surfaceForm: surfaceForm ?? this.surfaceForm,
      paragraphIndex: paragraphIndex ?? this.paragraphIndex,
      startOffset: startOffset ?? this.startOffset,
      endOffset: endOffset ?? this.endOffset,
      overrideVocabularyId: overrideVocabularyId ?? this.overrideVocabularyId,
      isManuallyCorrected: isManuallyCorrected ?? this.isManuallyCorrected,
      revision: revision ?? this.revision,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (vocabularyId.present) {
      map['vocabulary_id'] = Variable<String>(vocabularyId.value);
    }
    if (surfaceForm.present) {
      map['surface_form'] = Variable<String>(surfaceForm.value);
    }
    if (paragraphIndex.present) {
      map['paragraph_index'] = Variable<int>(paragraphIndex.value);
    }
    if (startOffset.present) {
      map['start_offset'] = Variable<int>(startOffset.value);
    }
    if (endOffset.present) {
      map['end_offset'] = Variable<int>(endOffset.value);
    }
    if (overrideVocabularyId.present) {
      map['override_vocabulary_id'] = Variable<String>(
        overrideVocabularyId.value,
      );
    }
    if (isManuallyCorrected.present) {
      map['is_manually_corrected'] = Variable<bool>(isManuallyCorrected.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordOccurrencesCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('chapterId: $chapterId, ')
          ..write('vocabularyId: $vocabularyId, ')
          ..write('surfaceForm: $surfaceForm, ')
          ..write('paragraphIndex: $paragraphIndex, ')
          ..write('startOffset: $startOffset, ')
          ..write('endOffset: $endOffset, ')
          ..write('overrideVocabularyId: $overrideVocabularyId, ')
          ..write('isManuallyCorrected: $isManuallyCorrected, ')
          ..write('revision: $revision, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WordStatusesTable extends WordStatuses
    with TableInfo<$WordStatusesTable, WordStatuse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordStatusesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _vocabularyIdMeta = const VerificationMeta(
    'vocabularyId',
  );
  @override
  late final GeneratedColumn<String> vocabularyId = GeneratedColumn<String>(
    'vocabulary_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vocabulary (id)',
    ),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    vocabularyId,
    status,
    revision,
    updatedBy,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'word_statuses';
  @override
  VerificationContext validateIntegrity(
    Insertable<WordStatuse> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('vocabulary_id')) {
      context.handle(
        _vocabularyIdMeta,
        vocabularyId.isAcceptableOrUnknown(
          data['vocabulary_id']!,
          _vocabularyIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_vocabularyIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {vocabularyId};
  @override
  WordStatuse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WordStatuse(
      vocabularyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vocabulary_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WordStatusesTable createAlias(String alias) {
    return $WordStatusesTable(attachedDatabase, alias);
  }
}

class WordStatuse extends DataClass implements Insertable<WordStatuse> {
  final String vocabularyId;
  final String status;
  final int revision;
  final String? updatedBy;
  final DateTime updatedAt;
  const WordStatuse({
    required this.vocabularyId,
    required this.status,
    required this.revision,
    this.updatedBy,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['vocabulary_id'] = Variable<String>(vocabularyId);
    map['status'] = Variable<String>(status);
    map['revision'] = Variable<int>(revision);
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WordStatusesCompanion toCompanion(bool nullToAbsent) {
    return WordStatusesCompanion(
      vocabularyId: Value(vocabularyId),
      status: Value(status),
      revision: Value(revision),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      updatedAt: Value(updatedAt),
    );
  }

  factory WordStatuse.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WordStatuse(
      vocabularyId: serializer.fromJson<String>(json['vocabularyId']),
      status: serializer.fromJson<String>(json['status']),
      revision: serializer.fromJson<int>(json['revision']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'vocabularyId': serializer.toJson<String>(vocabularyId),
      'status': serializer.toJson<String>(status),
      'revision': serializer.toJson<int>(revision),
      'updatedBy': serializer.toJson<String?>(updatedBy),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WordStatuse copyWith({
    String? vocabularyId,
    String? status,
    int? revision,
    Value<String?> updatedBy = const Value.absent(),
    DateTime? updatedAt,
  }) => WordStatuse(
    vocabularyId: vocabularyId ?? this.vocabularyId,
    status: status ?? this.status,
    revision: revision ?? this.revision,
    updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WordStatuse copyWithCompanion(WordStatusesCompanion data) {
    return WordStatuse(
      vocabularyId: data.vocabularyId.present
          ? data.vocabularyId.value
          : this.vocabularyId,
      status: data.status.present ? data.status.value : this.status,
      revision: data.revision.present ? data.revision.value : this.revision,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WordStatuse(')
          ..write('vocabularyId: $vocabularyId, ')
          ..write('status: $status, ')
          ..write('revision: $revision, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(vocabularyId, status, revision, updatedBy, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordStatuse &&
          other.vocabularyId == this.vocabularyId &&
          other.status == this.status &&
          other.revision == this.revision &&
          other.updatedBy == this.updatedBy &&
          other.updatedAt == this.updatedAt);
}

class WordStatusesCompanion extends UpdateCompanion<WordStatuse> {
  final Value<String> vocabularyId;
  final Value<String> status;
  final Value<int> revision;
  final Value<String?> updatedBy;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const WordStatusesCompanion({
    this.vocabularyId = const Value.absent(),
    this.status = const Value.absent(),
    this.revision = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WordStatusesCompanion.insert({
    required String vocabularyId,
    required String status,
    this.revision = const Value.absent(),
    this.updatedBy = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : vocabularyId = Value(vocabularyId),
       status = Value(status),
       updatedAt = Value(updatedAt);
  static Insertable<WordStatuse> custom({
    Expression<String>? vocabularyId,
    Expression<String>? status,
    Expression<int>? revision,
    Expression<String>? updatedBy,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (vocabularyId != null) 'vocabulary_id': vocabularyId,
      if (status != null) 'status': status,
      if (revision != null) 'revision': revision,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WordStatusesCompanion copyWith({
    Value<String>? vocabularyId,
    Value<String>? status,
    Value<int>? revision,
    Value<String?>? updatedBy,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return WordStatusesCompanion(
      vocabularyId: vocabularyId ?? this.vocabularyId,
      status: status ?? this.status,
      revision: revision ?? this.revision,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (vocabularyId.present) {
      map['vocabulary_id'] = Variable<String>(vocabularyId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordStatusesCompanion(')
          ..write('vocabularyId: $vocabularyId, ')
          ..write('status: $status, ')
          ..write('revision: $revision, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DefinitionsTable extends Definitions
    with TableInfo<$DefinitionsTable, Definition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DefinitionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vocabularyIdMeta = const VerificationMeta(
    'vocabularyId',
  );
  @override
  late final GeneratedColumn<String> vocabularyId = GeneratedColumn<String>(
    'vocabulary_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vocabulary (id)',
    ),
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('en'),
  );
  static const VerificationMeta _meaningMeta = const VerificationMeta(
    'meaning',
  );
  @override
  late final GeneratedColumn<String> meaning = GeneratedColumn<String>(
    'meaning',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exampleMeta = const VerificationMeta(
    'example',
  );
  @override
  late final GeneratedColumn<String> example = GeneratedColumn<String>(
    'example',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vocabularyId,
    language,
    meaning,
    example,
    revision,
    updatedBy,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'definitions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Definition> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('vocabulary_id')) {
      context.handle(
        _vocabularyIdMeta,
        vocabularyId.isAcceptableOrUnknown(
          data['vocabulary_id']!,
          _vocabularyIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_vocabularyIdMeta);
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    }
    if (data.containsKey('meaning')) {
      context.handle(
        _meaningMeta,
        meaning.isAcceptableOrUnknown(data['meaning']!, _meaningMeta),
      );
    } else if (isInserting) {
      context.missing(_meaningMeta);
    }
    if (data.containsKey('example')) {
      context.handle(
        _exampleMeta,
        example.isAcceptableOrUnknown(data['example']!, _exampleMeta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Definition map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Definition(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      vocabularyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vocabulary_id'],
      )!,
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      meaning: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning'],
      )!,
      example: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}example'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DefinitionsTable createAlias(String alias) {
    return $DefinitionsTable(attachedDatabase, alias);
  }
}

class Definition extends DataClass implements Insertable<Definition> {
  final String id;
  final String vocabularyId;
  final String language;
  final String meaning;
  final String? example;
  final int revision;
  final String? updatedBy;
  final DateTime updatedAt;
  const Definition({
    required this.id,
    required this.vocabularyId,
    required this.language,
    required this.meaning,
    this.example,
    required this.revision,
    this.updatedBy,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['vocabulary_id'] = Variable<String>(vocabularyId);
    map['language'] = Variable<String>(language);
    map['meaning'] = Variable<String>(meaning);
    if (!nullToAbsent || example != null) {
      map['example'] = Variable<String>(example);
    }
    map['revision'] = Variable<int>(revision);
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DefinitionsCompanion toCompanion(bool nullToAbsent) {
    return DefinitionsCompanion(
      id: Value(id),
      vocabularyId: Value(vocabularyId),
      language: Value(language),
      meaning: Value(meaning),
      example: example == null && nullToAbsent
          ? const Value.absent()
          : Value(example),
      revision: Value(revision),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      updatedAt: Value(updatedAt),
    );
  }

  factory Definition.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Definition(
      id: serializer.fromJson<String>(json['id']),
      vocabularyId: serializer.fromJson<String>(json['vocabularyId']),
      language: serializer.fromJson<String>(json['language']),
      meaning: serializer.fromJson<String>(json['meaning']),
      example: serializer.fromJson<String?>(json['example']),
      revision: serializer.fromJson<int>(json['revision']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'vocabularyId': serializer.toJson<String>(vocabularyId),
      'language': serializer.toJson<String>(language),
      'meaning': serializer.toJson<String>(meaning),
      'example': serializer.toJson<String?>(example),
      'revision': serializer.toJson<int>(revision),
      'updatedBy': serializer.toJson<String?>(updatedBy),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Definition copyWith({
    String? id,
    String? vocabularyId,
    String? language,
    String? meaning,
    Value<String?> example = const Value.absent(),
    int? revision,
    Value<String?> updatedBy = const Value.absent(),
    DateTime? updatedAt,
  }) => Definition(
    id: id ?? this.id,
    vocabularyId: vocabularyId ?? this.vocabularyId,
    language: language ?? this.language,
    meaning: meaning ?? this.meaning,
    example: example.present ? example.value : this.example,
    revision: revision ?? this.revision,
    updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Definition copyWithCompanion(DefinitionsCompanion data) {
    return Definition(
      id: data.id.present ? data.id.value : this.id,
      vocabularyId: data.vocabularyId.present
          ? data.vocabularyId.value
          : this.vocabularyId,
      language: data.language.present ? data.language.value : this.language,
      meaning: data.meaning.present ? data.meaning.value : this.meaning,
      example: data.example.present ? data.example.value : this.example,
      revision: data.revision.present ? data.revision.value : this.revision,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Definition(')
          ..write('id: $id, ')
          ..write('vocabularyId: $vocabularyId, ')
          ..write('language: $language, ')
          ..write('meaning: $meaning, ')
          ..write('example: $example, ')
          ..write('revision: $revision, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    vocabularyId,
    language,
    meaning,
    example,
    revision,
    updatedBy,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Definition &&
          other.id == this.id &&
          other.vocabularyId == this.vocabularyId &&
          other.language == this.language &&
          other.meaning == this.meaning &&
          other.example == this.example &&
          other.revision == this.revision &&
          other.updatedBy == this.updatedBy &&
          other.updatedAt == this.updatedAt);
}

class DefinitionsCompanion extends UpdateCompanion<Definition> {
  final Value<String> id;
  final Value<String> vocabularyId;
  final Value<String> language;
  final Value<String> meaning;
  final Value<String?> example;
  final Value<int> revision;
  final Value<String?> updatedBy;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DefinitionsCompanion({
    this.id = const Value.absent(),
    this.vocabularyId = const Value.absent(),
    this.language = const Value.absent(),
    this.meaning = const Value.absent(),
    this.example = const Value.absent(),
    this.revision = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DefinitionsCompanion.insert({
    required String id,
    required String vocabularyId,
    this.language = const Value.absent(),
    required String meaning,
    this.example = const Value.absent(),
    this.revision = const Value.absent(),
    this.updatedBy = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       vocabularyId = Value(vocabularyId),
       meaning = Value(meaning),
       updatedAt = Value(updatedAt);
  static Insertable<Definition> custom({
    Expression<String>? id,
    Expression<String>? vocabularyId,
    Expression<String>? language,
    Expression<String>? meaning,
    Expression<String>? example,
    Expression<int>? revision,
    Expression<String>? updatedBy,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vocabularyId != null) 'vocabulary_id': vocabularyId,
      if (language != null) 'language': language,
      if (meaning != null) 'meaning': meaning,
      if (example != null) 'example': example,
      if (revision != null) 'revision': revision,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DefinitionsCompanion copyWith({
    Value<String>? id,
    Value<String>? vocabularyId,
    Value<String>? language,
    Value<String>? meaning,
    Value<String?>? example,
    Value<int>? revision,
    Value<String?>? updatedBy,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return DefinitionsCompanion(
      id: id ?? this.id,
      vocabularyId: vocabularyId ?? this.vocabularyId,
      language: language ?? this.language,
      meaning: meaning ?? this.meaning,
      example: example ?? this.example,
      revision: revision ?? this.revision,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (vocabularyId.present) {
      map['vocabulary_id'] = Variable<String>(vocabularyId.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (meaning.present) {
      map['meaning'] = Variable<String>(meaning.value);
    }
    if (example.present) {
      map['example'] = Variable<String>(example.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DefinitionsCompanion(')
          ..write('id: $id, ')
          ..write('vocabularyId: $vocabularyId, ')
          ..write('language: $language, ')
          ..write('meaning: $meaning, ')
          ..write('example: $example, ')
          ..write('revision: $revision, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FsrsCardsTable extends FsrsCards
    with TableInfo<$FsrsCardsTable, FsrsCard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FsrsCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _vocabularyIdMeta = const VerificationMeta(
    'vocabularyId',
  );
  @override
  late final GeneratedColumn<String> vocabularyId = GeneratedColumn<String>(
    'vocabulary_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vocabulary (id)',
    ),
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueMeta = const VerificationMeta('due');
  @override
  late final GeneratedColumn<DateTime> due = GeneratedColumn<DateTime>(
    'due',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stabilityMeta = const VerificationMeta(
    'stability',
  );
  @override
  late final GeneratedColumn<double> stability = GeneratedColumn<double>(
    'stability',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<double> difficulty = GeneratedColumn<double>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _elapsedDaysMeta = const VerificationMeta(
    'elapsedDays',
  );
  @override
  late final GeneratedColumn<int> elapsedDays = GeneratedColumn<int>(
    'elapsed_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _scheduledDaysMeta = const VerificationMeta(
    'scheduledDays',
  );
  @override
  late final GeneratedColumn<int> scheduledDays = GeneratedColumn<int>(
    'scheduled_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lapsesMeta = const VerificationMeta('lapses');
  @override
  late final GeneratedColumn<int> lapses = GeneratedColumn<int>(
    'lapses',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastReviewMeta = const VerificationMeta(
    'lastReview',
  );
  @override
  late final GeneratedColumn<DateTime> lastReview = GeneratedColumn<DateTime>(
    'last_review',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    vocabularyId,
    state,
    due,
    stability,
    difficulty,
    elapsedDays,
    scheduledDays,
    reps,
    lapses,
    lastReview,
    revision,
    updatedBy,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fsrs_cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<FsrsCard> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('vocabulary_id')) {
      context.handle(
        _vocabularyIdMeta,
        vocabularyId.isAcceptableOrUnknown(
          data['vocabulary_id']!,
          _vocabularyIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_vocabularyIdMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('due')) {
      context.handle(
        _dueMeta,
        due.isAcceptableOrUnknown(data['due']!, _dueMeta),
      );
    } else if (isInserting) {
      context.missing(_dueMeta);
    }
    if (data.containsKey('stability')) {
      context.handle(
        _stabilityMeta,
        stability.isAcceptableOrUnknown(data['stability']!, _stabilityMeta),
      );
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    }
    if (data.containsKey('elapsed_days')) {
      context.handle(
        _elapsedDaysMeta,
        elapsedDays.isAcceptableOrUnknown(
          data['elapsed_days']!,
          _elapsedDaysMeta,
        ),
      );
    }
    if (data.containsKey('scheduled_days')) {
      context.handle(
        _scheduledDaysMeta,
        scheduledDays.isAcceptableOrUnknown(
          data['scheduled_days']!,
          _scheduledDaysMeta,
        ),
      );
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    }
    if (data.containsKey('lapses')) {
      context.handle(
        _lapsesMeta,
        lapses.isAcceptableOrUnknown(data['lapses']!, _lapsesMeta),
      );
    }
    if (data.containsKey('last_review')) {
      context.handle(
        _lastReviewMeta,
        lastReview.isAcceptableOrUnknown(data['last_review']!, _lastReviewMeta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {vocabularyId};
  @override
  FsrsCard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FsrsCard(
      vocabularyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vocabulary_id'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      due: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due'],
      )!,
      stability: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stability'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}difficulty'],
      )!,
      elapsedDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}elapsed_days'],
      )!,
      scheduledDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scheduled_days'],
      )!,
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      )!,
      lapses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lapses'],
      )!,
      lastReview: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_review'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FsrsCardsTable createAlias(String alias) {
    return $FsrsCardsTable(attachedDatabase, alias);
  }
}

class FsrsCard extends DataClass implements Insertable<FsrsCard> {
  final String vocabularyId;
  final String state;
  final DateTime due;
  final double stability;
  final double difficulty;
  final int elapsedDays;
  final int scheduledDays;
  final int reps;
  final int lapses;
  final DateTime? lastReview;
  final int revision;
  final String? updatedBy;
  final DateTime updatedAt;
  const FsrsCard({
    required this.vocabularyId,
    required this.state,
    required this.due,
    required this.stability,
    required this.difficulty,
    required this.elapsedDays,
    required this.scheduledDays,
    required this.reps,
    required this.lapses,
    this.lastReview,
    required this.revision,
    this.updatedBy,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['vocabulary_id'] = Variable<String>(vocabularyId);
    map['state'] = Variable<String>(state);
    map['due'] = Variable<DateTime>(due);
    map['stability'] = Variable<double>(stability);
    map['difficulty'] = Variable<double>(difficulty);
    map['elapsed_days'] = Variable<int>(elapsedDays);
    map['scheduled_days'] = Variable<int>(scheduledDays);
    map['reps'] = Variable<int>(reps);
    map['lapses'] = Variable<int>(lapses);
    if (!nullToAbsent || lastReview != null) {
      map['last_review'] = Variable<DateTime>(lastReview);
    }
    map['revision'] = Variable<int>(revision);
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FsrsCardsCompanion toCompanion(bool nullToAbsent) {
    return FsrsCardsCompanion(
      vocabularyId: Value(vocabularyId),
      state: Value(state),
      due: Value(due),
      stability: Value(stability),
      difficulty: Value(difficulty),
      elapsedDays: Value(elapsedDays),
      scheduledDays: Value(scheduledDays),
      reps: Value(reps),
      lapses: Value(lapses),
      lastReview: lastReview == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReview),
      revision: Value(revision),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      updatedAt: Value(updatedAt),
    );
  }

  factory FsrsCard.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FsrsCard(
      vocabularyId: serializer.fromJson<String>(json['vocabularyId']),
      state: serializer.fromJson<String>(json['state']),
      due: serializer.fromJson<DateTime>(json['due']),
      stability: serializer.fromJson<double>(json['stability']),
      difficulty: serializer.fromJson<double>(json['difficulty']),
      elapsedDays: serializer.fromJson<int>(json['elapsedDays']),
      scheduledDays: serializer.fromJson<int>(json['scheduledDays']),
      reps: serializer.fromJson<int>(json['reps']),
      lapses: serializer.fromJson<int>(json['lapses']),
      lastReview: serializer.fromJson<DateTime?>(json['lastReview']),
      revision: serializer.fromJson<int>(json['revision']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'vocabularyId': serializer.toJson<String>(vocabularyId),
      'state': serializer.toJson<String>(state),
      'due': serializer.toJson<DateTime>(due),
      'stability': serializer.toJson<double>(stability),
      'difficulty': serializer.toJson<double>(difficulty),
      'elapsedDays': serializer.toJson<int>(elapsedDays),
      'scheduledDays': serializer.toJson<int>(scheduledDays),
      'reps': serializer.toJson<int>(reps),
      'lapses': serializer.toJson<int>(lapses),
      'lastReview': serializer.toJson<DateTime?>(lastReview),
      'revision': serializer.toJson<int>(revision),
      'updatedBy': serializer.toJson<String?>(updatedBy),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  FsrsCard copyWith({
    String? vocabularyId,
    String? state,
    DateTime? due,
    double? stability,
    double? difficulty,
    int? elapsedDays,
    int? scheduledDays,
    int? reps,
    int? lapses,
    Value<DateTime?> lastReview = const Value.absent(),
    int? revision,
    Value<String?> updatedBy = const Value.absent(),
    DateTime? updatedAt,
  }) => FsrsCard(
    vocabularyId: vocabularyId ?? this.vocabularyId,
    state: state ?? this.state,
    due: due ?? this.due,
    stability: stability ?? this.stability,
    difficulty: difficulty ?? this.difficulty,
    elapsedDays: elapsedDays ?? this.elapsedDays,
    scheduledDays: scheduledDays ?? this.scheduledDays,
    reps: reps ?? this.reps,
    lapses: lapses ?? this.lapses,
    lastReview: lastReview.present ? lastReview.value : this.lastReview,
    revision: revision ?? this.revision,
    updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  FsrsCard copyWithCompanion(FsrsCardsCompanion data) {
    return FsrsCard(
      vocabularyId: data.vocabularyId.present
          ? data.vocabularyId.value
          : this.vocabularyId,
      state: data.state.present ? data.state.value : this.state,
      due: data.due.present ? data.due.value : this.due,
      stability: data.stability.present ? data.stability.value : this.stability,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      elapsedDays: data.elapsedDays.present
          ? data.elapsedDays.value
          : this.elapsedDays,
      scheduledDays: data.scheduledDays.present
          ? data.scheduledDays.value
          : this.scheduledDays,
      reps: data.reps.present ? data.reps.value : this.reps,
      lapses: data.lapses.present ? data.lapses.value : this.lapses,
      lastReview: data.lastReview.present
          ? data.lastReview.value
          : this.lastReview,
      revision: data.revision.present ? data.revision.value : this.revision,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FsrsCard(')
          ..write('vocabularyId: $vocabularyId, ')
          ..write('state: $state, ')
          ..write('due: $due, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('elapsedDays: $elapsedDays, ')
          ..write('scheduledDays: $scheduledDays, ')
          ..write('reps: $reps, ')
          ..write('lapses: $lapses, ')
          ..write('lastReview: $lastReview, ')
          ..write('revision: $revision, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    vocabularyId,
    state,
    due,
    stability,
    difficulty,
    elapsedDays,
    scheduledDays,
    reps,
    lapses,
    lastReview,
    revision,
    updatedBy,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FsrsCard &&
          other.vocabularyId == this.vocabularyId &&
          other.state == this.state &&
          other.due == this.due &&
          other.stability == this.stability &&
          other.difficulty == this.difficulty &&
          other.elapsedDays == this.elapsedDays &&
          other.scheduledDays == this.scheduledDays &&
          other.reps == this.reps &&
          other.lapses == this.lapses &&
          other.lastReview == this.lastReview &&
          other.revision == this.revision &&
          other.updatedBy == this.updatedBy &&
          other.updatedAt == this.updatedAt);
}

class FsrsCardsCompanion extends UpdateCompanion<FsrsCard> {
  final Value<String> vocabularyId;
  final Value<String> state;
  final Value<DateTime> due;
  final Value<double> stability;
  final Value<double> difficulty;
  final Value<int> elapsedDays;
  final Value<int> scheduledDays;
  final Value<int> reps;
  final Value<int> lapses;
  final Value<DateTime?> lastReview;
  final Value<int> revision;
  final Value<String?> updatedBy;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const FsrsCardsCompanion({
    this.vocabularyId = const Value.absent(),
    this.state = const Value.absent(),
    this.due = const Value.absent(),
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.elapsedDays = const Value.absent(),
    this.scheduledDays = const Value.absent(),
    this.reps = const Value.absent(),
    this.lapses = const Value.absent(),
    this.lastReview = const Value.absent(),
    this.revision = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FsrsCardsCompanion.insert({
    required String vocabularyId,
    required String state,
    required DateTime due,
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.elapsedDays = const Value.absent(),
    this.scheduledDays = const Value.absent(),
    this.reps = const Value.absent(),
    this.lapses = const Value.absent(),
    this.lastReview = const Value.absent(),
    this.revision = const Value.absent(),
    this.updatedBy = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : vocabularyId = Value(vocabularyId),
       state = Value(state),
       due = Value(due),
       updatedAt = Value(updatedAt);
  static Insertable<FsrsCard> custom({
    Expression<String>? vocabularyId,
    Expression<String>? state,
    Expression<DateTime>? due,
    Expression<double>? stability,
    Expression<double>? difficulty,
    Expression<int>? elapsedDays,
    Expression<int>? scheduledDays,
    Expression<int>? reps,
    Expression<int>? lapses,
    Expression<DateTime>? lastReview,
    Expression<int>? revision,
    Expression<String>? updatedBy,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (vocabularyId != null) 'vocabulary_id': vocabularyId,
      if (state != null) 'state': state,
      if (due != null) 'due': due,
      if (stability != null) 'stability': stability,
      if (difficulty != null) 'difficulty': difficulty,
      if (elapsedDays != null) 'elapsed_days': elapsedDays,
      if (scheduledDays != null) 'scheduled_days': scheduledDays,
      if (reps != null) 'reps': reps,
      if (lapses != null) 'lapses': lapses,
      if (lastReview != null) 'last_review': lastReview,
      if (revision != null) 'revision': revision,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FsrsCardsCompanion copyWith({
    Value<String>? vocabularyId,
    Value<String>? state,
    Value<DateTime>? due,
    Value<double>? stability,
    Value<double>? difficulty,
    Value<int>? elapsedDays,
    Value<int>? scheduledDays,
    Value<int>? reps,
    Value<int>? lapses,
    Value<DateTime?>? lastReview,
    Value<int>? revision,
    Value<String?>? updatedBy,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return FsrsCardsCompanion(
      vocabularyId: vocabularyId ?? this.vocabularyId,
      state: state ?? this.state,
      due: due ?? this.due,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      elapsedDays: elapsedDays ?? this.elapsedDays,
      scheduledDays: scheduledDays ?? this.scheduledDays,
      reps: reps ?? this.reps,
      lapses: lapses ?? this.lapses,
      lastReview: lastReview ?? this.lastReview,
      revision: revision ?? this.revision,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (vocabularyId.present) {
      map['vocabulary_id'] = Variable<String>(vocabularyId.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (due.present) {
      map['due'] = Variable<DateTime>(due.value);
    }
    if (stability.present) {
      map['stability'] = Variable<double>(stability.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<double>(difficulty.value);
    }
    if (elapsedDays.present) {
      map['elapsed_days'] = Variable<int>(elapsedDays.value);
    }
    if (scheduledDays.present) {
      map['scheduled_days'] = Variable<int>(scheduledDays.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (lapses.present) {
      map['lapses'] = Variable<int>(lapses.value);
    }
    if (lastReview.present) {
      map['last_review'] = Variable<DateTime>(lastReview.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FsrsCardsCompanion(')
          ..write('vocabularyId: $vocabularyId, ')
          ..write('state: $state, ')
          ..write('due: $due, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('elapsedDays: $elapsedDays, ')
          ..write('scheduledDays: $scheduledDays, ')
          ..write('reps: $reps, ')
          ..write('lapses: $lapses, ')
          ..write('lastReview: $lastReview, ')
          ..write('revision: $revision, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReviewLogsTable extends ReviewLogs
    with TableInfo<$ReviewLogsTable, ReviewLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vocabularyIdMeta = const VerificationMeta(
    'vocabularyId',
  );
  @override
  late final GeneratedColumn<String> vocabularyId = GeneratedColumn<String>(
    'vocabulary_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vocabulary (id)',
    ),
  );
  static const VerificationMeta _reviewedAtMeta = const VerificationMeta(
    'reviewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> reviewedAt = GeneratedColumn<DateTime>(
    'reviewed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateBeforeMeta = const VerificationMeta(
    'stateBefore',
  );
  @override
  late final GeneratedColumn<String> stateBefore = GeneratedColumn<String>(
    'state_before',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateAfterMeta = const VerificationMeta(
    'stateAfter',
  );
  @override
  late final GeneratedColumn<String> stateAfter = GeneratedColumn<String>(
    'state_after',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stabilityBeforeMeta = const VerificationMeta(
    'stabilityBefore',
  );
  @override
  late final GeneratedColumn<double> stabilityBefore = GeneratedColumn<double>(
    'stability_before',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stabilityAfterMeta = const VerificationMeta(
    'stabilityAfter',
  );
  @override
  late final GeneratedColumn<double> stabilityAfter = GeneratedColumn<double>(
    'stability_after',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intervalDaysMeta = const VerificationMeta(
    'intervalDays',
  );
  @override
  late final GeneratedColumn<int> intervalDays = GeneratedColumn<int>(
    'interval_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueAfterMeta = const VerificationMeta(
    'dueAfter',
  );
  @override
  late final GeneratedColumn<DateTime> dueAfter = GeneratedColumn<DateTime>(
    'due_after',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vocabularyId,
    reviewedAt,
    rating,
    stateBefore,
    stateAfter,
    stabilityBefore,
    stabilityAfter,
    intervalDays,
    dueAfter,
    deviceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'review_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReviewLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('vocabulary_id')) {
      context.handle(
        _vocabularyIdMeta,
        vocabularyId.isAcceptableOrUnknown(
          data['vocabulary_id']!,
          _vocabularyIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_vocabularyIdMeta);
    }
    if (data.containsKey('reviewed_at')) {
      context.handle(
        _reviewedAtMeta,
        reviewedAt.isAcceptableOrUnknown(data['reviewed_at']!, _reviewedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_reviewedAtMeta);
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    } else if (isInserting) {
      context.missing(_ratingMeta);
    }
    if (data.containsKey('state_before')) {
      context.handle(
        _stateBeforeMeta,
        stateBefore.isAcceptableOrUnknown(
          data['state_before']!,
          _stateBeforeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stateBeforeMeta);
    }
    if (data.containsKey('state_after')) {
      context.handle(
        _stateAfterMeta,
        stateAfter.isAcceptableOrUnknown(data['state_after']!, _stateAfterMeta),
      );
    } else if (isInserting) {
      context.missing(_stateAfterMeta);
    }
    if (data.containsKey('stability_before')) {
      context.handle(
        _stabilityBeforeMeta,
        stabilityBefore.isAcceptableOrUnknown(
          data['stability_before']!,
          _stabilityBeforeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stabilityBeforeMeta);
    }
    if (data.containsKey('stability_after')) {
      context.handle(
        _stabilityAfterMeta,
        stabilityAfter.isAcceptableOrUnknown(
          data['stability_after']!,
          _stabilityAfterMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stabilityAfterMeta);
    }
    if (data.containsKey('interval_days')) {
      context.handle(
        _intervalDaysMeta,
        intervalDays.isAcceptableOrUnknown(
          data['interval_days']!,
          _intervalDaysMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_intervalDaysMeta);
    }
    if (data.containsKey('due_after')) {
      context.handle(
        _dueAfterMeta,
        dueAfter.isAcceptableOrUnknown(data['due_after']!, _dueAfterMeta),
      );
    } else if (isInserting) {
      context.missing(_dueAfterMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReviewLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      vocabularyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vocabulary_id'],
      )!,
      reviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reviewed_at'],
      )!,
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      )!,
      stateBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state_before'],
      )!,
      stateAfter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state_after'],
      )!,
      stabilityBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stability_before'],
      )!,
      stabilityAfter: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stability_after'],
      )!,
      intervalDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_days'],
      )!,
      dueAfter: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_after'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
    );
  }

  @override
  $ReviewLogsTable createAlias(String alias) {
    return $ReviewLogsTable(attachedDatabase, alias);
  }
}

class ReviewLog extends DataClass implements Insertable<ReviewLog> {
  final String id;
  final String vocabularyId;
  final DateTime reviewedAt;
  final int rating;
  final String stateBefore;
  final String stateAfter;
  final double stabilityBefore;
  final double stabilityAfter;
  final int intervalDays;
  final DateTime dueAfter;
  final String? deviceId;
  const ReviewLog({
    required this.id,
    required this.vocabularyId,
    required this.reviewedAt,
    required this.rating,
    required this.stateBefore,
    required this.stateAfter,
    required this.stabilityBefore,
    required this.stabilityAfter,
    required this.intervalDays,
    required this.dueAfter,
    this.deviceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['vocabulary_id'] = Variable<String>(vocabularyId);
    map['reviewed_at'] = Variable<DateTime>(reviewedAt);
    map['rating'] = Variable<int>(rating);
    map['state_before'] = Variable<String>(stateBefore);
    map['state_after'] = Variable<String>(stateAfter);
    map['stability_before'] = Variable<double>(stabilityBefore);
    map['stability_after'] = Variable<double>(stabilityAfter);
    map['interval_days'] = Variable<int>(intervalDays);
    map['due_after'] = Variable<DateTime>(dueAfter);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    return map;
  }

  ReviewLogsCompanion toCompanion(bool nullToAbsent) {
    return ReviewLogsCompanion(
      id: Value(id),
      vocabularyId: Value(vocabularyId),
      reviewedAt: Value(reviewedAt),
      rating: Value(rating),
      stateBefore: Value(stateBefore),
      stateAfter: Value(stateAfter),
      stabilityBefore: Value(stabilityBefore),
      stabilityAfter: Value(stabilityAfter),
      intervalDays: Value(intervalDays),
      dueAfter: Value(dueAfter),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
    );
  }

  factory ReviewLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewLog(
      id: serializer.fromJson<String>(json['id']),
      vocabularyId: serializer.fromJson<String>(json['vocabularyId']),
      reviewedAt: serializer.fromJson<DateTime>(json['reviewedAt']),
      rating: serializer.fromJson<int>(json['rating']),
      stateBefore: serializer.fromJson<String>(json['stateBefore']),
      stateAfter: serializer.fromJson<String>(json['stateAfter']),
      stabilityBefore: serializer.fromJson<double>(json['stabilityBefore']),
      stabilityAfter: serializer.fromJson<double>(json['stabilityAfter']),
      intervalDays: serializer.fromJson<int>(json['intervalDays']),
      dueAfter: serializer.fromJson<DateTime>(json['dueAfter']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'vocabularyId': serializer.toJson<String>(vocabularyId),
      'reviewedAt': serializer.toJson<DateTime>(reviewedAt),
      'rating': serializer.toJson<int>(rating),
      'stateBefore': serializer.toJson<String>(stateBefore),
      'stateAfter': serializer.toJson<String>(stateAfter),
      'stabilityBefore': serializer.toJson<double>(stabilityBefore),
      'stabilityAfter': serializer.toJson<double>(stabilityAfter),
      'intervalDays': serializer.toJson<int>(intervalDays),
      'dueAfter': serializer.toJson<DateTime>(dueAfter),
      'deviceId': serializer.toJson<String?>(deviceId),
    };
  }

  ReviewLog copyWith({
    String? id,
    String? vocabularyId,
    DateTime? reviewedAt,
    int? rating,
    String? stateBefore,
    String? stateAfter,
    double? stabilityBefore,
    double? stabilityAfter,
    int? intervalDays,
    DateTime? dueAfter,
    Value<String?> deviceId = const Value.absent(),
  }) => ReviewLog(
    id: id ?? this.id,
    vocabularyId: vocabularyId ?? this.vocabularyId,
    reviewedAt: reviewedAt ?? this.reviewedAt,
    rating: rating ?? this.rating,
    stateBefore: stateBefore ?? this.stateBefore,
    stateAfter: stateAfter ?? this.stateAfter,
    stabilityBefore: stabilityBefore ?? this.stabilityBefore,
    stabilityAfter: stabilityAfter ?? this.stabilityAfter,
    intervalDays: intervalDays ?? this.intervalDays,
    dueAfter: dueAfter ?? this.dueAfter,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
  );
  ReviewLog copyWithCompanion(ReviewLogsCompanion data) {
    return ReviewLog(
      id: data.id.present ? data.id.value : this.id,
      vocabularyId: data.vocabularyId.present
          ? data.vocabularyId.value
          : this.vocabularyId,
      reviewedAt: data.reviewedAt.present
          ? data.reviewedAt.value
          : this.reviewedAt,
      rating: data.rating.present ? data.rating.value : this.rating,
      stateBefore: data.stateBefore.present
          ? data.stateBefore.value
          : this.stateBefore,
      stateAfter: data.stateAfter.present
          ? data.stateAfter.value
          : this.stateAfter,
      stabilityBefore: data.stabilityBefore.present
          ? data.stabilityBefore.value
          : this.stabilityBefore,
      stabilityAfter: data.stabilityAfter.present
          ? data.stabilityAfter.value
          : this.stabilityAfter,
      intervalDays: data.intervalDays.present
          ? data.intervalDays.value
          : this.intervalDays,
      dueAfter: data.dueAfter.present ? data.dueAfter.value : this.dueAfter,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewLog(')
          ..write('id: $id, ')
          ..write('vocabularyId: $vocabularyId, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('rating: $rating, ')
          ..write('stateBefore: $stateBefore, ')
          ..write('stateAfter: $stateAfter, ')
          ..write('stabilityBefore: $stabilityBefore, ')
          ..write('stabilityAfter: $stabilityAfter, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('dueAfter: $dueAfter, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    vocabularyId,
    reviewedAt,
    rating,
    stateBefore,
    stateAfter,
    stabilityBefore,
    stabilityAfter,
    intervalDays,
    dueAfter,
    deviceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewLog &&
          other.id == this.id &&
          other.vocabularyId == this.vocabularyId &&
          other.reviewedAt == this.reviewedAt &&
          other.rating == this.rating &&
          other.stateBefore == this.stateBefore &&
          other.stateAfter == this.stateAfter &&
          other.stabilityBefore == this.stabilityBefore &&
          other.stabilityAfter == this.stabilityAfter &&
          other.intervalDays == this.intervalDays &&
          other.dueAfter == this.dueAfter &&
          other.deviceId == this.deviceId);
}

class ReviewLogsCompanion extends UpdateCompanion<ReviewLog> {
  final Value<String> id;
  final Value<String> vocabularyId;
  final Value<DateTime> reviewedAt;
  final Value<int> rating;
  final Value<String> stateBefore;
  final Value<String> stateAfter;
  final Value<double> stabilityBefore;
  final Value<double> stabilityAfter;
  final Value<int> intervalDays;
  final Value<DateTime> dueAfter;
  final Value<String?> deviceId;
  final Value<int> rowid;
  const ReviewLogsCompanion({
    this.id = const Value.absent(),
    this.vocabularyId = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    this.rating = const Value.absent(),
    this.stateBefore = const Value.absent(),
    this.stateAfter = const Value.absent(),
    this.stabilityBefore = const Value.absent(),
    this.stabilityAfter = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.dueAfter = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReviewLogsCompanion.insert({
    required String id,
    required String vocabularyId,
    required DateTime reviewedAt,
    required int rating,
    required String stateBefore,
    required String stateAfter,
    required double stabilityBefore,
    required double stabilityAfter,
    required int intervalDays,
    required DateTime dueAfter,
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       vocabularyId = Value(vocabularyId),
       reviewedAt = Value(reviewedAt),
       rating = Value(rating),
       stateBefore = Value(stateBefore),
       stateAfter = Value(stateAfter),
       stabilityBefore = Value(stabilityBefore),
       stabilityAfter = Value(stabilityAfter),
       intervalDays = Value(intervalDays),
       dueAfter = Value(dueAfter);
  static Insertable<ReviewLog> custom({
    Expression<String>? id,
    Expression<String>? vocabularyId,
    Expression<DateTime>? reviewedAt,
    Expression<int>? rating,
    Expression<String>? stateBefore,
    Expression<String>? stateAfter,
    Expression<double>? stabilityBefore,
    Expression<double>? stabilityAfter,
    Expression<int>? intervalDays,
    Expression<DateTime>? dueAfter,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vocabularyId != null) 'vocabulary_id': vocabularyId,
      if (reviewedAt != null) 'reviewed_at': reviewedAt,
      if (rating != null) 'rating': rating,
      if (stateBefore != null) 'state_before': stateBefore,
      if (stateAfter != null) 'state_after': stateAfter,
      if (stabilityBefore != null) 'stability_before': stabilityBefore,
      if (stabilityAfter != null) 'stability_after': stabilityAfter,
      if (intervalDays != null) 'interval_days': intervalDays,
      if (dueAfter != null) 'due_after': dueAfter,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReviewLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? vocabularyId,
    Value<DateTime>? reviewedAt,
    Value<int>? rating,
    Value<String>? stateBefore,
    Value<String>? stateAfter,
    Value<double>? stabilityBefore,
    Value<double>? stabilityAfter,
    Value<int>? intervalDays,
    Value<DateTime>? dueAfter,
    Value<String?>? deviceId,
    Value<int>? rowid,
  }) {
    return ReviewLogsCompanion(
      id: id ?? this.id,
      vocabularyId: vocabularyId ?? this.vocabularyId,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      rating: rating ?? this.rating,
      stateBefore: stateBefore ?? this.stateBefore,
      stateAfter: stateAfter ?? this.stateAfter,
      stabilityBefore: stabilityBefore ?? this.stabilityBefore,
      stabilityAfter: stabilityAfter ?? this.stabilityAfter,
      intervalDays: intervalDays ?? this.intervalDays,
      dueAfter: dueAfter ?? this.dueAfter,
      deviceId: deviceId ?? this.deviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (vocabularyId.present) {
      map['vocabulary_id'] = Variable<String>(vocabularyId.value);
    }
    if (reviewedAt.present) {
      map['reviewed_at'] = Variable<DateTime>(reviewedAt.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (stateBefore.present) {
      map['state_before'] = Variable<String>(stateBefore.value);
    }
    if (stateAfter.present) {
      map['state_after'] = Variable<String>(stateAfter.value);
    }
    if (stabilityBefore.present) {
      map['stability_before'] = Variable<double>(stabilityBefore.value);
    }
    if (stabilityAfter.present) {
      map['stability_after'] = Variable<double>(stabilityAfter.value);
    }
    if (intervalDays.present) {
      map['interval_days'] = Variable<int>(intervalDays.value);
    }
    if (dueAfter.present) {
      map['due_after'] = Variable<DateTime>(dueAfter.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewLogsCompanion(')
          ..write('id: $id, ')
          ..write('vocabularyId: $vocabularyId, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('rating: $rating, ')
          ..write('stateBefore: $stateBefore, ')
          ..write('stateAfter: $stateAfter, ')
          ..write('stabilityBefore: $stabilityBefore, ')
          ..write('stabilityAfter: $stabilityAfter, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('dueAfter: $dueAfter, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const AppSetting({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSetting copyWith({String? key, String? value, DateTime? updatedAt}) =>
      AppSetting(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppMetadataTable extends AppMetadata
    with TableInfo<$AppMetadataTable, AppMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppMetadataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppMetadataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppMetadataData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppMetadataTable createAlias(String alias) {
    return $AppMetadataTable(attachedDatabase, alias);
  }
}

class AppMetadataData extends DataClass implements Insertable<AppMetadataData> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const AppMetadataData({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppMetadataCompanion toCompanion(bool nullToAbsent) {
    return AppMetadataCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppMetadataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppMetadataData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppMetadataData copyWith({String? key, String? value, DateTime? updatedAt}) =>
      AppMetadataData(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AppMetadataData copyWithCompanion(AppMetadataCompanion data) {
    return AppMetadataData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppMetadataData(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppMetadataData &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class AppMetadataCompanion extends UpdateCompanion<AppMetadataData> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppMetadataCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppMetadataCompanion.insert({
    required String key,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<AppMetadataData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppMetadataCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppMetadataCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppMetadataCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncMetadataTable extends SyncMetadata
    with TableInfo<$SyncMetadataTable, SyncMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>(
        'local_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncedVersionMeta = const VerificationMeta(
    'lastSyncedVersion',
  );
  @override
  late final GeneratedColumn<int> lastSyncedVersion = GeneratedColumn<int>(
    'last_synced_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    entityId,
    localUpdatedAt,
    lastSyncedAt,
    lastSyncedVersion,
    syncStatus,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetadataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_synced_version')) {
      context.handle(
        _lastSyncedVersionMeta,
        lastSyncedVersion.isAcceptableOrUnknown(
          data['last_synced_version']!,
          _lastSyncedVersionMeta,
        ),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {entityType, entityId},
  ];
  @override
  SyncMetadataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetadataData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}local_updated_at'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      lastSyncedVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_synced_version'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $SyncMetadataTable createAlias(String alias) {
    return $SyncMetadataTable(attachedDatabase, alias);
  }
}

class SyncMetadataData extends DataClass
    implements Insertable<SyncMetadataData> {
  final String id;
  final String entityType;
  final String entityId;
  final DateTime localUpdatedAt;
  final DateTime? lastSyncedAt;
  final int? lastSyncedVersion;
  final String syncStatus;
  final DateTime? deletedAt;
  const SyncMetadataData({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.localUpdatedAt,
    this.lastSyncedAt,
    this.lastSyncedVersion,
    required this.syncStatus,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    if (!nullToAbsent || lastSyncedVersion != null) {
      map['last_synced_version'] = Variable<int>(lastSyncedVersion);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  SyncMetadataCompanion toCompanion(bool nullToAbsent) {
    return SyncMetadataCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      localUpdatedAt: Value(localUpdatedAt),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      lastSyncedVersion: lastSyncedVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedVersion),
      syncStatus: Value(syncStatus),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory SyncMetadataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetadataData(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      lastSyncedVersion: serializer.fromJson<int?>(json['lastSyncedVersion']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'lastSyncedVersion': serializer.toJson<int?>(lastSyncedVersion),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  SyncMetadataData copyWith({
    String? id,
    String? entityType,
    String? entityId,
    DateTime? localUpdatedAt,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    Value<int?> lastSyncedVersion = const Value.absent(),
    String? syncStatus,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => SyncMetadataData(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    lastSyncedVersion: lastSyncedVersion.present
        ? lastSyncedVersion.value
        : this.lastSyncedVersion,
    syncStatus: syncStatus ?? this.syncStatus,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  SyncMetadataData copyWithCompanion(SyncMetadataCompanion data) {
    return SyncMetadataData(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      lastSyncedVersion: data.lastSyncedVersion.present
          ? data.lastSyncedVersion.value
          : this.lastSyncedVersion,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataData(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('lastSyncedVersion: $lastSyncedVersion, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityType,
    entityId,
    localUpdatedAt,
    lastSyncedAt,
    lastSyncedVersion,
    syncStatus,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetadataData &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.lastSyncedVersion == this.lastSyncedVersion &&
          other.syncStatus == this.syncStatus &&
          other.deletedAt == this.deletedAt);
}

class SyncMetadataCompanion extends UpdateCompanion<SyncMetadataData> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<DateTime> localUpdatedAt;
  final Value<DateTime?> lastSyncedAt;
  final Value<int?> lastSyncedVersion;
  final Value<String> syncStatus;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const SyncMetadataCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.lastSyncedVersion = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetadataCompanion.insert({
    required String id,
    required String entityType,
    required String entityId,
    required DateTime localUpdatedAt,
    this.lastSyncedAt = const Value.absent(),
    this.lastSyncedVersion = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entityType = Value(entityType),
       entityId = Value(entityId),
       localUpdatedAt = Value(localUpdatedAt);
  static Insertable<SyncMetadataData> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<DateTime>? localUpdatedAt,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? lastSyncedVersion,
    Expression<String>? syncStatus,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (lastSyncedVersion != null) 'last_synced_version': lastSyncedVersion,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMetadataCompanion copyWith({
    Value<String>? id,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<DateTime>? localUpdatedAt,
    Value<DateTime?>? lastSyncedAt,
    Value<int?>? lastSyncedVersion,
    Value<String>? syncStatus,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return SyncMetadataCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      lastSyncedVersion: lastSyncedVersion ?? this.lastSyncedVersion,
      syncStatus: syncStatus ?? this.syncStatus,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (lastSyncedVersion.present) {
      map['last_synced_version'] = Variable<int>(lastSyncedVersion.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('lastSyncedVersion: $lastSyncedVersion, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BooksTable books = $BooksTable(this);
  late final $BookGroupsTable bookGroups = $BookGroupsTable(this);
  late final $BookGroupBooksTable bookGroupBooks = $BookGroupBooksTable(this);
  late final $DictionariesTable dictionaries = $DictionariesTable(this);
  late final $DictionaryEntriesTable dictionaryEntries =
      $DictionaryEntriesTable(this);
  late final $ChaptersTable chapters = $ChaptersTable(this);
  late final $ReadingProgressTable readingProgress = $ReadingProgressTable(
    this,
  );
  late final $PaginationCachesTable paginationCaches = $PaginationCachesTable(
    this,
  );
  late final $VocabularyTable vocabulary = $VocabularyTable(this);
  late final $WordFormsTable wordForms = $WordFormsTable(this);
  late final $WordOccurrencesTable wordOccurrences = $WordOccurrencesTable(
    this,
  );
  late final $WordStatusesTable wordStatuses = $WordStatusesTable(this);
  late final $DefinitionsTable definitions = $DefinitionsTable(this);
  late final $FsrsCardsTable fsrsCards = $FsrsCardsTable(this);
  late final $ReviewLogsTable reviewLogs = $ReviewLogsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $AppMetadataTable appMetadata = $AppMetadataTable(this);
  late final $SyncMetadataTable syncMetadata = $SyncMetadataTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    books,
    bookGroups,
    bookGroupBooks,
    dictionaries,
    dictionaryEntries,
    chapters,
    readingProgress,
    paginationCaches,
    vocabulary,
    wordForms,
    wordOccurrences,
    wordStatuses,
    definitions,
    fsrsCards,
    reviewLogs,
    appSettings,
    appMetadata,
    syncMetadata,
  ];
}

typedef $$BooksTableCreateCompanionBuilder = BooksCompanion Function({
  required String id,
  required String title,
  Value<String?> author,
  Value<String?> description,
  Value<String?> coverPath,
  required String originalFilePath,
  required String format,
  Value<String> language,
  Value<String?> fileSha256,
  Value<int> revision,
  Value<String?> updatedBy,
  required DateTime importedAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$BooksTableUpdateCompanionBuilder = BooksCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String?> author,
  Value<String?> description,
  Value<String?> coverPath,
  Value<String> originalFilePath,
  Value<String> format,
  Value<String> language,
  Value<String?> fileSha256,
  Value<int> revision,
  Value<String?> updatedBy,
  Value<DateTime> importedAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

final class $$BooksTableReferences
    extends BaseReferences<_$AppDatabase, $BooksTable, Book> {
  $$BooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BookGroupBooksTable, List<BookGroupBook>>
  _bookGroupBooksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.bookGroupBooks,
    aliasName: 'books__id__book_group_books__book_id',
  );

  $$BookGroupBooksTableProcessedTableManager get bookGroupBooksRefs {
    final manager = $$BookGroupBooksTableTableManager(
      $_db,
      $_db.bookGroupBooks,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookGroupBooksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ChaptersTable, List<Chapter>> _chaptersRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.chapters,
    aliasName: 'books__id__chapters__book_id',
  );

  $$ChaptersTableProcessedTableManager get chaptersRefs {
    final manager = $$ChaptersTableTableManager(
      $_db,
      $_db.chapters,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_chaptersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReadingProgressTable, List<ReadingProgressData>>
  _readingProgressRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.readingProgress,
    aliasName: 'books__id__reading_progress__book_id',
  );

  $$ReadingProgressTableProcessedTableManager get readingProgressRefs {
    final manager = $$ReadingProgressTableTableManager(
      $_db,
      $_db.readingProgress,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _readingProgressRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WordOccurrencesTable, List<WordOccurrence>>
  _wordOccurrencesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.wordOccurrences,
    aliasName: 'books__id__word_occurrences__book_id',
  );

  $$WordOccurrencesTableProcessedTableManager get wordOccurrencesRefs {
    final manager = $$WordOccurrencesTableTableManager(
      $_db,
      $_db.wordOccurrences,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _wordOccurrencesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BooksTableFilterComposer extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverPath => $composableBuilder(
    column: $table.coverPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalFilePath => $composableBuilder(
    column: $table.originalFilePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileSha256 => $composableBuilder(
    column: $table.fileSha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> bookGroupBooksRefs(
    Expression<bool> Function($$BookGroupBooksTableFilterComposer f) f,
  ) {
    final $$BookGroupBooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookGroupBooks,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookGroupBooksTableFilterComposer(
            $db: $db,
            $table: $db.bookGroupBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> chaptersRefs(
    Expression<bool> Function($$ChaptersTableFilterComposer f) f,
  ) {
    final $$ChaptersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chapters,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChaptersTableFilterComposer(
            $db: $db,
            $table: $db.chapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> readingProgressRefs(
    Expression<bool> Function($$ReadingProgressTableFilterComposer f) f,
  ) {
    final $$ReadingProgressTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readingProgress,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingProgressTableFilterComposer(
            $db: $db,
            $table: $db.readingProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> wordOccurrencesRefs(
    Expression<bool> Function($$WordOccurrencesTableFilterComposer f) f,
  ) {
    final $$WordOccurrencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordOccurrences,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordOccurrencesTableFilterComposer(
            $db: $db,
            $table: $db.wordOccurrences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BooksTableOrderingComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverPath => $composableBuilder(
    column: $table.coverPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalFilePath => $composableBuilder(
    column: $table.originalFilePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileSha256 => $composableBuilder(
    column: $table.fileSha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverPath =>
      $composableBuilder(column: $table.coverPath, builder: (column) => column);

  GeneratedColumn<String> get originalFilePath => $composableBuilder(
    column: $table.originalFilePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get fileSha256 => $composableBuilder(
    column: $table.fileSha256,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> bookGroupBooksRefs<T extends Object>(
    Expression<T> Function($$BookGroupBooksTableAnnotationComposer a) f,
  ) {
    final $$BookGroupBooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookGroupBooks,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookGroupBooksTableAnnotationComposer(
            $db: $db,
            $table: $db.bookGroupBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> chaptersRefs<T extends Object>(
    Expression<T> Function($$ChaptersTableAnnotationComposer a) f,
  ) {
    final $$ChaptersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chapters,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChaptersTableAnnotationComposer(
            $db: $db,
            $table: $db.chapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> readingProgressRefs<T extends Object>(
    Expression<T> Function($$ReadingProgressTableAnnotationComposer a) f,
  ) {
    final $$ReadingProgressTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readingProgress,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingProgressTableAnnotationComposer(
            $db: $db,
            $table: $db.readingProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> wordOccurrencesRefs<T extends Object>(
    Expression<T> Function($$WordOccurrencesTableAnnotationComposer a) f,
  ) {
    final $$WordOccurrencesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordOccurrences,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordOccurrencesTableAnnotationComposer(
            $db: $db,
            $table: $db.wordOccurrences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BooksTable,
          Book,
          $$BooksTableFilterComposer,
          $$BooksTableOrderingComposer,
          $$BooksTableAnnotationComposer,
          $$BooksTableCreateCompanionBuilder,
          $$BooksTableUpdateCompanionBuilder,
          (Book, $$BooksTableReferences),
          Book,
          PrefetchHooks Function({
            bool bookGroupBooksRefs,
            bool chaptersRefs,
            bool readingProgressRefs,
            bool wordOccurrencesRefs,
          })
        > {
  $$BooksTableTableManager(_$AppDatabase db, $BooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> author = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> coverPath = const Value.absent(),
                Value<String> originalFilePath = const Value.absent(),
                Value<String> format = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<String?> fileSha256 = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<DateTime> importedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BooksCompanion(
                id: id,
                title: title,
                author: author,
                description: description,
                coverPath: coverPath,
                originalFilePath: originalFilePath,
                format: format,
                language: language,
                fileSha256: fileSha256,
                revision: revision,
                updatedBy: updatedBy,
                importedAt: importedAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> author = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> coverPath = const Value.absent(),
                required String originalFilePath,
                required String format,
                Value<String> language = const Value.absent(),
                Value<String?> fileSha256 = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                required DateTime importedAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BooksCompanion.insert(
                id: id,
                title: title,
                author: author,
                description: description,
                coverPath: coverPath,
                originalFilePath: originalFilePath,
                format: format,
                language: language,
                fileSha256: fileSha256,
                revision: revision,
                updatedBy: updatedBy,
                importedAt: importedAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BooksTable, Book>(table),
                  $$BooksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                bookGroupBooksRefs = false,
                chaptersRefs = false,
                readingProgressRefs = false,
                wordOccurrencesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (bookGroupBooksRefs) db.bookGroupBooks,
                    if (chaptersRefs) db.chapters,
                    if (readingProgressRefs) db.readingProgress,
                    if (wordOccurrencesRefs) db.wordOccurrences,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (bookGroupBooksRefs)
                        await $_getPrefetchedDataByColumns<
                          Book,
                          $BooksTable,
                          BookGroupBook,
                          $BookGroupBooksTable
                        >(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._bookGroupBooksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(
                                db,
                                table,
                                p0,
                              ).bookGroupBooksRefs,
                          currentColumn: 'id',
                          referencedColumn: 'book_id',
                          typedResults: items,
                        ),
                      if (chaptersRefs)
                        await $_getPrefetchedDataByColumns<
                          Book,
                          $BooksTable,
                          Chapter,
                          $ChaptersTable
                        >(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._chaptersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(
                                db,
                                table,
                                p0,
                              ).chaptersRefs,
                          currentColumn: 'id',
                          referencedColumn: 'book_id',
                          typedResults: items,
                        ),
                      if (readingProgressRefs)
                        await $_getPrefetchedDataByColumns<
                          Book,
                          $BooksTable,
                          ReadingProgressData,
                          $ReadingProgressTable
                        >(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._readingProgressRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(
                                db,
                                table,
                                p0,
                              ).readingProgressRefs,
                          currentColumn: 'id',
                          referencedColumn: 'book_id',
                          typedResults: items,
                        ),
                      if (wordOccurrencesRefs)
                        await $_getPrefetchedDataByColumns<
                          Book,
                          $BooksTable,
                          WordOccurrence,
                          $WordOccurrencesTable
                        >(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._wordOccurrencesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(
                                db,
                                table,
                                p0,
                              ).wordOccurrencesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'book_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$BooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BooksTable,
      Book,
      $$BooksTableFilterComposer,
      $$BooksTableOrderingComposer,
      $$BooksTableAnnotationComposer,
      $$BooksTableCreateCompanionBuilder,
      $$BooksTableUpdateCompanionBuilder,
      (Book, $$BooksTableReferences),
      Book,
      PrefetchHooks Function({
        bool bookGroupBooksRefs,
        bool chaptersRefs,
        bool readingProgressRefs,
        bool wordOccurrencesRefs,
      })
    >;
typedef $$BookGroupsTableCreateCompanionBuilder = BookGroupsCompanion Function({
  required String id,
  required String name,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$BookGroupsTableUpdateCompanionBuilder = BookGroupsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$BookGroupsTableReferences
    extends BaseReferences<_$AppDatabase, $BookGroupsTable, BookGroup> {
  $$BookGroupsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BookGroupBooksTable, List<BookGroupBook>>
  _bookGroupBooksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.bookGroupBooks,
    aliasName: 'book_groups__id__book_group_books__group_id',
  );

  $$BookGroupBooksTableProcessedTableManager get bookGroupBooksRefs {
    final manager = $$BookGroupBooksTableTableManager(
      $_db,
      $_db.bookGroupBooks,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookGroupBooksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BookGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $BookGroupsTable> {
  $$BookGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> bookGroupBooksRefs(
    Expression<bool> Function($$BookGroupBooksTableFilterComposer f) f,
  ) {
    final $$BookGroupBooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookGroupBooks,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookGroupBooksTableFilterComposer(
            $db: $db,
            $table: $db.bookGroupBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BookGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $BookGroupsTable> {
  $$BookGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BookGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookGroupsTable> {
  $$BookGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> bookGroupBooksRefs<T extends Object>(
    Expression<T> Function($$BookGroupBooksTableAnnotationComposer a) f,
  ) {
    final $$BookGroupBooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookGroupBooks,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookGroupBooksTableAnnotationComposer(
            $db: $db,
            $table: $db.bookGroupBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BookGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookGroupsTable,
          BookGroup,
          $$BookGroupsTableFilterComposer,
          $$BookGroupsTableOrderingComposer,
          $$BookGroupsTableAnnotationComposer,
          $$BookGroupsTableCreateCompanionBuilder,
          $$BookGroupsTableUpdateCompanionBuilder,
          (BookGroup, $$BookGroupsTableReferences),
          BookGroup,
          PrefetchHooks Function({bool bookGroupBooksRefs})
        > {
  $$BookGroupsTableTableManager(_$AppDatabase db, $BookGroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookGroupsCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => BookGroupsCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BookGroupsTable, BookGroup>(table),
                  $$BookGroupsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookGroupBooksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (bookGroupBooksRefs) db.bookGroupBooks,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (bookGroupBooksRefs)
                    await $_getPrefetchedDataByColumns<
                      BookGroup,
                      $BookGroupsTable,
                      BookGroupBook,
                      $BookGroupBooksTable
                    >(
                      currentTable: table,
                      referencedTable: $$BookGroupsTableReferences
                          ._bookGroupBooksRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$BookGroupsTableReferences(
                            db,
                            table,
                            p0,
                          ).bookGroupBooksRefs,
                      currentColumn: 'id',
                      referencedColumn: 'group_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$BookGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookGroupsTable,
      BookGroup,
      $$BookGroupsTableFilterComposer,
      $$BookGroupsTableOrderingComposer,
      $$BookGroupsTableAnnotationComposer,
      $$BookGroupsTableCreateCompanionBuilder,
      $$BookGroupsTableUpdateCompanionBuilder,
      (BookGroup, $$BookGroupsTableReferences),
      BookGroup,
      PrefetchHooks Function({bool bookGroupBooksRefs})
    >;
typedef $$BookGroupBooksTableCreateCompanionBuilder =
    BookGroupBooksCompanion Function({
      required String groupId,
      required String bookId,
      required DateTime addedAt,
      Value<int> rowid,
    });
typedef $$BookGroupBooksTableUpdateCompanionBuilder =
    BookGroupBooksCompanion Function({
      Value<String> groupId,
      Value<String> bookId,
      Value<DateTime> addedAt,
      Value<int> rowid,
    });

final class $$BookGroupBooksTableReferences
    extends BaseReferences<_$AppDatabase, $BookGroupBooksTable, BookGroupBook> {
  $$BookGroupBooksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BookGroupsTable _groupIdTable(_$AppDatabase db) =>
      db.bookGroups.createAlias('book_group_books__group_id__book_groups__id');

  $$BookGroupsTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<String>('group_id')!;

    final manager = $$BookGroupsTableTableManager(
      $_db,
      $_db.bookGroups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $BooksTable _bookIdTable(_$AppDatabase db) =>
      db.books.createAlias('book_group_books__book_id__books__id');

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<String>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BookGroupBooksTableFilterComposer
    extends Composer<_$AppDatabase, $BookGroupBooksTable> {
  $$BookGroupBooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BookGroupsTableFilterComposer get groupId {
    final $$BookGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.bookGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookGroupsTableFilterComposer(
            $db: $db,
            $table: $db.bookGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookGroupBooksTableOrderingComposer
    extends Composer<_$AppDatabase, $BookGroupBooksTable> {
  $$BookGroupBooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BookGroupsTableOrderingComposer get groupId {
    final $$BookGroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.bookGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookGroupsTableOrderingComposer(
            $db: $db,
            $table: $db.bookGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookGroupBooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookGroupBooksTable> {
  $$BookGroupBooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  $$BookGroupsTableAnnotationComposer get groupId {
    final $$BookGroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.bookGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookGroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.bookGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookGroupBooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookGroupBooksTable,
          BookGroupBook,
          $$BookGroupBooksTableFilterComposer,
          $$BookGroupBooksTableOrderingComposer,
          $$BookGroupBooksTableAnnotationComposer,
          $$BookGroupBooksTableCreateCompanionBuilder,
          $$BookGroupBooksTableUpdateCompanionBuilder,
          (BookGroupBook, $$BookGroupBooksTableReferences),
          BookGroupBook,
          PrefetchHooks Function({bool groupId, bool bookId})
        > {
  $$BookGroupBooksTableTableManager(
    _$AppDatabase db,
    $BookGroupBooksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookGroupBooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookGroupBooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookGroupBooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> groupId = const Value.absent(),
                Value<String> bookId = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookGroupBooksCompanion(
                groupId: groupId,
                bookId: bookId,
                addedAt: addedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String groupId,
                required String bookId,
                required DateTime addedAt,
                Value<int> rowid = const Value.absent(),
              }) => BookGroupBooksCompanion.insert(
                groupId: groupId,
                bookId: bookId,
                addedAt: addedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BookGroupBooksTable, BookGroupBook>(table),
                  $$BookGroupBooksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({groupId = false, bookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (groupId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.groupId,
                        referencedTable: $$BookGroupBooksTableReferences
                            ._groupIdTable(db),
                        referencedColumn: $$BookGroupBooksTableReferences
                            ._groupIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (bookId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.bookId,
                        referencedTable: $$BookGroupBooksTableReferences
                            ._bookIdTable(db),
                        referencedColumn: $$BookGroupBooksTableReferences
                            ._bookIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BookGroupBooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookGroupBooksTable,
      BookGroupBook,
      $$BookGroupBooksTableFilterComposer,
      $$BookGroupBooksTableOrderingComposer,
      $$BookGroupBooksTableAnnotationComposer,
      $$BookGroupBooksTableCreateCompanionBuilder,
      $$BookGroupBooksTableUpdateCompanionBuilder,
      (BookGroupBook, $$BookGroupBooksTableReferences),
      BookGroupBook,
      PrefetchHooks Function({bool groupId, bool bookId})
    >;
typedef $$DictionariesTableCreateCompanionBuilder =
    DictionariesCompanion Function({
      required String id,
      required String name,
      required String kind,
      Value<String?> source,
      Value<bool> enabled,
      Value<int> entryCount,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$DictionariesTableUpdateCompanionBuilder =
    DictionariesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> kind,
      Value<String?> source,
      Value<bool> enabled,
      Value<int> entryCount,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$DictionariesTableReferences
    extends BaseReferences<_$AppDatabase, $DictionariesTable, Dictionary> {
  $$DictionariesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DictionaryEntriesTable, List<DictionaryEntry>>
  _dictionaryEntriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.dictionaryEntries,
        aliasName: 'dictionaries__id__dictionary_entries__dictionary_id',
      );

  $$DictionaryEntriesTableProcessedTableManager get dictionaryEntriesRefs {
    final manager = $$DictionaryEntriesTableTableManager(
      $_db,
      $_db.dictionaryEntries,
    ).filter((f) => f.dictionaryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _dictionaryEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DictionariesTableFilterComposer
    extends Composer<_$AppDatabase, $DictionariesTable> {
  $$DictionariesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get entryCount => $composableBuilder(
    column: $table.entryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> dictionaryEntriesRefs(
    Expression<bool> Function($$DictionaryEntriesTableFilterComposer f) f,
  ) {
    final $$DictionaryEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dictionaryEntries,
      getReferencedColumn: (t) => t.dictionaryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DictionaryEntriesTableFilterComposer(
            $db: $db,
            $table: $db.dictionaryEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DictionariesTableOrderingComposer
    extends Composer<_$AppDatabase, $DictionariesTable> {
  $$DictionariesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get entryCount => $composableBuilder(
    column: $table.entryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DictionariesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DictionariesTable> {
  $$DictionariesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<int> get entryCount => $composableBuilder(
    column: $table.entryCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> dictionaryEntriesRefs<T extends Object>(
    Expression<T> Function($$DictionaryEntriesTableAnnotationComposer a) f,
  ) {
    final $$DictionaryEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.dictionaryEntries,
          getReferencedColumn: (t) => t.dictionaryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DictionaryEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.dictionaryEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$DictionariesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DictionariesTable,
          Dictionary,
          $$DictionariesTableFilterComposer,
          $$DictionariesTableOrderingComposer,
          $$DictionariesTableAnnotationComposer,
          $$DictionariesTableCreateCompanionBuilder,
          $$DictionariesTableUpdateCompanionBuilder,
          (Dictionary, $$DictionariesTableReferences),
          Dictionary,
          PrefetchHooks Function({bool dictionaryEntriesRefs})
        > {
  $$DictionariesTableTableManager(_$AppDatabase db, $DictionariesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DictionariesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DictionariesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DictionariesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> entryCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DictionariesCompanion(
                id: id,
                name: name,
                kind: kind,
                source: source,
                enabled: enabled,
                entryCount: entryCount,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String kind,
                Value<String?> source = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> entryCount = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => DictionariesCompanion.insert(
                id: id,
                name: name,
                kind: kind,
                source: source,
                enabled: enabled,
                entryCount: entryCount,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DictionariesTable, Dictionary>(table),
                  $$DictionariesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({dictionaryEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (dictionaryEntriesRefs) db.dictionaryEntries,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (dictionaryEntriesRefs)
                    await $_getPrefetchedDataByColumns<
                      Dictionary,
                      $DictionariesTable,
                      DictionaryEntry,
                      $DictionaryEntriesTable
                    >(
                      currentTable: table,
                      referencedTable: $$DictionariesTableReferences
                          ._dictionaryEntriesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$DictionariesTableReferences(
                            db,
                            table,
                            p0,
                          ).dictionaryEntriesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'dictionary_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$DictionariesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DictionariesTable,
      Dictionary,
      $$DictionariesTableFilterComposer,
      $$DictionariesTableOrderingComposer,
      $$DictionariesTableAnnotationComposer,
      $$DictionariesTableCreateCompanionBuilder,
      $$DictionariesTableUpdateCompanionBuilder,
      (Dictionary, $$DictionariesTableReferences),
      Dictionary,
      PrefetchHooks Function({bool dictionaryEntriesRefs})
    >;
typedef $$DictionaryEntriesTableCreateCompanionBuilder =
    DictionaryEntriesCompanion Function({
      Value<int> id,
      required String dictionaryId,
      required String lemma,
      Value<String> partOfSpeech,
      required String meaning,
      Value<String?> example,
    });
typedef $$DictionaryEntriesTableUpdateCompanionBuilder =
    DictionaryEntriesCompanion Function({
      Value<int> id,
      Value<String> dictionaryId,
      Value<String> lemma,
      Value<String> partOfSpeech,
      Value<String> meaning,
      Value<String?> example,
    });

final class $$DictionaryEntriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $DictionaryEntriesTable,
          DictionaryEntry
        > {
  $$DictionaryEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DictionariesTable _dictionaryIdTable(_$AppDatabase db) => db
      .dictionaries
      .createAlias('dictionary_entries__dictionary_id__dictionaries__id');

  $$DictionariesTableProcessedTableManager get dictionaryId {
    final $_column = $_itemColumn<String>('dictionary_id')!;

    final manager = $$DictionariesTableTableManager(
      $_db,
      $_db.dictionaries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dictionaryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DictionaryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $DictionaryEntriesTable> {
  $$DictionaryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lemma => $composableBuilder(
    column: $table.lemma,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partOfSpeech => $composableBuilder(
    column: $table.partOfSpeech,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get example => $composableBuilder(
    column: $table.example,
    builder: (column) => ColumnFilters(column),
  );

  $$DictionariesTableFilterComposer get dictionaryId {
    final $$DictionariesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dictionaryId,
      referencedTable: $db.dictionaries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DictionariesTableFilterComposer(
            $db: $db,
            $table: $db.dictionaries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DictionaryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DictionaryEntriesTable> {
  $$DictionaryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lemma => $composableBuilder(
    column: $table.lemma,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partOfSpeech => $composableBuilder(
    column: $table.partOfSpeech,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get example => $composableBuilder(
    column: $table.example,
    builder: (column) => ColumnOrderings(column),
  );

  $$DictionariesTableOrderingComposer get dictionaryId {
    final $$DictionariesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dictionaryId,
      referencedTable: $db.dictionaries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DictionariesTableOrderingComposer(
            $db: $db,
            $table: $db.dictionaries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DictionaryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DictionaryEntriesTable> {
  $$DictionaryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get lemma =>
      $composableBuilder(column: $table.lemma, builder: (column) => column);

  GeneratedColumn<String> get partOfSpeech => $composableBuilder(
    column: $table.partOfSpeech,
    builder: (column) => column,
  );

  GeneratedColumn<String> get meaning =>
      $composableBuilder(column: $table.meaning, builder: (column) => column);

  GeneratedColumn<String> get example =>
      $composableBuilder(column: $table.example, builder: (column) => column);

  $$DictionariesTableAnnotationComposer get dictionaryId {
    final $$DictionariesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dictionaryId,
      referencedTable: $db.dictionaries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DictionariesTableAnnotationComposer(
            $db: $db,
            $table: $db.dictionaries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DictionaryEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DictionaryEntriesTable,
          DictionaryEntry,
          $$DictionaryEntriesTableFilterComposer,
          $$DictionaryEntriesTableOrderingComposer,
          $$DictionaryEntriesTableAnnotationComposer,
          $$DictionaryEntriesTableCreateCompanionBuilder,
          $$DictionaryEntriesTableUpdateCompanionBuilder,
          (DictionaryEntry, $$DictionaryEntriesTableReferences),
          DictionaryEntry,
          PrefetchHooks Function({bool dictionaryId})
        > {
  $$DictionaryEntriesTableTableManager(
    _$AppDatabase db,
    $DictionaryEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DictionaryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DictionaryEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DictionaryEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> dictionaryId = const Value.absent(),
                Value<String> lemma = const Value.absent(),
                Value<String> partOfSpeech = const Value.absent(),
                Value<String> meaning = const Value.absent(),
                Value<String?> example = const Value.absent(),
              }) => DictionaryEntriesCompanion(
                id: id,
                dictionaryId: dictionaryId,
                lemma: lemma,
                partOfSpeech: partOfSpeech,
                meaning: meaning,
                example: example,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String dictionaryId,
                required String lemma,
                Value<String> partOfSpeech = const Value.absent(),
                required String meaning,
                Value<String?> example = const Value.absent(),
              }) => DictionaryEntriesCompanion.insert(
                id: id,
                dictionaryId: dictionaryId,
                lemma: lemma,
                partOfSpeech: partOfSpeech,
                meaning: meaning,
                example: example,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DictionaryEntriesTable, DictionaryEntry>(table),
                  $$DictionaryEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({dictionaryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (dictionaryId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.dictionaryId,
                        referencedTable: $$DictionaryEntriesTableReferences
                            ._dictionaryIdTable(db),
                        referencedColumn: $$DictionaryEntriesTableReferences
                            ._dictionaryIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DictionaryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DictionaryEntriesTable,
      DictionaryEntry,
      $$DictionaryEntriesTableFilterComposer,
      $$DictionaryEntriesTableOrderingComposer,
      $$DictionaryEntriesTableAnnotationComposer,
      $$DictionaryEntriesTableCreateCompanionBuilder,
      $$DictionaryEntriesTableUpdateCompanionBuilder,
      (DictionaryEntry, $$DictionaryEntriesTableReferences),
      DictionaryEntry,
      PrefetchHooks Function({bool dictionaryId})
    >;
typedef $$ChaptersTableCreateCompanionBuilder = ChaptersCompanion Function({
  required String id,
  required String bookId,
  required String title,
  required int chapterIndex,
  required String content,
  required String contentHash,
  Value<int> revision,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$ChaptersTableUpdateCompanionBuilder = ChaptersCompanion Function({
  Value<String> id,
  Value<String> bookId,
  Value<String> title,
  Value<int> chapterIndex,
  Value<String> content,
  Value<String> contentHash,
  Value<int> revision,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$ChaptersTableReferences
    extends BaseReferences<_$AppDatabase, $ChaptersTable, Chapter> {
  $$ChaptersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) =>
      db.books.createAlias('chapters__book_id__books__id');

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<String>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ReadingProgressTable, List<ReadingProgressData>>
  _readingProgressRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.readingProgress,
    aliasName: 'chapters__id__reading_progress__chapter_id',
  );

  $$ReadingProgressTableProcessedTableManager get readingProgressRefs {
    final manager = $$ReadingProgressTableTableManager(
      $_db,
      $_db.readingProgress,
    ).filter((f) => f.chapterId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _readingProgressRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PaginationCachesTable, List<PaginationCache>>
  _paginationCachesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.paginationCaches,
    aliasName: 'chapters__id__pagination_caches__chapter_id',
  );

  $$PaginationCachesTableProcessedTableManager get paginationCachesRefs {
    final manager = $$PaginationCachesTableTableManager(
      $_db,
      $_db.paginationCaches,
    ).filter((f) => f.chapterId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _paginationCachesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WordOccurrencesTable, List<WordOccurrence>>
  _wordOccurrencesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.wordOccurrences,
    aliasName: 'chapters__id__word_occurrences__chapter_id',
  );

  $$WordOccurrencesTableProcessedTableManager get wordOccurrencesRefs {
    final manager = $$WordOccurrencesTableTableManager(
      $_db,
      $_db.wordOccurrences,
    ).filter((f) => f.chapterId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _wordOccurrencesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ChaptersTableFilterComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> readingProgressRefs(
    Expression<bool> Function($$ReadingProgressTableFilterComposer f) f,
  ) {
    final $$ReadingProgressTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readingProgress,
      getReferencedColumn: (t) => t.chapterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingProgressTableFilterComposer(
            $db: $db,
            $table: $db.readingProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> paginationCachesRefs(
    Expression<bool> Function($$PaginationCachesTableFilterComposer f) f,
  ) {
    final $$PaginationCachesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paginationCaches,
      getReferencedColumn: (t) => t.chapterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaginationCachesTableFilterComposer(
            $db: $db,
            $table: $db.paginationCaches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> wordOccurrencesRefs(
    Expression<bool> Function($$WordOccurrencesTableFilterComposer f) f,
  ) {
    final $$WordOccurrencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordOccurrences,
      getReferencedColumn: (t) => t.chapterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordOccurrencesTableFilterComposer(
            $db: $db,
            $table: $db.wordOccurrences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChaptersTableOrderingComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChaptersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> readingProgressRefs<T extends Object>(
    Expression<T> Function($$ReadingProgressTableAnnotationComposer a) f,
  ) {
    final $$ReadingProgressTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readingProgress,
      getReferencedColumn: (t) => t.chapterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingProgressTableAnnotationComposer(
            $db: $db,
            $table: $db.readingProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> paginationCachesRefs<T extends Object>(
    Expression<T> Function($$PaginationCachesTableAnnotationComposer a) f,
  ) {
    final $$PaginationCachesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paginationCaches,
      getReferencedColumn: (t) => t.chapterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaginationCachesTableAnnotationComposer(
            $db: $db,
            $table: $db.paginationCaches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> wordOccurrencesRefs<T extends Object>(
    Expression<T> Function($$WordOccurrencesTableAnnotationComposer a) f,
  ) {
    final $$WordOccurrencesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordOccurrences,
      getReferencedColumn: (t) => t.chapterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordOccurrencesTableAnnotationComposer(
            $db: $db,
            $table: $db.wordOccurrences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChaptersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChaptersTable,
          Chapter,
          $$ChaptersTableFilterComposer,
          $$ChaptersTableOrderingComposer,
          $$ChaptersTableAnnotationComposer,
          $$ChaptersTableCreateCompanionBuilder,
          $$ChaptersTableUpdateCompanionBuilder,
          (Chapter, $$ChaptersTableReferences),
          Chapter,
          PrefetchHooks Function({
            bool bookId,
            bool readingProgressRefs,
            bool paginationCachesRefs,
            bool wordOccurrencesRefs,
          })
        > {
  $$ChaptersTableTableManager(_$AppDatabase db, $ChaptersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChaptersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChaptersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChaptersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> bookId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> chapterIndex = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> contentHash = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChaptersCompanion(
                id: id,
                bookId: bookId,
                title: title,
                chapterIndex: chapterIndex,
                content: content,
                contentHash: contentHash,
                revision: revision,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String bookId,
                required String title,
                required int chapterIndex,
                required String content,
                required String contentHash,
                Value<int> revision = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ChaptersCompanion.insert(
                id: id,
                bookId: bookId,
                title: title,
                chapterIndex: chapterIndex,
                content: content,
                contentHash: contentHash,
                revision: revision,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ChaptersTable, Chapter>(table),
                  $$ChaptersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                bookId = false,
                readingProgressRefs = false,
                paginationCachesRefs = false,
                wordOccurrencesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (readingProgressRefs) db.readingProgress,
                    if (paginationCachesRefs) db.paginationCaches,
                    if (wordOccurrencesRefs) db.wordOccurrences,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (bookId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.bookId,
                            referencedTable: $$ChaptersTableReferences
                                ._bookIdTable(db),
                            referencedColumn: $$ChaptersTableReferences
                                ._bookIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (readingProgressRefs)
                        await $_getPrefetchedDataByColumns<
                          Chapter,
                          $ChaptersTable,
                          ReadingProgressData,
                          $ReadingProgressTable
                        >(
                          currentTable: table,
                          referencedTable: $$ChaptersTableReferences
                              ._readingProgressRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChaptersTableReferences(
                                db,
                                table,
                                p0,
                              ).readingProgressRefs,
                          currentColumn: 'id',
                          referencedColumn: 'chapter_id',
                          typedResults: items,
                        ),
                      if (paginationCachesRefs)
                        await $_getPrefetchedDataByColumns<
                          Chapter,
                          $ChaptersTable,
                          PaginationCache,
                          $PaginationCachesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ChaptersTableReferences
                              ._paginationCachesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChaptersTableReferences(
                                db,
                                table,
                                p0,
                              ).paginationCachesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'chapter_id',
                          typedResults: items,
                        ),
                      if (wordOccurrencesRefs)
                        await $_getPrefetchedDataByColumns<
                          Chapter,
                          $ChaptersTable,
                          WordOccurrence,
                          $WordOccurrencesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ChaptersTableReferences
                              ._wordOccurrencesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChaptersTableReferences(
                                db,
                                table,
                                p0,
                              ).wordOccurrencesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'chapter_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ChaptersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChaptersTable,
      Chapter,
      $$ChaptersTableFilterComposer,
      $$ChaptersTableOrderingComposer,
      $$ChaptersTableAnnotationComposer,
      $$ChaptersTableCreateCompanionBuilder,
      $$ChaptersTableUpdateCompanionBuilder,
      (Chapter, $$ChaptersTableReferences),
      Chapter,
      PrefetchHooks Function({
        bool bookId,
        bool readingProgressRefs,
        bool paginationCachesRefs,
        bool wordOccurrencesRefs,
      })
    >;
typedef $$ReadingProgressTableCreateCompanionBuilder =
    ReadingProgressCompanion Function({
      required String id,
      required String bookId,
      required String chapterId,
      Value<int> anchorParagraph,
      Value<int> anchorOffset,
      Value<int> cachedPageIndex,
      Value<int> cachedPageCount,
      Value<String?> layoutSignature,
      Value<int> revision,
      Value<String?> updatedBy,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ReadingProgressTableUpdateCompanionBuilder =
    ReadingProgressCompanion Function({
      Value<String> id,
      Value<String> bookId,
      Value<String> chapterId,
      Value<int> anchorParagraph,
      Value<int> anchorOffset,
      Value<int> cachedPageIndex,
      Value<int> cachedPageCount,
      Value<String?> layoutSignature,
      Value<int> revision,
      Value<String?> updatedBy,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ReadingProgressTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ReadingProgressTable,
          ReadingProgressData
        > {
  $$ReadingProgressTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BooksTable _bookIdTable(_$AppDatabase db) =>
      db.books.createAlias('reading_progress__book_id__books__id');

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<String>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ChaptersTable _chapterIdTable(_$AppDatabase db) =>
      db.chapters.createAlias('reading_progress__chapter_id__chapters__id');

  $$ChaptersTableProcessedTableManager get chapterId {
    final $_column = $_itemColumn<String>('chapter_id')!;

    final manager = $$ChaptersTableTableManager(
      $_db,
      $_db.chapters,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chapterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReadingProgressTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingProgressTable> {
  $$ReadingProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get anchorParagraph => $composableBuilder(
    column: $table.anchorParagraph,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get anchorOffset => $composableBuilder(
    column: $table.anchorOffset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cachedPageIndex => $composableBuilder(
    column: $table.cachedPageIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cachedPageCount => $composableBuilder(
    column: $table.cachedPageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get layoutSignature => $composableBuilder(
    column: $table.layoutSignature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ChaptersTableFilterComposer get chapterId {
    final $$ChaptersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chapterId,
      referencedTable: $db.chapters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChaptersTableFilterComposer(
            $db: $db,
            $table: $db.chapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingProgressTable> {
  $$ReadingProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get anchorParagraph => $composableBuilder(
    column: $table.anchorParagraph,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get anchorOffset => $composableBuilder(
    column: $table.anchorOffset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cachedPageIndex => $composableBuilder(
    column: $table.cachedPageIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cachedPageCount => $composableBuilder(
    column: $table.cachedPageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get layoutSignature => $composableBuilder(
    column: $table.layoutSignature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ChaptersTableOrderingComposer get chapterId {
    final $$ChaptersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chapterId,
      referencedTable: $db.chapters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChaptersTableOrderingComposer(
            $db: $db,
            $table: $db.chapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingProgressTable> {
  $$ReadingProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get anchorParagraph => $composableBuilder(
    column: $table.anchorParagraph,
    builder: (column) => column,
  );

  GeneratedColumn<int> get anchorOffset => $composableBuilder(
    column: $table.anchorOffset,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cachedPageIndex => $composableBuilder(
    column: $table.cachedPageIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cachedPageCount => $composableBuilder(
    column: $table.cachedPageCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get layoutSignature => $composableBuilder(
    column: $table.layoutSignature,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ChaptersTableAnnotationComposer get chapterId {
    final $$ChaptersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chapterId,
      referencedTable: $db.chapters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChaptersTableAnnotationComposer(
            $db: $db,
            $table: $db.chapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadingProgressTable,
          ReadingProgressData,
          $$ReadingProgressTableFilterComposer,
          $$ReadingProgressTableOrderingComposer,
          $$ReadingProgressTableAnnotationComposer,
          $$ReadingProgressTableCreateCompanionBuilder,
          $$ReadingProgressTableUpdateCompanionBuilder,
          (ReadingProgressData, $$ReadingProgressTableReferences),
          ReadingProgressData,
          PrefetchHooks Function({bool bookId, bool chapterId})
        > {
  $$ReadingProgressTableTableManager(
    _$AppDatabase db,
    $ReadingProgressTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> bookId = const Value.absent(),
                Value<String> chapterId = const Value.absent(),
                Value<int> anchorParagraph = const Value.absent(),
                Value<int> anchorOffset = const Value.absent(),
                Value<int> cachedPageIndex = const Value.absent(),
                Value<int> cachedPageCount = const Value.absent(),
                Value<String?> layoutSignature = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReadingProgressCompanion(
                id: id,
                bookId: bookId,
                chapterId: chapterId,
                anchorParagraph: anchorParagraph,
                anchorOffset: anchorOffset,
                cachedPageIndex: cachedPageIndex,
                cachedPageCount: cachedPageCount,
                layoutSignature: layoutSignature,
                revision: revision,
                updatedBy: updatedBy,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String bookId,
                required String chapterId,
                Value<int> anchorParagraph = const Value.absent(),
                Value<int> anchorOffset = const Value.absent(),
                Value<int> cachedPageIndex = const Value.absent(),
                Value<int> cachedPageCount = const Value.absent(),
                Value<String?> layoutSignature = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ReadingProgressCompanion.insert(
                id: id,
                bookId: bookId,
                chapterId: chapterId,
                anchorParagraph: anchorParagraph,
                anchorOffset: anchorOffset,
                cachedPageIndex: cachedPageIndex,
                cachedPageCount: cachedPageCount,
                layoutSignature: layoutSignature,
                revision: revision,
                updatedBy: updatedBy,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReadingProgressTable, ReadingProgressData>(
                    table,
                  ),
                  $$ReadingProgressTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false, chapterId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.bookId,
                        referencedTable: $$ReadingProgressTableReferences
                            ._bookIdTable(db),
                        referencedColumn: $$ReadingProgressTableReferences
                            ._bookIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (chapterId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.chapterId,
                        referencedTable: $$ReadingProgressTableReferences
                            ._chapterIdTable(db),
                        referencedColumn: $$ReadingProgressTableReferences
                            ._chapterIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReadingProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadingProgressTable,
      ReadingProgressData,
      $$ReadingProgressTableFilterComposer,
      $$ReadingProgressTableOrderingComposer,
      $$ReadingProgressTableAnnotationComposer,
      $$ReadingProgressTableCreateCompanionBuilder,
      $$ReadingProgressTableUpdateCompanionBuilder,
      (ReadingProgressData, $$ReadingProgressTableReferences),
      ReadingProgressData,
      PrefetchHooks Function({bool bookId, bool chapterId})
    >;
typedef $$PaginationCachesTableCreateCompanionBuilder =
    PaginationCachesCompanion Function({
      Value<int> id,
      required String chapterId,
      required String layoutSignature,
      required int pageIndex,
      required int startParagraph,
      required int startOffset,
      required int endParagraph,
      required int endOffset,
      required DateTime createdAt,
    });
typedef $$PaginationCachesTableUpdateCompanionBuilder =
    PaginationCachesCompanion Function({
      Value<int> id,
      Value<String> chapterId,
      Value<String> layoutSignature,
      Value<int> pageIndex,
      Value<int> startParagraph,
      Value<int> startOffset,
      Value<int> endParagraph,
      Value<int> endOffset,
      Value<DateTime> createdAt,
    });

final class $$PaginationCachesTableReferences
    extends
        BaseReferences<_$AppDatabase, $PaginationCachesTable, PaginationCache> {
  $$PaginationCachesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ChaptersTable _chapterIdTable(_$AppDatabase db) =>
      db.chapters.createAlias('pagination_caches__chapter_id__chapters__id');

  $$ChaptersTableProcessedTableManager get chapterId {
    final $_column = $_itemColumn<String>('chapter_id')!;

    final manager = $$ChaptersTableTableManager(
      $_db,
      $_db.chapters,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chapterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PaginationCachesTableFilterComposer
    extends Composer<_$AppDatabase, $PaginationCachesTable> {
  $$PaginationCachesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get layoutSignature => $composableBuilder(
    column: $table.layoutSignature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageIndex => $composableBuilder(
    column: $table.pageIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startParagraph => $composableBuilder(
    column: $table.startParagraph,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startOffset => $composableBuilder(
    column: $table.startOffset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endParagraph => $composableBuilder(
    column: $table.endParagraph,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endOffset => $composableBuilder(
    column: $table.endOffset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ChaptersTableFilterComposer get chapterId {
    final $$ChaptersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chapterId,
      referencedTable: $db.chapters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChaptersTableFilterComposer(
            $db: $db,
            $table: $db.chapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaginationCachesTableOrderingComposer
    extends Composer<_$AppDatabase, $PaginationCachesTable> {
  $$PaginationCachesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get layoutSignature => $composableBuilder(
    column: $table.layoutSignature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageIndex => $composableBuilder(
    column: $table.pageIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startParagraph => $composableBuilder(
    column: $table.startParagraph,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startOffset => $composableBuilder(
    column: $table.startOffset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endParagraph => $composableBuilder(
    column: $table.endParagraph,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endOffset => $composableBuilder(
    column: $table.endOffset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ChaptersTableOrderingComposer get chapterId {
    final $$ChaptersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chapterId,
      referencedTable: $db.chapters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChaptersTableOrderingComposer(
            $db: $db,
            $table: $db.chapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaginationCachesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaginationCachesTable> {
  $$PaginationCachesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get layoutSignature => $composableBuilder(
    column: $table.layoutSignature,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pageIndex =>
      $composableBuilder(column: $table.pageIndex, builder: (column) => column);

  GeneratedColumn<int> get startParagraph => $composableBuilder(
    column: $table.startParagraph,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startOffset => $composableBuilder(
    column: $table.startOffset,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endParagraph => $composableBuilder(
    column: $table.endParagraph,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endOffset =>
      $composableBuilder(column: $table.endOffset, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ChaptersTableAnnotationComposer get chapterId {
    final $$ChaptersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chapterId,
      referencedTable: $db.chapters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChaptersTableAnnotationComposer(
            $db: $db,
            $table: $db.chapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaginationCachesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaginationCachesTable,
          PaginationCache,
          $$PaginationCachesTableFilterComposer,
          $$PaginationCachesTableOrderingComposer,
          $$PaginationCachesTableAnnotationComposer,
          $$PaginationCachesTableCreateCompanionBuilder,
          $$PaginationCachesTableUpdateCompanionBuilder,
          (PaginationCache, $$PaginationCachesTableReferences),
          PaginationCache,
          PrefetchHooks Function({bool chapterId})
        > {
  $$PaginationCachesTableTableManager(
    _$AppDatabase db,
    $PaginationCachesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaginationCachesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaginationCachesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaginationCachesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> chapterId = const Value.absent(),
                Value<String> layoutSignature = const Value.absent(),
                Value<int> pageIndex = const Value.absent(),
                Value<int> startParagraph = const Value.absent(),
                Value<int> startOffset = const Value.absent(),
                Value<int> endParagraph = const Value.absent(),
                Value<int> endOffset = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PaginationCachesCompanion(
                id: id,
                chapterId: chapterId,
                layoutSignature: layoutSignature,
                pageIndex: pageIndex,
                startParagraph: startParagraph,
                startOffset: startOffset,
                endParagraph: endParagraph,
                endOffset: endOffset,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String chapterId,
                required String layoutSignature,
                required int pageIndex,
                required int startParagraph,
                required int startOffset,
                required int endParagraph,
                required int endOffset,
                required DateTime createdAt,
              }) => PaginationCachesCompanion.insert(
                id: id,
                chapterId: chapterId,
                layoutSignature: layoutSignature,
                pageIndex: pageIndex,
                startParagraph: startParagraph,
                startOffset: startOffset,
                endParagraph: endParagraph,
                endOffset: endOffset,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PaginationCachesTable, PaginationCache>(table),
                  $$PaginationCachesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({chapterId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (chapterId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.chapterId,
                        referencedTable: $$PaginationCachesTableReferences
                            ._chapterIdTable(db),
                        referencedColumn: $$PaginationCachesTableReferences
                            ._chapterIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PaginationCachesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaginationCachesTable,
      PaginationCache,
      $$PaginationCachesTableFilterComposer,
      $$PaginationCachesTableOrderingComposer,
      $$PaginationCachesTableAnnotationComposer,
      $$PaginationCachesTableCreateCompanionBuilder,
      $$PaginationCachesTableUpdateCompanionBuilder,
      (PaginationCache, $$PaginationCachesTableReferences),
      PaginationCache,
      PrefetchHooks Function({bool chapterId})
    >;
typedef $$VocabularyTableCreateCompanionBuilder = VocabularyCompanion Function({
  required String id,
  required String lemma,
  Value<String> language,
  Value<String?> senseLabel,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$VocabularyTableUpdateCompanionBuilder = VocabularyCompanion Function({
  Value<String> id,
  Value<String> lemma,
  Value<String> language,
  Value<String?> senseLabel,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$VocabularyTableReferences
    extends BaseReferences<_$AppDatabase, $VocabularyTable, VocabularyData> {
  $$VocabularyTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WordFormsTable, List<WordForm>>
  _wordFormsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.wordForms,
    aliasName: 'vocabulary__id__word_forms__vocabulary_id',
  );

  $$WordFormsTableProcessedTableManager get wordFormsRefs {
    final manager = $$WordFormsTableTableManager(
      $_db,
      $_db.wordForms,
    ).filter((f) => f.vocabularyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_wordFormsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WordStatusesTable, List<WordStatuse>>
  _wordStatusesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.wordStatuses,
    aliasName: 'vocabulary__id__word_statuses__vocabulary_id',
  );

  $$WordStatusesTableProcessedTableManager get wordStatusesRefs {
    final manager = $$WordStatusesTableTableManager(
      $_db,
      $_db.wordStatuses,
    ).filter((f) => f.vocabularyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_wordStatusesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DefinitionsTable, List<Definition>>
  _definitionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.definitions,
    aliasName: 'vocabulary__id__definitions__vocabulary_id',
  );

  $$DefinitionsTableProcessedTableManager get definitionsRefs {
    final manager = $$DefinitionsTableTableManager(
      $_db,
      $_db.definitions,
    ).filter((f) => f.vocabularyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_definitionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FsrsCardsTable, List<FsrsCard>>
  _fsrsCardsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.fsrsCards,
    aliasName: 'vocabulary__id__fsrs_cards__vocabulary_id',
  );

  $$FsrsCardsTableProcessedTableManager get fsrsCardsRefs {
    final manager = $$FsrsCardsTableTableManager(
      $_db,
      $_db.fsrsCards,
    ).filter((f) => f.vocabularyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_fsrsCardsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReviewLogsTable, List<ReviewLog>>
  _reviewLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reviewLogs,
    aliasName: 'vocabulary__id__review_logs__vocabulary_id',
  );

  $$ReviewLogsTableProcessedTableManager get reviewLogsRefs {
    final manager = $$ReviewLogsTableTableManager(
      $_db,
      $_db.reviewLogs,
    ).filter((f) => f.vocabularyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_reviewLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VocabularyTableFilterComposer
    extends Composer<_$AppDatabase, $VocabularyTable> {
  $$VocabularyTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lemma => $composableBuilder(
    column: $table.lemma,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senseLabel => $composableBuilder(
    column: $table.senseLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> wordFormsRefs(
    Expression<bool> Function($$WordFormsTableFilterComposer f) f,
  ) {
    final $$WordFormsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordForms,
      getReferencedColumn: (t) => t.vocabularyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordFormsTableFilterComposer(
            $db: $db,
            $table: $db.wordForms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> wordStatusesRefs(
    Expression<bool> Function($$WordStatusesTableFilterComposer f) f,
  ) {
    final $$WordStatusesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordStatuses,
      getReferencedColumn: (t) => t.vocabularyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordStatusesTableFilterComposer(
            $db: $db,
            $table: $db.wordStatuses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> definitionsRefs(
    Expression<bool> Function($$DefinitionsTableFilterComposer f) f,
  ) {
    final $$DefinitionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.definitions,
      getReferencedColumn: (t) => t.vocabularyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DefinitionsTableFilterComposer(
            $db: $db,
            $table: $db.definitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> fsrsCardsRefs(
    Expression<bool> Function($$FsrsCardsTableFilterComposer f) f,
  ) {
    final $$FsrsCardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fsrsCards,
      getReferencedColumn: (t) => t.vocabularyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FsrsCardsTableFilterComposer(
            $db: $db,
            $table: $db.fsrsCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> reviewLogsRefs(
    Expression<bool> Function($$ReviewLogsTableFilterComposer f) f,
  ) {
    final $$ReviewLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reviewLogs,
      getReferencedColumn: (t) => t.vocabularyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReviewLogsTableFilterComposer(
            $db: $db,
            $table: $db.reviewLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VocabularyTableOrderingComposer
    extends Composer<_$AppDatabase, $VocabularyTable> {
  $$VocabularyTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lemma => $composableBuilder(
    column: $table.lemma,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senseLabel => $composableBuilder(
    column: $table.senseLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VocabularyTableAnnotationComposer
    extends Composer<_$AppDatabase, $VocabularyTable> {
  $$VocabularyTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get lemma =>
      $composableBuilder(column: $table.lemma, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get senseLabel => $composableBuilder(
    column: $table.senseLabel,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> wordFormsRefs<T extends Object>(
    Expression<T> Function($$WordFormsTableAnnotationComposer a) f,
  ) {
    final $$WordFormsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordForms,
      getReferencedColumn: (t) => t.vocabularyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordFormsTableAnnotationComposer(
            $db: $db,
            $table: $db.wordForms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> wordStatusesRefs<T extends Object>(
    Expression<T> Function($$WordStatusesTableAnnotationComposer a) f,
  ) {
    final $$WordStatusesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordStatuses,
      getReferencedColumn: (t) => t.vocabularyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordStatusesTableAnnotationComposer(
            $db: $db,
            $table: $db.wordStatuses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> definitionsRefs<T extends Object>(
    Expression<T> Function($$DefinitionsTableAnnotationComposer a) f,
  ) {
    final $$DefinitionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.definitions,
      getReferencedColumn: (t) => t.vocabularyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DefinitionsTableAnnotationComposer(
            $db: $db,
            $table: $db.definitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> fsrsCardsRefs<T extends Object>(
    Expression<T> Function($$FsrsCardsTableAnnotationComposer a) f,
  ) {
    final $$FsrsCardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fsrsCards,
      getReferencedColumn: (t) => t.vocabularyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FsrsCardsTableAnnotationComposer(
            $db: $db,
            $table: $db.fsrsCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> reviewLogsRefs<T extends Object>(
    Expression<T> Function($$ReviewLogsTableAnnotationComposer a) f,
  ) {
    final $$ReviewLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reviewLogs,
      getReferencedColumn: (t) => t.vocabularyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReviewLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.reviewLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VocabularyTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VocabularyTable,
          VocabularyData,
          $$VocabularyTableFilterComposer,
          $$VocabularyTableOrderingComposer,
          $$VocabularyTableAnnotationComposer,
          $$VocabularyTableCreateCompanionBuilder,
          $$VocabularyTableUpdateCompanionBuilder,
          (VocabularyData, $$VocabularyTableReferences),
          VocabularyData,
          PrefetchHooks Function({
            bool wordFormsRefs,
            bool wordStatusesRefs,
            bool definitionsRefs,
            bool fsrsCardsRefs,
            bool reviewLogsRefs,
          })
        > {
  $$VocabularyTableTableManager(_$AppDatabase db, $VocabularyTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VocabularyTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VocabularyTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VocabularyTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> lemma = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<String?> senseLabel = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VocabularyCompanion(
                id: id,
                lemma: lemma,
                language: language,
                senseLabel: senseLabel,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String lemma,
                Value<String> language = const Value.absent(),
                Value<String?> senseLabel = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => VocabularyCompanion.insert(
                id: id,
                lemma: lemma,
                language: language,
                senseLabel: senseLabel,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VocabularyTable, VocabularyData>(table),
                  $$VocabularyTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                wordFormsRefs = false,
                wordStatusesRefs = false,
                definitionsRefs = false,
                fsrsCardsRefs = false,
                reviewLogsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (wordFormsRefs) db.wordForms,
                    if (wordStatusesRefs) db.wordStatuses,
                    if (definitionsRefs) db.definitions,
                    if (fsrsCardsRefs) db.fsrsCards,
                    if (reviewLogsRefs) db.reviewLogs,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (wordFormsRefs)
                        await $_getPrefetchedDataByColumns<
                          VocabularyData,
                          $VocabularyTable,
                          WordForm,
                          $WordFormsTable
                        >(
                          currentTable: table,
                          referencedTable: $$VocabularyTableReferences
                              ._wordFormsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VocabularyTableReferences(
                                db,
                                table,
                                p0,
                              ).wordFormsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'vocabulary_id',
                          typedResults: items,
                        ),
                      if (wordStatusesRefs)
                        await $_getPrefetchedDataByColumns<
                          VocabularyData,
                          $VocabularyTable,
                          WordStatuse,
                          $WordStatusesTable
                        >(
                          currentTable: table,
                          referencedTable: $$VocabularyTableReferences
                              ._wordStatusesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VocabularyTableReferences(
                                db,
                                table,
                                p0,
                              ).wordStatusesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'vocabulary_id',
                          typedResults: items,
                        ),
                      if (definitionsRefs)
                        await $_getPrefetchedDataByColumns<
                          VocabularyData,
                          $VocabularyTable,
                          Definition,
                          $DefinitionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$VocabularyTableReferences
                              ._definitionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VocabularyTableReferences(
                                db,
                                table,
                                p0,
                              ).definitionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'vocabulary_id',
                          typedResults: items,
                        ),
                      if (fsrsCardsRefs)
                        await $_getPrefetchedDataByColumns<
                          VocabularyData,
                          $VocabularyTable,
                          FsrsCard,
                          $FsrsCardsTable
                        >(
                          currentTable: table,
                          referencedTable: $$VocabularyTableReferences
                              ._fsrsCardsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VocabularyTableReferences(
                                db,
                                table,
                                p0,
                              ).fsrsCardsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'vocabulary_id',
                          typedResults: items,
                        ),
                      if (reviewLogsRefs)
                        await $_getPrefetchedDataByColumns<
                          VocabularyData,
                          $VocabularyTable,
                          ReviewLog,
                          $ReviewLogsTable
                        >(
                          currentTable: table,
                          referencedTable: $$VocabularyTableReferences
                              ._reviewLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VocabularyTableReferences(
                                db,
                                table,
                                p0,
                              ).reviewLogsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'vocabulary_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$VocabularyTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VocabularyTable,
      VocabularyData,
      $$VocabularyTableFilterComposer,
      $$VocabularyTableOrderingComposer,
      $$VocabularyTableAnnotationComposer,
      $$VocabularyTableCreateCompanionBuilder,
      $$VocabularyTableUpdateCompanionBuilder,
      (VocabularyData, $$VocabularyTableReferences),
      VocabularyData,
      PrefetchHooks Function({
        bool wordFormsRefs,
        bool wordStatusesRefs,
        bool definitionsRefs,
        bool fsrsCardsRefs,
        bool reviewLogsRefs,
      })
    >;
typedef $$WordFormsTableCreateCompanionBuilder = WordFormsCompanion Function({
  required String id,
  required String surfaceForm,
  required String normalizedForm,
  required String vocabularyId,
  Value<double> confidence,
  Value<bool> isVerified,
  Value<bool> isPrimary,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$WordFormsTableUpdateCompanionBuilder = WordFormsCompanion Function({
  Value<String> id,
  Value<String> surfaceForm,
  Value<String> normalizedForm,
  Value<String> vocabularyId,
  Value<double> confidence,
  Value<bool> isVerified,
  Value<bool> isPrimary,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$WordFormsTableReferences
    extends BaseReferences<_$AppDatabase, $WordFormsTable, WordForm> {
  $$WordFormsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VocabularyTable _vocabularyIdTable(_$AppDatabase db) =>
      db.vocabulary.createAlias('word_forms__vocabulary_id__vocabulary__id');

  $$VocabularyTableProcessedTableManager get vocabularyId {
    final $_column = $_itemColumn<String>('vocabulary_id')!;

    final manager = $$VocabularyTableTableManager(
      $_db,
      $_db.vocabulary,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vocabularyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WordFormsTableFilterComposer
    extends Composer<_$AppDatabase, $WordFormsTable> {
  $$WordFormsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get surfaceForm => $composableBuilder(
    column: $table.surfaceForm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedForm => $composableBuilder(
    column: $table.normalizedForm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isVerified => $composableBuilder(
    column: $table.isVerified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$VocabularyTableFilterComposer get vocabularyId {
    final $$VocabularyTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vocabularyId,
      referencedTable: $db.vocabulary,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VocabularyTableFilterComposer(
            $db: $db,
            $table: $db.vocabulary,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordFormsTableOrderingComposer
    extends Composer<_$AppDatabase, $WordFormsTable> {
  $$WordFormsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get surfaceForm => $composableBuilder(
    column: $table.surfaceForm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedForm => $composableBuilder(
    column: $table.normalizedForm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isVerified => $composableBuilder(
    column: $table.isVerified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$VocabularyTableOrderingComposer get vocabularyId {
    final $$VocabularyTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vocabularyId,
      referencedTable: $db.vocabulary,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VocabularyTableOrderingComposer(
            $db: $db,
            $table: $db.vocabulary,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordFormsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordFormsTable> {
  $$WordFormsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get surfaceForm => $composableBuilder(
    column: $table.surfaceForm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get normalizedForm => $composableBuilder(
    column: $table.normalizedForm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isVerified => $composableBuilder(
    column: $table.isVerified,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPrimary =>
      $composableBuilder(column: $table.isPrimary, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$VocabularyTableAnnotationComposer get vocabularyId {
    final $$VocabularyTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vocabularyId,
      referencedTable: $db.vocabulary,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VocabularyTableAnnotationComposer(
            $db: $db,
            $table: $db.vocabulary,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordFormsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WordFormsTable,
          WordForm,
          $$WordFormsTableFilterComposer,
          $$WordFormsTableOrderingComposer,
          $$WordFormsTableAnnotationComposer,
          $$WordFormsTableCreateCompanionBuilder,
          $$WordFormsTableUpdateCompanionBuilder,
          (WordForm, $$WordFormsTableReferences),
          WordForm,
          PrefetchHooks Function({bool vocabularyId})
        > {
  $$WordFormsTableTableManager(_$AppDatabase db, $WordFormsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordFormsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordFormsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordFormsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> surfaceForm = const Value.absent(),
                Value<String> normalizedForm = const Value.absent(),
                Value<String> vocabularyId = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<bool> isVerified = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WordFormsCompanion(
                id: id,
                surfaceForm: surfaceForm,
                normalizedForm: normalizedForm,
                vocabularyId: vocabularyId,
                confidence: confidence,
                isVerified: isVerified,
                isPrimary: isPrimary,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String surfaceForm,
                required String normalizedForm,
                required String vocabularyId,
                Value<double> confidence = const Value.absent(),
                Value<bool> isVerified = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => WordFormsCompanion.insert(
                id: id,
                surfaceForm: surfaceForm,
                normalizedForm: normalizedForm,
                vocabularyId: vocabularyId,
                confidence: confidence,
                isVerified: isVerified,
                isPrimary: isPrimary,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WordFormsTable, WordForm>(table),
                  $$WordFormsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({vocabularyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (vocabularyId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.vocabularyId,
                        referencedTable: $$WordFormsTableReferences
                            ._vocabularyIdTable(db),
                        referencedColumn: $$WordFormsTableReferences
                            ._vocabularyIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WordFormsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WordFormsTable,
      WordForm,
      $$WordFormsTableFilterComposer,
      $$WordFormsTableOrderingComposer,
      $$WordFormsTableAnnotationComposer,
      $$WordFormsTableCreateCompanionBuilder,
      $$WordFormsTableUpdateCompanionBuilder,
      (WordForm, $$WordFormsTableReferences),
      WordForm,
      PrefetchHooks Function({bool vocabularyId})
    >;
typedef $$WordOccurrencesTableCreateCompanionBuilder =
    WordOccurrencesCompanion Function({
      required String id,
      required String bookId,
      required String chapterId,
      required String vocabularyId,
      required String surfaceForm,
      required int paragraphIndex,
      required int startOffset,
      required int endOffset,
      Value<String?> overrideVocabularyId,
      Value<bool> isManuallyCorrected,
      Value<int> revision,
      Value<String?> updatedBy,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$WordOccurrencesTableUpdateCompanionBuilder =
    WordOccurrencesCompanion Function({
      Value<String> id,
      Value<String> bookId,
      Value<String> chapterId,
      Value<String> vocabularyId,
      Value<String> surfaceForm,
      Value<int> paragraphIndex,
      Value<int> startOffset,
      Value<int> endOffset,
      Value<String?> overrideVocabularyId,
      Value<bool> isManuallyCorrected,
      Value<int> revision,
      Value<String?> updatedBy,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$WordOccurrencesTableReferences
    extends
        BaseReferences<_$AppDatabase, $WordOccurrencesTable, WordOccurrence> {
  $$WordOccurrencesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BooksTable _bookIdTable(_$AppDatabase db) =>
      db.books.createAlias('word_occurrences__book_id__books__id');

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<String>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ChaptersTable _chapterIdTable(_$AppDatabase db) =>
      db.chapters.createAlias('word_occurrences__chapter_id__chapters__id');

  $$ChaptersTableProcessedTableManager get chapterId {
    final $_column = $_itemColumn<String>('chapter_id')!;

    final manager = $$ChaptersTableTableManager(
      $_db,
      $_db.chapters,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chapterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $VocabularyTable _vocabularyIdTable(_$AppDatabase db) => db.vocabulary
      .createAlias('word_occurrences__vocabulary_id__vocabulary__id');

  $$VocabularyTableProcessedTableManager get vocabularyId {
    final $_column = $_itemColumn<String>('vocabulary_id')!;

    final manager = $$VocabularyTableTableManager(
      $_db,
      $_db.vocabulary,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vocabularyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $VocabularyTable _overrideVocabularyIdTable(_$AppDatabase db) => db
      .vocabulary
      .createAlias('word_occurrences__override_vocabulary_id__vocabulary__id');

  $$VocabularyTableProcessedTableManager? get overrideVocabularyId {
    final $_column = $_itemColumn<String>('override_vocabulary_id');
    if ($_column == null) return null;
    final manager = $$VocabularyTableTableManager(
      $_db,
      $_db.vocabulary,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _overrideVocabularyIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WordOccurrencesTableFilterComposer
    extends Composer<_$AppDatabase, $WordOccurrencesTable> {
  $$WordOccurrencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get surfaceForm => $composableBuilder(
    column: $table.surfaceForm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paragraphIndex => $composableBuilder(
    column: $table.paragraphIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startOffset => $composableBuilder(
    column: $table.startOffset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endOffset => $composableBuilder(
    column: $table.endOffset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isManuallyCorrected => $composableBuilder(
    column: $table.isManuallyCorrected,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ChaptersTableFilterComposer get chapterId {
    final $$ChaptersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chapterId,
      referencedTable: $db.chapters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChaptersTableFilterComposer(
            $db: $db,
            $table: $db.chapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VocabularyTableFilterComposer get vocabularyId {
    final $$VocabularyTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vocabularyId,
      referencedTable: $db.vocabulary,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VocabularyTableFilterComposer(
            $db: $db,
            $table: $db.vocabulary,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VocabularyTableFilterComposer get overrideVocabularyId {
    final $$VocabularyTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.overrideVocabularyId,
      referencedTable: $db.vocabulary,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VocabularyTableFilterComposer(
            $db: $db,
            $table: $db.vocabulary,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordOccurrencesTableOrderingComposer
    extends Composer<_$AppDatabase, $WordOccurrencesTable> {
  $$WordOccurrencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get surfaceForm => $composableBuilder(
    column: $table.surfaceForm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paragraphIndex => $composableBuilder(
    column: $table.paragraphIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startOffset => $composableBuilder(
    column: $table.startOffset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endOffset => $composableBuilder(
    column: $table.endOffset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isManuallyCorrected => $composableBuilder(
    column: $table.isManuallyCorrected,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ChaptersTableOrderingComposer get chapterId {
    final $$ChaptersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chapterId,
      referencedTable: $db.chapters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChaptersTableOrderingComposer(
            $db: $db,
            $table: $db.chapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VocabularyTableOrderingComposer get vocabularyId {
    final $$VocabularyTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vocabularyId,
      referencedTable: $db.vocabulary,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VocabularyTableOrderingComposer(
            $db: $db,
            $table: $db.vocabulary,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VocabularyTableOrderingComposer get overrideVocabularyId {
    final $$VocabularyTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.overrideVocabularyId,
      referencedTable: $db.vocabulary,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VocabularyTableOrderingComposer(
            $db: $db,
            $table: $db.vocabulary,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordOccurrencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordOccurrencesTable> {
  $$WordOccurrencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get surfaceForm => $composableBuilder(
    column: $table.surfaceForm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get paragraphIndex => $composableBuilder(
    column: $table.paragraphIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startOffset => $composableBuilder(
    column: $table.startOffset,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endOffset =>
      $composableBuilder(column: $table.endOffset, builder: (column) => column);

  GeneratedColumn<bool> get isManuallyCorrected => $composableBuilder(
    column: $table.isManuallyCorrected,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ChaptersTableAnnotationComposer get chapterId {
    final $$ChaptersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chapterId,
      referencedTable: $db.chapters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChaptersTableAnnotationComposer(
            $db: $db,
            $table: $db.chapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VocabularyTableAnnotationComposer get vocabularyId {
    final $$VocabularyTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vocabularyId,
      referencedTable: $db.vocabulary,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VocabularyTableAnnotationComposer(
            $db: $db,
            $table: $db.vocabulary,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VocabularyTableAnnotationComposer get overrideVocabularyId {
    final $$VocabularyTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.overrideVocabularyId,
      referencedTable: $db.vocabulary,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VocabularyTableAnnotationComposer(
            $db: $db,
            $table: $db.vocabulary,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordOccurrencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WordOccurrencesTable,
          WordOccurrence,
          $$WordOccurrencesTableFilterComposer,
          $$WordOccurrencesTableOrderingComposer,
          $$WordOccurrencesTableAnnotationComposer,
          $$WordOccurrencesTableCreateCompanionBuilder,
          $$WordOccurrencesTableUpdateCompanionBuilder,
          (WordOccurrence, $$WordOccurrencesTableReferences),
          WordOccurrence,
          PrefetchHooks Function({
            bool bookId,
            bool chapterId,
            bool vocabularyId,
            bool overrideVocabularyId,
          })
        > {
  $$WordOccurrencesTableTableManager(
    _$AppDatabase db,
    $WordOccurrencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordOccurrencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordOccurrencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordOccurrencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> bookId = const Value.absent(),
                Value<String> chapterId = const Value.absent(),
                Value<String> vocabularyId = const Value.absent(),
                Value<String> surfaceForm = const Value.absent(),
                Value<int> paragraphIndex = const Value.absent(),
                Value<int> startOffset = const Value.absent(),
                Value<int> endOffset = const Value.absent(),
                Value<String?> overrideVocabularyId = const Value.absent(),
                Value<bool> isManuallyCorrected = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WordOccurrencesCompanion(
                id: id,
                bookId: bookId,
                chapterId: chapterId,
                vocabularyId: vocabularyId,
                surfaceForm: surfaceForm,
                paragraphIndex: paragraphIndex,
                startOffset: startOffset,
                endOffset: endOffset,
                overrideVocabularyId: overrideVocabularyId,
                isManuallyCorrected: isManuallyCorrected,
                revision: revision,
                updatedBy: updatedBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String bookId,
                required String chapterId,
                required String vocabularyId,
                required String surfaceForm,
                required int paragraphIndex,
                required int startOffset,
                required int endOffset,
                Value<String?> overrideVocabularyId = const Value.absent(),
                Value<bool> isManuallyCorrected = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => WordOccurrencesCompanion.insert(
                id: id,
                bookId: bookId,
                chapterId: chapterId,
                vocabularyId: vocabularyId,
                surfaceForm: surfaceForm,
                paragraphIndex: paragraphIndex,
                startOffset: startOffset,
                endOffset: endOffset,
                overrideVocabularyId: overrideVocabularyId,
                isManuallyCorrected: isManuallyCorrected,
                revision: revision,
                updatedBy: updatedBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WordOccurrencesTable, WordOccurrence>(table),
                  $$WordOccurrencesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                bookId = false,
                chapterId = false,
                vocabularyId = false,
                overrideVocabularyId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (bookId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.bookId,
                            referencedTable: $$WordOccurrencesTableReferences
                                ._bookIdTable(db),
                            referencedColumn: $$WordOccurrencesTableReferences
                                ._bookIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (chapterId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.chapterId,
                            referencedTable: $$WordOccurrencesTableReferences
                                ._chapterIdTable(db),
                            referencedColumn: $$WordOccurrencesTableReferences
                                ._chapterIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (vocabularyId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.vocabularyId,
                            referencedTable: $$WordOccurrencesTableReferences
                                ._vocabularyIdTable(db),
                            referencedColumn: $$WordOccurrencesTableReferences
                                ._vocabularyIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (overrideVocabularyId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.overrideVocabularyId,
                            referencedTable: $$WordOccurrencesTableReferences
                                ._overrideVocabularyIdTable(db),
                            referencedColumn: $$WordOccurrencesTableReferences
                                ._overrideVocabularyIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$WordOccurrencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WordOccurrencesTable,
      WordOccurrence,
      $$WordOccurrencesTableFilterComposer,
      $$WordOccurrencesTableOrderingComposer,
      $$WordOccurrencesTableAnnotationComposer,
      $$WordOccurrencesTableCreateCompanionBuilder,
      $$WordOccurrencesTableUpdateCompanionBuilder,
      (WordOccurrence, $$WordOccurrencesTableReferences),
      WordOccurrence,
      PrefetchHooks Function({
        bool bookId,
        bool chapterId,
        bool vocabularyId,
        bool overrideVocabularyId,
      })
    >;
typedef $$WordStatusesTableCreateCompanionBuilder =
    WordStatusesCompanion Function({
      required String vocabularyId,
      required String status,
      Value<int> revision,
      Value<String?> updatedBy,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$WordStatusesTableUpdateCompanionBuilder =
    WordStatusesCompanion Function({
      Value<String> vocabularyId,
      Value<String> status,
      Value<int> revision,
      Value<String?> updatedBy,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$WordStatusesTableReferences
    extends BaseReferences<_$AppDatabase, $WordStatusesTable, WordStatuse> {
  $$WordStatusesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VocabularyTable _vocabularyIdTable(_$AppDatabase db) =>
      db.vocabulary.createAlias('word_statuses__vocabulary_id__vocabulary__id');

  $$VocabularyTableProcessedTableManager get vocabularyId {
    final $_column = $_itemColumn<String>('vocabulary_id')!;

    final manager = $$VocabularyTableTableManager(
      $_db,
      $_db.vocabulary,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vocabularyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WordStatusesTableFilterComposer
    extends Composer<_$AppDatabase, $WordStatusesTable> {
  $$WordStatusesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$VocabularyTableFilterComposer get vocabularyId {
    final $$VocabularyTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vocabularyId,
      referencedTable: $db.vocabulary,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VocabularyTableFilterComposer(
            $db: $db,
            $table: $db.vocabulary,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordStatusesTableOrderingComposer
    extends Composer<_$AppDatabase, $WordStatusesTable> {
  $$WordStatusesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$VocabularyTableOrderingComposer get vocabularyId {
    final $$VocabularyTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vocabularyId,
      referencedTable: $db.vocabulary,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VocabularyTableOrderingComposer(
            $db: $db,
            $table: $db.vocabulary,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordStatusesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordStatusesTable> {
  $$WordStatusesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$VocabularyTableAnnotationComposer get vocabularyId {
    final $$VocabularyTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vocabularyId,
      referencedTable: $db.vocabulary,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VocabularyTableAnnotationComposer(
            $db: $db,
            $table: $db.vocabulary,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordStatusesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WordStatusesTable,
          WordStatuse,
          $$WordStatusesTableFilterComposer,
          $$WordStatusesTableOrderingComposer,
          $$WordStatusesTableAnnotationComposer,
          $$WordStatusesTableCreateCompanionBuilder,
          $$WordStatusesTableUpdateCompanionBuilder,
          (WordStatuse, $$WordStatusesTableReferences),
          WordStatuse,
          PrefetchHooks Function({bool vocabularyId})
        > {
  $$WordStatusesTableTableManager(_$AppDatabase db, $WordStatusesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordStatusesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordStatusesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordStatusesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> vocabularyId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WordStatusesCompanion(
                vocabularyId: vocabularyId,
                status: status,
                revision: revision,
                updatedBy: updatedBy,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String vocabularyId,
                required String status,
                Value<int> revision = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => WordStatusesCompanion.insert(
                vocabularyId: vocabularyId,
                status: status,
                revision: revision,
                updatedBy: updatedBy,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WordStatusesTable, WordStatuse>(table),
                  $$WordStatusesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({vocabularyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (vocabularyId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.vocabularyId,
                        referencedTable: $$WordStatusesTableReferences
                            ._vocabularyIdTable(db),
                        referencedColumn: $$WordStatusesTableReferences
                            ._vocabularyIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WordStatusesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WordStatusesTable,
      WordStatuse,
      $$WordStatusesTableFilterComposer,
      $$WordStatusesTableOrderingComposer,
      $$WordStatusesTableAnnotationComposer,
      $$WordStatusesTableCreateCompanionBuilder,
      $$WordStatusesTableUpdateCompanionBuilder,
      (WordStatuse, $$WordStatusesTableReferences),
      WordStatuse,
      PrefetchHooks Function({bool vocabularyId})
    >;
typedef $$DefinitionsTableCreateCompanionBuilder =
    DefinitionsCompanion Function({
      required String id,
      required String vocabularyId,
      Value<String> language,
      required String meaning,
      Value<String?> example,
      Value<int> revision,
      Value<String?> updatedBy,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$DefinitionsTableUpdateCompanionBuilder =
    DefinitionsCompanion Function({
      Value<String> id,
      Value<String> vocabularyId,
      Value<String> language,
      Value<String> meaning,
      Value<String?> example,
      Value<int> revision,
      Value<String?> updatedBy,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$DefinitionsTableReferences
    extends BaseReferences<_$AppDatabase, $DefinitionsTable, Definition> {
  $$DefinitionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VocabularyTable _vocabularyIdTable(_$AppDatabase db) =>
      db.vocabulary.createAlias('definitions__vocabulary_id__vocabulary__id');

  $$VocabularyTableProcessedTableManager get vocabularyId {
    final $_column = $_itemColumn<String>('vocabulary_id')!;

    final manager = $$VocabularyTableTableManager(
      $_db,
      $_db.vocabulary,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vocabularyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DefinitionsTableFilterComposer
    extends Composer<_$AppDatabase, $DefinitionsTable> {
  $$DefinitionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get example => $composableBuilder(
    column: $table.example,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$VocabularyTableFilterComposer get vocabularyId {
    final $$VocabularyTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vocabularyId,
      referencedTable: $db.vocabulary,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VocabularyTableFilterComposer(
            $db: $db,
            $table: $db.vocabulary,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DefinitionsTableOrderingComposer
    extends Composer<_$AppDatabase, $DefinitionsTable> {
  $$DefinitionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get example => $composableBuilder(
    column: $table.example,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$VocabularyTableOrderingComposer get vocabularyId {
    final $$VocabularyTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vocabularyId,
      referencedTable: $db.vocabulary,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VocabularyTableOrderingComposer(
            $db: $db,
            $table: $db.vocabulary,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DefinitionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DefinitionsTable> {
  $$DefinitionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get meaning =>
      $composableBuilder(column: $table.meaning, builder: (column) => column);

  GeneratedColumn<String> get example =>
      $composableBuilder(column: $table.example, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$VocabularyTableAnnotationComposer get vocabularyId {
    final $$VocabularyTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vocabularyId,
      referencedTable: $db.vocabulary,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VocabularyTableAnnotationComposer(
            $db: $db,
            $table: $db.vocabulary,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DefinitionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DefinitionsTable,
          Definition,
          $$DefinitionsTableFilterComposer,
          $$DefinitionsTableOrderingComposer,
          $$DefinitionsTableAnnotationComposer,
          $$DefinitionsTableCreateCompanionBuilder,
          $$DefinitionsTableUpdateCompanionBuilder,
          (Definition, $$DefinitionsTableReferences),
          Definition,
          PrefetchHooks Function({bool vocabularyId})
        > {
  $$DefinitionsTableTableManager(_$AppDatabase db, $DefinitionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DefinitionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DefinitionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DefinitionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> vocabularyId = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<String> meaning = const Value.absent(),
                Value<String?> example = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DefinitionsCompanion(
                id: id,
                vocabularyId: vocabularyId,
                language: language,
                meaning: meaning,
                example: example,
                revision: revision,
                updatedBy: updatedBy,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String vocabularyId,
                Value<String> language = const Value.absent(),
                required String meaning,
                Value<String?> example = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => DefinitionsCompanion.insert(
                id: id,
                vocabularyId: vocabularyId,
                language: language,
                meaning: meaning,
                example: example,
                revision: revision,
                updatedBy: updatedBy,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DefinitionsTable, Definition>(table),
                  $$DefinitionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({vocabularyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (vocabularyId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.vocabularyId,
                        referencedTable: $$DefinitionsTableReferences
                            ._vocabularyIdTable(db),
                        referencedColumn: $$DefinitionsTableReferences
                            ._vocabularyIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DefinitionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DefinitionsTable,
      Definition,
      $$DefinitionsTableFilterComposer,
      $$DefinitionsTableOrderingComposer,
      $$DefinitionsTableAnnotationComposer,
      $$DefinitionsTableCreateCompanionBuilder,
      $$DefinitionsTableUpdateCompanionBuilder,
      (Definition, $$DefinitionsTableReferences),
      Definition,
      PrefetchHooks Function({bool vocabularyId})
    >;
typedef $$FsrsCardsTableCreateCompanionBuilder = FsrsCardsCompanion Function({
  required String vocabularyId,
  required String state,
  required DateTime due,
  Value<double> stability,
  Value<double> difficulty,
  Value<int> elapsedDays,
  Value<int> scheduledDays,
  Value<int> reps,
  Value<int> lapses,
  Value<DateTime?> lastReview,
  Value<int> revision,
  Value<String?> updatedBy,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$FsrsCardsTableUpdateCompanionBuilder = FsrsCardsCompanion Function({
  Value<String> vocabularyId,
  Value<String> state,
  Value<DateTime> due,
  Value<double> stability,
  Value<double> difficulty,
  Value<int> elapsedDays,
  Value<int> scheduledDays,
  Value<int> reps,
  Value<int> lapses,
  Value<DateTime?> lastReview,
  Value<int> revision,
  Value<String?> updatedBy,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$FsrsCardsTableReferences
    extends BaseReferences<_$AppDatabase, $FsrsCardsTable, FsrsCard> {
  $$FsrsCardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VocabularyTable _vocabularyIdTable(_$AppDatabase db) =>
      db.vocabulary.createAlias('fsrs_cards__vocabulary_id__vocabulary__id');

  $$VocabularyTableProcessedTableManager get vocabularyId {
    final $_column = $_itemColumn<String>('vocabulary_id')!;

    final manager = $$VocabularyTableTableManager(
      $_db,
      $_db.vocabulary,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vocabularyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FsrsCardsTableFilterComposer
    extends Composer<_$AppDatabase, $FsrsCardsTable> {
  $$FsrsCardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get due => $composableBuilder(
    column: $table.due,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stability => $composableBuilder(
    column: $table.stability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get elapsedDays => $composableBuilder(
    column: $table.elapsedDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scheduledDays => $composableBuilder(
    column: $table.scheduledDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lapses => $composableBuilder(
    column: $table.lapses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReview => $composableBuilder(
    column: $table.lastReview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$VocabularyTableFilterComposer get vocabularyId {
    final $$VocabularyTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vocabularyId,
      referencedTable: $db.vocabulary,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VocabularyTableFilterComposer(
            $db: $db,
            $table: $db.vocabulary,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FsrsCardsTableOrderingComposer
    extends Composer<_$AppDatabase, $FsrsCardsTable> {
  $$FsrsCardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get due => $composableBuilder(
    column: $table.due,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stability => $composableBuilder(
    column: $table.stability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get elapsedDays => $composableBuilder(
    column: $table.elapsedDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scheduledDays => $composableBuilder(
    column: $table.scheduledDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lapses => $composableBuilder(
    column: $table.lapses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReview => $composableBuilder(
    column: $table.lastReview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$VocabularyTableOrderingComposer get vocabularyId {
    final $$VocabularyTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vocabularyId,
      referencedTable: $db.vocabulary,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VocabularyTableOrderingComposer(
            $db: $db,
            $table: $db.vocabulary,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FsrsCardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FsrsCardsTable> {
  $$FsrsCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<DateTime> get due =>
      $composableBuilder(column: $table.due, builder: (column) => column);

  GeneratedColumn<double> get stability =>
      $composableBuilder(column: $table.stability, builder: (column) => column);

  GeneratedColumn<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<int> get elapsedDays => $composableBuilder(
    column: $table.elapsedDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get scheduledDays => $composableBuilder(
    column: $table.scheduledDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<int> get lapses =>
      $composableBuilder(column: $table.lapses, builder: (column) => column);

  GeneratedColumn<DateTime> get lastReview => $composableBuilder(
    column: $table.lastReview,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$VocabularyTableAnnotationComposer get vocabularyId {
    final $$VocabularyTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vocabularyId,
      referencedTable: $db.vocabulary,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VocabularyTableAnnotationComposer(
            $db: $db,
            $table: $db.vocabulary,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FsrsCardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FsrsCardsTable,
          FsrsCard,
          $$FsrsCardsTableFilterComposer,
          $$FsrsCardsTableOrderingComposer,
          $$FsrsCardsTableAnnotationComposer,
          $$FsrsCardsTableCreateCompanionBuilder,
          $$FsrsCardsTableUpdateCompanionBuilder,
          (FsrsCard, $$FsrsCardsTableReferences),
          FsrsCard,
          PrefetchHooks Function({bool vocabularyId})
        > {
  $$FsrsCardsTableTableManager(_$AppDatabase db, $FsrsCardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FsrsCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FsrsCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FsrsCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> vocabularyId = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<DateTime> due = const Value.absent(),
                Value<double> stability = const Value.absent(),
                Value<double> difficulty = const Value.absent(),
                Value<int> elapsedDays = const Value.absent(),
                Value<int> scheduledDays = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<int> lapses = const Value.absent(),
                Value<DateTime?> lastReview = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FsrsCardsCompanion(
                vocabularyId: vocabularyId,
                state: state,
                due: due,
                stability: stability,
                difficulty: difficulty,
                elapsedDays: elapsedDays,
                scheduledDays: scheduledDays,
                reps: reps,
                lapses: lapses,
                lastReview: lastReview,
                revision: revision,
                updatedBy: updatedBy,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String vocabularyId,
                required String state,
                required DateTime due,
                Value<double> stability = const Value.absent(),
                Value<double> difficulty = const Value.absent(),
                Value<int> elapsedDays = const Value.absent(),
                Value<int> scheduledDays = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<int> lapses = const Value.absent(),
                Value<DateTime?> lastReview = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => FsrsCardsCompanion.insert(
                vocabularyId: vocabularyId,
                state: state,
                due: due,
                stability: stability,
                difficulty: difficulty,
                elapsedDays: elapsedDays,
                scheduledDays: scheduledDays,
                reps: reps,
                lapses: lapses,
                lastReview: lastReview,
                revision: revision,
                updatedBy: updatedBy,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FsrsCardsTable, FsrsCard>(table),
                  $$FsrsCardsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({vocabularyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (vocabularyId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.vocabularyId,
                        referencedTable: $$FsrsCardsTableReferences
                            ._vocabularyIdTable(db),
                        referencedColumn: $$FsrsCardsTableReferences
                            ._vocabularyIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FsrsCardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FsrsCardsTable,
      FsrsCard,
      $$FsrsCardsTableFilterComposer,
      $$FsrsCardsTableOrderingComposer,
      $$FsrsCardsTableAnnotationComposer,
      $$FsrsCardsTableCreateCompanionBuilder,
      $$FsrsCardsTableUpdateCompanionBuilder,
      (FsrsCard, $$FsrsCardsTableReferences),
      FsrsCard,
      PrefetchHooks Function({bool vocabularyId})
    >;
typedef $$ReviewLogsTableCreateCompanionBuilder = ReviewLogsCompanion Function({
  required String id,
  required String vocabularyId,
  required DateTime reviewedAt,
  required int rating,
  required String stateBefore,
  required String stateAfter,
  required double stabilityBefore,
  required double stabilityAfter,
  required int intervalDays,
  required DateTime dueAfter,
  Value<String?> deviceId,
  Value<int> rowid,
});
typedef $$ReviewLogsTableUpdateCompanionBuilder = ReviewLogsCompanion Function({
  Value<String> id,
  Value<String> vocabularyId,
  Value<DateTime> reviewedAt,
  Value<int> rating,
  Value<String> stateBefore,
  Value<String> stateAfter,
  Value<double> stabilityBefore,
  Value<double> stabilityAfter,
  Value<int> intervalDays,
  Value<DateTime> dueAfter,
  Value<String?> deviceId,
  Value<int> rowid,
});

final class $$ReviewLogsTableReferences
    extends BaseReferences<_$AppDatabase, $ReviewLogsTable, ReviewLog> {
  $$ReviewLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VocabularyTable _vocabularyIdTable(_$AppDatabase db) =>
      db.vocabulary.createAlias('review_logs__vocabulary_id__vocabulary__id');

  $$VocabularyTableProcessedTableManager get vocabularyId {
    final $_column = $_itemColumn<String>('vocabulary_id')!;

    final manager = $$VocabularyTableTableManager(
      $_db,
      $_db.vocabulary,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vocabularyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReviewLogsTableFilterComposer
    extends Composer<_$AppDatabase, $ReviewLogsTable> {
  $$ReviewLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stateBefore => $composableBuilder(
    column: $table.stateBefore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stateAfter => $composableBuilder(
    column: $table.stateAfter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stabilityBefore => $composableBuilder(
    column: $table.stabilityBefore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stabilityAfter => $composableBuilder(
    column: $table.stabilityAfter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueAfter => $composableBuilder(
    column: $table.dueAfter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  $$VocabularyTableFilterComposer get vocabularyId {
    final $$VocabularyTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vocabularyId,
      referencedTable: $db.vocabulary,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VocabularyTableFilterComposer(
            $db: $db,
            $table: $db.vocabulary,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReviewLogsTable> {
  $$ReviewLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stateBefore => $composableBuilder(
    column: $table.stateBefore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stateAfter => $composableBuilder(
    column: $table.stateAfter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stabilityBefore => $composableBuilder(
    column: $table.stabilityBefore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stabilityAfter => $composableBuilder(
    column: $table.stabilityAfter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueAfter => $composableBuilder(
    column: $table.dueAfter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  $$VocabularyTableOrderingComposer get vocabularyId {
    final $$VocabularyTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vocabularyId,
      referencedTable: $db.vocabulary,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VocabularyTableOrderingComposer(
            $db: $db,
            $table: $db.vocabulary,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReviewLogsTable> {
  $$ReviewLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get stateBefore => $composableBuilder(
    column: $table.stateBefore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get stateAfter => $composableBuilder(
    column: $table.stateAfter,
    builder: (column) => column,
  );

  GeneratedColumn<double> get stabilityBefore => $composableBuilder(
    column: $table.stabilityBefore,
    builder: (column) => column,
  );

  GeneratedColumn<double> get stabilityAfter => $composableBuilder(
    column: $table.stabilityAfter,
    builder: (column) => column,
  );

  GeneratedColumn<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueAfter =>
      $composableBuilder(column: $table.dueAfter, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  $$VocabularyTableAnnotationComposer get vocabularyId {
    final $$VocabularyTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vocabularyId,
      referencedTable: $db.vocabulary,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VocabularyTableAnnotationComposer(
            $db: $db,
            $table: $db.vocabulary,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReviewLogsTable,
          ReviewLog,
          $$ReviewLogsTableFilterComposer,
          $$ReviewLogsTableOrderingComposer,
          $$ReviewLogsTableAnnotationComposer,
          $$ReviewLogsTableCreateCompanionBuilder,
          $$ReviewLogsTableUpdateCompanionBuilder,
          (ReviewLog, $$ReviewLogsTableReferences),
          ReviewLog,
          PrefetchHooks Function({bool vocabularyId})
        > {
  $$ReviewLogsTableTableManager(_$AppDatabase db, $ReviewLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReviewLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReviewLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReviewLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> vocabularyId = const Value.absent(),
                Value<DateTime> reviewedAt = const Value.absent(),
                Value<int> rating = const Value.absent(),
                Value<String> stateBefore = const Value.absent(),
                Value<String> stateAfter = const Value.absent(),
                Value<double> stabilityBefore = const Value.absent(),
                Value<double> stabilityAfter = const Value.absent(),
                Value<int> intervalDays = const Value.absent(),
                Value<DateTime> dueAfter = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReviewLogsCompanion(
                id: id,
                vocabularyId: vocabularyId,
                reviewedAt: reviewedAt,
                rating: rating,
                stateBefore: stateBefore,
                stateAfter: stateAfter,
                stabilityBefore: stabilityBefore,
                stabilityAfter: stabilityAfter,
                intervalDays: intervalDays,
                dueAfter: dueAfter,
                deviceId: deviceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String vocabularyId,
                required DateTime reviewedAt,
                required int rating,
                required String stateBefore,
                required String stateAfter,
                required double stabilityBefore,
                required double stabilityAfter,
                required int intervalDays,
                required DateTime dueAfter,
                Value<String?> deviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReviewLogsCompanion.insert(
                id: id,
                vocabularyId: vocabularyId,
                reviewedAt: reviewedAt,
                rating: rating,
                stateBefore: stateBefore,
                stateAfter: stateAfter,
                stabilityBefore: stabilityBefore,
                stabilityAfter: stabilityAfter,
                intervalDays: intervalDays,
                dueAfter: dueAfter,
                deviceId: deviceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReviewLogsTable, ReviewLog>(table),
                  $$ReviewLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({vocabularyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (vocabularyId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.vocabularyId,
                        referencedTable: $$ReviewLogsTableReferences
                            ._vocabularyIdTable(db),
                        referencedColumn: $$ReviewLogsTableReferences
                            ._vocabularyIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReviewLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReviewLogsTable,
      ReviewLog,
      $$ReviewLogsTableFilterComposer,
      $$ReviewLogsTableOrderingComposer,
      $$ReviewLogsTableAnnotationComposer,
      $$ReviewLogsTableCreateCompanionBuilder,
      $$ReviewLogsTableUpdateCompanionBuilder,
      (ReviewLog, $$ReviewLogsTableReferences),
      ReviewLog,
      PrefetchHooks Function({bool vocabularyId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSetting>(table),
                  BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$AppMetadataTableCreateCompanionBuilder =
    AppMetadataCompanion Function({
      required String key,
      required String value,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AppMetadataTableUpdateCompanionBuilder =
    AppMetadataCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AppMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $AppMetadataTable> {
  $$AppMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $AppMetadataTable> {
  $$AppMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppMetadataTable> {
  $$AppMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppMetadataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppMetadataTable,
          AppMetadataData,
          $$AppMetadataTableFilterComposer,
          $$AppMetadataTableOrderingComposer,
          $$AppMetadataTableAnnotationComposer,
          $$AppMetadataTableCreateCompanionBuilder,
          $$AppMetadataTableUpdateCompanionBuilder,
          (
            AppMetadataData,
            BaseReferences<_$AppDatabase, $AppMetadataTable, AppMetadataData>,
          ),
          AppMetadataData,
          PrefetchHooks Function()
        > {
  $$AppMetadataTableTableManager(_$AppDatabase db, $AppMetadataTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppMetadataCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppMetadataCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppMetadataTable, AppMetadataData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AppMetadataTable,
                    AppMetadataData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppMetadataTable,
      AppMetadataData,
      $$AppMetadataTableFilterComposer,
      $$AppMetadataTableOrderingComposer,
      $$AppMetadataTableAnnotationComposer,
      $$AppMetadataTableCreateCompanionBuilder,
      $$AppMetadataTableUpdateCompanionBuilder,
      (
        AppMetadataData,
        BaseReferences<_$AppDatabase, $AppMetadataTable, AppMetadataData>,
      ),
      AppMetadataData,
      PrefetchHooks Function()
    >;
typedef $$SyncMetadataTableCreateCompanionBuilder =
    SyncMetadataCompanion Function({
      required String id,
      required String entityType,
      required String entityId,
      required DateTime localUpdatedAt,
      Value<DateTime?> lastSyncedAt,
      Value<int?> lastSyncedVersion,
      Value<String> syncStatus,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$SyncMetadataTableUpdateCompanionBuilder =
    SyncMetadataCompanion Function({
      Value<String> id,
      Value<String> entityType,
      Value<String> entityId,
      Value<DateTime> localUpdatedAt,
      Value<DateTime?> lastSyncedAt,
      Value<int?> lastSyncedVersion,
      Value<String> syncStatus,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$SyncMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSyncedVersion => $composableBuilder(
    column: $table.lastSyncedVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSyncedVersion => $composableBuilder(
    column: $table.lastSyncedVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSyncedVersion => $composableBuilder(
    column: $table.lastSyncedVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$SyncMetadataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncMetadataTable,
          SyncMetadataData,
          $$SyncMetadataTableFilterComposer,
          $$SyncMetadataTableOrderingComposer,
          $$SyncMetadataTableAnnotationComposer,
          $$SyncMetadataTableCreateCompanionBuilder,
          $$SyncMetadataTableUpdateCompanionBuilder,
          (
            SyncMetadataData,
            BaseReferences<_$AppDatabase, $SyncMetadataTable, SyncMetadataData>,
          ),
          SyncMetadataData,
          PrefetchHooks Function()
        > {
  $$SyncMetadataTableTableManager(_$AppDatabase db, $SyncMetadataTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int?> lastSyncedVersion = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetadataCompanion(
                id: id,
                entityType: entityType,
                entityId: entityId,
                localUpdatedAt: localUpdatedAt,
                lastSyncedAt: lastSyncedAt,
                lastSyncedVersion: lastSyncedVersion,
                syncStatus: syncStatus,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entityType,
                required String entityId,
                required DateTime localUpdatedAt,
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int?> lastSyncedVersion = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetadataCompanion.insert(
                id: id,
                entityType: entityType,
                entityId: entityId,
                localUpdatedAt: localUpdatedAt,
                lastSyncedAt: lastSyncedAt,
                lastSyncedVersion: lastSyncedVersion,
                syncStatus: syncStatus,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncMetadataTable, SyncMetadataData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SyncMetadataTable,
                    SyncMetadataData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncMetadataTable,
      SyncMetadataData,
      $$SyncMetadataTableFilterComposer,
      $$SyncMetadataTableOrderingComposer,
      $$SyncMetadataTableAnnotationComposer,
      $$SyncMetadataTableCreateCompanionBuilder,
      $$SyncMetadataTableUpdateCompanionBuilder,
      (
        SyncMetadataData,
        BaseReferences<_$AppDatabase, $SyncMetadataTable, SyncMetadataData>,
      ),
      SyncMetadataData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db, _db.books);
  $$BookGroupsTableTableManager get bookGroups =>
      $$BookGroupsTableTableManager(_db, _db.bookGroups);
  $$BookGroupBooksTableTableManager get bookGroupBooks =>
      $$BookGroupBooksTableTableManager(_db, _db.bookGroupBooks);
  $$DictionariesTableTableManager get dictionaries =>
      $$DictionariesTableTableManager(_db, _db.dictionaries);
  $$DictionaryEntriesTableTableManager get dictionaryEntries =>
      $$DictionaryEntriesTableTableManager(_db, _db.dictionaryEntries);
  $$ChaptersTableTableManager get chapters =>
      $$ChaptersTableTableManager(_db, _db.chapters);
  $$ReadingProgressTableTableManager get readingProgress =>
      $$ReadingProgressTableTableManager(_db, _db.readingProgress);
  $$PaginationCachesTableTableManager get paginationCaches =>
      $$PaginationCachesTableTableManager(_db, _db.paginationCaches);
  $$VocabularyTableTableManager get vocabulary =>
      $$VocabularyTableTableManager(_db, _db.vocabulary);
  $$WordFormsTableTableManager get wordForms =>
      $$WordFormsTableTableManager(_db, _db.wordForms);
  $$WordOccurrencesTableTableManager get wordOccurrences =>
      $$WordOccurrencesTableTableManager(_db, _db.wordOccurrences);
  $$WordStatusesTableTableManager get wordStatuses =>
      $$WordStatusesTableTableManager(_db, _db.wordStatuses);
  $$DefinitionsTableTableManager get definitions =>
      $$DefinitionsTableTableManager(_db, _db.definitions);
  $$FsrsCardsTableTableManager get fsrsCards =>
      $$FsrsCardsTableTableManager(_db, _db.fsrsCards);
  $$ReviewLogsTableTableManager get reviewLogs =>
      $$ReviewLogsTableTableManager(_db, _db.reviewLogs);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$AppMetadataTableTableManager get appMetadata =>
      $$AppMetadataTableTableManager(_db, _db.appMetadata);
  $$SyncMetadataTableTableManager get syncMetadata =>
      $$SyncMetadataTableTableManager(_db, _db.syncMetadata);
}
