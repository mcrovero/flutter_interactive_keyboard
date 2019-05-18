package com.ujiboo.interactive_keyboard_native

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class InteractiveKeyboardNativePlugin: MethodCallHandler {

  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "interactive_keyboard_native")
      channel.setMethodCallHandler(InteractiveKeyboardNativePlugin())
    }
  }

  var keyboardHeight = 0.0

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "endScroll") {

    } 
    else if(call.method == "startScroll") {
      //keyboardHeight = call.
    } 
    else if(call.method == "updateScroll") {

    }
  }
}
