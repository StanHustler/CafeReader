#include "flutter_window.h"

#include <dwmapi.h>
#include <flutter/standard_method_codec.h>
#include <windowsx.h>

#include <cmath>
#include <cstdint>
#include <optional>

#include "flutter/generated_plugin_registrant.h"

namespace {

// Geometry of the unified title bar. These values mirror the Flutter side
// (kDesktopTitleBarHeight / kDesktopCaptionButtonWidth) in
// lib/core/platform/window_chrome.dart.
constexpr int kTitleBarHeight = 38;
constexpr int kCaptionButtonWidth = 46;
constexpr int kCaptionButtonCount = 3;
constexpr int kResizeBorder = 6;

int Scaled(int logical_value, UINT dpi) {
  const double scale = dpi > 0 ? dpi / 96.0 : 1.0;
  return static_cast<int>(std::lround(logical_value * scale));
}

// Window attributes used to tint the caption bar. Redefined here so the
// runner still builds with Windows SDKs older than 10.0.22000.0.
#ifndef DWMWA_USE_IMMERSIVE_DARK_MODE
#define DWMWA_USE_IMMERSIVE_DARK_MODE 20
#endif
#ifndef DWMWA_BORDER_COLOR
#define DWMWA_BORDER_COLOR 34
#endif
#ifndef DWMWA_CAPTION_COLOR
#define DWMWA_CAPTION_COLOR 35
#endif
#ifndef DWMWA_TEXT_COLOR
#define DWMWA_TEXT_COLOR 36
#endif
// Requests native rounded window corners. Evaluated only by Windows 11
// (build 22000+); Windows 10 rejects the attribute and keeps its square frame.
#ifndef DWMWA_WINDOW_CORNER_PREFERENCE
#define DWMWA_WINDOW_CORNER_PREFERENCE 33
#endif
#ifndef DWMWCP_ROUND
#define DWMWCP_ROUND 2
#endif

// Converts an 0xAARRGGBB color into a Win32 COLORREF (0x00BBGGRR).
COLORREF ToColorRef(int64_t argb) {
  return RGB(static_cast<BYTE>((argb >> 16) & 0xFF),
             static_cast<BYTE>((argb >> 8) & 0xFF),
             static_cast<BYTE>(argb & 0xFF));
}

}  // namespace

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());
  ApplyRoundedCorners();

  window_channel_ =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          flutter_controller_->engine()->messenger(), "cafereader/window",
          &flutter::StandardMethodCodec::GetInstance());
  window_channel_->SetMethodCallHandler(
      [this](const flutter::MethodCall<flutter::EncodableValue>& call,
             std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>
                 result) {
        const std::string& method = call.method_name();
        HWND window = GetHandle();
        if (method == "minimize") {
          if (window != nullptr) {
            ShowWindow(window, SW_MINIMIZE);
          }
          result->Success();
          return;
        }
        if (method == "toggleMaximize") {
          if (window != nullptr) {
            ShowWindow(window, IsZoomed(window) ? SW_RESTORE : SW_MAXIMIZE);
          }
          result->Success();
          return;
        }
        if (method == "close") {
          if (window != nullptr) {
            PostMessage(window, WM_CLOSE, 0, 0);
          }
          result->Success();
          return;
        }
        if (method == "isMaximized") {
          result->Success(flutter::EncodableValue(
              window != nullptr && IsZoomed(window) != 0));
          return;
        }
        if (method == "startDrag") {
          if (window != nullptr) {
            ReleaseCapture();
            SendMessage(window, WM_NCLBUTTONDOWN, HTCAPTION, 0);
          }
          result->Success();
          return;
        }
        if (method == "startResizing") {
          int hit = HTCLIENT;
          const auto* arguments =
              std::get_if<flutter::EncodableMap>(call.arguments());
          if (arguments != nullptr) {
            const auto edge_it =
                arguments->find(flutter::EncodableValue("edge"));
            if (edge_it != arguments->end()) {
              const auto* edge =
                  std::get_if<std::string>(&edge_it->second);
              if (edge != nullptr) {
                if (*edge == "left") {
                  hit = HTLEFT;
                } else if (*edge == "right") {
                  hit = HTRIGHT;
                } else if (*edge == "top") {
                  hit = HTTOP;
                } else if (*edge == "bottom") {
                  hit = HTBOTTOM;
                } else if (*edge == "topLeft") {
                  hit = HTTOPLEFT;
                } else if (*edge == "topRight") {
                  hit = HTTOPRIGHT;
                } else if (*edge == "bottomLeft") {
                  hit = HTBOTTOMLEFT;
                } else if (*edge == "bottomRight") {
                  hit = HTBOTTOMRIGHT;
                }
              }
            }
          }
          if (window != nullptr && hit != HTCLIENT) {
            ReleaseCapture();
            SendMessage(window, WM_NCLBUTTONDOWN, hit, 0);
          }
          result->Success();
          return;
        }
        if (method != "setTitleBarColor") {
          result->NotImplemented();
          return;
        }
        const auto* arguments =
            std::get_if<flutter::EncodableMap>(call.arguments());
        if (arguments == nullptr) {
          result->Error("bad_arguments", "Expected a map of arguments.");
          return;
        }
        const auto background_it =
            arguments->find(flutter::EncodableValue("background"));
        const auto foreground_it =
            arguments->find(flutter::EncodableValue("foreground"));
        if (background_it == arguments->end() ||
            foreground_it == arguments->end()) {
          result->Error("bad_arguments",
                        "Missing 'background' or 'foreground'.");
          return;
        }
        const int64_t* background =
            std::get_if<int64_t>(&background_it->second);
        const int64_t* foreground =
            std::get_if<int64_t>(&foreground_it->second);
        if (background == nullptr || foreground == nullptr) {
          result->Error("bad_arguments", "Colors must be 32-bit ARGB values.");
          return;
        }
        bool dark = false;
        const auto dark_it = arguments->find(flutter::EncodableValue("dark"));
        if (dark_it != arguments->end()) {
          if (const bool* dark_value = std::get_if<bool>(&dark_it->second)) {
            dark = *dark_value;
          }
        }
        SetTitleBarColor(*background, *foreground, dark);
        result->Success();
      });

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  window_channel_ = nullptr;
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

void FlutterWindow::SetTitleBarColor(int64_t background,
                                     int64_t foreground,
                                     bool dark) {
  HWND window = GetHandle();
  if (window == nullptr) {
    return;
  }

  const COLORREF caption_color = ToColorRef(background);
  const COLORREF text_color = ToColorRef(foreground);

  // The in-app palette is authoritative, not the system light/dark preference.
  const BOOL use_dark_mode = dark ? TRUE : FALSE;
  DwmSetWindowAttribute(window, DWMWA_USE_IMMERSIVE_DARK_MODE, &use_dark_mode,
                        sizeof(use_dark_mode));
  // Caption tinting only exists on Windows 11; on older systems these calls
  // fail and the window keeps the default system chrome.
  DwmSetWindowAttribute(window, DWMWA_CAPTION_COLOR, &caption_color,
                        sizeof(caption_color));
  DwmSetWindowAttribute(window, DWMWA_TEXT_COLOR, &text_color,
                        sizeof(text_color));
  DwmSetWindowAttribute(window, DWMWA_BORDER_COLOR, &caption_color,
                        sizeof(caption_color));

  // DWM does not always repaint an already visible frame after these
  // attributes change, so nudge the non-client area.
  SetWindowPos(window, nullptr, 0, 0, 0, 0,
               SWP_FRAMECHANGED | SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER |
                   SWP_NOACTIVATE);

  // Re-assert the corner preference after the frame change above.
  ApplyRoundedCorners();
}

void FlutterWindow::ApplyRoundedCorners() {
  HWND window = GetHandle();
  if (window == nullptr) {
    return;
  }

  // The window keeps WS_OVERLAPPEDWINDOW (WS_THICKFRAME included), so DWM can
  // round the top-level window natively. On Windows 10 the call fails and the
  // window keeps its existing square corners.
  const DWORD preference = DWMWCP_ROUND;
  DwmSetWindowAttribute(window, DWMWA_WINDOW_CORNER_PREFERENCE, &preference,
                        sizeof(preference));
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_NCCALCSIZE:
      // The Flutter view covers the whole window. The standard caption and
      // frame are suppressed; resizing and dragging are handled below.
      if (wparam == TRUE) {
        if (IsZoomed(hwnd)) {
          // A maximized thick-frame window is inflated past the screen edges.
          // Keep the client exactly on the monitor work area so no content is
          // clipped and the taskbar stays covered correctly.
          auto* params = reinterpret_cast<NCCALCSIZE_PARAMS*>(lparam);
          HMONITOR monitor = MonitorFromWindow(hwnd, MONITOR_DEFAULTTONEAREST);
          MONITORINFO monitor_info{};
          monitor_info.cbSize = sizeof(monitor_info);
          if (GetMonitorInfo(monitor, &monitor_info)) {
            params->rgrc[0] = monitor_info.rcWork;
          }
        }
        return 0;
      }
      break;
    case WM_NCHITTEST:
      return HitTestWindow(lparam);
    case WM_GETMINMAXINFO: {
      // Keep a maximized borderless window inside the monitor work area.
      DefWindowProc(hwnd, message, wparam, lparam);
      auto* info = reinterpret_cast<MINMAXINFO*>(lparam);
      HMONITOR monitor = MonitorFromWindow(hwnd, MONITOR_DEFAULTTONEAREST);
      MONITORINFO monitor_info{};
      monitor_info.cbSize = sizeof(monitor_info);
      if (GetMonitorInfo(monitor, &monitor_info)) {
        info->ptMaxPosition.x =
            monitor_info.rcWork.left - monitor_info.rcMonitor.left;
        info->ptMaxPosition.y =
            monitor_info.rcWork.top - monitor_info.rcMonitor.top;
        info->ptMaxSize.x =
            monitor_info.rcWork.right - monitor_info.rcWork.left;
        info->ptMaxSize.y =
            monitor_info.rcWork.bottom - monitor_info.rcWork.top;
      }
      return 0;
    }
    case WM_SIZE:
      NotifyWindowState();
      break;
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}

LRESULT FlutterWindow::HitTestWindow(LPARAM lparam) {
  HWND hwnd = GetHandle();
  if (hwnd == nullptr) {
    return HTCLIENT;
  }

  const POINT cursor = {GET_X_LPARAM(lparam), GET_Y_LPARAM(lparam)};
  RECT window_rect{};
  if (!GetWindowRect(hwnd, &window_rect)) {
    return HTCLIENT;
  }

  const UINT dpi = GetDpiForWindow(hwnd);
  const int border = Scaled(kResizeBorder, dpi);
  const bool maximized = IsZoomed(hwnd) != 0;

  if (!maximized) {
    const bool left = cursor.x < window_rect.left + border;
    const bool right = cursor.x >= window_rect.right - border;
    const bool top = cursor.y < window_rect.top + border;
    const bool bottom = cursor.y >= window_rect.bottom - border;
    if (top && left) {
      return HTTOPLEFT;
    }
    if (top && right) {
      return HTTOPRIGHT;
    }
    if (bottom && left) {
      return HTBOTTOMLEFT;
    }
    if (bottom && right) {
      return HTBOTTOMRIGHT;
    }
    if (left) {
      return HTLEFT;
    }
    if (right) {
      return HTRIGHT;
    }
    if (top) {
      return HTTOP;
    }
    if (bottom) {
      return HTBOTTOM;
    }
  }

  const int title_height = Scaled(kTitleBarHeight, dpi);
  const int buttons_width = Scaled(kCaptionButtonWidth, dpi) *
                            kCaptionButtonCount;
  if (cursor.y < window_rect.top + title_height &&
      cursor.x >= window_rect.right - buttons_width) {
    // The caption buttons are Flutter widgets, so they must receive input.
    return HTCLIENT;
  }
  if (cursor.y < window_rect.top + title_height) {
    // Native drag, double-click maximize and snap behaviour come for free.
    return HTCAPTION;
  }
  return HTCLIENT;
}

void FlutterWindow::NotifyWindowState() {
  if (window_channel_ == nullptr) {
    return;
  }
  HWND hwnd = GetHandle();
  const bool maximized = hwnd != nullptr && IsZoomed(hwnd) != 0;
  if (maximized == last_maximized_) {
    return;
  }
  last_maximized_ = maximized;
  window_channel_->InvokeMethod(
      "maximizedChanged",
      std::make_unique<flutter::EncodableValue>(maximized));
}
