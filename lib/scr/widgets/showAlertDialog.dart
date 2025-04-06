

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';
import 'customText.dart';

Future<bool> showAlertDialog({
  @required BuildContext context,
  @required String title,
  @required String content,
  @required Function yesOnPressed,
  Color color,
  Color yesColor,
  Color noColor,
}) async {
  return showCupertinoDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: CText(msg: title, color: blue),
      content: CText(msg: content, color: color ?? red, size: 20.0),
      actions: <Widget>[
        CupertinoDialogAction(
          child: CText(
            msg: "No",
            color: noColor ?? blue,
          ),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        CupertinoDialogAction(
          child: CText(
            msg: "Yes",
            color: yesColor ?? red,
          ),
          onPressed: ()=>yesOnPressed(),
        ),
      ],
    ),
  );
}