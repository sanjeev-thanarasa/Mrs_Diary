import 'package:flutter/material.dart';

class Gap extends StatelessWidget {
  final double h;
  final double w;

  const Gap({Key key, this.h, this.w}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: h ?? null,
      width: w ?? null,
    );
  }
}
