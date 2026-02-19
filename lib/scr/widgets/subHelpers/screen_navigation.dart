import 'package:flutter/material.dart';

PageRouteBuilder<T> _noAnimationRoute<T>(Widget widget) {
  return PageRouteBuilder<T>(
    pageBuilder: (_, __, ___) => widget,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
  );
}

void changeScreen(BuildContext context, Widget widget) {
  Navigator.push(context, _noAnimationRoute(widget));
}

void changeScreenAnimated(BuildContext context, Widget widget) {
  Navigator.of(context).push(_noAnimationRoute(widget));
}

// request here
void changeScreenReplacement(BuildContext context, Widget widget) {
  Navigator.pushReplacement(context, _noAnimationRoute(widget));
}
