import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/RoundedButton.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/customText.dart';
import 'package:passcode_screen/circle.dart';
import 'package:passcode_screen/keyboard.dart';
import 'package:passcode_screen/passcode_screen.dart';

import 'Welcome.dart';

const storedPasscode = '198430';

class LoginScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final StreamController<bool> _verificationNotifier = StreamController<bool>.broadcast();

  bool isAuthenticated = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                height: MediaQuery.of(context).size.height*0.4,
              child: FadeInImage(
                placeholder: AssetImage("assets/images/diary.png",),
                image: AssetImage("assets/images/bgworld.png",),
                fadeInDuration: Duration(seconds: 1),
                fit: BoxFit.cover,
              ),
              ),
           SizedBox(height: 30.0,),
            SvgPicture.asset(
                  "assets/icons/chat.svg",
                  height: size.height * 0.40,
                ),
           SizedBox(height: 30.0,),
           Center(
                  child: RoundedButton(
                    text: "LOGIN",
                    press: () {
                      _showLockScreen(
                        context,
                        opaque: false,
                        cancelButton: CText(
                          msg : 'Cancel',
                          size: 16, color: Colors.white,
                          semanticsLabel: 'Cancel',
                        ),
                      );
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }

  _showLockScreen(BuildContext context,
      {bool opaque,
        CircleUIConfig circleUIConfig,
        KeyboardUIConfig keyboardUIConfig,
        Widget cancelButton,
        List<String> digits}) {
    Navigator.push(
        context,
        PageRouteBuilder(
          opaque: opaque,
          pageBuilder: (context, animation, secondaryAnimation) => PasscodeScreen(
            title: CText(
              msg : 'Enter App Passcode',
              textAlign: TextAlign.center,
              color: Colors.white,
              size: 28,
            ),
            circleUIConfig: circleUIConfig,
            keyboardUIConfig: keyboardUIConfig,
            passwordEnteredCallback: _onPasscodeEntered,
            cancelButton: cancelButton,
            deleteButton: CText(
              msg :'Delete',
              size: 16,
              color: Colors.white,
              semanticsLabel: 'Delete',
            ),
            shouldTriggerVerification: _verificationNotifier.stream,
            backgroundColor: Colors.black.withOpacity(0.8),
            cancelCallback: _onPasscodeCancelled,
            digits: digits,
            passwordDigits: 6,
            bottomWidget: _buildPasscodeRestoreButton(),
          ),
        ));
  }

  _onPasscodeEntered(String enteredPasscode) {
    bool isValid = storedPasscode == enteredPasscode;
    _verificationNotifier.add(isValid);
    if (isValid) {
      setState(() {
        this.isAuthenticated = isValid;
      });
      Navigator.push(context, PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => IntroScreen()
      ));
    }
  }

  _onPasscodeCancelled() {
    Navigator.maybePop(context);
  }

  @override
  void dispose() {
    _verificationNotifier.close();
    super.dispose();
  }

  _buildPasscodeRestoreButton() => Align(
    alignment: Alignment.bottomCenter,
    child: Container(
      margin: const EdgeInsets.only(bottom: 10.0, top: 20.0),
      child: FlatButton(
        child: CText(
         msg: "Reset passcode",
          textAlign: TextAlign.center,
          size: 16,
          color: Colors.white,
          weight: FontWeight.w300,
        ),
        splashColor: Colors.white.withOpacity(0.4),
        highlightColor: Colors.white.withOpacity(0.2),
        onPressed: _resetAppPassword,
      ),
    ),
  );

  _resetAppPassword() {
    Navigator.maybePop(context).then((result) {
      if (!result) {
        return;
      }
      _showRestoreDialog(() {
        Navigator.maybePop(context);
        //TODO: Clear your stored passcode here
      });
    });
  }

  _showRestoreDialog(VoidCallback onAccepted) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: CText(
            msg: "Reset passcode",
            color: Colors.black87,
          ),
          content: CText(
            msg :"Passcode reset is a non-secure operation!\n\nConsider removing all user data if this action performed.",
            color: Colors.black87,
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: CText(
               msg:"Cancel",
                size: 18,
              ),
              onPressed: () {
                Navigator.maybePop(context);
              },
            ),
            FlatButton(
              child: CText(
                msg:"I understand",
                size: 18,
              ),
              onPressed: onAccepted,
            ),
          ],
        );
      },
    );
  }

}

