import 'package:animated_icon_button/animated_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';

class CustomTextField extends StatefulWidget{
  final IconData icon;
  final IconData animatedIconButtonStratIcon;
  final IconData animatedIconButtonEndIcon;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final String hintText;
  final String image;
  final bool iconButton;
  final bool readOnly;
  final Function animatedIconButtonOnTap;
  final TextStyle textStyle;
  final Color leadingIconColor;
  final Color hintTextColor;

  CustomTextField({Key key ,
    this.icon ,
    this.keyboardType ,
    this.controller,
    this.hintText,
    this.image,
    this.iconButton = false,
    this.readOnly,
    this.animatedIconButtonOnTap,
    this.animatedIconButtonStratIcon,
    this.animatedIconButtonEndIcon,
    this.textStyle,
    this.leadingIconColor,
    this.hintTextColor

  }) : super (key: key);


  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      decoration: BoxDecoration(
        border: Border.all(color: widget.leadingIconColor ?? Colors.blue, width: 1.0,),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
              blurRadius: 1,
              color: Colors.white,
              offset: Offset(0, 2))
        ],
      ),

      margin:
      const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: Row(
        children: <Widget>[
          Padding(
              padding:
              EdgeInsets.symmetric(vertical: 0.0, horizontal: 15.0),
              child: widget.image==null ? Icon(
                this.widget.icon,
                color: widget.leadingIconColor ?? Colors.blue,size: 20.0,
              ): Image(image:AssetImage(
                widget.image,
              ),fit: BoxFit.cover,height: 30,width: 25,color: mainBlue,)
          ),//////ICON OR IMAGE////////
          Container(
            height: 25.0,
            width: 1.0,
            color: widget.leadingIconColor ??  Colors.blue,
            margin: const EdgeInsets.only(left: 00.0, right: 10.0),
          ),///////// | //////////
          Expanded(
            child: TextField(
              keyboardType: widget.keyboardType,
              readOnly: widget.readOnly ?? false ,
              style: TextStyle(
                  fontSize: 20.0,
                color: Colors.blue
              ),
              controller: widget.controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: widget.hintText,
                alignLabelWithHint: true,

                hintStyle: widget.textStyle ?? TextStyle(color: widget.hintTextColor ?? Colors.grey,fontSize: 16.0,fontFamily: "TamilArima"),
              ),
            ),
          ),/////////TEXT FIELD///////////
          widget.iconButton ? AnimatedIconButton(
             duration: Duration(milliseconds: 200),
             startIcon: Icon(widget.animatedIconButtonStratIcon,size: 20,),
              endIcon: widget.animatedIconButtonEndIcon ==null
                  ? Icon(widget.animatedIconButtonStratIcon,size: 20,)
                  : Icon(widget.animatedIconButtonEndIcon,size: 20,),
              onPressed: ()=>widget.animatedIconButtonOnTap()
          )
              :SizedBox(),
        ],
      ),
    );
  }
  @override
  void dispose() {
    super.dispose();
  }
}