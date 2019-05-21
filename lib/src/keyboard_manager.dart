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
  int activePointer;

  List<double> _velocities = [];
  double _velocity; 
  int _lastTime;
  double _lastPosition;

  bool _keyboardOpen = false;
  bool _dragging = false;
  bool _isAnimating = false;

  double _keyboardHeight = 0.0;
  double _over;

  @override
  void initState() { 
    super.initState();
    widget.focusNode.addListener((){
    });
  }

  @override
  Widget build(BuildContext context) {
    var bottom = MediaQuery.of(context).viewInsets.bottom;
    _keyboardOpen = bottom > 0;
    if(_keyboardOpen) 
      _keyboardHeight = bottom;
    return Listener(
      onPointerDown: (details){
        print("pointerDown $_isAnimating $activePointer");
        if(activePointer == null) {
          activePointer = details.pointer;
          _velocities.clear();
          if(Platform.isIOS && _keyboardOpen) {
            _dragging = true;
            ChannelManager.startScroll(MediaQuery.of(context).viewInsets.bottom);
          }
          _lastPosition = details.position.dy;
          _lastTime = DateTime.now().millisecondsSinceEpoch;
        }
      },
      onPointerHover: (details) {
        print("pointerHover");

        if(details.pointer == activePointer)
          activePointer = null;
      },
      onPointerExit: (details){
        print("pointerExit");
        if(details.pointer == activePointer)
          activePointer = null;
      },
      onPointerCancel: (details){
        print("pointerCancel");
        if(details.pointer == activePointer)
          activePointer = null;
      },
      onPointerUp: (details){
        print("pointerUp $_velocity - $_over - ${details.pointer} - $activePointer");
        if(details.pointer == activePointer) {
          activePointer = null;
          _dragging = false;
          if(!_isAnimating){
            if(_over > 0) {
              if(Platform.isIOS){
                print("fling $_velocity");
                _isAnimating = true;
                if(_velocity.abs()>0.3){
                  ChannelManager.fling(_velocity).then((value){
                    _isAnimating = false;
                    if(_velocity<0 && !_dragging && activePointer==null){
                      showKeyboard(false);
                    } 
                  });
                } else {
                  print("expand");
                  ChannelManager.expand().then((value){
                    _isAnimating = false;
                    if(!_dragging && activePointer==null)
                      showKeyboard(false);
                  });
                }
              } 
            }
          }
        }
      },
      onPointerMove: (details){
        print("pointerMove $_isAnimating $activePointer ${details.pointer}");
        if(details.pointer == activePointer) {
          if(!_isAnimating && _dragging){
            // UPDATING VELOCITY
            var position = details.position.dy;
            _over = position - (MediaQuery.of(context).size.height - _keyboardHeight);
            var time = DateTime.now().millisecondsSinceEpoch;
            if(time - _lastTime > 0) {
              _velocity = (position - _lastPosition)/(time - _lastTime);
            }
            _lastPosition = position;
            _lastTime = time;
            // -----------------

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
                ChannelManager.updateScroll(0.0);
                if(!_keyboardOpen){
                  showKeyboard(false);
                }
              }
            }
          }
        }
      },
      child: widget.child,
    );
  }

  showKeyboard(bool animate) {
    if(!animate && Platform.isIOS){
      ChannelManager.animate(false).then((value){
        FocusScope.of(context).requestFocus(widget.focusNode);
        SystemChannels.textInput.invokeMethod('TextInput.show');
        ChannelManager.animate(true);
      });
    } else {
      FocusScope.of(context).requestFocus(widget.focusNode);
      SystemChannels.textInput.invokeMethod('TextInput.show');
    }
  }

  hideKeyboard(bool animate) {
    if(!animate && Platform.isIOS){
      ChannelManager.animate(false).then((value){
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        FocusScope.of(context).requestFocus(FocusNode());
        ChannelManager.animate(true);
      });
    } else {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      FocusScope.of(context).requestFocus(FocusNode());
    }
  }
}