import 'package:flutter/material.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/responsive.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final IconData prefixIcon;
  final VoidCallback? iconOnTap;
  final ValueChanged<String>? onChanged;
  final VoidCallback? logoOnTap;
  final Widget? trailing;
  final String? hintText;
  final TextStyle? hintStyle;

  const CustomAppBar({
    super.key,
    required this.prefixIcon,
    this.iconOnTap,
    this.onChanged,
    this.logoOnTap,
    this.trailing,
    this.hintText,
    this.hintStyle,
  });

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  final TextEditingController search = TextEditingController();

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    return SafeArea(
      maintainBottomViewPadding: true,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: rs.rh(10),
            right: rs.rw(15),
            left: rs.rw(15),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .8),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(rs.r(20.0)),
                    bottomRight: Radius.circular(rs.r(20.0)),
                    topRight: Radius.circular(rs.r(20.0)),
                    topLeft: Radius.circular(rs.r(20.0)),
                  )),
              child: Row(
                children: <Widget>[
                  Material(
                    type: MaterialType.transparency,
                    child: Padding(
                      padding: EdgeInsets.only(left: rs.rw(8.0)),
                      child: IconButton(
                        splashColor: Colors.blueGrey,
                        icon: Icon(widget.prefixIcon),
                        onPressed: widget.iconOnTap,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: search,
                      cursorColor: Colors.black,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.go,
                      onChanged: widget.onChanged,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          // contentPadding: EdgeInsets.symmetric(
                          //   horizontal: rs.rw(15),
                          // ),
                          hintText: widget.hintText ?? "Search",
                          alignLabelWithHint: true,
                          hintStyle: widget.hintStyle ??
                              TextStyle(
                                color: kPrimaryColor,
                                fontFamily: "TamilArima",
                                fontSize: rs.r(16.0),
                              )),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(
                  right: rs.rw(20),
                  top: rs.rh(10),
                ),
                child: widget.trailing ??
                    InkWell(
                        splashColor: Colors.blueGrey,
                        onTap: widget.logoOnTap,
                        child: Image(
                          image: AssetImage("assets/images/mrslogo.png"),
                          height: rs.r(40.0),
                          width: rs.r(50.0),
                        )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
