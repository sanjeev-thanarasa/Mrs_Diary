import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

void changeScreen(BuildContext context, Widget widget) {
  Navigator.push(
      context,
      PageTransition(type: PageTransitionType.bottomToTop, duration: Duration(seconds: 1), child:widget));
}

void changeScreenAnimated(BuildContext context, Widget widget) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (BuildContext context) {
        return widget;
      },
    ),
  );
}

// request here
void changeScreenReplacement(BuildContext context, Widget widget) {
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => widget));
}
