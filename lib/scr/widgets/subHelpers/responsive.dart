import 'dart:math' as math;
import 'package:flutter/widgets.dart';

class ResponsiveScale {
  ResponsiveScale(this.size);

  static const double designWidth = 375;
  static const double designHeight = 812;

  final Size size;

  double get scaleW => size.width / designWidth;
  double get scaleH => size.height / designHeight;
  double get scale => math.min(scaleW, scaleH);

  double rw(double value) => value * scaleW;
  double rh(double value) => value * scaleH;
  double r(double value) => value * scale;
  double sp(double value) => value * scale;

  double textScale({double min = 0.9, double max = 1.3}) {
    final value = scale;
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }
}

extension ResponsiveContext on BuildContext {
  ResponsiveScale get rs => ResponsiveScale(MediaQuery.sizeOf(this));
}
