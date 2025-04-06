import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class CToast extends StatelessWidget {
  final BuildContext context;
  final String message;

  const CToast({Key key,
  @required this.context,
  @required this.message
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return toast(message);
  }
  toast(String message){
    return Toast.show(message, context, duration: Toast.LENGTH_SHORT, gravity:  Toast.CENTER);
  }
}
