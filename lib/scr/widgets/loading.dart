import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingWave extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: SpinKitWave(
        color: Colors.grey,
        size: 20,
      )
    );
  }
}

class LoadingCircle extends StatelessWidget {
  final Color color;

  const LoadingCircle({Key key, this.color}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: SpinKitCircle(
        duration: Duration(milliseconds: 1200),
        color: color ?? Colors.black,
        size: 30,
      )
    );
  }
}
