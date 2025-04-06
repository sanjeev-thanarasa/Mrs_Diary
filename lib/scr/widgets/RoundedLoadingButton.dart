import 'package:flutter/material.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class RoundedLoading extends StatefulWidget {
  final RoundedLoadingButtonController btnController;
  final Function buttonPressed;
  final double paddingTop;
  final double paddingLeft;
  final double paddingRight;
  final double buttonHeight;
  final Color btnColor;

  const RoundedLoading({Key key,
    this.btnController,
    this.buttonPressed,
    this.paddingLeft,
    this.paddingRight,
    this.paddingTop,
    this.btnColor,
    this.buttonHeight

  }) : super(key: key);
  @override
  _RoundedLoadingState createState() => _RoundedLoadingState();
}

class _RoundedLoadingState extends State<RoundedLoading> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: widget.paddingTop,right: widget.paddingRight,left: widget.paddingLeft),
      child: RoundedLoadingButton(
        width: 100.0,
        height: widget.buttonHeight ?? 50.0,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text("Save",style: TextStyle(fontSize: 20.0,color: Colors.white),),
        ),
        controller: widget.btnController,
        successColor: Colors.green,
        color: widget.btnColor ?? mainBlue,
        elevation: 10.0,
        onPressed: ()=>widget.buttonPressed(),
      ),
    );
  }
}
