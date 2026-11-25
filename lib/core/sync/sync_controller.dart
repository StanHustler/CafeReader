import 'package:flutter/foundation.dart';

import '../../app/app_services.dart';
import '../../data/onedrive/graph_client.dart';
import '../../data/onedrive/onedrive_auth.dart';
import 'sync_engine.dart';

class SyncController extends ChangeNotifier {
  SyncController(this.app);

  final AppServices app;

  MicrosoftAccount? account;
  String? clientId;
  SyncProgress? progress;
  SyncResult? lastResult;
  String? error;
  DateTime? lastSyncAt;
  bool initializing = true;
  bool connecting = false;
  bool syncing = false;
  SyncCancellation? _cancellation;
  bool _disposed = false;

  bool get isSignedIn => account != null;

  Future<void> initialize() async {
    try {
      clientId = await app.oneDriveAuth.configuredClientId();
      account = await app.oneDriveAuth.currentAccount();
      final all = await app.settings.getAll();
      lastSyncAt = DateTime.tryParse(all['last_sync_at'] ?? '');
    } catch (_) {
      // A secure-storage or settings failure should not prevent the app from
      // opening. The connection can be retried from the UI.
    } finally {
      initializing = false;
      _notify();
    }
  }

  Future<void> saveClientId(String value) async {
    final trimmed = value.trim();
    final previous = clientId;
    await app.settings.set('onedrive_client_id', trimmed);
    clientId = trimmed.isEmpty ? null : trimmed;
    if (previous != null && previous != trimmed && account != null) {
      await app.oneDriveAuth.signOut();
      account = null;
    }
    _notify();
  }

  Future<void> connect() async {
    if (connecting || syncing) return;
    connecting = true;
    error = null;
    _notify();
    try {
      account = await app.oneDriveAuth.signIn();
    } catch (failure) {
      error = failure.toString();
    } finally {
      connecting = false;
      _notify();
    }
  }

  Future<void> disconnect() async {
    await app.oneDriveAuth.signOut();
    account = null;
    progress = null;
    _notify();
  }

  Future<void> syncNow() async {
    if (syncing) return;
    syncing = true;
    error = null;
    progress = const SyncProgress(
      stage: SyncStage.checking,
      message: 'Starting sync…',
    );
    _cancellation = SyncCancellation();
    _notify();
    try {
      final result = await app.syncEngine.sync(
        cancellation: _cancellation,
        onProgress: (value) {
          progress = value;
          _notify();
        },
      );
      lastResult = result;
      lastSyncAt = DateTime.now();
      progress = const SyncProgress(
        stage: SyncStage.completed,
        message: 'Sync complete.',
      );
    } catch (failure) {
      if (failure is SyncCancelledException) {
        progress = const SyncProgress(
          stage: SyncStage.cancelled,
          message: 'Sync cancelled.',
        );
      } else {
        error = failure.toString();
        progress = SyncProgress(
          stage: SyncStage.failed,
          message: 'Sync failed: $failure',
        );
      }
    } finally {
      syncing = false;
      _cancellation = null;
      _notify();
    }
  }

  void cancelSync() {
    _cancellation?.cancel();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
