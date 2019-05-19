import 'dart:async';

import 'package:flutter/services.dart';

class ChannelManager {

  static const MethodChannel _channel = const MethodChannel('flutter_interactive_keyboard');

  static Future<bool> expand() async {
    return await _channel.invokeMethod('expand');
  }
  static Future<void> flingClose(double velocity) async {
    await _channel.invokeMethod('flingClose',velocity);
  }
  static Future<void> updateScroll(double position) async {
    await _channel.invokeMethod('updateScroll',position);
  }
  static Future<void> startScroll(double keyboardHeight) async {
    await _channel.invokeMethod('startScroll',keyboardHeight);
  }

}
