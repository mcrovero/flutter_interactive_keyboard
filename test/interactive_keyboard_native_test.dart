import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_keyboard_native/interactive_keyboard_native.dart';

void main() {
  const MethodChannel channel = MethodChannel('interactive_keyboard_native');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await InteractiveKeyboardNative.platformVersion, '42');
  });
}
