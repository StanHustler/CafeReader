import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../platform/window_chrome.dart';

/// Page geometry shared by every screen.
///
/// One gutter, one maximum column width and one bottom inset keep the layout
/// from jumping when you move between destinations.
abstract final class PageGeometry {
  /// Widest the content column may grow, gutters included.
  static const double maxWidth = 920;

  /// Space between the content column and the window edge.
  static const double gutter = 24;

  /// Space above the first element of a page.
  static const double top = 4;

  /// Space below the last element of a page.
  static const double bottom = 48;

  /// Width available to content once both gutters are removed.
  static const double innerMaxWidth = maxWidth - gutter * 2;
}

/// Marks a subtree that already lives inside the app shell's content pane.
///
/// Such pages do not reserve the unified title bar strip themselves; the shell
/// reserves it once for all of its destinations.
class ShellContentScope extends InheritedWidget {
  const ShellContentScope({super.key, required super.child});

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ShellContentScope>() != null;

  @override
  bool updateShouldNotify(ShellContentScope oldWidget) => false;
}

/// Vertical space a page must leave for the unified desktop title bar.
double pageTopInset(BuildContext context) =>
    ShellContentScope.of(context) ? 0 : desktopTitleBarInset;

/// Centers [child] in the page column and applies the shared gutter.
///
/// This is the single place that decides how much room the outer ring of
/// padding gets and how wide the content is allowed to be.
class PageContent extends StatelessWidget {
  const PageContent({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: PageGeometry.gutter),
    this.maxWidth = PageGeometry.maxWidth,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final EdgeInsets padding;
  final double maxWidth;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Horizontal geometry of the page column inside a given viewport.
///
/// Sliver-based pages (the library grid, the deck list) own their scroll view,
/// so they cannot use [PageContent]; they use this instead to line their
/// slivers up with the same column.
@immutable
class PageColumn {
  const PageColumn._(this.viewportWidth, this.outerInset, this.width);

  factory PageColumn.fit(double viewportWidth) {
    final width = math.min(viewportWidth, PageGeometry.maxWidth);
    return PageColumn._(viewportWidth, (viewportWidth - width) / 2, width);
  }

  final double viewportWidth;

  /// Blank space on either side of the capped column.
  final double outerInset;

  /// Width of the column, gutters included.
  final double width;

  /// Left/right padding that lands content on the column's gutter.
  double get contentInset => outerInset + PageGeometry.gutter;

  /// Width available to content inside the gutters.
  double get contentWidth => math.max(0, width - PageGeometry.gutter * 2);
}

/// The outer frame shared by simple routed pages.
///
/// Reserves the desktop title bar (unless already inside the shell), then
/// places [child] in the shared content column, optionally scrolling. Pages
/// that build their own scroll view (slivers) skip this and use
/// [PageContent] or [PageColumn] directly.
class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    required this.child,
    this.header,
    this.scrollable = true,
    this.maxWidth = PageGeometry.maxWidth,
    this.backgroundColor,
  });

  final Widget child;

  /// A fixed bar shown above the scrolling body (page title, back button).
  final Widget? header;

  final bool scrollable;
  final double maxWidth;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final content = PageContent(
      maxWidth: maxWidth,
      padding: const EdgeInsets.fromLTRB(
        PageGeometry.gutter,
        PageGeometry.top,
        PageGeometry.gutter,
        PageGeometry.bottom,
      ),
      child: child,
    );
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(top: pageTopInset(context)),
          child: Column(
            children: [
              ?header,
              Expanded(
                child: scrollable
                    ? SingleChildScrollView(child: content)
                    : content,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
