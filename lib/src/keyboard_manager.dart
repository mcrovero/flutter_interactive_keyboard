import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'channel_manager.dart';

class KeyboardManagerWidget extends StatefulWidget {
  final Widget child;
  final ScrollController scrollController;
  KeyboardManagerWidget({Key key, this.child, this.scrollController}) : super(key: key);

  _KeyboardManagerWidgetState createState() => _KeyboardManagerWidgetState();
}

class _KeyboardManagerWidgetState extends State<KeyboardManagerWidget> {
  List<double> _velocities = [];
  double _velocity; 
  int _lastTime;
  double _lastPosition;
  bool _isDragging = false;
  bool _keyboardOpen = false;
  double _keyboardHeight;
  double _over;

  @override
  Widget build(BuildContext context) {
    var bottom = MediaQuery.of(context).viewInsets.bottom;
    _keyboardOpen = bottom > 0;
    if(_keyboardOpen) 
      _keyboardHeight = bottom;
    return Listener(
      onPointerDown: (details){
        _velocities.clear();
        _isDragging = _keyboardOpen;
        if(_isDragging){
          if(Platform.isIOS) {
            ChannelManager.startScroll(MediaQuery.of(context).viewInsets.bottom);
          }

          _lastPosition = details.position.dy;
          _lastTime = DateTime.now().millisecondsSinceEpoch;
        }
      },
      onPointerUp: (details){
        if(_isDragging){
          _velocity = 0;
          _velocities.forEach((velocity){
            _velocity += velocity;
          });
          _velocity = _velocity / _velocities.length;

          if(_over > 0) {
            print(_velocity);
            if(_velocity > 0.5) {
              if(Platform.isIOS) {
                ChannelManager.flingClose(_velocity);
              } else {
                hideKeyboard();
              }
            } else {
              if(Platform.isIOS) {
                ChannelManager.expand();
              } else {
                showKeyboard();
              }
            }
          }
          _isDragging = false;
        }
      },
      onPointerMove: (details){
        if(_isDragging){
          var position = details.position.dy;
          _over = position - (MediaQuery.of(context).size.height - _keyboardHeight);
            
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
              ChannelManager.updateScroll(_over);
            } else {
              if(_velocity > 0) {
                if(_keyboardOpen)
                  hideKeyboard();
              } else {
                if(!_keyboardOpen)
                  showKeyboard();
              }
            }
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