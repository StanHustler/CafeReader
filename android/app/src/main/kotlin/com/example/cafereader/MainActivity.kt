package com.example.cafereader

import android.view.KeyEvent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var volumeChannel: MethodChannel? = null
    private var volumeKeysEnabled = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        volumeChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "cafereader/volume_keys"
        )
        volumeChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "setEnabled" -> {
                    volumeKeysEnabled = call.arguments as? Boolean ?: false
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
        if (volumeKeysEnabled &&
            event.action == KeyEvent.ACTION_DOWN &&
            (event.keyCode == KeyEvent.KEYCODE_VOLUME_DOWN ||
                event.keyCode == KeyEvent.KEYCODE_VOLUME_UP)
        ) {
            volumeChannel?.invokeMethod(
                if (event.keyCode == KeyEvent.KEYCODE_VOLUME_UP)
                    "volumeUp" else "volumeDown",
                null
            )
            return true
        }
        return super.dispatchKeyEvent(event)
    }
}
