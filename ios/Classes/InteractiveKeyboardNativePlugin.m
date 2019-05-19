#import "InteractiveKeyboardNativePlugin.h"
#import <flutter_interactive_keyboard/flutter_interactive_keyboard-Swift.h>

@implementation InteractiveKeyboardNativePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftInteractiveKeyboardNativePlugin registerWithRegistrar:registrar];
}
@end
