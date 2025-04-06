import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';


class CustomAppBar extends StatefulWidget with PreferredSizeWidget {
  final IconData prefixIcon;
  final Function iconOnTap;
  final Function onChanged;
  final Function() logoOnTap;
  final String hintText;

  const CustomAppBar({Key key,
    this.iconOnTap,
    this.prefixIcon,
    this.onChanged,
    this.logoOnTap,
    this.hintText,

  }) : super(key: key);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  TextEditingController search = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      maintainBottomViewPadding: true,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 10,
            right: 15,
            left: 15,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.8),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20.0),
                    bottomRight: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                    topLeft: Radius.circular(20.0),

                )
              ),
              child: Row(
                children: <Widget>[
                  Material(
                    type: MaterialType.transparency,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: IconButton(
                        splashColor: Colors.grey,
                        icon: Icon(widget.prefixIcon),
                        onPressed: ()=> widget.iconOnTap(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: search,
                      cursorColor: Colors.black,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.go,
                      onChanged: (text)=> widget.onChanged(text),
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 15),
                          hintText: "${widget.hintText}" ?? "Search",
                        alignLabelWithHint: true,
                        hintStyle: TextStyle(
                          color: kPrimaryColor,
                          fontFamily: "TamilArima",
                        )
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 11,
            right: 20,
            child: InkWell(
              splashColor: Colors.blueGrey,
              onTap: (){
                widget.logoOnTap();
              },
                child: Image(image: AssetImage("assets/images/mrslogo.png"),height: 40.0,width: 50.0,)),
          ),
        ],
      ),
    );
  }
}