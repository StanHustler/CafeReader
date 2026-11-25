import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../app/providers.dart';
import '../../core/design/app_theme.dart';
import '../../data/local/snapshot_service.dart';
import 'settings_widgets.dart';

class AboutSettingsPage extends ConsumerStatefulWidget {
  const AboutSettingsPage({super.key});

  @override
  ConsumerState<AboutSettingsPage> createState() => _AboutSettingsPageState();
}

class _AboutSettingsPageState extends ConsumerState<AboutSettingsPage> {
  String _version = '1.0.0';
  String _build = '';
  String _dataVersion = '1';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final dataVersion = await ref
          .read(settingsRepositoryProvider)
          .getMetadata('data_version');
      if (mounted) {
        setState(() {
          _version = info.version;
          _build = info.buildNumber;
          _dataVersion = dataVersion ?? '1';
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return SettingsScaffold(
      title: 'About',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/branding/icon.png',
                  width: 58,
                  height: 58,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CafeReader',
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontFamily: 'Literata'),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'A local-first reading room for words.',
                    style: TextStyle(color: palette.inkMuted, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),
          SettingsSection(
            title: 'Version',
            children: [
              SettingsValueTile(
                title: 'Application',
                value: _build.isEmpty ? _version : '$_version+$_build',
              ),
              SettingsValueTile(
                title: 'Database schema',
                value: '${SnapshotService.currentSchemaVersion}',
              ),
              SettingsValueTile(title: 'Data format', value: _dataVersion),
              const SettingsValueTile(
                title: 'Backup format',
                value: 'CafeReader .cfr · v1',
              ),
            ],
          ),
          SettingsSection(
            title: 'Privacy',
            children: const [
              _LegalText(
                text:
                    'CafeReader has no accounts, no analytics, no advertising, '
                    'and no server. Books, vocabulary states, definitions, and '
                    'review history are stored in a local SQLite database.',
              ),
              _LegalText(
                text:
                    'The Microsoft refresh token is stored only in the operating '
                    'system secure store. It is never written to the database or '
                    'included in backups. OneDrive is contacted only when you '
                    'press Sync now.',
              ),
              _LegalText(
                text:
                    'Dictionary glosses come from Princeton WordNet 3.0 and are '
                    'bundled offline. Reading typeface is Literata, licensed under '
                    'the SIL Open Font License 1.1.',
              ),
            ],
          ),
          SettingsSection(
            title: 'Open source',
            children: [
              SettingsValueTile(
                title: 'Third-party licenses',
                value: '',
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'CafeReader',
                  applicationVersion: _version,
                  applicationLegalese:
                      'Local-first reading and vocabulary learning.',
                ),
              ),
              SettingsValueTile(
                title: 'WordNet 3.0 license',
                value: '',
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () => _showAssetLicense(
                  'WordNet 3.0',
                  'assets/dictionary/WORDNET_LICENSE.txt',
                ),
              ),
              SettingsValueTile(
                title: 'Literata OFL license',
                value: '',
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () =>
                    _showAssetLicense('Literata', 'assets/fonts/OFL.txt'),
              ),
            ],
          ),
          Center(
            child: Text(
              'Made for long reading and quiet noticing.',
              style: TextStyle(fontSize: 11, color: palette.inkMuted),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAssetLicense(String title, String asset) async {
    final text = await rootBundle.loadString(asset);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: 560,
          height: 420,
          child: SingleChildScrollView(
            child: SelectableText(
              text,
              style: const TextStyle(fontSize: 11.5, height: 1.5),
            ),
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _LegalText extends StatelessWidget {
  const _LegalText({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, height: 1.55, color: palette.inkMuted),
      ),
    );
  }
}
