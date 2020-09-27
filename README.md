[![pub package](https://img.shields.io/pub/v/flutter_interactive_keyboard.svg)](https://pub.dev/packages/flutter_interactive_keyboard)

**This plugin is not under active development. If you'd like to contribute, PRs are welcomed.**

# Flutter Interactive Keyboard
A way to mimic the IOS interactive dismissable keyboard in Flutter. 
If you're shipping to Android the behavior will sill be applied without animation due to the Android keyboard limitations.

<img src="https://github.com/mcrovero/flutter_interactive_keyboard/raw/master/assets/demo1.gif" width="250">

## How to use it
The KeyboardManagerWidget defines the area where the drag is enabled, the touch are passed to the widget below in order to permit both scroll and drag to dismiss.
The focusNode of the textfield is needed to manage the keyboard opening and closing. 

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
If your app has more than one TextField you can change the current FocusNode from the KeyboardManagerWidgetState as follows:
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
