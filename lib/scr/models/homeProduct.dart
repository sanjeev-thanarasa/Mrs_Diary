import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeProduct{
  final String image;
  final String text;
  final Color notificationColor;
  final bool topStackLeft;
  final bool topStackRight;
  final String topStackImage;
  final Function onTapCard;

  HomeProduct({
    @required this.image,
    @required this.text,
    this.notificationColor=Colors.red,
    this.topStackLeft=false,
    this.topStackRight=false,
    this.topStackImage='',
    this.onTapCard,
  }
      );

}
