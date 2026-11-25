import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../core/design/app_theme.dart';
import '../../core/design/page_layout.dart';
import '../../data/repository/settings_repository.dart';
import 'about_settings_page.dart';
import 'data_settings_page.dart';
import 'fsrs_settings_page.dart';
import 'mark_settings_page.dart';
import 'onedrive_settings_page.dart';
import 'reading_settings_page.dart';
import 'settings_widgets.dart';
import 'vocabulary_settings_page.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearance =
        ref.watch(appAppearanceProvider).valueOrNull ?? const AppAppearance();
    final settings =
        ref.watch(readerSettingsProvider).valueOrNull ?? const ReaderSettings();
    final fsrs =
        ref.watch(fsrsSettingsProvider).valueOrNull ?? const FsrsSettings();
    final all = ref.watch(allSettingsProvider).valueOrNull ?? const {};
    final lastSync = DateTime.tryParse(all['last_sync_at'] ?? '');
    final oneDriveConnected = (all['onedrive_client_id'] ?? '')
        .trim()
        .isNotEmpty;

    return PageScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: Theme.of(context).textTheme.displayMedium
                ?.copyWith(fontSize: 36),
          ),
          const SizedBox(height: 30),
          SettingsSection(
            title: 'General',
            children: [
              SettingsValueTile(
                icon: Icons.palette_outlined,
                title: 'Appearance',
                value: '',
                trailing: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _AppearanceSelector(
                    selected: appearance.mode,
                    onSelected: (mode) => ref
                        .read(settingsRepositoryProvider)
                        .set('app_theme', mode.storageValue),
                  ),
                ),
              ),
            ],
          ),
          SettingsSection(
            title: 'Reading',
            children: [
              SettingsNavTile(
                icon: Icons.text_fields,
                title: 'Reading',
                subtitle:
                    '${settings.fontFamily} · '
                    '${settings.fontSize.toStringAsFixed(0)} pt',
                onTap: () => _push(context, const ReadingSettingsPage()),
              ),
              SettingsNavTile(
                icon: Icons.auto_stories_outlined,
                title: 'Vocabulary',
                subtitle: settings.lemmatizerEnabled
                    ? 'Dictionary lemmatization'
                    : 'Surface forms only',
                onTap: () => _push(context, const VocabularySettingsPage()),
              ),
              SettingsNavTile(
                icon: Icons.border_style_outlined,
                title: 'Mark',
                subtitle: 'New, Learning and Known word styles, per appearance',
                onTap: () => _push(context, const MarkSettingsPage()),
              ),
            ],
          ),
          SettingsSection(
            title: 'Learning',
            children: [
              SettingsNavTile(
                icon: Icons.school_outlined,
                title: 'FSRS review',
                subtitle:
                    '${fsrs.dailyNewLimit} new · ${fsrs.dailyReviewLimit} reviews · '
                    '${(fsrs.desiredRetention * 100).round()}% retention',
                onTap: () => _push(context, const FsrsSettingsPage()),
              ),
              SettingsNavTile(
                icon: Icons.storage_outlined,
                title: 'Data',
                subtitle:
                    'Backups, .cfr restores, merges, CSV and dictionaries',
                onTap: () => _push(context, const DataSettingsPage()),
              ),
              SettingsNavTile(
                icon: Icons.cloud_outlined,
                title: 'OneDrive',
                subtitle: oneDriveConnected
                    ? (lastSync == null
                          ? 'Manual sync configured'
                          : 'Last sync ${DateFormat.yMMMd().add_jm().format(lastSync.toLocal())}')
                    : 'Not configured',
                onTap: () => _push(context, const OneDriveSettingsPage()),
              ),
            ],
          ),
          SettingsSection(
            title: 'About',
            children: [
              SettingsNavTile(
                icon: Icons.info_outline,
                title: 'About CafeReader',
                subtitle: 'Version, licenses, privacy',
                onTap: () => _push(context, const AboutSettingsPage()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }
}

/// A compact four-way appearance selector that sits at the trailing edge of
/// the Appearance row, like the value controls on other settings rows.
class _AppearanceSelector extends StatelessWidget {
  const _AppearanceSelector({required this.selected, required this.onSelected});

  final AppAppearanceMode selected;
  final ValueChanged<AppAppearanceMode> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: palette.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final mode in AppAppearanceMode.values)
            Tooltip(
              message: mode.label,
              child: InkWell(
                onTap: () => onSelected(mode),
                customBorder: const StadiumBorder(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOut,
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: mode == selected
                        ? palette.surface
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: mode == selected
                          ? palette.line
                          : Colors.transparent,
                    ),
                  ),
                  child: Icon(
                    _iconFor(mode),
                    size: 15,
                    color: mode == selected ? palette.ink : palette.inkMuted,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static IconData _iconFor(AppAppearanceMode mode) => switch (mode) {
    AppAppearanceMode.light => Icons.light_mode_outlined,
    AppAppearanceMode.dark => Icons.dark_mode_outlined,
    AppAppearanceMode.auto => Icons.brightness_auto_outlined,
    AppAppearanceMode.eink => Icons.contrast,
  };
}
