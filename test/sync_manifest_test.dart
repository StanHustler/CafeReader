import 'package:cafereader/core/sync/sync_manifest.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sync manifest round-trips database and media entries', () {
    final manifest = SyncManifest(
      formatVersion: SyncManifest.currentFormatVersion,
      schemaVersion: 1,
      generatedAt: DateTime.utc(2026, 5, 1, 10),
      deviceId: 'device-a',
      database: const SyncFileEntry(
        path: 'database/snapshot.sqlite',
        size: 2048,
        sha256: 'abc',
      ),
      files: const [
        SyncFileEntry(path: 'books/book.epub', size: 100, sha256: 'def'),
      ],
    );
    final parsed = SyncManifest.parse(manifest.encode());
    expect(parsed.deviceId, 'device-a');
    expect(parsed.database.path, 'database/snapshot.sqlite');
    expect(parsed.files.single.path, 'books/book.epub');
    expect(parsed.generatedAt, DateTime.utc(2026, 5, 1, 10));
  });

  test('sync manifest rejects unrelated or incomplete JSON', () {
    expect(
      () => SyncManifest.parse('{"app":"Other","database":{}}'.codeUnits),
      throwsFormatException,
    );
    expect(
      () => SyncManifest.parse('{"app":"CafeReader","database":{}}'.codeUnits),
      throwsFormatException,
    );
  });
}
