import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/operations.dart';
import 'package:mrs_dth_diary_v1/scr/ui/DashBoard/editDashBoardPayment.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/animatedSizeTransition.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/showAlertDialog.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/screen_navigation.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';
import 'customText.dart';

class DashBoardPaymentContainerListTile extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> snapshot;

  const DashBoardPaymentContainerListTile({
    super.key,
    required this.snapshot,
  });

  @override
  _DashBoardPaymentContainerListTileState createState() =>
      _DashBoardPaymentContainerListTileState();
}

class _DashBoardPaymentContainerListTileState
    extends State<DashBoardPaymentContainerListTile> {
  Widget? image;
  bool tileVisible = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => showAlertDialog(
          context: context,
          title: "",
          content: "Do you want to delete this post ?",
          yesOnPressed: () {
            deleteProduct(
                id: widget.snapshot.id,
                collectionName: "DashboardPaymentRecords");
            Navigator.of(context).pop();
          }),
      onTap: () {
        setState(() {
          tileVisible = !tileVisible;
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: Color(0xffE7F8FA),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: statusCheck(
                      widget.snapshot['PENDING_AMOUNT']?.toString(),
                      widget.snapshot['BALANCE_AMOUNT']?.toString(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, left: 3.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: [
                            Image.asset("assets/images/dish.png",
                                height: 30, width: 30),
                            SizedBox(
                              width: 3.0,
                            ),
                            CText(
                              msg: widget.snapshot['RECHARGE_PLACE'] == ''
                                  ? "No Place Name"
                                  : widget.snapshot['RECHARGE_PLACE']
                                      .toString(),
                              size: 18,
                              color: kIndigoDark,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 1.0,
                        ),
                        CText(
                          msg: DateFormat('dd-MM-yyyy hh:mm a').format(
                            (widget.snapshot['CREATE_AT'] as Timestamp)
                                .toDate(),
                          ),
                          size: 16,
                          color: kIndigoLight,
                          weight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Transform.rotate(
                                  angle: 3.14 / 180 * 45,
                                  child: Icon(
                                    Icons.attach_file,
                                    color: kBlueLight,
                                  ),
                                ),
                                SizedBox(
                                  width: 5.0,
                                ),
                                CText(
                                  msg:
                                      "Rs.${widget.snapshot['RECHARGE_AMOUNT'] ?? "0"}",
                                  size: 16,
                                  color: Colors.black,
                                  weight: FontWeight.bold,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.expand_more_rounded,
                                color: mainBlue),
                            onPressed: () {
                              setState(() {
                                tileVisible = !tileVisible;
                              });
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Visibility(
                  visible: tileVisible,
                  child: AnimatedSizeTransition(
                    duration: 800,
                    child: Container(
                      width: 500,
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        elevation: 0.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: CText(
                                msg: "Payment Details",
                                color: kIndigoLight,
                                size: 18,
                              ),
                            ),
                            Divider(),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 15.0, top: 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CText(
                                        msg:
                                            "கொடுத்த பணம் :  Rs. ${widget.snapshot['PAID_AMOUNT'] == '' ? "0" : widget.snapshot['PAID_AMOUNT']}",
                                        size: 18,
                                        weight: FontWeight.bold,
                                        color: Color(0xff61b15a),
                                      ),
                                      GestureDetector(
                                        onTap: () => changeScreen(
                                            context,
                                            EditDashBoardPayment(
                                              snapshot: widget.snapshot,
                                              dbId: widget.snapshot.id,
                                            )),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              right: 15.0, bottom: 5),
                                          child: Icon(Icons.edit),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Visibility(
                                    visible:
                                        widget.snapshot['PENDING_AMOUNT'] == ''
                                            ? false
                                            : true,
                                    child: CText(
                                      msg:
                                          "கொடுமதி பணம் :  Rs. ${widget.snapshot['PENDING_AMOUNT']}",
                                      size: 18,
                                      weight: FontWeight.bold,
                                      color: Color(0xffaf0069),
                                    ),
                                  ),
                                  Visibility(
                                    visible:
                                        widget.snapshot['PAID_DATE'] == null
                                            ? false
                                            : true,
                                    child: CRText(
                                      msg1: "இறுதியாக பணம் கொடுத்த திகதி : >>>",
                                      msg2:
                                          "\n ${widget.snapshot['PAID_DATE'] == null ? "" : DateFormat('dd-MM-yyyy hh:mm a').format((widget.snapshot['PAID_DATE'] as Timestamp).toDate())}",
                                      size1: 15,
                                      weight1: FontWeight.bold,
                                      color1: Color(0xff09015f),
                                    ),
                                  ),
                                  Visibility(
                                    visible:
                                        widget.snapshot['BALANCE_AMOUNT'] == ''
                                            ? false
                                            : true,
                                    child: CText(
                                      msg:
                                          "தருமதி பணம் :  Rs. ${widget.snapshot['BALANCE_AMOUNT']}",
                                      size: 18,
                                      weight: FontWeight.bold,
                                      color: Color(0xffaf0069),
                                    ),
                                  ),
                                  Visibility(
                                    visible: widget.snapshot['USER_NOTE'] == ''
                                        ? false
                                        : true,
                                    child: CText(
                                      msg:
                                          "User Note:  ${widget.snapshot['USER_NOTE']}",
                                      size: 18,
                                      weight: FontWeight.bold,
                                      color: Color(0xffff884b),
                                    ),
                                  ),
                                  gap(h: 5.0),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget gap({double? h, double? w}) {
    return SizedBox(
      height: h,
      width: w,
    );
  }

  Widget statusCheck(String? pending, String? balance) {
    if (pending != null && pending.isNotEmpty) {
      return Image.asset("assets/images/wrong.png", height: 30, width: 30);
    }
    if (balance != null && balance.isNotEmpty) {
      return Image.asset(
        "assets/images/correct.png",
        height: 30,
        width: 30,
        color: Colors.blue,
      );
    }
    return Image.asset("assets/images/correct.png", height: 30, width: 30);
  }
}
