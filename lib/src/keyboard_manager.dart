import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'channel_manager.dart';

class KeyboardManagerWidget extends StatefulWidget {
  final Widget child;
  final FocusNode focusNode;
  KeyboardManagerWidget({Key key, this.child, this.focusNode}) : super(key: key);

  _KeyboardManagerWidgetState createState() => _KeyboardManagerWidgetState();
}

class _KeyboardManagerWidgetState extends State<KeyboardManagerWidget> {
  List<int> _pointers = [];
  int get activePointer => _pointers.length > 0 ? _pointers.first : null;

  List<double> _velocities = [];
  double _velocity; 
  int _lastTime;
  double _lastPosition;

  bool _keyboardOpen = false;
  bool _isAnimating = false;

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
        print("pointerDown $_isAnimating $activePointer");
        _pointers.add(details.pointer);
        if(_pointers.length == 1) {
          if(Platform.isIOS) {
            ChannelManager.startScroll(MediaQuery.of(context).viewInsets.bottom);
          }
          _lastPosition = details.position.dy;
          _lastTime = DateTime.now().millisecondsSinceEpoch;
          _velocities.clear();
        }
      },
      onPointerUp: (details){
        print("pointerUp $_velocity, $_over, ${details.pointer}, $activePointer");
        if(details.pointer == activePointer) {
          if(_over > 0) {
            if(Platform.isIOS){
              _isAnimating = true;
              if(_velocity > 0.1 || _velocity < -0.3){
                print("fling $_velocity");
                ChannelManager.fling(_velocity).then((value){
                  _isAnimating = false;
                  if(_velocity<0 && activePointer==null){
                    print("keyboard open");
                    showKeyboard(false);
                  } 
                });
              } else {
                print("expand");
                ChannelManager.expand().then((value){
                  _isAnimating = false;
                  if(activePointer==null){
                    print("keyboard open");
                    showKeyboard(false);
                  }
                });
              }
            } 
          }
        }
        _pointers.remove(details.pointer);
      },
      onPointerMove: (details){
        var position = details.position.dy;
        _over = position - (MediaQuery.of(context).size.height - _keyboardHeight);
        updateVelocity(position);
        print("pointerMove $_over, $_isAnimating, $activePointer, ${details.pointer}");
        if(details.pointer == activePointer) {
          if(_over > 0){
            if(Platform.isIOS) {
              if(_keyboardOpen)
                hideKeyboard(false);
              ChannelManager.updateScroll(_over);
            } else {
              if(_velocity > 0.1) {
                if(_keyboardOpen)
                  hideKeyboard(true);
              } 
              else if(_velocity < -0.5) {
                if(!_keyboardOpen)
                  showKeyboard(true);
              }
            }
          } else {
            if(Platform.isIOS) {
              if(!_keyboardOpen){
                showKeyboard(false);
              }
            }
          }
        }
      },
      onPointerExit: (details){
        print("pointerExit");
        _pointers.remove(details.pointer);
      },
      onPointerCancel: (details){
        print("pointerCancel");
        _pointers.remove(details.pointer);
      },
      child: widget.child,
    );
  }

  updateVelocity(double position) {
    var time = DateTime.now().millisecondsSinceEpoch;
    if(time - _lastTime > 0) {
      _velocity = (position - _lastPosition)/(time - _lastTime);
    }
    _lastPosition = position;
    _lastTime = time;
  }

  showKeyboard(bool animate) {
    if(!animate && Platform.isIOS){
      /*ChannelManager.animate(false).then((value){
        _showKeyboard();
        ChannelManager.animate(true);
      });*/
      ChannelManager.showKeyboard(true);
    } else {
      _showKeyboard();
    }
  }
  _showKeyboard() {
    FocusScope.of(context).requestFocus(widget.focusNode);
    SystemChannels.textInput.invokeMethod('TextInput.show');
  }

  hideKeyboard(bool animate) {
    if(!animate && Platform.isIOS){
      /*ChannelManager.animate(false).then((value){
        _hideKeyboard();
        ChannelManager.animate(true);
      });*/
      ChannelManager.showKeyboard(false);
    } else {
      _hideKeyboard();
    }
  }
  _hideKeyboard(){
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    FocusScope.of(context).requestFocus(FocusNode());
  }
}
