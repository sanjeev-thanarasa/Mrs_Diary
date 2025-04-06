import 'dart:collection';
import 'package:flutter/material.dart';


class CText extends StatelessWidget {
  final String msg;
  final double size;
  final Color color;
  final Color strokeColor;
  final FontWeight weight;
  final String fontFamily;
  final bool textStroke;
  final String semanticsLabel;
  final TextAlign textAlign;

  CText({
    @required this.msg,
    this.size,
    this.color,
    this.strokeColor,
    this.weight,
    this.fontFamily,
    this.textStroke=false,
    this.semanticsLabel,
    this.textAlign

  });

  @override
  Widget build(BuildContext context) {
    return textStroke
        ? Text(
      msg,style: TextStyle(
        shadows: outlinedText(strokeColor: strokeColor ?? Colors.blue),
        fontSize: size ?? 16,
        color: color ?? Colors.black,
        fontWeight: weight ??
            FontWeight.normal,
      fontFamily: fontFamily ?? "TamilArima2"
    ),

    )
        :Text(
      msg,style: TextStyle(
        fontSize: size ?? 16,
        color: color ?? Colors.black,
        fontWeight: weight ??
            FontWeight.normal,
        fontFamily: fontFamily ?? "TamilArima2"
    ),
      semanticsLabel: semanticsLabel ?? null,
      textAlign: textAlign ?? null,
    ) ;
  }
  static List<Shadow> outlinedText({double strokeWidth = 1, Color strokeColor = Colors.black, int precision = 5}) {
    Set<Shadow> result = HashSet();
    for (int x = 1; x < strokeWidth + precision; x++) {
      for(int y = 1; y < strokeWidth + precision; y++) {
        double offsetX = x.toDouble();
        double offsetY = y.toDouble();
        result.add(Shadow(offset: Offset(-strokeWidth / offsetX, -strokeWidth / offsetY), color: strokeColor));
        result.add(Shadow(offset: Offset(-strokeWidth / offsetX, strokeWidth / offsetY), color: strokeColor));
        result.add(Shadow(offset: Offset(strokeWidth / offsetX, -strokeWidth / offsetY), color: strokeColor));
        result.add(Shadow(offset: Offset(strokeWidth / offsetX, strokeWidth / offsetY), color: strokeColor));
      }
    }
    return result.toList();
  }
}

class CSText extends StatelessWidget{
  final String msg;
  final double size;
  final Color color;
  final FontWeight weight;
  final String fontFamily;
  final TextAlign textAlign;

  CSText({
    @required this.msg,
    this.size,
    this.color,
    this.weight,
    this.fontFamily,
    this.textAlign

  });
  @override
  Widget build(BuildContext context) {
    return SelectableText(msg ?? "",style: TextStyle(
        fontSize: size ?? 16,
        color: color ?? Colors.black,
        fontWeight: weight ??
            FontWeight.normal,
        fontFamily: fontFamily ?? "TamilArima2"
    ),
    textAlign: textAlign ?? null,);
  }

}


class CRText extends StatelessWidget{
  final String msg1;
  final String msg2;
  final double size1;
  final double size2;
  final Color color1;
  final Color color2;
  final FontWeight weight1;
  final FontWeight weight2;
  final String fontFamily1;
  final String fontFamily2;
  final String semanticsLabel1;
  final String semanticsLabel2;

  CRText({
    @required this.msg1,
    @required this.msg2,
    this.size1,
    this.size2,
    this.color1,
    this.color2,
    this.weight1,
    this.weight2,
    this.fontFamily1,
    this.fontFamily2,
    this.semanticsLabel1,
    this.semanticsLabel2

  });
  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: msg1,
            style: TextStyle(
                fontSize: size1 ?? 16,
                color: color1 ?? Colors.black,
                fontWeight: weight1 ??
                    FontWeight.normal,
                fontFamily: fontFamily1 ?? "TamilArima2"
            ),
              semanticsLabel: semanticsLabel1 ?? null,
          ),

          TextSpan(text: msg2,
            style: TextStyle(
                fontSize: size2 ?? 16,
                color: color2 ?? Colors.black,
                fontWeight: weight2 ??
                    FontWeight.normal,
                fontFamily: fontFamily2 ?? "TamilArima2"
            ),
              semanticsLabel: semanticsLabel2 ?? null,
          ),

        ],
      ),
    );
  }

}
