import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/design/app_theme.dart';
import '../../core/design/page_layout.dart';
import '../../core/design/subpage.dart';
import '../../core/design/word_mark.dart';
import '../../data/repository/settings_repository.dart';
import '../../domain/lemmatizer/tokenizer.dart';

/// Configures how New, Learning and Known words look in the reader.
///
/// The whole page fits one screen: the appearance switch, an interactive
/// preview, and a compact table of the three categories.
class MarkSettingsPage extends ConsumerStatefulWidget {
  const MarkSettingsPage({super.key});

  @override
  ConsumerState<MarkSettingsPage> createState() => _MarkSettingsPageState();
}

class _MarkSettingsPageState extends ConsumerState<MarkSettingsPage> {
  WordMarkMode _mode = WordMarkMode.day;
  WordMarkTarget _target = WordMarkTarget.newWord;

  @override
  Widget build(BuildContext context) {
    final marks =
        ref.watch(wordMarkSettingsProvider).valueOrNull ??
        WordMarkSettings.defaults;
    final repo = ref.read(settingsRepositoryProvider);

    return SubpageScaffold(
      showHeader: false,
      scrollable: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final column = PageColumn.fit(constraints.maxWidth);
          return Padding(
            padding: EdgeInsets.fromLTRB(
              column.contentInset,
              PageGeometry.top,
              column.contentInset,
              16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SubpageHeader(title: 'Mark'),
                const SizedBox(height: 14),
                SegmentedButton<WordMarkMode>(
                  showSelectedIcon: false,
                  segments: [
                    for (final mode in WordMarkMode.values)
                      ButtonSegment(value: mode, label: Text(mode.label)),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (value) =>
                      setState(() => _mode = value.first),
                ),
                const SizedBox(height: 12),
                _MarkPreview(mode: _mode, marks: marks),
                const SizedBox(height: 12),
                _CategoryEditor(
                  key: ValueKey(
                    '${_mode.storageValue}-${_target.storageValue}',
                  ),
                  mode: _mode,
                  target: _target,
                  appearance: marks.appearance(_mode, _target),
                  onTargetChanged: (target) => setState(() => _target = target),
                  onChanged: (appearance) =>
                      repo.setWordMarkAppearance(_mode, _target, appearance),
                ),
                const Spacer(),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// One card holding the category switch and the selected category's controls.
class _CategoryEditor extends StatelessWidget {
  const _CategoryEditor({
    super.key,
    required this.mode,
    required this.target,
    required this.appearance,
    required this.onTargetChanged,
    required this.onChanged,
  });

  final WordMarkMode mode;
  final WordMarkTarget target;
  final WordMarkAppearance appearance;
  final ValueChanged<WordMarkTarget> onTargetChanged;
  final ValueChanged<WordMarkAppearance> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    final defaults = WordMarkSettings.defaultFor(mode, target);
    return Material(
      color: palette.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: palette.line),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<WordMarkTarget>(
              showSelectedIcon: false,
              segments: [
                for (final value in WordMarkTarget.values)
                  ButtonSegment(
                    value: value,
                    label: Text(value.label),
                    tooltip: switch (value) {
                      WordMarkTarget.newWord =>
                        'Words with no entry in your dictionary yet.',
                      WordMarkTarget.learning =>
                        'Words in your FSRS review queue.',
                      WordMarkTarget.known => 'Words you have marked as Known.',
                    },
                  ),
              ],
              selected: {target},
              onSelectionChanged: (value) => onTargetChanged(value.first),
            ),
            const SizedBox(height: 12),
            const _CardLabel('Style'),
            const SizedBox(height: 6),
            _StyleSelector(
              value: appearance.style,
              onChanged: (style) =>
                  onChanged(appearance.copyWith(style: style)),
            ),
            const SizedBox(height: 10),
            _HexColorInput(
              key: const ValueKey('mark-color'),
              label: 'Mark color',
              color: appearance.color,
              defaultColor: defaults.color,
              onChanged: (color) =>
                  onChanged(appearance.copyWith(color: color)),
            ),
            const SizedBox(height: 8),
            _HexColorInput(
              key: const ValueKey('focus-color'),
              label: 'Focus box',
              color: appearance.focusColor,
              defaultColor: defaults.focusColor,
              onChanged: (color) =>
                  onChanged(appearance.copyWith(focusColor: color)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardLabel extends StatelessWidget {
  const _CardLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 9.5,
        letterSpacing: 0.9,
        fontWeight: FontWeight.w700,
        color: CafePalette.of(context).inkMuted,
      ),
    );
  }
}

class _StyleSelector extends StatelessWidget {
  const _StyleSelector({required this.value, required this.onChanged});

  final WordMarkStyle value;
  final ValueChanged<WordMarkStyle> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<WordMarkStyle>(
      showSelectedIcon: false,
      segments: [
        for (final style in WordMarkStyle.values)
          ButtonSegment(value: style, label: Text(style.label)),
      ],
      selected: {value},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}

/// A label and a HEX colour input with a live preview chip.
class _HexColorInput extends StatefulWidget {
  const _HexColorInput({
    super.key,
    required this.label,
    required this.color,
    required this.defaultColor,
    required this.onChanged,
  });

  final String label;
  final Color color;
  final Color defaultColor;
  final ValueChanged<Color> onChanged;

  @override
  State<_HexColorInput> createState() => _HexColorInputState();
}

class _HexColorInputState extends State<_HexColorInput> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _invalid = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _display(widget.color));
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant _HexColorInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.color != widget.color && !_focusNode.hasFocus) {
      _controller.text = _display(widget.color);
      _invalid = false;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) return;
    final parsed = tryColorFromStorage(_controller.text);
    setState(() {
      _invalid = false;
      _controller.text = _display(parsed ?? widget.color);
    });
  }

  void _handleChanged(String value) {
    final parsed = tryColorFromStorage(value);
    setState(() => _invalid = parsed == null && value.trim().isNotEmpty);
    if (parsed != null) widget.onChanged(parsed);
  }

  void _resetToDefault() {
    _controller.text = _display(widget.defaultColor);
    _focusNode.unfocus();
    setState(() => _invalid = false);
    widget.onChanged(widget.defaultColor);
  }

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    final atDefault = widget.color.toARGB32() == widget.defaultColor.toARGB32();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CardLabel(widget.label),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: palette.line),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                onChanged: _handleChanged,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[0-9a-fA-F#]')),
                  LengthLimitingTextInputFormatter(9),
                ],
                style: TextStyle(
                  fontSize: 12.5,
                  color: palette.ink,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: '#RRGGBB',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: _invalid ? palette.danger : Colors.transparent,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: _invalid ? palette.danger : palette.accent,
                      width: 1.2,
                    ),
                  ),
                ),
              ),
            ),
            if (_invalid) ...[
              const SizedBox(width: 6),
              Tooltip(
                message: 'Use #RRGGBB or #AARRGGBB',
                child: Icon(
                  Icons.error_outline,
                  size: 16,
                  color: palette.danger,
                ),
              ),
            ],
            const SizedBox(width: 2),
            IconButton(
              tooltip: 'Reset to default',
              onPressed: atDefault ? null : _resetToDefault,
              icon: const Icon(Icons.restart_alt, size: 17),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints.tightFor(width: 28, height: 28),
            ),
          ],
        ),
      ],
    );
  }

  static String _display(Color color) {
    final hex = colorToStorage(color);
    return hex.startsWith('#FF') ? '#${hex.substring(3)}' : hex;
  }
}

/// A live, interactive sample of the three categories in the selected
/// appearance. Hovering any word draws its category's focus box.
class _MarkPreview extends StatefulWidget {
  const _MarkPreview({required this.mode, required this.marks});

  final WordMarkMode mode;
  final WordMarkSettings marks;

  @override
  State<_MarkPreview> createState() => _MarkPreviewState();
}

class _MarkPreviewState extends State<_MarkPreview> {
  static const _sample = 'She studied a curious, familiar word.';

  WordFocusRange? _hoverFocus;

  @override
  void didUpdateWidget(covariant _MarkPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode != widget.mode) _hoverFocus = null;
  }

  @override
  Widget build(BuildContext context) {
    final mode = widget.mode;
    final night = mode == WordMarkMode.night;
    final eink = mode == WordMarkMode.eink;
    final colors = CafeTheme.colorsFor(night ? 'dark' : 'light', eink);
    final textStyle = TextStyle(
      color: colors.ink,
      fontFamily: 'Literata',
      fontSize: 16,
      height: 1.75,
    );
    final newAppearance = widget.marks.appearance(mode, WordMarkTarget.newWord);
    final learningAppearance = widget.marks.appearance(
      mode,
      WordMarkTarget.learning,
    );
    final knownAppearance = widget.marks.appearance(mode, WordMarkTarget.known);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(eink ? 6 : 14),
        border: Border.all(color: colors.line, width: eink ? 1.4 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${mode.label.toUpperCase()} PREVIEW',
                style: TextStyle(
                  fontSize: 9.5,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w700,
                  color: colors.inkMuted,
                ),
              ),
              const Spacer(),
              Text(
                'Hover a word',
                style: TextStyle(fontSize: 10, color: colors.inkMuted),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (context, constraints) {
              return MouseRegion(
                cursor: SystemMouseCursors.text,
                onHover: (event) =>
                    _handleHover(event, constraints.maxWidth, textStyle),
                onExit: (_) => _setHover(null),
                child: MarkedParagraph(
                  text: _sample,
                  style: textStyle,
                  ranges: [
                    _range('studied', newAppearance),
                    _range('curious', learningAppearance),
                    _range('familiar', knownAppearance),
                  ],
                  focusRanges: [?_hoverFocus],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              _Legend(
                label: 'New',
                appearance: newAppearance,
                ink: colors.inkMuted,
              ),
              _Legend(
                label: 'Learning',
                appearance: learningAppearance,
                ink: colors.inkMuted,
              ),
              _Legend(
                label: 'Known',
                appearance: knownAppearance,
                ink: colors.inkMuted,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleHover(
    PointerHoverEvent event,
    double maxWidth,
    TextStyle textStyle,
  ) {
    if (maxWidth <= 0) return;
    final painter = TextPainter(
      text: TextSpan(text: _sample, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    final offset = painter.getPositionForOffset(event.localPosition).offset;
    painter.dispose();

    WordFocusRange? next;
    for (final token in const Tokenizer().tokenize(_sample)) {
      if (offset < token.start || offset >= token.end) continue;
      final target = _targetFor(token.surface);
      final appearance = widget.marks.appearance(widget.mode, target);
      next = WordFocusRange(token.start, token.end, appearance.focusColor);
      break;
    }
    _setHover(next);
  }

  void _setHover(WordFocusRange? next) {
    if (next == _hoverFocus) return;
    setState(() => _hoverFocus = next);
  }

  static WordMarkTarget _targetFor(String surface) {
    return switch (surface.toLowerCase()) {
      'curious' => WordMarkTarget.learning,
      'familiar' => WordMarkTarget.known,
      _ => WordMarkTarget.newWord,
    };
  }

  static WordMarkRange _range(String word, WordMarkAppearance appearance) {
    final start = _sample.indexOf(word);
    return WordMarkRange(
      start,
      start + word.length,
      appearance.style,
      appearance.color,
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({
    required this.label,
    required this.appearance,
    required this.ink,
  });

  final String label;
  final WordMarkAppearance appearance;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: appearance.style == WordMarkStyle.none
                ? Colors.transparent
                : appearance.color,
            shape: BoxShape.circle,
            border: Border.all(color: ink.withValues(alpha: 0.4)),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          '$label · ${appearance.style.label}',
          style: TextStyle(fontSize: 10.5, color: ink),
        ),
      ],
    );
  }
}
