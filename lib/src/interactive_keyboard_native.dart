import 'dart:async';

import 'package:flutter/services.dart';

class InteractiveKeyboardNative {

  static const MethodChannel _channel = const MethodChannel('interactive_keyboard_native');

  static Future<void> endScroll(double velocity) async {
    await _channel.invokeMethod('endScroll',velocity);
  }
  static Future<void> updateScroll(double position) async {
    await _channel.invokeMethod('updateScroll',position);
  }
  static Future<void> startScroll(double keyboardHeight) async {
    await _channel.invokeMethod('startScroll',keyboardHeight);
  }

}
