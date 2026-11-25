import 'dart:convert';

class SyncFileEntry {
  const SyncFileEntry({
    required this.path,
    required this.size,
    required this.sha256,
  });

  final String path;
  final int size;
  final String sha256;

  Map<String, Object?> toJson() => {
    'path': path,
    'size': size,
    'sha256': sha256,
  };

  static SyncFileEntry? fromJson(Object? value) {
    if (value is! Map) return null;
    final path = value['path']?.toString();
    final size = (value['size'] as num?)?.toInt();
    final sha = value['sha256']?.toString();
    if (path == null || size == null || sha == null) return null;
    return SyncFileEntry(path: path, size: size, sha256: sha);
  }
}

class SyncManifest {
  const SyncManifest({
    required this.formatVersion,
    required this.schemaVersion,
    required this.generatedAt,
    required this.deviceId,
    required this.database,
    required this.files,
  });

  final int formatVersion;
  final int schemaVersion;
  final DateTime generatedAt;
  final String deviceId;
  final SyncFileEntry database;
  final List<SyncFileEntry> files;

  static const int currentFormatVersion = 1;

  Map<String, Object?> toJson() => {
    'format_version': formatVersion,
    'app': 'CafeReader',
    'schema_version': schemaVersion,
    'generated_at': generatedAt.toUtc().toIso8601String(),
    'device_id': deviceId,
    'database': database.toJson(),
    'files': files.map((file) => file.toJson()).toList(),
  };

  List<int> encode() => utf8.encode(jsonEncode(toJson()));

  static SyncManifest parse(List<int> bytes) {
    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is! Map ||
        decoded['app'] != 'CafeReader' ||
        decoded['database'] is! Map) {
      throw const FormatException('Invalid CafeReader sync manifest.');
    }
    final database = SyncFileEntry.fromJson(decoded['database']);
    if (database == null) {
      throw const FormatException('Sync manifest database is missing.');
    }
    final files = <SyncFileEntry>[];
    final rawFiles = decoded['files'];
    if (rawFiles is List) {
      for (final value in rawFiles) {
        final file = SyncFileEntry.fromJson(value);
        if (file != null) files.add(file);
      }
    }
    final generatedAt = DateTime.tryParse(
      decoded['generated_at']?.toString() ?? '',
    );
    if (generatedAt == null) {
      throw const FormatException('Sync manifest timestamp is invalid.');
    }
    return SyncManifest(
      formatVersion: (decoded['format_version'] as num?)?.toInt() ?? 0,
      schemaVersion: (decoded['schema_version'] as num?)?.toInt() ?? 0,
      generatedAt: generatedAt,
      deviceId: decoded['device_id']?.toString() ?? '',
      database: database,
      files: files,
    );
  }
}
