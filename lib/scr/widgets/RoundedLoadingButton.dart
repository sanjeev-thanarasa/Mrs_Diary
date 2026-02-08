import 'package:flutter/material.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class RoundedLoading extends StatefulWidget {
  final RoundedLoadingButtonController btnController;
  final VoidCallback buttonPressed;
  final double paddingTop;
  final double paddingLeft;
  final double paddingRight;
  final double? buttonHeight;
  final Color? btnColor;
  final String label;
  final TextStyle? textStyle;
  final double? elevation;

  const RoundedLoading({
    super.key,
    required this.btnController,
    required this.buttonPressed,
    this.paddingLeft = 0,
    this.paddingRight = 0,
    this.paddingTop = 0,
    this.btnColor,
    this.buttonHeight,
    this.label = "Save",
    this.textStyle,
    this.elevation,
  });
  @override
  _RoundedLoadingState createState() => _RoundedLoadingState();
}

class _RoundedLoadingState extends State<RoundedLoading> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          top: widget.paddingTop,
          right: widget.paddingRight,
          left: widget.paddingLeft),
      child: RoundedLoadingButton(
        width: 100.0,
        height: widget.buttonHeight ?? 50.0,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            widget.label,
            style: widget.textStyle ??
                const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'TamilArima',
                  color: Colors.white,
                ),
          ),
        ),
        controller: widget.btnController,
        successColor: Colors.green,
        color: widget.btnColor ?? mainBlue,
        elevation: widget.elevation ?? 6.0,
        onPressed: widget.buttonPressed,
      ),
    );
  }
}
