import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/screen_navigation.dart';

class SplashScreen extends StatefulWidget {
  final Widget secondScreen;

  const SplashScreen({Key key, @required this.secondScreen}) : super(key: key);
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    startTime();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: initScreen(context),
    );
  }
  startTime() async {
    var duration = new Duration(seconds: 6);
    return new Timer(duration, route);
  }
  route() {
    changeScreenAnimated(context, widget.secondScreen);
  }

  initScreen(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Image.asset("assets/images/mrslogo.png"),
            ),
            Padding(padding: EdgeInsets.only(top: 20.0)),
            // Text(
            //   "Splash Screen",
            //   style: TextStyle(
            //       fontSize: 20.0,
            //       color: Colors.white
            //   ),
            // ),
            Padding(padding: EdgeInsets.only(top: 20.0)),
            CircularProgressIndicator(
              backgroundColor: Colors.white,
              strokeWidth: 1,
            )
          ],
        ),
      ),
    );
  }
}
