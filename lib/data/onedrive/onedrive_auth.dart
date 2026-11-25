import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../repository/settings_repository.dart';

class MicrosoftAccount {
  const MicrosoftAccount({required this.displayName, required this.email});

  final String displayName;
  final String email;

  Map<String, Object?> toJson() => {'name': displayName, 'email': email};

  static MicrosoftAccount? fromJson(Object? value) {
    if (value is! Map) return null;
    return MicrosoftAccount(
      displayName: value['name']?.toString() ?? 'Microsoft account',
      email: value['email']?.toString() ?? '',
    );
  }
}

class OneDriveAuthException implements Exception {
  OneDriveAuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

class _OAuthTokens {
  _OAuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.account,
    required this.clientId,
  });

  String accessToken;
  String refreshToken;
  DateTime expiresAt;
  MicrosoftAccount account;
  String clientId;

  Map<String, Object?> toJson() => {
    'access_token': accessToken,
    'refresh_token': refreshToken,
    'expires_at': expiresAt.toUtc().toIso8601String(),
    'account': account.toJson(),
    'client_id': clientId,
  };

  static _OAuthTokens? fromJson(Object? value) {
    if (value is! Map) return null;
    final access = value['access_token']?.toString();
    final refresh = value['refresh_token']?.toString();
    final expiry = DateTime.tryParse(value['expires_at']?.toString() ?? '');
    final account = MicrosoftAccount.fromJson(value['account']);
    final clientId = value['client_id']?.toString();
    if (access == null ||
        refresh == null ||
        expiry == null ||
        account == null ||
        clientId == null) {
      return null;
    }
    return _OAuthTokens(
      accessToken: access,
      refreshToken: refresh,
      expiresAt: expiry,
      account: account,
      clientId: clientId,
    );
  }
}

/// Microsoft identity platform OAuth 2.0 with PKCE and a loopback redirect.
///
/// The app registration must be a public client and include:
/// http://localhost:53682/callback
/// as a "Mobile and desktop applications" redirect URI.
class OneDriveAuthService {
  OneDriveAuthService(this.settings);

  final SettingsRepository settings;
  final FlutterSecureStorage _secureStorage = Platform.isMacOS
      ? const FlutterSecureStorage(
          mOptions: MacOsOptions(usesDataProtectionKeychain: false),
        )
      : const FlutterSecureStorage();
  final http.Client _client = http.Client();
  final Random _random = Random.secure();

  static const String redirectUri = 'http://localhost:53682/callback';
  static const int loopbackPort = 53682;
  static const String _authority =
      'https://login.microsoftonline.com/common/oauth2/v2.0';
  static const String scope =
      'openid profile email offline_access Files.ReadWrite.AppFolder';
  static const String _storageKey = 'cafereader.onedrive.tokens.v1';

  _OAuthTokens? _tokens;
  Future<String>? _refreshInFlight;

  Future<String?> configuredClientId() async {
    final all = await settings.getAll();
    final clientId = (all['onedrive_client_id'] ?? '').trim();
    return clientId.isEmpty ? null : clientId;
  }

  Future<MicrosoftAccount?> currentAccount() async {
    final tokens = await _loadTokens();
    return tokens?.account;
  }

  Future<bool> hasSession() async {
    final tokens = await _loadTokens();
    return tokens != null;
  }

  Future<MicrosoftAccount> signIn() async {
    final clientId = await configuredClientId();
    if (clientId == null) {
      throw OneDriveAuthException(
        'Add your Microsoft Entra application client ID first.',
      );
    }
    final verifier = _randomString(64);
    final challenge = base64Url
        .encode(sha256.convert(utf8.encode(verifier)).bytes)
        .replaceAll('=', '');
    final state = _randomString(32);
    final authorization = Uri.https(
      'login.microsoftonline.com',
      '/common/oauth2/v2.0/authorize',
      {
        'client_id': clientId,
        'response_type': 'code',
        'redirect_uri': redirectUri,
        'response_mode': 'query',
        'scope': scope,
        'state': state,
        'code_challenge': challenge,
        'code_challenge_method': 'S256',
        'prompt': 'select_account',
      },
    );
    final loopback = await _LoopbackReceiver.start(loopbackPort, state);
    try {
      final opened = await launchUrl(
        authorization,
        mode: LaunchMode.externalApplication,
      );
      if (!opened) {
        throw OneDriveAuthException(
          'Could not open the Microsoft sign-in page.',
        );
      }
      final callback = await loopback.waitForCallback();
      final error = callback.queryParameters['error'];
      if (error != null) {
        throw OneDriveAuthException(
          callback.queryParameters['error_description'] ??
              'Microsoft sign-in was cancelled.',
        );
      }
      if (callback.queryParameters['state'] != state) {
        throw OneDriveAuthException('Sign-in state validation failed.');
      }
      final code = callback.queryParameters['code'];
      if (code == null || code.isEmpty) {
        throw OneDriveAuthException(
          'Microsoft did not return an authorization code.',
        );
      }
      final response = await _client
          .post(
            Uri.parse('$_authority/token'),
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: {
              'client_id': clientId,
              'grant_type': 'authorization_code',
              'code': code,
              'redirect_uri': redirectUri,
              'code_verifier': verifier,
              'scope': scope,
            },
          )
          .timeout(const Duration(seconds: 30));
      if (response.statusCode != 200) {
        throw OneDriveAuthException(_tokenError(response.body));
      }
      final tokens = _parseTokenResponse(response.body, clientId);
      await _saveTokens(tokens);
      return tokens.account;
    } finally {
      await loopback.close();
    }
  }

  Future<void> signOut() async {
    _tokens = null;
    await _secureStorage.delete(key: _storageKey);
  }

  Future<String> accessToken({bool forceRefresh = false}) async {
    final clientId = await configuredClientId();
    if (clientId == null) {
      throw OneDriveAuthException('No Microsoft client ID is configured.');
    }
    final tokens = await _loadTokens();
    if (tokens == null) {
      throw OneDriveAuthException('Connect your Microsoft account first.');
    }
    if (tokens.clientId != clientId) {
      await signOut();
      throw OneDriveAuthException(
        'The client ID changed. Connect your Microsoft account again.',
      );
    }
    if (!forceRefresh &&
        tokens.expiresAt.isAfter(
          DateTime.now().add(const Duration(seconds: 90)),
        )) {
      return tokens.accessToken;
    }
    final existingRefresh = _refreshInFlight;
    if (existingRefresh != null) return existingRefresh;
    final future = _refresh(clientId);
    _refreshInFlight = future;
    try {
      return await future;
    } finally {
      _refreshInFlight = null;
    }
  }

  Future<String> _refresh(String clientId) async {
    final tokens = await _loadTokens();
    if (tokens == null) {
      throw OneDriveAuthException('Connect your Microsoft account first.');
    }
    final response = await _client
        .post(
          Uri.parse('$_authority/token'),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {
            'client_id': clientId,
            'grant_type': 'refresh_token',
            'refresh_token': tokens.refreshToken,
            'scope': scope,
          },
        )
        .timeout(const Duration(seconds: 30));
    if (response.statusCode != 200) {
      await signOut();
      throw OneDriveAuthException(
        'Microsoft session expired. Reconnect your account. '
        '${_tokenError(response.body)}',
      );
    }
    final refreshed = _parseTokenResponse(
      response.body,
      clientId,
      previousRefreshToken: tokens.refreshToken,
      previousAccount: tokens.account,
    );
    await _saveTokens(refreshed);
    return refreshed.accessToken;
  }

  _OAuthTokens _parseTokenResponse(
    String body,
    String clientId, {
    String? previousRefreshToken,
    MicrosoftAccount? previousAccount,
  }) {
    final json = jsonDecode(body);
    if (json is! Map) {
      throw OneDriveAuthException(
        'Microsoft returned an invalid token response.',
      );
    }
    final access = json['access_token']?.toString();
    final refresh = json['refresh_token']?.toString() ?? previousRefreshToken;
    final expiresIn = (json['expires_in'] as num?)?.toInt() ?? 3600;
    if (access == null || refresh == null) {
      throw OneDriveAuthException('Microsoft returned incomplete credentials.');
    }
    final account =
        _accountFromIdToken(json['id_token']?.toString()) ??
        previousAccount ??
        const MicrosoftAccount(displayName: 'Microsoft account', email: '');
    return _OAuthTokens(
      accessToken: access,
      refreshToken: refresh,
      expiresAt: DateTime.now().add(Duration(seconds: expiresIn)),
      account: account,
      clientId: clientId,
    );
  }

  MicrosoftAccount? _accountFromIdToken(String? token) {
    if (token == null) return null;
    try {
      final parts = token.split('.');
      if (parts.length < 2) return null;
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final json = jsonDecode(payload);
      if (json is! Map) return null;
      return MicrosoftAccount(
        displayName:
            (json['name'] ?? json['preferred_username'] ?? 'Microsoft account')
                .toString(),
        email: (json['preferred_username'] ?? json['email'] ?? '').toString(),
      );
    } catch (_) {
      return null;
    }
  }

  String _tokenError(String body) {
    try {
      final json = jsonDecode(body);
      if (json is Map) {
        final error = json['error']?.toString() ?? 'sign-in failed';
        final description = json['error_description']?.toString();
        return description == null ? error : '$error: $description';
      }
    } catch (_) {}
    return 'Microsoft sign-in failed.';
  }

  Future<_OAuthTokens?> _loadTokens() async {
    if (_tokens != null) return _tokens;
    try {
      final stored = await _secureStorage.read(key: _storageKey);
      if (stored == null) return null;
      final parsed = _OAuthTokens.fromJson(jsonDecode(stored));
      _tokens = parsed;
      return parsed;
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveTokens(_OAuthTokens tokens) async {
    _tokens = tokens;
    await _secureStorage.write(
      key: _storageKey,
      value: jsonEncode(tokens.toJson()),
    );
  }

  String _randomString(int byteCount) {
    final bytes = List<int>.generate(byteCount, (_) => _random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }
}

class _LoopbackReceiver {
  _LoopbackReceiver._(this._server, this._state, this._completer);

  final HttpServer _server;
  final String _state;
  final Completer<Uri> _completer;
  StreamSubscription<HttpRequest>? _subscription;

  static Future<_LoopbackReceiver> start(int port, String state) async {
    final HttpServer server;
    try {
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    } catch (_) {
      throw OneDriveAuthException(
        'Port $port is unavailable. Close other CafeReader sign-in windows '
        'and try again.',
      );
    }
    final receiver = _LoopbackReceiver._(server, state, Completer<Uri>());
    receiver._listen();
    return receiver;
  }

  void _listen() {
    _subscription = _server.listen((request) async {
      if (request.uri.path != '/callback') {
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
        return;
      }
      if (request.uri.queryParameters['state'] != _state) {
        request.response.statusCode = HttpStatus.badRequest;
        request.response.write('Invalid OAuth state.');
        await request.response.close();
        return;
      }
      request.response.headers.contentType = ContentType.html;
      request.response.write('''
        <!doctype html><html><head><meta charset="utf-8">
        <title>CafeReader</title></head>
        <body style="font-family: sans-serif; padding: 48px; max-width: 560px;">
        <h2>CafeReader</h2>
        <p>Microsoft sign-in is complete. You can close this tab and return to the app.</p>
        </body></html>
      ''');
      await request.response.close();
      if (!_completer.isCompleted) _completer.complete(request.uri);
    });
  }

  Future<Uri> waitForCallback() => _completer.future.timeout(
    const Duration(minutes: 5),
    onTimeout: () {
      throw OneDriveAuthException(
        'Microsoft sign-in timed out. Please try again.',
      );
    },
  );

  Future<void> close() async {
    await _subscription?.cancel();
    await _server.close(force: true);
  }
}
