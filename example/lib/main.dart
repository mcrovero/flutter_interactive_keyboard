import 'package:flutter/material.dart';
import 'package:flutter_interactive_keyboard/flutter_interactive_keyboard.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final FocusNode _focusNode = InteractiveKeyboardFocusNode();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Interactive Keyboard'),
        ),
        body: Container(
          margin: EdgeInsets.only(top:100),
          child: Column(
            children: <Widget>[
              TextField(
                focusNode: _focusNode,
                keyboardAppearance: Brightness.dark,
              ),
              Expanded(
                child: KeyboardManagerWidget(
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
              )
            ],
          ),
        ),
      ),
    );
  }
}