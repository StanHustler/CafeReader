import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/design/app_theme.dart';
import '../../data/repository/settings_repository.dart';

class ReaderQuickSettings extends ConsumerStatefulWidget {
  const ReaderQuickSettings({super.key});

  @override
  ConsumerState<ReaderQuickSettings> createState() =>
      _ReaderQuickSettingsState();
}

class _ReaderQuickSettingsState extends ConsumerState<ReaderQuickSettings> {
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

  Future<void> _save(ReaderSettings next) async {
    setState(() => _settings = next);
    final repo = ref.read(settingsRepositoryProvider);
    await repo.setDouble('reader_font_size', next.fontSize);
    await repo.setDouble('reader_line_height', next.lineHeight);
    await repo.setDouble('reader_paragraph_spacing', next.paragraphSpacing);
    await repo.set('reader_font_family', next.fontFamily);
  }

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    final theme = Theme.of(context);
    return Material(
      color: palette.surface,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 10,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: palette.line,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              Row(
                children: [
                  Text('Reading', style: theme.textTheme.headlineSmall),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Done'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: palette.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: palette.line),
                ),
                child: Text(
                  'The planet is surprisingly beautiful.',
                  style: TextStyle(
                    fontFamily: _settings.fontFamily == 'System'
                        ? null
                        : _settings.fontFamily,
                    fontSize: _settings.fontSize,
                    height: _settings.lineHeight,
                    color: palette.ink,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text('Typeface', style: theme.textTheme.titleSmall),
                  const Spacer(),
                  SegmentedButton<String>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: 'Literata', label: Text('Literata')),
                      ButtonSegment(value: 'System', label: Text('System')),
                    ],
                    selected: {_settings.fontFamily},
                    onSelectionChanged: (value) =>
                        _save(_settings.copyWith(fontFamily: value.first)),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _SliderRow(
                label: 'Text size',
                value: _settings.fontSize,
                min: 14,
                max: 32,
                divisions: 36,
                display: _settings.fontSize.toStringAsFixed(0),
                onChanged: (value) => setState(
                  () => _settings = _settings.copyWith(fontSize: value),
                ),
                onChangeEnd: (_) => _save(_settings),
              ),
              _SliderRow(
                label: 'Line height',
                value: _settings.lineHeight,
                min: 1.2,
                max: 2.2,
                divisions: 20,
                display: _settings.lineHeight.toStringAsFixed(2),
                onChanged: (value) => setState(
                  () => _settings = _settings.copyWith(lineHeight: value),
                ),
                onChangeEnd: (_) => _save(_settings),
              ),
              _SliderRow(
                label: 'Space between paragraphs',
                value: _settings.paragraphSpacing,
                min: 0,
                max: 32,
                divisions: 32,
                display: _settings.paragraphSpacing.toStringAsFixed(0),
                onChanged: (value) => setState(
                  () => _settings = _settings.copyWith(paragraphSpacing: value),
                ),
                onChangeEnd: (_) => _save(_settings),
              ),
              const SizedBox(height: 14),
              Text(
                'Changing type or spacing re-flows the chapter and keeps your '
                'place at the same text anchor.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: palette.inkMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.display,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String display;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return Column(
      children: [
        Row(
          children: [
            Text(label, style: Theme.of(context).textTheme.titleSmall),
            const Spacer(),
            Text(
              display,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: palette.inkMuted,
              ),
            ),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
          onChangeEnd: onChangeEnd,
        ),
      ],
    );
  }
}
