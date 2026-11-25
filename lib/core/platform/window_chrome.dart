import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design/app_theme.dart';

/// Height of the unified title bar reserved at the top of the window.
///
/// The Windows runner mirrors this value in
/// `windows/runner/flutter_window.cpp` to decide where a press starts a
/// window drag instead of reaching Flutter.
const double kDesktopTitleBarHeight = 38;

/// Width of each Flutter-drawn window caption button (Windows only).
const double kDesktopCaptionButtonWidth = 46;

/// True on the desktop platforms that use the unified title bar.
bool get isDesktopWindow =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS);

/// Space that page content must leave at the top of the window so it does not
/// sit underneath the native title bar / caption buttons.
double get desktopTitleBarInset {
  if (!isDesktopWindow) return 0;
  // macOS keeps the native title bar (traffic lights); Windows uses the
  // custom caption row height.
  return defaultTargetPlatform == TargetPlatform.macOS
      ? 32
      : kDesktopTitleBarHeight;
}

/// Tints the native desktop window chrome (title bar) to match the app theme.
///
/// Implemented for Windows and macOS in the platform runners; calls are a
/// no-op everywhere else, and older runners simply report a missing plugin.
abstract final class WindowChrome {
  static const _channel = MethodChannel('cafereader/window');

  static int? _lastBackground;
  static int? _lastForeground;
  static bool? _lastDark;
  static bool _listening = false;

  /// Whether the window is currently maximized. Updated by the Windows
  /// runner when the window state changes (button, double-click or snap).
  static final ValueNotifier<bool> maximized = ValueNotifier<bool>(false);

  /// Installs the native -> Dart state listener. Safe to call repeatedly.
  static void listenForWindowState() {
    if (_listening || !isDesktopWindow) return;
    _listening = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'maximizedChanged') {
        maximized.value = call.arguments == true;
      }
    });
    if (defaultTargetPlatform == TargetPlatform.windows) {
      unawaited(syncMaximized());
    }
  }

  static Future<void> syncMaximized() async {
    try {
      final value = await _channel.invokeMethod<bool>('isMaximized');
      if (value != null) maximized.value = value;
    } catch (_) {
      // The runner may predate the custom title bar; keep the default.
    }
  }

  static Future<void> minimize() => _invoke('minimize');

  static Future<void> toggleMaximize() => _invoke('toggleMaximize');

  static Future<void> close() => _invoke('close');

  /// Begins a native window move loop (drag, snap, restore and so on).
  static Future<void> startDrag() => _invoke('startDrag');

  /// Begins a native resize loop from [edge].
  static Future<void> startResizing(WindowResizeEdge edge) async {
    try {
      await _channel.invokeMethod<void>('startResizing', {'edge': edge.name});
    } catch (_) {
      // The runner may predate the custom title bar.
    }
  }

  static Future<void> _invoke(String method) async {
    try {
      await _channel.invokeMethod<void>(method);
    } catch (_) {
      // The runner may predate the custom title bar.
    }
  }

  static Future<void> apply({
    required Color background,
    required Color foreground,
    required bool dark,
  }) async {
    if (kIsWeb) return;
    if (defaultTargetPlatform != TargetPlatform.windows &&
        defaultTargetPlatform != TargetPlatform.macOS) {
      return;
    }

    final backgroundArgb = background.toARGB32();
    final foregroundArgb = foreground.toARGB32();
    if (backgroundArgb == _lastBackground &&
        foregroundArgb == _lastForeground &&
        dark == _lastDark) {
      return;
    }
    _lastBackground = backgroundArgb;
    _lastForeground = foregroundArgb;
    _lastDark = dark;

    try {
      await _channel.invokeMethod<void>('setTitleBarColor', {
        'background': backgroundArgb,
        'foreground': foregroundArgb,
        'dark': dark,
      });
    } on MissingPluginException {
      // The platform runner predates this channel; keep the system chrome.
      _lastBackground = null;
      _lastForeground = null;
      _lastDark = null;
    } on PlatformException catch (error) {
      debugPrint('WindowChrome: ${error.code} ${error.message}');
    }
  }
}

/// Applies [WindowChrome] whenever the ambient [Theme] changes.
class WindowChromeSync extends StatefulWidget {
  const WindowChromeSync({super.key, required this.child});

  final Widget child;

  @override
  State<WindowChromeSync> createState() => _WindowChromeSyncState();
}

class _WindowChromeSyncState extends State<WindowChromeSync> {
  Color? _background;
  Color? _foreground;
  Brightness? _brightness;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final colors = CafePalette.of(context);
    final brightness = Theme.of(context).brightness;
    if (_background == colors.background &&
        _foreground == colors.ink &&
        _brightness == brightness) {
      return;
    }
    _background = colors.background;
    _foreground = colors.ink;
    _brightness = brightness;
    unawaited(
      WindowChrome.apply(
        background: colors.background,
        foreground: colors.ink,
        dark: brightness == Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Edges of the window used for Flutter-initiated native resizing.
enum WindowResizeEdge {
  left,
  right,
  top,
  bottom,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

/// Draws the Flutter side of the unified desktop title bar.
///
/// On Windows the caption buttons, drag strip and resize handles are rendered
/// here, above the navigator, so they remain available on every route. The
/// Flutter view is a child window that receives pointer input, so the runner
/// cannot rely on native non-client hit-testing; instead Flutter starts the
/// native move/resize loops. On macOS the native traffic lights and title bar
/// are preserved, so this is a pass-through.
class DesktopWindowFrame extends StatefulWidget {
  const DesktopWindowFrame({super.key, required this.child});

  final Widget child;

  @override
  State<DesktopWindowFrame> createState() => _DesktopWindowFrameState();
}

class _DesktopWindowFrameState extends State<DesktopWindowFrame> {
  @override
  void initState() {
    super.initState();
    WindowChrome.listenForWindowState();
  }

  @override
  Widget build(BuildContext context) {
    if (!isDesktopWindow) return widget.child;
    if (defaultTargetPlatform != TargetPlatform.windows) {
      return widget.child;
    }
    return Stack(
      children: [
        Positioned.fill(child: widget.child),
        const Positioned(
          top: 0,
          left: 0,
          right: 3 * kDesktopCaptionButtonWidth,
          height: kDesktopTitleBarHeight,
          child: _WindowDragArea(),
        ),
        const Positioned(top: 0, right: 0, child: _CaptionButtons()),
        ValueListenableBuilder<bool>(
          valueListenable: WindowChrome.maximized,
          builder: (context, maximized, _) {
            if (maximized) return const SizedBox.shrink();
            return const Stack(
              children: [
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  width: 6,
                  child: _ResizeHandle(
                    edge: WindowResizeEdge.left,
                    cursor: SystemMouseCursors.resizeLeftRight,
                  ),
                ),
                Positioned(
                  top: kDesktopTitleBarHeight,
                  bottom: 0,
                  right: 0,
                  width: 6,
                  child: _ResizeHandle(
                    edge: WindowResizeEdge.right,
                    cursor: SystemMouseCursors.resizeLeftRight,
                  ),
                ),
                Positioned(
                  left: 6,
                  right: 6,
                  bottom: 0,
                  height: 6,
                  child: _ResizeHandle(
                    edge: WindowResizeEdge.bottom,
                    cursor: SystemMouseCursors.resizeUpDown,
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 6,
                  right: 3 * kDesktopCaptionButtonWidth,
                  height: 6,
                  child: _ResizeHandle(
                    edge: WindowResizeEdge.top,
                    cursor: SystemMouseCursors.resizeUpDown,
                  ),
                ),
                Positioned(
                  left: 0,
                  bottom: 0,
                  width: 10,
                  height: 10,
                  child: _ResizeHandle(
                    edge: WindowResizeEdge.bottomLeft,
                    cursor: SystemMouseCursors.resizeUpLeftDownRight,
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  width: 10,
                  height: 10,
                  child: _ResizeHandle(
                    edge: WindowResizeEdge.bottomRight,
                    cursor: SystemMouseCursors.resizeUpRightDownLeft,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// The empty strip at the top of the window that starts a native drag.
///
/// A second press within the double-click interval maximizes or restores the
/// window, mirroring the Windows caption behaviour.
class _WindowDragArea extends StatefulWidget {
  const _WindowDragArea();

  @override
  State<_WindowDragArea> createState() => _WindowDragAreaState();
}

class _WindowDragAreaState extends State<_WindowDragArea> {
  static const Duration _doubleClickWindow = Duration(milliseconds: 380);

  DateTime? _lastDownAt;
  Offset? _lastDownPosition;

  void _handlePointerDown(PointerDownEvent event) {
    final now = DateTime.now();
    final last = _lastDownAt;
    final lastPosition = _lastDownPosition;
    if (last != null &&
        now.difference(last) <= _doubleClickWindow &&
        lastPosition != null &&
        (event.position - lastPosition).distance <= 8) {
      _lastDownAt = null;
      _lastDownPosition = null;
      WindowChrome.toggleMaximize();
      return;
    }
    _lastDownAt = now;
    _lastDownPosition = event.position;
    WindowChrome.startDrag();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: _handlePointerDown,
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _ResizeHandle extends StatelessWidget {
  const _ResizeHandle({required this.edge, required this.cursor});

  final WindowResizeEdge edge;
  final MouseCursor cursor;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: cursor,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (_) => WindowChrome.startResizing(edge),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _CaptionButtons extends StatelessWidget {
  const _CaptionButtons();

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    return SizedBox(
      height: kDesktopTitleBarHeight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CaptionButton(
            key: const ValueKey('caption-minimize'),
            label: 'Minimize',
            onTap: WindowChrome.minimize,
            child: _LineGlyph(color: palette.inkMuted),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: WindowChrome.maximized,
            builder: (context, maximized, _) => _CaptionButton(
              key: ValueKey(maximized ? 'caption-restore' : 'caption-maximize'),
              label: maximized ? 'Restore' : 'Maximize',
              onTap: WindowChrome.toggleMaximize,
              child: maximized
                  ? _RestoreGlyph(color: palette.inkMuted)
                  : _SquareGlyph(color: palette.inkMuted),
            ),
          ),
          _CaptionButton(
            key: const ValueKey('caption-close'),
            label: 'Close',
            close: true,
            onTap: WindowChrome.close,
            child: Icon(
              Icons.close,
              size: 13,
              color: CafePalette.of(context).inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _CaptionButton extends StatefulWidget {
  const _CaptionButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.child,
    this.close = false,
  });

  final String label;
  final VoidCallback onTap;
  final Widget child;
  final bool close;

  @override
  State<_CaptionButton> createState() => _CaptionButtonState();
}

class _CaptionButtonState extends State<_CaptionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = CafePalette.of(context);
    final background = _hovered
        ? (widget.close ? const Color(0xFFE81123) : palette.surfaceMuted)
        : Colors.transparent;
    final child = widget.close && _hovered
        ? const Icon(Icons.close, size: 13, color: Colors.white)
        : widget.child;
    return Semantics(
      button: true,
      label: widget.label,
      child: MouseRegion(
        cursor: SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: kDesktopCaptionButtonWidth,
            height: kDesktopTitleBarHeight,
            color: background,
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}

class _LineGlyph extends StatelessWidget {
  const _LineGlyph({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(width: 10, height: 1, color: color);
  }
}

class _SquareGlyph extends StatelessWidget {
  const _SquareGlyph({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(border: Border.all(color: color, width: 1)),
    );
  }
}

class _RestoreGlyph extends StatelessWidget {
  const _RestoreGlyph({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 11,
      height: 11,
      child: Stack(
        children: [
          Positioned(
            left: 2,
            bottom: 0,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                border: Border.all(color: color, width: 1),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: color, width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
