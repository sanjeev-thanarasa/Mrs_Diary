import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/screen_navigation.dart';

class SplashScreen extends StatefulWidget {
  final Widget secondScreen;
  final ValueListenable<bool>? lockVisibleListenable;

  const SplashScreen({
    super.key,
    required this.secondScreen,
    this.lockVisibleListenable,
  });
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

  Timer startTime() {
    const duration = Duration(seconds: 2);
    return Timer(duration, route);
  }

  route() {
    final isLocked = widget.lockVisibleListenable?.value ?? false;
    if (isLocked) {
      startTime();
      return;
    }
    changeScreenReplacement(context, widget.secondScreen);
  }

  initScreen(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withValues(alpha: 0.95),
              colorScheme.primaryContainer.withValues(alpha: 0.92),
              colorScheme.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/images/MRS-LOGO.png',
                height: 150,
                width: 150,
              ),
              const SizedBox(height: 18),
              Text(
                "MRS Diary",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onPrimary,
                  fontFamily: 'TamilArima',
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Smart payment companion",
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onPrimary.withValues(alpha: 0.8),
                  fontFamily: 'TamilArima2',
                ),
              ),
              const SizedBox(height: 18),
              CircularProgressIndicator(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  colorScheme.onPrimary,
                ),
                strokeWidth: 2,
              )
            ],
          ),
        ),
      ),
    );
  }
}
