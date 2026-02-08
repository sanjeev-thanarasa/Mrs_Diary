import 'package:flutter/material.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/responsive.dart';

class CustomTextField extends StatefulWidget {
  final IconData? icon;
  final IconData? animatedIconButtonStratIcon;
  final IconData? animatedIconButtonEndIcon;
  final TextInputType? keyboardType;
  final TextEditingController controller;
  final String? hintText;
  final String? image;
  final bool iconButton;
  final bool readOnly;
  final VoidCallback? animatedIconButtonOnTap;
  final TextStyle? textStyle;
  final Color? leadingIconColor;
  final Color? hintTextColor;

  const CustomTextField({
    super.key,
    this.icon,
    this.keyboardType,
    required this.controller,
    this.hintText,
    this.image,
    this.iconButton = false,
    this.readOnly = false,
    this.animatedIconButtonOnTap,
    this.animatedIconButtonStratIcon,
    this.animatedIconButtonEndIcon,
    this.textStyle,
    this.leadingIconColor,
    this.hintTextColor,
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    final accent = widget.leadingIconColor ?? mainBlue;
    final rs = context.rs;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rs.r(12.0)),
        border: Border.all(color: accent.withValues(alpha: 0.35), width: 1.0),
        boxShadow: [
          BoxShadow(
            blurRadius: rs.r(10),
            color: Colors.black.withValues(alpha: 0.04),
            offset: Offset(0, rs.rh(6)),
          )
        ],
      ),
      margin: EdgeInsets.symmetric(vertical: rs.rh(6.0)),
      padding: EdgeInsets.symmetric(
        horizontal: rs.rw(12.0),
        vertical: rs.rh(2.0),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: rs.r(36),
            height: rs.r(36),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(rs.r(10)),
            ),
            child: Center(
              child: widget.image != null
                  ? Image(
                      image: AssetImage(widget.image!),
                      fit: BoxFit.cover,
                      height: rs.r(20),
                      width: rs.r(20),
                      color: accent,
                    )
                  : Icon(
                      widget.icon ?? Icons.text_fields,
                      color: accent,
                      size: rs.r(20),
                    ),
            ),
          ),
          SizedBox(width: rs.rw(10)),
          Expanded(
            child: TextField(
              keyboardType: widget.keyboardType,
              readOnly: widget.readOnly,
              style: widget.textStyle ??
                  const TextStyle(
                    fontSize: 15.5,
                    fontFamily: 'TamilArima',
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
              controller: widget.controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: widget.hintText,
                alignLabelWithHint: true,
                hintStyle: widget.textStyle ??
                    TextStyle(
                      color: widget.hintTextColor ?? Colors.black45,
                      fontSize: 14.5,
                      fontFamily: "TamilArima2",
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
          if (widget.iconButton)
            IconButton(
              icon: Icon(
                widget.animatedIconButtonStratIcon ?? Icons.add,
                size: rs.r(20),
                color: accent,
              ),
              onPressed: widget.animatedIconButtonOnTap,
            )
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
