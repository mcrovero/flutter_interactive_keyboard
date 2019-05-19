package com.ujiboo.flutter_interactive_keyboard

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class FlutterInteractiveKeyboardPlugin: MethodCallHandler {

  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "flutter_interactive_keyboard")
      channel.setMethodCallHandler(FlutterInteractiveKeyboardPlugin())
    }
  }

  var keyboardHeight = 0.0

  override fun onMethodCall(call: MethodCall, result: Result) {
    result.notImplemented()
  }
}
