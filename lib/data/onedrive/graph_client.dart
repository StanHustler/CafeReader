import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class OneDriveException implements Exception {
  OneDriveException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => message;
}

class SyncCancellation {
  bool _cancelled = false;
  bool get isCancelled => _cancelled;
  void cancel() => _cancelled = true;

  void throwIfCancelled() {
    if (_cancelled) throw const SyncCancelledException();
  }
}

class SyncCancelledException implements Exception {
  const SyncCancelledException();
  @override
  String toString() => 'Sync cancelled.';
}

class CloudManifest {
  const CloudManifest({required this.bytes, this.etag});
  final List<int> bytes;
  final String? etag;
}

/// The subset of Microsoft Graph used by the sync engine. Keeping this
/// interface separate allows the sync workflow itself to be tested with a
/// deterministic in-memory Graph implementation.
abstract class GraphApi {
  Future<Map<String, dynamic>?> itemMetadata(String path);

  Future<CloudManifest?> downloadManifest(
    String path, {
    SyncCancellation? cancellation,
  });

  Future<bool> downloadToFile(
    String path,
    File destination, {
    SyncCancellation? cancellation,
    void Function(int received, int? total)? onProgress,
  });

  Future<void> uploadBytes(
    String path,
    List<int> bytes, {
    Map<String, String> extraHeaders = const {},
    SyncCancellation? cancellation,
  });

  Future<void> uploadFile(
    String path,
    File file, {
    SyncCancellation? cancellation,
    void Function(int sent, int total)? onProgress,
  });
}

class GraphClient implements GraphApi {
  GraphClient(this._accessToken);

  final Future<String> Function({bool forceRefresh}) _accessToken;
  final http.Client _client = http.Client();

  static const String _base =
      'https://graph.microsoft.com/v1.0/me/drive/special/approot';

  Uri _contentUri(String path) => Uri.parse(
    '$_base:/${path.split('/').map(Uri.encodeComponent).join('/')}:/content',
  );

  Uri _itemUri(String path) => Uri.parse(
    '$_base:/${path.split('/').map(Uri.encodeComponent).join('/')}',
  );

  @override
  @override
  Future<Map<String, dynamic>?> itemMetadata(String path) async {
    return _withAuth((token) async {
      final response = await _client
          .get(_itemUri(path), headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 404) return null;
      _throwIfError(response);
      final json = jsonDecode(response.body);
      return json is Map<String, dynamic> ? json : null;
    });
  }

  @override
  @override
  Future<CloudManifest?> downloadManifest(
    String path, {
    SyncCancellation? cancellation,
  }) async {
    cancellation?.throwIfCancelled();
    return _withAuth((token) async {
      final response = await _client
          .get(_contentUri(path), headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 404) return null;
      _throwIfError(response);
      return CloudManifest(
        bytes: response.bodyBytes,
        etag: response.headers['etag'],
      );
    });
  }

  Future<Uint8List?> downloadBytes(
    String path, {
    SyncCancellation? cancellation,
  }) async {
    cancellation?.throwIfCancelled();
    return _withAuth((token) async {
      final response = await _client
          .get(_contentUri(path), headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 60));
      if (response.statusCode == 404) return null;
      _throwIfError(response);
      cancellation?.throwIfCancelled();
      return response.bodyBytes;
    });
  }

  @override
  @override
  Future<bool> downloadToFile(
    String path,
    File destination, {
    SyncCancellation? cancellation,
    void Function(int received, int? total)? onProgress,
  }) async {
    cancellation?.throwIfCancelled();
    final token = await _accessToken();
    var request = http.Request('GET', _contentUri(path))
      ..headers['Authorization'] = 'Bearer $token'
      ..followRedirects = false;
    var response = await _client.send(request);
    if (response.statusCode == 401) {
      await response.stream.drain<void>();
      final refreshed = await _accessToken(forceRefresh: true);
      request = http.Request('GET', _contentUri(path))
        ..headers['Authorization'] = 'Bearer $refreshed'
        ..followRedirects = false;
      response = await _client.send(request);
    }
    if (response.statusCode == 302 || response.statusCode == 307) {
      final location = response.headers['location'];
      await response.stream.drain<void>();
      if (location == null) {
        throw OneDriveException('OneDrive download redirect was invalid.');
      }
      final redirectRequest = http.Request('GET', Uri.parse(location))
        ..followRedirects = true;
      response = await _client.send(redirectRequest);
    }
    if (response.statusCode == 404) {
      await response.stream.drain<void>();
      return false;
    }
    if (response.statusCode != 200) {
      final body = await response.stream.bytesToString();
      throw OneDriveException(
        _graphError(body, response.statusCode),
        statusCode: response.statusCode,
      );
    }
    await destination.parent.create(recursive: true);
    final temp = File('${destination.path}.part');
    final sink = temp.openWrite();
    var received = 0;
    final total = response.contentLength;
    try {
      await for (final chunk in response.stream) {
        cancellation?.throwIfCancelled();
        sink.add(chunk);
        received += chunk.length;
        onProgress?.call(received, total);
      }
      await sink.flush();
      await sink.close();
      if (total != null && received != total) {
        throw OneDriveException('The downloaded file was incomplete.');
      }
      if (await destination.exists()) await destination.delete();
      await temp.rename(destination.path);
      return true;
    } catch (_) {
      await sink.close();
      if (await temp.exists()) await temp.delete();
      rethrow;
    }
  }

  @override
  @override
  Future<void> uploadBytes(
    String path,
    List<int> bytes, {
    Map<String, String> extraHeaders = const {},
    SyncCancellation? cancellation,
  }) async {
    if (bytes.length > 4 * 1024 * 1024) {
      throw ArgumentError('uploadBytes is only for small files.');
    }
    cancellation?.throwIfCancelled();
    await _withAuth((token) async {
      final response = await _client
          .put(
            _contentUri(path),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/octet-stream',
              ...extraHeaders,
            },
            body: bytes,
          )
          .timeout(const Duration(seconds: 90));
      cancellation?.throwIfCancelled();
      _throwIfError(response);
    });
  }

  @override
  @override
  Future<void> uploadFile(
    String path,
    File file, {
    SyncCancellation? cancellation,
    void Function(int sent, int total)? onProgress,
  }) async {
    cancellation?.throwIfCancelled();
    final length = await file.length();
    if (length <= 4 * 1024 * 1024) {
      final bytes = await file.readAsBytes();
      cancellation?.throwIfCancelled();
      await uploadBytes(path, bytes, cancellation: cancellation);
      onProgress?.call(length, length);
      return;
    }
    final token = await _accessToken();
    final sessionResponse = await _client
        .post(
          Uri.parse(
            '$_base:/${path.split('/').map(Uri.encodeComponent).join('/')}'
            ':/createUploadSession',
          ),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'item': {'@microsoft.graph.conflictBehavior': 'replace'},
          }),
        )
        .timeout(const Duration(seconds: 30));
    _throwIfError(sessionResponse);
    final sessionJson = jsonDecode(sessionResponse.body);
    final uploadUrl = sessionJson is Map
        ? sessionJson['uploadUrl']?.toString()
        : null;
    if (uploadUrl == null) {
      throw OneDriveException('OneDrive did not create an upload session.');
    }
    const chunkSize = 10 * 1024 * 1024;
    final handle = await file.open();
    var offset = 0;
    try {
      while (offset < length) {
        cancellation?.throwIfCancelled();
        final endExclusive = min(offset + chunkSize, length);
        await handle.setPosition(offset);
        final chunk = await handle.read(endExclusive - offset);
        final response = await _client
            .put(
              Uri.parse(uploadUrl),
              headers: {
                'Content-Length': '${chunk.length}',
                'Content-Range': 'bytes $offset-${endExclusive - 1}/$length',
              },
              body: chunk,
            )
            .timeout(const Duration(minutes: 2));
        if (response.statusCode == 429) {
          throw OneDriveException(
            'OneDrive is throttling uploads.',
            statusCode: 429,
          );
        }
        if (response.statusCode >= 400) {
          throw OneDriveException(
            _graphError(response.body, response.statusCode),
            statusCode: response.statusCode,
          );
        }
        offset = endExclusive;
        onProgress?.call(offset, length);
      }
    } catch (_) {
      try {
        await _client.delete(Uri.parse(uploadUrl));
      } catch (_) {}
      rethrow;
    } finally {
      await handle.close();
    }
  }

  Future<T> _withAuth<T>(Future<T> Function(String token) action) async {
    var attempt = 0;
    var refreshed = false;
    var forceRefresh = false;
    while (true) {
      attempt++;
      final token = await _accessToken(forceRefresh: forceRefresh);
      try {
        return await action(token);
      } on SyncCancelledException {
        rethrow;
      } on OneDriveException catch (error) {
        if (error.statusCode == 401 && !refreshed) {
          refreshed = true;
          forceRefresh = true;
          continue;
        }
        if ((error.statusCode == 429 || (error.statusCode ?? 0) >= 500) &&
            attempt <= 3) {
          await Future<void>.delayed(Duration(seconds: attempt * 2));
          continue;
        }
        rethrow;
      } on FormatException {
        rethrow;
      } catch (error) {
        if (attempt <= 3) {
          await Future<void>.delayed(Duration(seconds: attempt * 2));
          continue;
        }
        throw OneDriveException('OneDrive network error: $error');
      }
    }
  }

  void _throwIfError(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    throw OneDriveException(
      _graphError(response.body, response.statusCode),
      statusCode: response.statusCode,
    );
  }

  String _graphError(String body, int status) {
    try {
      final json = jsonDecode(body);
      if (json is Map) {
        final error = json['error'];
        if (error is Map) {
          final message = error['message']?.toString();
          if (message != null && message.isNotEmpty) {
            return 'OneDrive error ($status): $message';
          }
        }
      }
    } catch (_) {}
    return 'OneDrive request failed ($status).';
  }
}
