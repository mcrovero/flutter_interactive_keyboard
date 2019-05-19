#import "FlutterInteractiveKeyboardPlugin.h"
#import <flutter_interactive_keyboard/flutter_interactive_keyboard-Swift.h>

@implementation FlutterInteractiveKeyboardPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterInteractiveKeyboardPlugin registerWithRegistrar:registrar];
}
@end
