import 'package:flutter/material.dart';

import '../../core/design/app_theme.dart';
import '../../core/design/page_layout.dart';
import '../../core/platform/window_chrome.dart';
import '../deck/deck_page.dart';
import '../dictionary/dictionary_page.dart';
import '../home/home_page.dart';
import '../settings/settings_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const int _dictionaryIndex = 2;
  static const int _settingsIndex = 3;

  int _index = 0;

  /// Every tab owns a nested navigator. Secondary pages — book details, group
  /// pages, review sessions, settings — are pushed there, so they render
  /// inside the content pane and never cover the sidebar. The reader opts out
  /// and uses the root navigator because it is meant to be immersive.
  final GlobalKey<NavigatorState> _homeNavigatorKey =
      GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _deckNavigatorKey =
      GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _dictionaryNavigatorKey =
      GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _settingsNavigatorKey =
      GlobalKey<NavigatorState>();

  GlobalKey<NavigatorState> _navigatorFor(int index) => switch (index) {
    0 => _homeNavigatorKey,
    1 => _deckNavigatorKey,
    2 => _dictionaryNavigatorKey,
    _ => _settingsNavigatorKey,
  };

  /// Rail order: Home, Deck, Dictionary, Settings.
  static const _destinations = [
    _Destination(
      label: 'Home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
    ),
    _Destination(
      label: 'Deck',
      icon: Icons.style_outlined,
      selectedIcon: Icons.style_rounded,
    ),
    _Destination(
      label: 'Dictionary',
      icon: Icons.translate_outlined,
      selectedIcon: Icons.translate_rounded,
    ),
    _Destination(
      label: 'Settings',
      icon: Icons.tune_outlined,
      selectedIcon: Icons.tune_rounded,
    ),
  ];

  /// Bottom bar order: Home, Deck, Dictionary, Settings.
  static const _bottomOrder = <int>[0, 1, 2, 3];

  void _selectTab(int index) {
    if (index == _index) {
      // Tapping the active destination returns its nested stack to the root.
      _navigatorFor(index).currentState?.popUntil((route) => route.isFirst);
      return;
    }
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _TabFlow(
        navigatorKey: _homeNavigatorKey,
        active: _index == 0,
        builder: (_) => const HomePage(),
      ),
      _TabFlow(
        navigatorKey: _deckNavigatorKey,
        active: _index == 1,
        builder: (_) => const DeckPage(),
      ),
      _TabFlow(
        navigatorKey: _dictionaryNavigatorKey,
        active: _index == _dictionaryIndex,
        builder: (_) => const DictionaryPage(),
      ),
      _TabFlow(
        navigatorKey: _settingsNavigatorKey,
        active: _index == _settingsIndex,
        builder: (_) => const SettingsPage(),
      ),
    ];
    // The shell reserves the unified title bar strip once and tells its pages
    // via ShellContentScope, and it reserves it on every layout, not just the
    // sidebar one, so page content never slips under the caption buttons.
    final body = ShellContentScope(
      child: Padding(
        padding: EdgeInsets.only(top: desktopTitleBarInset),
        child: IndexedStack(index: _index, children: pages),
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final showSidebar = constraints.maxWidth >= 900;
        if (!showSidebar) {
          return Scaffold(
            body: body,
            bottomNavigationBar: _BottomBar(
              index: _index,
              destinations: _destinations,
              order: _bottomOrder,
              onSelected: _selectTab,
            ),
          );
        }
        return Scaffold(
          body: Row(
            children: [
              _Sidebar(
                index: _index,
                destinations: _destinations,
                onSelected: _selectTab,
                topInset: desktopTitleBarInset,
              ),
              Expanded(child: body),
            ],
          ),
        );
      },
    );
  }
}

/// Hosts one destination and its secondary pages on a nested navigator so
/// opening a sub-page swaps the content pane instead of covering the window.
class _TabFlow extends StatelessWidget {
  const _TabFlow({
    required this.navigatorKey,
    required this.active,
    required this.builder,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final bool active;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return NavigatorPopHandler<Object?>(
      enabled: active,
      onPopWithResult: (result) => navigatorKey.currentState!.pop(result),
      child: Navigator(
        key: navigatorKey,
        onGenerateRoute: (settings) =>
            MaterialPageRoute<void>(builder: builder, settings: settings),
      ),
    );
  }
}

class _Destination {
  const _Destination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.index,
    required this.destinations,
    required this.onSelected,
    required this.topInset,
  });

  final int index;
  final List<_Destination> destinations;
  final ValueChanged<int> onSelected;
  final double topInset;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return Container(
      width: 226,
      decoration: BoxDecoration(
        color: palette.sidebar,
        border: Border(right: BorderSide(color: palette.line)),
      ),
      child: SafeArea(
        right: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(padding: EdgeInsets.fromLTRB(20, topInset, 0, 8)),
            for (var i = 0; i < destinations.length; i++)
              _SidebarItem(
                destination: destinations[i],
                selected: index == i,
                onTap: () => onSelected(i),
              ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 0, 8),
              child: Text(
                'LIBRARY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: palette.inkMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final _Destination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    final foreground = selected ? palette.surface : palette.ink;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      child: Material(
        color: selected ? palette.ink : Colors.transparent,
        borderRadius: BorderRadius.circular(7),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(7),
          hoverColor: selected
              ? Colors.transparent
              : palette.ink.withValues(alpha: 0.05),
          child: SizedBox(
            height: 36,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Icon(
                    selected ? destination.selectedIcon : destination.icon,
                    size: 18,
                    color: foreground,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    destination.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: foreground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.index,
    required this.destinations,
    required this.order,
    required this.onSelected,
  });

  final int index;
  final List<_Destination> destinations;
  final List<int> order;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.line)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 54,
          child: Row(
            children: [
              for (final i in order)
                Expanded(
                  child: _BottomItem(
                    destination: destinations[i],
                    selected: index == i,
                    onTap: () => onSelected(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  const _BottomItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final _Destination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    final color = selected ? palette.ink : palette.inkMuted;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            selected ? destination.selectedIcon : destination.icon,
            size: 22,
            color: color,
          ),
          const SizedBox(height: 2),
          Text(
            destination.label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
