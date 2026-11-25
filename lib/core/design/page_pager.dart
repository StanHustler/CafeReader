import 'package:flutter/material.dart';

import 'app_theme.dart';

/// The shared page-turner used by every non-settings screen.
///
/// It renders as a floating horizontal capsule with a previous and a next
/// button. The page counter sits between them so the reader always knows where
/// they are without adding a second control.
class PageFlipBar extends StatelessWidget {
  const PageFlipBar({
    super.key,
    required this.pageIndex,
    required this.pageCount,
    this.onPrevious,
    this.onNext,
  });

  /// Zero-based index of the visible page.
  final int pageIndex;

  /// Total number of pages. Values below one are treated as a single page.
  final int pageCount;

  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    final total = pageCount < 1 ? 1 : pageCount;
    final current = pageIndex.clamp(0, total - 1);
    return BubbleBar(
      children: [
        BubbleIconButton(
          key: const ValueKey('pager-previous'),
          icon: Icons.chevron_left_rounded,
          tooltip: 'Previous page',
          onTap: onPrevious,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            '${current + 1} / $total',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
              color: palette.inkMuted,
            ),
          ),
        ),
        BubbleIconButton(
          key: const ValueKey('pager-next'),
          icon: Icons.chevron_right_rounded,
          tooltip: 'Next page',
          onTap: onNext,
        ),
      ],
    );
  }
}

/// A floating capsule that groups [BubbleIconButton]s.
///
/// The same surface, border, radius and shadow as [PageFlipBar] so header
/// actions and pagers read as one family of controls.
class BubbleBar extends StatelessWidget {
  const BubbleBar({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.line),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

/// A round icon button designed to live inside a [BubbleBar].
class BubbleIconButton extends StatelessWidget {
  const BubbleIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.selected = false,
    this.selectedColor,
    this.selectedBackground,
    this.label,
    this.dense = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  /// Optional text shown beside the icon, for controls whose value matters at
  /// a glance (the due-review count, for example). Unlabelled buttons stay
  /// perfect circles.
  final String? label;

  /// Tightens the horizontal padding so three labelled actions still fit in a
  /// phone-width header.
  final bool dense;

  /// Tints the bubble when the action has an active state (open search, a
  /// non-default sort, and so on).
  final bool selected;

  /// Overrides the selected icon colour. Defaults to the palette accent; deck
  /// filters pass their own Learning/Known state colour instead.
  final Color? selectedColor;

  /// Overrides the selected bubble fill. Defaults to the palette accent tint.
  final Color? selectedBackground;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    final enabled = onTap != null;
    final color = selected
        ? (selectedColor ?? palette.accent)
        : enabled
        ? palette.ink
        : palette.inkMuted.withValues(alpha: 0.32);
    return Tooltip(
      message: tooltip,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          hoverColor: palette.surfaceMuted,
          child: Container(
            width: label == null ? 38 : null,
            height: 38,
            padding: label == null
                ? null
                : EdgeInsets.symmetric(horizontal: dense ? 8 : 12),
            decoration: selected
                ? BoxDecoration(
                    color: selectedBackground ?? palette.accentSoft,
                    shape: label == null ? BoxShape.circle : BoxShape.rectangle,
                    borderRadius: label == null
                        ? null
                        : BorderRadius.circular(999),
                  )
                : null,
            child: label == null
                ? Icon(icon, size: 20, color: color)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 20, color: color),
                      const SizedBox(width: 5),
                      Text(
                        label!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// The search field opened by a [BubbleIconButton].
///
/// It is pill-shaped and filled like the bubble that opened it, so an open
/// search reads as part of the same control family instead of a separate row.
class BubbleSearchField extends StatelessWidget {
  const BubbleSearchField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: TextStyle(fontSize: 13, color: palette.ink),
      decoration: InputDecoration(
        hintText: hintText,
        isDense: true,
        filled: true,
        fillColor: palette.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        prefixIcon: Icon(Icons.search, size: 18, color: palette.inkMuted),
        prefixIconConstraints: const BoxConstraints(minWidth: 40),
        suffixIcon: query.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                onPressed: onClear,
                icon: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: palette.inkMuted,
                ),
              ),
        suffixIconConstraints: const BoxConstraints(minWidth: 38),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: palette.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: palette.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: palette.accent, width: 1.2),
        ),
      ),
    );
  }
}

/// Places a [PageFlipBar] over the bottom-right corner of [child].
///
/// Every screen uses the same overlay, so the pager keeps one position and one
/// look while the page beneath it changes.
class PageFlipOverlay extends StatelessWidget {
  const PageFlipOverlay({
    super.key,
    required this.child,
    required this.pageIndex,
    required this.pageCount,
    this.onPrevious,
    this.onNext,
    this.right = 24,
    this.bottom = 20,
  });

  final Widget child;
  final int pageIndex;
  final int pageCount;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final double right;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: EdgeInsets.only(right: right, bottom: bottom),
            child: PageFlipBar(
              pageIndex: pageIndex,
              pageCount: pageCount,
              onPrevious: onPrevious,
              onNext: onNext,
            ),
          ),
        ),
      ],
    );
  }
}
