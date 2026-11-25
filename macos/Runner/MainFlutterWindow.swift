import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  private var windowChannel: FlutterMethodChannel?

  override func awakeFromNib() {
    // Unified title bar: keep the native traffic lights, let the Flutter view
    // extend behind the title bar, and hide the title itself so the page
    // heading lives inside the content area.
    styleMask.insert(.fullSizeContentView)
    titlebarAppearsTransparent = true
    titleVisibility = .hidden
    isMovableByWindowBackground = false
    if #available(macOS 11.0, *) {
      titlebarSeparatorStyle = .none
    }

    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    let channel = FlutterMethodChannel(
      name: "cafereader/window",
      binaryMessenger: flutterViewController.engine.binaryMessenger)
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "setTitleBarColor" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard
        let arguments = call.arguments as? [String: Any],
        let background = arguments["background"] as? Int
      else {
        result(FlutterError(code: "bad_arguments",
                            message: "Expected a background ARGB color.",
                            details: nil))
        return
      }
      let dark = arguments["dark"] as? Bool ?? false
      self?.applyTitleBarColor(background: background, dark: dark)
      result(nil)
    }
    windowChannel = channel

    super.awakeFromNib()
  }

  /// Tints the title bar so it matches the in-app theme instead of the
  /// system appearance.
  private func applyTitleBarColor(background: Int, dark: Bool) {
    let color = NSColor(
      srgbRed: CGFloat((background >> 16) & 0xFF) / 255.0,
      green: CGFloat((background >> 8) & 0xFF) / 255.0,
      blue: CGFloat(background & 0xFF) / 255.0,
      alpha: 1.0)
    appearance = NSAppearance(named: dark ? .darkAqua : .aqua)
    titlebarAppearsTransparent = true
    backgroundColor = color
  }
}
