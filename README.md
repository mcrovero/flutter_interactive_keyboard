[![pub package](https://img.shields.io/pub/v/flutter_interactive_keyboard.svg)](https://pub.dev/packages/flutter_interactive_keyboard)

**This plugin is not under active development. If you'd like to contribute, PRs are welcomed.**

# Flutter Interactive Keyboard
A way to mimic the iOS interactive dismissable keyboard in Flutter. 
For Android, the behavior will still be applied without animation due to the Android keyboard limitations.

<img src="https://github.com/mcrovero/flutter_interactive_keyboard/raw/master/assets/demo1.gif" width="250">

## How to use it
The `KeyboardManagerWidget` defines the area where the draggable keyboard is enabled. Gestures are passed to the widget in order to permit both scrolling and drag-to-dismiss behavior.

`focusNode` is required when using a `TextField` to manage the keyboard opening and closing.

See the [full example](https://github.com/mcrovero/flutter_interactive_keyboard/blob/master/example/lib/main.dart) to see a complete implementation.
```dart
KeyboardManagerWidget(
  focusNode: _focusNode,
  child: ListView.builder(
    itemCount: 100,
    itemBuilder: (context,index){
      return ListTile(
        title: Text("element $index"),
      );
    },
  ),
)
```

## Advanced
### Change focusNode
If your app has more than one `TextField` that should trigger the keyboard, you can change the current `FocusNode` from the `KeyboardManagerWidgetState` as follows:
```dart
// Init variable
GlobalKey<KeyboardManagerWidgetState> _key = GlobalKey();

// In the build method
KeyboardManagerWidget(
  key: _key,
  ...
)

// Wherever you like
_key.currentState.substituteFocusNode = newFocusNode;
```
