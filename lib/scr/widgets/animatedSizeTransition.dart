import 'package:flutter/material.dart';

class AnimatedSizeTransition extends StatefulWidget {
  final Widget child;
  final int duration;

  const AnimatedSizeTransition({Key key,
    @required this.child,
    this.duration,

  }) : super(key: key);
  @override
  _AnimatedSizeTransitionState createState() => _AnimatedSizeTransitionState();
}

class _AnimatedSizeTransitionState extends State<AnimatedSizeTransition>  with SingleTickerProviderStateMixin{
  AnimationController expandController;
  Animation<double> animation;
  bool isShow = true;

  @override
  void initState() {
    super.initState();
    expandController =
        AnimationController(vsync: this, duration: Duration(milliseconds: widget.duration ?? 800));
    animation = CurvedAnimation(
      parent: expandController,
      curve: Curves.fastOutSlowIn,
    );
    _runExpandCheck();
  }

  void _runExpandCheck() {
    if (isShow) {
      expandController.forward();
    } else {
      expandController.reverse();
    }
  }

  @override
  void dispose() {
    expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
        axisAlignment: 0.5,
        axis: Axis.vertical,
        sizeFactor: animation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.only(bottom: 10),
          decoration: new BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20)),
            color: Colors.white,
          ),
          child: widget.child
        ));
  }
}
