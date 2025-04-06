import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/operations.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/gap.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';
import 'customText.dart';

class CListTile extends StatefulWidget {
  final BuildContext context;
  final String docId;
  final String collectionName;
  final Function tileOnTap;
  final String image;
  final Color subCircleColor;
  final String title;
  final String subtitle;
  final String subtitle2;
  final String subtitle3;
  final IconData subtitleIcon;
  final String counter;
  final String pendingAmount;

  const CListTile({
    Key key,
    @required this.context,
    @required this.docId,
    @required this.collectionName,
    this.tileOnTap,
    this.image,
    this.subCircleColor,
    @required this.title,
    @required this.subtitle,
    this.subtitle2,
    this.subtitle3,
    @required this.subtitleIcon,
    this.counter,
    this.pendingAmount,
  }) : super(key: key);

  @override
  _CListTileState createState() => _CListTileState();
}

class _CListTileState extends State<CListTile> {
  SlidableController _slidableController = SlidableController();

  @override
  void initState() {
    Slidable.of(context)?.renderingMode == SlidableRenderingMode.none
        ? Slidable.of(context)?.open()
        : Slidable.of(context)?.close();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      actionExtentRatio: .12,
      fastThreshold: 15.0,
      closeOnScroll: true,
      controller: _slidableController,
      actionPane: SlidableDrawerActionPane(),
      secondaryActions: [
        IconSlideAction(
          iconWidget: Container(
            height: 95.0,
            width: 60.0,
            child: Card(
                shadowColor: white.withOpacity(.8),
                color: red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20.0),
                        bottomLeft: Radius.circular(20.0))),
                elevation: 10,
                child: IconButton(
                  icon: Icon(Icons.delete_rounded),
                  iconSize: 30.0,
                  color: white,
                  onPressed: () => showAlertDialog(
                    context: context,
                    title: "Delete",
                    content: "இந்த பதிவை நீக்க விரும்புகிறீர்களா ?",
                  ),
                )),
          ),
          color: Colors.transparent,
          closeOnTap: true,
        ),
      ],
      child: GestureDetector(
        onTap: () => widget.tileOnTap() ?? {},
        child: Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          elevation: 8,
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            child: ListTile(
              leading: widget.image == null
                  ? CircleAvatar(
                      radius: 25,
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                      child: CText(
                        msg: widget.counter ?? "",
                        color: Colors.white,
                        size: 18.0,
                      ),
                    )
                  : Stack(
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                          child: Image.asset(
                            widget.image,
                            height: 56,
                            width: 56,
                            fit: BoxFit.fill,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 2,
                          child: Container(
                            padding: EdgeInsets.all(2),
                            child: CircleAvatar(
                              radius: 6,
                              backgroundColor:
                                  widget.subCircleColor ?? Colors.transparent,
                            ),
                          ),
                        )
                      ],
                    ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CText(
                    msg: widget.title ?? "",
                    color: kIndigoDark,
                    size: widget.collectionName == "Villages" ? 18 : 16,
                    weight: FontWeight.w600,
                  ),
                  CText(
                    msg: widget.pendingAmount ?? "",
                    color: kIndigoDark,
                    size: 18,
                    weight: FontWeight.w600,
                  ),

                  Row(
                    children: [
                      widget.subtitle2 != null
                          ? Row(
                              children: [
                                Image.asset(
                                  "assets/images/dish.png",
                                  height: 20,
                                  width: 20,
                                ),
                                CSText(
                                  msg: widget.subtitle2 ?? "",
                                  color: kBlueColor,
                                  size: 20,
                                  weight: FontWeight.w600,
                                ),
                              ],
                            )
                          : SizedBox(),
                    ],
                  )
                ],
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        widget.subtitleIcon ?? Icons.error_outline,
                        color: kBlueColor,
                        size: 12,
                      ),
                      SizedBox(
                        width: 3,
                      ),
                      CText(
                        msg: widget.subtitle ?? "",
                        size: 13,
                        weight: FontWeight.w600,
                      ),
                    ],
                  ),
                  widget.subtitle3 != null
                      ? Row(
                          children: [
                            Icon(
                              Icons.people_alt_rounded,
                              size: 13,
                              color: kPrimaryColor,
                            ),
                            Gap(
                              w: 3.0,
                            ),
                            CText(
                              msg: widget.subtitle3 ?? "",
                              size: 13,
                              weight: FontWeight.w600,
                              color: kPrimaryColor,
                            ),
                          ],
                        )
                      : SizedBox(),
                ],
              ),
              // trailing: Container(
              //   decoration: BoxDecoration(
              //       color: mainBlue,
              //       borderRadius: BorderRadius.only(
              //         topLeft: Radius.circular(5),
              //         bottomLeft: Radius.circular(5),
              //       )),
              //   width: 4.0,
              //   height: 50.0,
              //   child: Ink(
              //     child: Icon(
              //       Icons.arrow_left,
              //       color: kBlueColor,
              //       size: 35,
              //     ),
              //   ),
              // ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> showAlertDialog({
    @required BuildContext context,
    @required String title,
    @required String content,
  }) async {
    return showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: CText(msg: title, color: blue),
        content: CText(msg: content, color: red, size: 20.0),
        actions: <Widget>[
          CupertinoDialogAction(
            child: CText(
              msg: "No",
              color: blue,
            ),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          CupertinoDialogAction(
            child: CText(
              msg: "Yes",
              color: red,
            ),
            onPressed: () {
              deleteProduct(
                  id: widget.docId ?? "",
                  collectionName: widget.collectionName);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
