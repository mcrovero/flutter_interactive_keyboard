import 'package:flutter/services.dart';

class ChannelReceiver {

  final Function onScreenshotTaken;

  MethodChannel channel = const MethodChannel('flutter_interactive_keyboard');

  ChannelReceiver(this.onScreenshotTaken);

  init() {
    channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'screenshotTaken':
          onScreenshotTaken();
          break;
      }
    });
  }
}