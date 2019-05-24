import 'dart:async';

import 'package:flutter/services.dart';

class ChannelManager {

  static const MethodChannel _channel = const MethodChannel('flutter_interactive_keyboard');

  static Future<void> init() async {
    await _channel.invokeMethod('init');
  }
  // True opens keyboard, false hides it
  static Future<void> showKeyboard(bool show) async {
    await _channel.invokeMethod('showKeyboard',show);
  }
  static Future<void> animate(bool animate) async {
    await _channel.invokeMethod('animate',animate);
  }
  static Future<bool> expand() async {
    return await _channel.invokeMethod('expand');
  }
  static Future<bool> fling(double velocity) async {
    return await _channel.invokeMethod('fling',velocity);
  }
  static Future<void> updateScroll(double position) async {
    await _channel.invokeMethod('updateScroll',position);
  }
  static Future<void> startScroll(double keyboardHeight) async {
    await _channel.invokeMethod('startScroll',keyboardHeight);
  }
  

}
