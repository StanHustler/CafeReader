import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'page_layout.dart';

/// The three sizes of secondary-page header.
///
/// * [compact] — a 44px toolbar for content-heavy pages that manage their own
///   full-height body (book details, review sessions).
/// * [standard] — the settings-section header: round back button and a medium
///   title.
/// * [large] — a display title and optional subtitle, used when the page lives
///   inside a grid whose header doubles as the page title.
enum SubpageHeaderStyle { compact, standard, large }

/// The shared header used by every secondary page.
///
/// It can be placed inside [SubpageScaffold] or, for pages whose body owns the
/// layout (the library grid), returned from a custom header builder.
class SubpageHeader extends StatelessWidget {
  const SubpageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.eyebrow,
    this.actions = const <Widget>[],
    this.onBack,
    this.canGoBack = true,
    this.backIcon = Icons.arrow_back,
    this.backTooltip = 'Back',
    this.showBack = true,
    this.style = SubpageHeaderStyle.standard,
    this.compact = false,
  });

  final String title;
  final String? subtitle;

  /// Small uppercase label shown above the title.
  final String? eyebrow;

  /// Trailing controls aligned with the title.
  final List<Widget> actions;

  /// Overrides the default pop action.
  final VoidCallback? onBack;

  /// Set false to show a disabled back/close button without removing it.
  final bool canGoBack;

  final IconData backIcon;
  final String backTooltip;
  final bool showBack;
  final SubpageHeaderStyle style;

  /// Tightens the [SubpageHeaderStyle.large] title on narrow screens.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    final onPressed = canGoBack
        ? (onBack ?? () => Navigator.of(context).maybePop())
        : null;

    final leading = showBack
        ? (style == SubpageHeaderStyle.compact
              ? IconButton(
                  tooltip: backTooltip,
                  onPressed: onPressed,
                  icon: Icon(backIcon, size: 20),
                )
              : _RoundBackButton(
                  tooltip: backTooltip,
                  icon: backIcon,
                  onPressed: onPressed,
                ))
        : null;

    final titleBlock = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow != null && style != SubpageHeaderStyle.compact) ...[
          Text(
            eyebrow!.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: palette.inkMuted,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _titleStyle(context, palette),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: palette.inkMuted),
          ),
        ],
      ],
    );

    if (style == SubpageHeaderStyle.compact) {
      return ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Row(
          children: [
            ?leading,
            if (leading != null) const SizedBox(width: 2),
            Expanded(child: titleBlock),
            for (final action in actions) ...[const SizedBox(width: 4), action],
            const SizedBox(width: 4),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ?leading,
        if (leading != null) const SizedBox(width: 12),
        Expanded(child: titleBlock),
        for (final action in actions) ...[const SizedBox(width: 8), action],
      ],
    );
  }

  TextStyle? _titleStyle(BuildContext context, CafeColors palette) {
    final theme = Theme.of(context);
    return switch (style) {
      SubpageHeaderStyle.compact => theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      SubpageHeaderStyle.standard => theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.1,
      ),
      SubpageHeaderStyle.large => theme.textTheme.displayMedium?.copyWith(
        fontSize: compact ? 28 : 34,
        letterSpacing: -0.8,
        color: palette.ink,
      ),
    };
  }
}

/// The shared frame for every secondary (pushed) page.
///
/// Scrollable pages use the same centered content column as the rest of the
/// app. Pages that own their layout — a fixed grid, a paged detail view —
/// set [scrollable] to false and receive a full-height body below the header.
///
/// Set [showHeader] to false when the body renders its own [SubpageHeader]
/// (the library grid does this so the header lines up with its columns).
class SubpageScaffold extends StatelessWidget {
  const SubpageScaffold({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.eyebrow,
    this.actions = const <Widget>[],
    this.style = SubpageHeaderStyle.standard,
    this.compactHeader = false,
    this.showHeader = true,
    this.onBack,
    this.canGoBack = true,
    this.backIcon = Icons.arrow_back,
    this.backTooltip = 'Back',
    this.showBack = true,
    this.scrollable = true,
    this.headerPadding = const EdgeInsets.fromLTRB(8, 4, 8, 4),
    this.maxWidth = PageGeometry.maxWidth,
    this.backgroundColor,
  }) : assert(
         title != null || !showHeader,
         'A title is required when the scaffold draws its header.',
       );

  final Widget child;
  final String? title;
  final String? subtitle;
  final String? eyebrow;
  final List<Widget> actions;
  final SubpageHeaderStyle style;

  /// Tightens the title on narrow screens for [SubpageHeaderStyle.large].
  final bool compactHeader;
  final bool showHeader;
  final VoidCallback? onBack;
  final bool canGoBack;
  final IconData backIcon;
  final String backTooltip;
  final bool showBack;
  final bool scrollable;
  final EdgeInsetsGeometry headerPadding;
  final double maxWidth;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final header = showHeader
        ? SubpageHeader(
            title: title!,
            subtitle: subtitle,
            eyebrow: eyebrow,
            actions: actions,
            onBack: onBack,
            canGoBack: canGoBack,
            backIcon: backIcon,
            backTooltip: backTooltip,
            showBack: showBack,
            style: style,
            compact: compactHeader,
          )
        : null;

    if (scrollable) {
      return PageScaffold(
        maxWidth: maxWidth,
        backgroundColor: backgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (header != null) ...[header, const SizedBox(height: 24)],
            child,
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(top: pageTopInset(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (header != null)
                Padding(padding: headerPadding, child: header),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundBackButton extends StatelessWidget {
  const _RoundBackButton({
    required this.onPressed,
    required this.icon,
    required this.tooltip,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    final enabled = onPressed != null;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: palette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: palette.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          hoverColor: palette.surfaceMuted,
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(
              icon,
              size: 18,
              color: enabled ? palette.ink : palette.inkMuted,
            ),
          ),
        ),
      ),
    );
  }
}
