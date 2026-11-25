import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/design/app_theme.dart';
import '../../data/repository/settings_repository.dart';
import 'settings_widgets.dart';

class ReadingSettingsPage extends ConsumerStatefulWidget {
  const ReadingSettingsPage({super.key});

  @override
  ConsumerState<ReadingSettingsPage> createState() =>
      _ReadingSettingsPageState();
}

class _ReadingSettingsPageState extends ConsumerState<ReadingSettingsPage> {
  late ReaderSettings _settings;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _settings =
          ref.read(readerSettingsProvider).valueOrNull ??
          const ReaderSettings();
      _loaded = true;
    }
  }

  Future<void> _persist() async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.set('reader_font_family', _settings.fontFamily);
    await repo.setDouble('reader_font_size', _settings.fontSize);
    await repo.setInt('reader_font_weight', _settings.fontWeight);
    await repo.setDouble('reader_line_height', _settings.lineHeight);
    await repo.setDouble(
      'reader_paragraph_spacing',
      _settings.paragraphSpacing,
    );
    await repo.setDouble(
      'reader_horizontal_padding',
      _settings.horizontalPadding,
    );
    await repo.setDouble('reader_vertical_padding', _settings.verticalPadding);
    await repo.setBool('volume_keys_turn_pages', _settings.volumeKeysTurnPages);
  }

  void _update(ReaderSettings next, {bool save = false}) {
    setState(() => _settings = next);
    if (save) _persist();
  }

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return SettingsScaffold(
      title: 'Reading',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: palette.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: palette.line),
            ),
            child: Text(
              'This is a greeting from the author Stan.',
              style: TextStyle(
                fontFamily: _settings.fontFamily == 'System'
                    ? null
                    : _settings.fontFamily,
                fontSize: _settings.fontSize,
                fontWeight: _fontWeight(_settings.fontWeight),
                height: _settings.lineHeight,
                color: palette.ink,
              ),
            ),
          ),
          const SizedBox(height: 26),
          SettingsSection(
            title: 'Typeface',
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: SegmentedButton<String>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: 'Literata', label: Text('Literata')),
                    ButtonSegment(value: 'System', label: Text('System')),
                  ],
                  selected: {_settings.fontFamily},
                  onSelectionChanged: (value) => _update(
                    _settings.copyWith(fontFamily: value.first),
                    save: true,
                  ),
                ),
              ),
              SettingsValueTile(
                title: 'Font weight',
                value: '',
                trailing: SegmentedButton<int>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: 400, label: Text('Regular')),
                    ButtonSegment(value: 500, label: Text('Medium')),
                    ButtonSegment(value: 600, label: Text('Semibold')),
                  ],
                  selected: {_settings.fontWeight},
                  onSelectionChanged: (value) => _update(
                    _settings.copyWith(fontWeight: value.first),
                    save: true,
                  ),
                ),
              ),
              SettingsSliderRow(
                title: 'Text size',
                value: _settings.fontSize,
                min: 14,
                max: 32,
                divisions: 36,
                display: '${_settings.fontSize.toStringAsFixed(0)} pt',
                onChanged: (value) =>
                    _update(_settings.copyWith(fontSize: value)),
                onChangeEnd: (_) => _persist(),
              ),
              SettingsSliderRow(
                title: 'Line height',
                value: _settings.lineHeight,
                min: 1.2,
                max: 2.2,
                divisions: 20,
                display: _settings.lineHeight.toStringAsFixed(2),
                onChanged: (value) =>
                    _update(_settings.copyWith(lineHeight: value)),
                onChangeEnd: (_) => _persist(),
              ),
              SettingsSliderRow(
                title: 'Paragraph spacing',
                value: _settings.paragraphSpacing,
                min: 0,
                max: 36,
                divisions: 36,
                display: _settings.paragraphSpacing.toStringAsFixed(0),
                onChanged: (value) =>
                    _update(_settings.copyWith(paragraphSpacing: value)),
                onChangeEnd: (_) => _persist(),
              ),
            ],
          ),
          SettingsSection(
            title: 'Page margins',
            description:
                'Margins shrink the measured text box. The reader restores '
                'the same paragraph and offset after re-pagination.',
            children: [
              SettingsSliderRow(
                title: 'Side margin',
                value: _settings.horizontalPadding,
                min: 12,
                max: 64,
                divisions: 52,
                display: _settings.horizontalPadding.toStringAsFixed(0),
                onChanged: (value) =>
                    _update(_settings.copyWith(horizontalPadding: value)),
                onChangeEnd: (_) => _persist(),
              ),
              SettingsSliderRow(
                title: 'Top and bottom margin',
                value: _settings.verticalPadding,
                min: 8,
                max: 56,
                divisions: 48,
                display: _settings.verticalPadding.toStringAsFixed(0),
                onChanged: (value) =>
                    _update(_settings.copyWith(verticalPadding: value)),
                onChangeEnd: (_) => _persist(),
              ),
            ],
          ),
          SettingsSection(
            title: 'Page controls',
            description: 'On desktop, Left/Right arrows and Page Up/Page Down turn pages.',
            children: [
              SettingsSwitchRow(
                title: 'Volume buttons turn pages',
                subtitle:
                    'Android only. Volume up goes back; volume down advances '
                    'exactly like tapping the right edge.',
                value: _settings.volumeKeysTurnPages,
                onChanged: (value) => _update(
                  _settings.copyWith(volumeKeysTurnPages: value),
                  save: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.touch_app_outlined,
                      size: 18,
                      color: palette.inkMuted,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tap the left or right region to turn a page. Tap a '
                        'word in the center to open its vocabulary panel.',
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: palette.inkMuted),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () {
                _persist();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reading settings saved.')),
                );
              },
              child: const Text('Save changes'),
            ),
          ),
        ],
      ),
    );
  }

  static FontWeight _fontWeight(int value) {
    final index = ((value / 100).round() - 1).clamp(0, 8);
    return FontWeight.values[index];
  }
}
