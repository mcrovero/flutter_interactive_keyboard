import 'package:flutter/material.dart';
import 'interactive_keyboard_native.dart';

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

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (details){
        InteractiveKeyboardNative.startScroll(MediaQuery.of(context).viewInsets.bottom);
        _lastPosition = details.position.dy;
        _lastTime = DateTime.now().millisecondsSinceEpoch;
      },
      onPointerUp: (details){
        _velocity = 0;
        _velocities.forEach((velocity){
          _velocity += velocity;
        });
        _velocity = _velocity / _velocities.length;
        InteractiveKeyboardNative.endScroll(_velocity);
      },
      onPointerMove: (details){
        var position = details.position.dy;
        InteractiveKeyboardNative.updateScroll(position);
        var time = DateTime.now().millisecondsSinceEpoch;
        if(time - _lastTime > 0) {
          _velocity = (position - _lastPosition)/(time - _lastTime);
          _velocities.add(_velocity);
          if(_velocities.length > 10) {
            _velocities.removeAt(0);
          }
        }
        _lastPosition = position;
        _lastTime = time;
      },
      child: widget.child,
    );
  }

}