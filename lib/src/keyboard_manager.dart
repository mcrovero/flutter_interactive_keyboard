import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_interactive_keyboard/src/channel_receiver.dart';
import 'channel_manager.dart';

class KeyboardManagerWidget extends StatefulWidget {
  final Widget child;
  final FocusNode focusNode;
  KeyboardManagerWidget({Key key, @required this.child, @required this.focusNode}) : super(key: key);

  KeyboardManagerWidgetState createState() => KeyboardManagerWidgetState();
}

class KeyboardManagerWidgetState extends State<KeyboardManagerWidget> {

  ChannelReceiver _channelReceiver;
  
  List<int> _pointers = [];
  int get activePointer => _pointers.length > 0 ? _pointers.first : null;

  List<double> _velocities = [];
  double _velocity = 0.0; 
  int _lastTime = 0;
  double _lastPosition = 0.0;

  bool _keyboardOpen = false;

  double _keyboardHeight = 0.0;
  double _over = 0.0;

  bool dismissed = true; 
  bool _dismissing = false;

  FocusNode substituteFocusNode;
  FocusNode get _focusNode => substituteFocusNode ?? widget.focusNode;

  bool _hasScreenshot = false;

  @override
  void initState() {
    super.initState();
    _channelReceiver = ChannelReceiver((){
      _hasScreenshot = true;
    });
    _channelReceiver.init();
    ChannelManager.init();
  }

  @override
  Widget build(BuildContext context) {
    var bottom = MediaQuery.of(context).viewInsets.bottom;
    _keyboardOpen = bottom > 0;
    if(_keyboardOpen) {
      dismissed = false; 
      _keyboardHeight = bottom;
    }
  
    return Listener(
      onPointerDown: (details){
        //print("pointerDown $dismissed $_isAnimating $activePointer $_keyboardOpen ${_pointers.length} $_dismissing");
        if((!dismissed && !_dismissing) || _keyboardOpen) {
          _pointers.add(details.pointer);
          if(_pointers.length == 1) {
            if(Platform.isIOS) {
              ChannelManager.startScroll(MediaQuery.of(context).viewInsets.bottom);
            }
            _lastPosition = details.position.dy;
            _lastTime = DateTime.now().millisecondsSinceEpoch;
            _velocities.clear();
          }
        }
      },
      onPointerUp: (details){
        if(details.pointer == activePointer && _pointers.length == 1) {
          //print("pointerUp $_velocity, $_over, ${details.pointer}, $activePointer");
          if(_over > 0) {
            if(Platform.isIOS){
              if(_velocity > 0.1 || _velocity < -0.3){
                if(_velocity > 0){
                  _dismissing = true;
                }
                ChannelManager.fling(_velocity).then((value){
                  if(_velocity<0){
                    if(activePointer==null && !dismissed) {
                      showKeyboard(false);
                    }
                  } else {
                    _dismissing = false;
                    dismissed = true;
                  }
                });
              } else {
                ChannelManager.expand().then((value){
                  if(activePointer==null){
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
        if(details.pointer == activePointer) {
          var position = details.position.dy;
          _over = position - (MediaQuery.of(context).size.height - _keyboardHeight);
          updateVelocity(position);
          //print("pointerMove $_over, $_isAnimating, $activePointer, ${details.pointer}");
          if(_over > 0){
            if(Platform.isIOS) {
              if(_keyboardOpen && _hasScreenshot)
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
      },
      onPointerExit: (details){
        _pointers.remove(details.pointer);
      },
      onPointerCancel: (details){
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
      ChannelManager.showKeyboard(true);
    } else {
      _showKeyboard();
    }
  }
  _showKeyboard() {
    FocusScope.of(context).requestFocus(_focusNode);
    SystemChannels.textInput.invokeMethod('TextInput.show');
  }

  hideKeyboard(bool animate) {
    if(!animate && Platform.isIOS){
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
