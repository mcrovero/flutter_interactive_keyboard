#import "InteractiveKeyboardNativePlugin.h"
#import <interactive_keyboard_native/interactive_keyboard_native-Swift.h>

@implementation InteractiveKeyboardNativePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftInteractiveKeyboardNativePlugin registerWithRegistrar:registrar];
}
@end
