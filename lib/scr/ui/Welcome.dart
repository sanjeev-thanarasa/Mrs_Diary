import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/customText.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/screen_navigation.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';

import 'homePage.dart';


class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;
  final duration = Duration(milliseconds: 5000);

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: duration);
    animation = CurvedAnimation(parent: controller, curve: Curves.bounceInOut);

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(
          Duration(milliseconds: 500),
              () => changeScreenReplacement(context, HomePage()),
        );
      }
    });

    return Scaffold(
      backgroundColor: kIndigoLight,
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(
              child: CText(
                msg: 'Welcome to MRS Dish Solution',
                textAlign: TextAlign.center,
                color: white,
                weight: FontWeight.bold,
                size: 30.0,
              ),
            ),
            Expanded(
              flex: 3,
              child: RotationTransition(
                child: Image.asset(
                  'assets/images/dishCartoon.png',
                  height: 160,
                  width: 160,
                ),
                turns: animation,
              ),
            ),
            Flexible(
              flex: 1,
              child: Container(
                width: 200,
                child: FAProgressBar(
                  direction: Axis.horizontal,
                  size: 20,
                  animatedDuration: duration,
                  backgroundColor: mainBlue,
                  progressColor: Colors.white,
                  currentValue: 100,
                  displayText: '%',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // dispose the animation controller to avoid memory leaks.
    controller.dispose();
    super.dispose();
  }
}