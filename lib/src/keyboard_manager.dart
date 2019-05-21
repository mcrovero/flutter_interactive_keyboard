import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'channel_manager.dart';

class KeyboardManagerWidget extends StatefulWidget {
  final Widget child;

  KeyboardManagerWidget({Key key, this.child}) : super(key: key);

  _KeyboardManagerWidgetState createState() => _KeyboardManagerWidgetState();
}

class _KeyboardManagerWidgetState extends State<KeyboardManagerWidget> {
  List<double> _velocities = [];
  double _velocity; 
  int _lastTime;
  double _lastPosition;

  bool _isKeyboardDrag = false;
  bool _keyboardOpen = false;
  bool _dragging = false;

  double _keyboardHeight = 0.0;
  double _over;

  @override
  Widget build(BuildContext context) {
    var bottom = MediaQuery.of(context).viewInsets.bottom;
    _keyboardOpen = bottom > 0;
    if(_keyboardOpen) 
      _keyboardHeight = bottom;
    return Listener(
      onPointerDown: (details){
        print("pointerDown");
        _dragging = true;
        _velocities.clear();
        if(Platform.isIOS && _keyboardOpen) {
          _isKeyboardDrag = true;
          ChannelManager.startScroll(MediaQuery.of(context).viewInsets.bottom);
        }
        
        _lastPosition = details.position.dy;
        _lastTime = DateTime.now().millisecondsSinceEpoch;
      },
      onPointerUp: (details){
        _dragging = false;
        if(_isKeyboardDrag){
          print("pointerUp");
          _velocity = 0;
          _velocities.forEach((velocity){
            _velocity += velocity;
          });
          _velocity = _velocity / _velocities.length;

          if(_over > 0) {
            if(_velocity.abs() > 0) {
              if(Platform.isIOS) {
                ChannelManager.fling(_velocity).then((value){
                  if(!_dragging){
                    if(_velocity<0){
                      showKeyboard();
                    }
                    _isKeyboardDrag = false;
                  }
                });
              } 
            } else {
              if(Platform.isIOS) {
                ChannelManager.expand().then((value){
                  if(!_dragging){
                    showKeyboard();
                    _isKeyboardDrag = false;
                  }
                });
              } 
            }
          } else {
            _isKeyboardDrag = false;
            if(!_keyboardOpen){
              showKeyboard();
            }
          }
        }
      },
      onPointerMove: (details){
        _dragging = true;
        if(_isKeyboardDrag){
          print("pointerMove");
          var position = details.position.dy;
          _over = position - (MediaQuery.of(context).size.height - _keyboardHeight);
          print(_over);  
          var time = DateTime.now().millisecondsSinceEpoch;
          if(time - _lastTime > 0) {
            _velocity = (position - _lastPosition)/(time - _lastTime);
            _velocities.add(_velocity);
            if(_velocities.length > 5) {
              _velocities.removeAt(0);
            }
          }
          _lastPosition = position;
          _lastTime = time;

          if(_over > 0){
            if(Platform.isIOS) {
              if(_keyboardOpen)
                hideKeyboard();
              ChannelManager.updateScroll(_over);
            } else {
              if(_velocity > 0.1) {
                if(_keyboardOpen)
                  hideKeyboard();
              } 
              else if(_velocity < -0.5) {
                if(!_keyboardOpen)
                  showKeyboard();
              }
            }
          } else {
            ChannelManager.updateScroll(0.0);
          }
        }
      },
      child: widget.child,
    );
  }

  showKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.show');
  }

  hideKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }
}