import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../../core/design/app_theme.dart';
import '../../core/design/word_mark.dart';

class ReaderSettings {
  const ReaderSettings({
    this.fontFamily = 'Literata',
    this.fontSize = 19,
    this.fontWeight = 400,
    this.lineHeight = 1.65,
    this.paragraphSpacing = 14,
    this.horizontalPadding = 28,
    this.verticalPadding = 24,
    this.volumeKeysTurnPages = false,
    this.lemmatizerEnabled = true,
  });

  final String fontFamily;
  final double fontSize;
  final int fontWeight;
  final double lineHeight;
  final double paragraphSpacing;
  final double horizontalPadding;
  final double verticalPadding;
  final bool volumeKeysTurnPages;
  final bool lemmatizerEnabled;

  ReaderSettings copyWith({
    String? fontFamily,
    double? fontSize,
    int? fontWeight,
    double? lineHeight,
    double? paragraphSpacing,
    double? horizontalPadding,
    double? verticalPadding,
    bool? volumeKeysTurnPages,
    bool? lemmatizerEnabled,
  }) {
    return ReaderSettings(
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      lineHeight: lineHeight ?? this.lineHeight,
      paragraphSpacing: paragraphSpacing ?? this.paragraphSpacing,
      horizontalPadding: horizontalPadding ?? this.horizontalPadding,
      verticalPadding: verticalPadding ?? this.verticalPadding,
      volumeKeysTurnPages: volumeKeysTurnPages ?? this.volumeKeysTurnPages,
      lemmatizerEnabled: lemmatizerEnabled ?? this.lemmatizerEnabled,
    );
  }
}

/// The three appearances that can carry their own word-mark style.
enum WordMarkMode {
  day('day', 'Day'),
  night('night', 'Night'),
  eink('eink', 'E-ink');

  const WordMarkMode(this.storageValue, this.label);

  final String storageValue;
  final String label;
}

/// The three kinds of words the reader can mark. New words have no vocabulary
/// entry yet, Learning words are in the deck, and Known words are retired.
enum WordMarkTarget {
  newWord('new', 'New'),
  learning('learning', 'Learning'),
  known('known', 'Known');

  const WordMarkTarget(this.storageValue, this.label);

  final String storageValue;
  final String label;
}

/// Every mark configuration, keyed by appearance and word category.
class WordMarkSettings {
  const WordMarkSettings(this.byMode);

  final Map<WordMarkMode, Map<WordMarkTarget, WordMarkAppearance>> byMode;

  WordMarkAppearance appearance(WordMarkMode mode, WordMarkTarget target) =>
      byMode[mode]?[target] ?? defaultFor(mode, target);

  /// Defaults come from the theme palette so the reader's marks stay in the
  /// same colour system as the rest of the app. New and Learning words are
  /// filled on screens and switch to border / double underline on e-ink;
  /// Known words stay plain.
  static WordMarkAppearance defaultFor(
    WordMarkMode mode,
    WordMarkTarget target,
  ) {
    final colors = switch (mode) {
      WordMarkMode.day => CafeTheme.light,
      WordMarkMode.night => CafeTheme.dark,
      WordMarkMode.eink => CafeTheme.eink,
    };
    final style = switch (target) {
      WordMarkTarget.newWord =>
        mode == WordMarkMode.eink ? WordMarkStyle.border : WordMarkStyle.fill,
      WordMarkTarget.learning =>
        mode == WordMarkMode.eink
            ? WordMarkStyle.underlineDouble
            : WordMarkStyle.fill,
      WordMarkTarget.known => WordMarkStyle.none,
    };
    final (color, focusColor) = switch (target) {
      WordMarkTarget.newWord => (colors.newWordMark, colors.newWordFocus),
      WordMarkTarget.learning => (colors.learningMark, colors.learningFocus),
      WordMarkTarget.known => (colors.ink, colors.ink),
    };
    return WordMarkAppearance(
      style: style,
      color: color,
      focusColor: focusColor,
    );
  }

  static final WordMarkSettings defaults = WordMarkSettings({
    for (final mode in WordMarkMode.values)
      mode: {
        for (final target in WordMarkTarget.values)
          target: defaultFor(mode, target),
      },
  });
}

/// The four appearance modes offered in Settings.
enum AppAppearanceMode {
  light('light', 'Day'),
  dark('dark', 'Night'),
  auto('auto', 'Auto'),
  eink('eink', 'E-ink');

  const AppAppearanceMode(this.storageValue, this.label);

  final String storageValue;
  final String label;

  static AppAppearanceMode fromStorage(String? value) => switch (value) {
    'dark' => dark,
    'auto' => auto,
    'eink' => eink,
    _ => light,
  };
}

/// Colours of the application chrome and the reading page. The reader follows
/// this appearance so the whole app stays on one palette.
class AppAppearance {
  const AppAppearance({this.mode = AppAppearanceMode.light});

  final AppAppearanceMode mode;

  AppAppearance copyWith({AppAppearanceMode? mode}) =>
      AppAppearance(mode: mode ?? this.mode);
}

class FsrsSettings {
  const FsrsSettings({
    this.dailyNewLimit = 20,
    this.dailyReviewLimit = 200,
    this.desiredRetention = 0.9,
  });

  final int dailyNewLimit;
  final int dailyReviewLimit;
  final double desiredRetention;
}

class SettingsRepository {
  SettingsRepository(this.db, this.deviceId);

  final AppDatabase db;
  final String deviceId;

  static const _defaults = <String, String>{
    'reader_font_family': 'Literata',
    'reader_font_size': '19',
    'reader_font_weight': '400',
    'reader_line_height': '1.65',
    'reader_paragraph_spacing': '14',
    'reader_horizontal_padding': '28',
    'reader_vertical_padding': '24',
    'app_theme': 'light',
    'volume_keys_turn_pages': 'false',
    'lemmatizer_enabled': 'true',
    'fsrs_daily_new_limit': '20',
    'fsrs_daily_review_limit': '200',
    'fsrs_desired_retention': '0.9',
    'last_sync_at': '',
    'last_sync_result': '',
    'onedrive_client_id': '',
  };

  Future<void> ensureDefaults() async {
    final existing = await db.select(db.appSettings).get();
    final keys = existing.map((row) => row.key).toSet();
    final now = DateTime.now();
    await db.batch((batch) {
      for (final entry in _defaults.entries) {
        if (keys.contains(entry.key)) continue;
        batch.insert(
          db.appSettings,
          AppSettingsCompanion.insert(
            key: entry.key,
            value: entry.value,
            updatedAt: now,
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Stream<Map<String, String>> watchAll() {
    return db
        .select(db.appSettings)
        .watch()
        .map((rows) => {for (final row in rows) row.key: row.value});
  }

  Future<Map<String, String>> getAll() async {
    final rows = await db.select(db.appSettings).get();
    return {for (final row in rows) row.key: row.value};
  }

  Stream<ReaderSettings> watchReaderSettings() =>
      watchAll().map(readerSettingsFromMap);

  Future<ReaderSettings> getReaderSettings() async =>
      readerSettingsFromMap(await getAll());

  ReaderSettings readerSettingsFromMap(Map<String, String> values) {
    String read(String key) => values[key] ?? _defaults[key] ?? '';
    double readDouble(String key, double fallback) =>
        double.tryParse(read(key)) ?? fallback;
    int readInt(String key, int fallback) =>
        int.tryParse(read(key)) ?? fallback;
    bool readBool(String key, bool fallback) {
      final value = read(key).toLowerCase();
      if (value == 'true') return true;
      if (value == 'false') return false;
      return fallback;
    }

    return ReaderSettings(
      fontFamily: read('reader_font_family'),
      fontSize: readDouble('reader_font_size', 19),
      fontWeight: readInt('reader_font_weight', 400),
      lineHeight: readDouble('reader_line_height', 1.65),
      paragraphSpacing: readDouble('reader_paragraph_spacing', 14),
      horizontalPadding: readDouble('reader_horizontal_padding', 28),
      verticalPadding: readDouble('reader_vertical_padding', 24),
      volumeKeysTurnPages: readBool('volume_keys_turn_pages', false),
      lemmatizerEnabled: readBool('lemmatizer_enabled', true),
    );
  }

  WordMarkSettings wordMarkSettingsFromMap(Map<String, String> values) {
    WordMarkAppearance read(WordMarkMode mode, WordMarkTarget target) {
      final fallback = WordMarkSettings.defaultFor(mode, target);
      final raw = values[_markKey(mode, target)];
      if (raw == null || raw.isEmpty) return fallback;
      final parts = raw.split(';');
      return WordMarkAppearance(
        style: WordMarkStyle.fromStorage(parts.first),
        color: colorFromStorage(
          parts.length > 1 ? parts[1] : null,
          fallback.color,
        ),
        focusColor: colorFromStorage(
          parts.length > 2 ? parts[2] : null,
          fallback.focusColor,
        ),
      );
    }

    return WordMarkSettings({
      for (final mode in WordMarkMode.values)
        mode: {
          for (final target in WordMarkTarget.values)
            target: read(mode, target),
        },
    });
  }

  static String _markKey(WordMarkMode mode, WordMarkTarget target) =>
      'mark_${target.storageValue}_${mode.storageValue}';

  Stream<WordMarkSettings> watchWordMarkSettings() =>
      watchAll().map(wordMarkSettingsFromMap);

  Future<WordMarkSettings> getWordMarkSettings() async =>
      wordMarkSettingsFromMap(await getAll());

  Future<void> setWordMarkAppearance(
    WordMarkMode mode,
    WordMarkTarget target,
    WordMarkAppearance appearance,
  ) => set(
    _markKey(mode, target),
    '${appearance.style.storageValue};'
    '${colorToStorage(appearance.color)};'
    '${colorToStorage(appearance.focusColor)}',
  );

  Stream<AppAppearance> watchAppAppearance() =>
      watchAll().map(appAppearanceFromMap);

  Future<AppAppearance> getAppAppearance() async =>
      appAppearanceFromMap(await getAll());

  AppAppearance appAppearanceFromMap(Map<String, String> values) {
    final stored = values['app_theme'] ?? _defaults['app_theme'];
    return AppAppearance(mode: AppAppearanceMode.fromStorage(stored));
  }

  FsrsSettings fsrsSettingsFromMap(Map<String, String> values) {
    return FsrsSettings(
      dailyNewLimit: int.tryParse(values['fsrs_daily_new_limit'] ?? '') ?? 20,
      dailyReviewLimit:
          int.tryParse(values['fsrs_daily_review_limit'] ?? '') ?? 200,
      desiredRetention:
          double.tryParse(values['fsrs_desired_retention'] ?? '') ?? 0.9,
    );
  }

  Stream<FsrsSettings> watchFsrsSettings() =>
      watchAll().map(fsrsSettingsFromMap);

  Future<void> set(String key, String value) async {
    await db
        .into(db.appSettings)
        .insert(
          AppSettingsCompanion.insert(
            key: key,
            value: value,
            updatedAt: DateTime.now(),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<void> setBool(String key, bool value) => set(key, value.toString());
  Future<void> setDouble(String key, double value) => set(key, '$value');
  Future<void> setInt(String key, int value) => set(key, '$value');

  Future<void> setMetadata(String key, String value) async {
    await db
        .into(db.appMetadata)
        .insert(
          AppMetadataCompanion.insert(
            key: key,
            value: value,
            updatedAt: DateTime.now(),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<String?> getMetadata(String key) async {
    final row = await (db.select(
      db.appMetadata,
    )..where((table) => table.key.equals(key))).getSingleOrNull();
    return row?.value;
  }
}
