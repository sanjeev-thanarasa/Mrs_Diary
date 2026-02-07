import 'package:flutter/material.dart';

class HomeProduct {
  final String image;
  final String text;
  final Color notificationColor;
  final bool topStackLeft;
  final bool topStackRight;
  final String topStackImage;
  final ValueChanged<BuildContext> onTapCard;

  HomeProduct({
    required this.image,
    required this.text,
    this.notificationColor = Colors.red,
    this.topStackLeft = false,
    this.topStackRight = false,
    this.topStackImage = '',
    required this.onTapCard,
  });
}
