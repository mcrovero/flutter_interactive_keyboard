import 'package:flutter/material.dart';
import 'package:interactive_keyboard_native/interactive_keyboard_native.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Container(
          margin: EdgeInsets.only(top:100),
          child: Column(
            children: <Widget>[
              TextField(),
              Expanded(
                child: KeyboardManagerWidget(
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