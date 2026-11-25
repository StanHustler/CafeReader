import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../core/design/app_theme.dart';
import '../../core/sync/sync_controller.dart';
import '../../core/sync/sync_engine.dart';
import '../../data/onedrive/onedrive_auth.dart';
import 'settings_widgets.dart';

class OneDriveSettingsPage extends ConsumerStatefulWidget {
  const OneDriveSettingsPage({super.key});

  @override
  ConsumerState<OneDriveSettingsPage> createState() =>
      _OneDriveSettingsPageState();
}

class _OneDriveSettingsPageState extends ConsumerState<OneDriveSettingsPage> {
  final TextEditingController _clientIdController = TextEditingController();
  bool _initializedText = false;
  bool _savingClientId = false;

  @override
  void dispose() {
    _clientIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(syncControllerProvider);
    final palette = CafePalette.of(context);
    if (!_initializedText && !controller.initializing) {
      _clientIdController.text = controller.clientId ?? '';
      _initializedText = true;
    }
    return SettingsScaffold(
      title: 'OneDrive',
      child: controller.initializing
          ? const Padding(
              padding: EdgeInsets.all(48),
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (controller.clientId == null) _setupCard(context, palette),
                if (controller.clientId == null) const SizedBox(height: 20),
                SettingsSection(
                  title: 'Microsoft account',
                  description:
                      'CafeReader requests only the OneDrive app-folder scope, '
                      'offline access, and basic profile claims.',
                  children: [
                    if (controller.isSignedIn)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: palette.accentSoft,
                              child: Icon(
                                Icons.person_outline,
                                color: palette.accent,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    controller.account!.displayName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall,
                                  ),
                                  if (controller.account!.email.isNotEmpty)
                                    Text(
                                      controller.account!.email,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: palette.inkMuted,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            OutlinedButton(
                              onPressed:
                                  controller.connecting || controller.syncing
                                  ? null
                                  : () => _disconnect(controller),
                              child: const Text('Disconnect'),
                            ),
                          ],
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.account_circle_outlined,
                              color: palette.inkMuted,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Connect a Microsoft account to sync this library '
                                'across devices.',
                              ),
                            ),
                            FilledButton(
                              onPressed:
                                  controller.connecting ||
                                      controller.clientId == null
                                  ? null
                                  : () => controller.connect(),
                              child: controller.connecting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Connect'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                SettingsSection(
                  title: 'Manual sync',
                  description:
                      'Sync downloads the remote snapshot, merges entities, uploads '
                      'changed book files, then publishes a new manifest. Conflicts '
                      'use revision numbers and stable device-id tie breaks.',
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      controller.lastSyncAt == null
                                          ? 'Never synced'
                                          : 'Last sync ${DateFormat.yMMMd().add_jm().format(controller.lastSyncAt!.toLocal())}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'Your local data is fully usable offline.',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: palette.inkMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (controller.syncing)
                                OutlinedButton(
                                  onPressed: controller.cancelSync,
                                  child: const Text('Cancel'),
                                )
                              else
                                FilledButton.icon(
                                  onPressed: controller.isSignedIn
                                      ? () => controller.syncNow()
                                      : null,
                                  icon: const Icon(Icons.sync, size: 18),
                                  label: const Text('Sync now'),
                                ),
                            ],
                          ),
                          if (controller.syncing ||
                              controller.progress != null) ...[
                            const SizedBox(height: 18),
                            _SyncProgressView(
                              progress: controller.progress,
                              syncing: controller.syncing,
                            ),
                          ],
                          if (controller.lastResult != null &&
                              !controller.syncing) ...[
                            const SizedBox(height: 14),
                            Text(
                              'Uploaded ${controller.lastResult!.uploadedFiles} files · '
                              'downloaded ${controller.lastResult!.downloadedFiles} · '
                              'merged ${controller.lastResult!.merged ? 'yes' : 'no'}',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: palette.inkMuted,
                              ),
                            ),
                            for (final warning
                                in controller.lastResult!.warnings.take(4))
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '· $warning',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: palette.ink,
                                  ),
                                ),
                              ),
                          ],
                          if (controller.error != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: palette.danger.withValues(alpha: 0.07),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: palette.danger.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                controller.error!,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: palette.danger,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                SettingsSection(
                  title: 'Connection details',
                  children: [
                    _InfoLine(
                      label: 'Redirect URI',
                      value: OneDriveAuthService.redirectUri,
                      onCopy: () async {
                        await Clipboard.setData(
                          const ClipboardData(
                            text: OneDriveAuthService.redirectUri,
                          ),
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Redirect URI copied.'),
                            ),
                          );
                        }
                      },
                    ),
                    const _InfoLine(
                      label: 'Permission',
                      value: 'Files.ReadWrite.AppFolder (delegated)',
                    ),
                    const _InfoLine(
                      label: 'Token storage',
                      value: 'System secure storage, never the database',
                    ),
                  ],
                ),
                _clientIdCard(context, palette, controller),
                const SizedBox(height: 18),
                Text(
                  'OneDrive is optional. It is not a live database, nothing is '
                  'read from the cloud until you press Sync now, and a failed '
                  'sync never replaces local data with an incomplete file.',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: palette.inkMuted, height: 1.5),
                ),
              ],
            ),
    );
  }

  Widget _setupCard(BuildContext context, CafeColors palette) {
    return const SettingsHero(
      icon: Icons.app_registration,
      title: 'One setup step: Microsoft app registration',
      body:
          'CafeReader ships without a shared cloud identity. Register a public '
          'client app in Microsoft Entra, add the redirect URI '
          '${OneDriveAuthService.redirectUri} under Mobile and desktop '
          'applications, and grant Microsoft Graph delegated '
          'Files.ReadWrite.AppFolder. Then paste the Application (client) ID '
          'below.',
    );
  }

  Widget _clientIdCard(
    BuildContext context,
    CafeColors palette,
    SyncController controller,
  ) {
    return SettingsSection(
      title: 'Application client ID',
      description:
          'A public client ID is not a secret. Changing it disconnects the '
          'current Microsoft session.',
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _clientIdController,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: const InputDecoration(
                    labelText: 'Microsoft Entra Application (client) ID',
                    hintText: '00000000-0000-0000-0000-000000000000',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: _savingClientId
                    ? null
                    : () async {
                        setState(() => _savingClientId = true);
                        await controller.saveClientId(_clientIdController.text);
                        if (context.mounted) {
                          setState(() => _savingClientId = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('OneDrive client ID saved.'),
                            ),
                          );
                        }
                      },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _disconnect(SyncController controller) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disconnect Microsoft account?'),
        content: const Text(
          'Secure tokens are removed from this device. Local books and '
          'vocabulary are untouched.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
    if (confirmed == true) await controller.disconnect();
  }
}

class _SyncProgressView extends StatelessWidget {
  const _SyncProgressView({required this.progress, required this.syncing});
  final SyncProgress? progress;
  final bool syncing;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    final value = progress;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              _icon(value?.stage),
              size: 16,
              color: syncing ? palette.accent : palette.inkMuted,
            ),
            const SizedBox(width: 8),
            Text(
              value?.message ?? 'Starting…',
              style: TextStyle(
                fontSize: 11.5,
                color: palette.inkMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: value?.fraction,
            minHeight: 5,
            backgroundColor: palette.surfaceMuted,
          ),
        ),
      ],
    );
  }

  IconData _icon(SyncStage? stage) => switch (stage) {
    SyncStage.checking => Icons.cloud_queue,
    SyncStage.downloading => Icons.cloud_download_outlined,
    SyncStage.merging => Icons.merge_type,
    SyncStage.uploading => Icons.cloud_upload_outlined,
    SyncStage.completed => Icons.check_circle_outline,
    SyncStage.failed => Icons.error_outline,
    SyncStage.cancelled => Icons.cancel_outlined,
    _ => Icons.sync,
  };
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value, this.onCopy});
  final String label;
  final String value;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 10.5, color: palette.inkMuted),
                ),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          if (onCopy != null)
            IconButton(
              onPressed: onCopy,
              icon: const Icon(Icons.copy, size: 16),
              tooltip: 'Copy',
            ),
        ],
      ),
    );
  }
}
