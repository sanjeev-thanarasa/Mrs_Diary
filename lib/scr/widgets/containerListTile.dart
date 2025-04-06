// import 'package:animated_icon_button/animated_icon_button.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/screen_navigation.dart';
// import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';
// import 'animatedSizeTransition.dart';
// import 'customText.dart';
//
// class PaymentContainerListTile extends StatefulWidget {
//   final String packageName;
//   final String rechargeDate;
//   final String rechargeAmount;
//   final String paidMoney;
//   final String pendingMoney;
//   final String pendingDate;
//   final String balanceMoney;
//   final String userNote;
//   final DocumentSnapshot snapshot;
//
//
//   const PaymentContainerListTile({Key key,
//     @required this.packageName,
//     @required this.rechargeDate,
//     @required this.rechargeAmount,
//     @required this.paidMoney,
//     @required this.pendingMoney,
//     @required this.pendingDate,
//     @required this.balanceMoney,
//     @required this.userNote,
//     @required this.snapshot,
//   }) : super(key: key);
//
//
//
//   @override
//   _PaymentContainerListTileState createState() => _PaymentContainerListTileState();
// }
//
// class _PaymentContainerListTileState extends State<PaymentContainerListTile>
//     with SingleTickerProviderStateMixin {
//
//
//   bool tileVisible = false;
//   bool give = false;
//   bool pending = false;
//   bool pendingD = false;
//   bool balance = false;
//   bool note = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onLongPress: ()=>showAlertDialog(
//         context: context,
//         title: "Delete",
//         content: "இந்த பதிவை நீக்க விரும்புகிறீர்களா ?",
//       ),
//       child: Container(
//         margin: EdgeInsets.symmetric(vertical: 12),
//         width: MediaQuery.of(context).size.width * 0.5,
//         color: Color(0xffE7F8FA),
//         child: Column(
//           children: [
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 Container(
//                   width: 3,
//                   color: kBlueLight,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Transform.rotate(
//                     angle: 3.14 / 180 * 45,
//                     child: Icon(
//                       Icons.attach_file,
//                       color: function,
//                     ),
//                   ),
//                 ),
//                 Column(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: <Widget>[
//                     CText(
//                       msg: widget.packageName,
//                       size: 18,
//                       color: kIndigoDark,
//                     ),
//                     CText(
//                       msg: widget.rechargeDate,
//                       size: 16,
//                       color: kIndigoLight,
//                       weight: FontWeight.w600,
//                     ),
//                   ],
//                 ),
//                 Expanded(
//                   child: Padding(
//                     padding: EdgeInsets.only(right: 8.0),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         CText(
//                           msg: "Rs." + widget.rechargeAmount,
//                           size: 20,
//                           color: Colors.green,
//                           weight: FontWeight.bold,
//                         ),
//                         AnimatedIconButton(
//                           duration: Duration(milliseconds: 500),
//                           startIcon: Icon(Icons.more_outlined,color: mainBlue),
//                           endIcon: Icon(Icons.unfold_more_sharp,color: mainBlue),
//                           onPressed: () {
//                             setState(() {
//                               tileVisible = !tileVisible;
//                             });
//                           },
//
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             Visibility(
//                 visible: tileVisible,
//                 child: AnimatedSizeTransition(
//                 child: Container(
//                 width: 500,
//                 child: Card(
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10.0)),
//                   elevation: 4.0,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Center(
//                         child: CText(
//                           msg: "Payment Details",
//                           color: kIndigoLight,
//                           size: 18,
//                         ),
//                       ),
//
//                       Divider(),
//                       Padding(
//                         padding: const EdgeInsets.only(left: 15.0,top: 10.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 CText(
//                                   msg: "தந்த பணம் :  Rs. ${widget.paidMoney}",
//                                   size: 18,
//                                   weight: FontWeight.bold,
//                                   color: lightGreen,
//                                 ),
//                                 GestureDetector(
//                                   onTap:()=>changeScreen(context, EditPayment(
//                                     snapshot: widget.snapshot,
//                                       packageName: widget.packageName,
//                                       rechargeDate: widget.rechargeDate,
//                                       paidMoney: widget.paidMoney,
//                                       pendingMoney: widget.pendingMoney,
//                                       pendingDate: widget.pendingDate,
//                                       balanceMoney: widget.balanceMoney,
//                                       userNote: widget.userNote,
//                                   )),
//                                   child: Padding(
//                                     padding: const EdgeInsets.only(right: 15.0,bottom: 5),
//                                     child: Icon(Icons.edit),
//                                   ),
//                                 ),
//                               ],
//                             ),
//
//                             Visibility(
//                               visible: widget.pendingMoney=='' ? false:true,
//                               child: CText(
//                                 msg: "முடியும் திகதி :  ${widget.snapshot["EXPIRED_AT"]}",
//                                 size: 18,
//                                 weight: FontWeight.bold,
//                                 color: lightGreen,
//                               ),
//                             ),
//                             Visibility(
//                               visible: widget.pendingDate=='' ? false:true,
//                               child: CText(
//                                 msg: "தருமதி திகதி : ${widget.pendingDate}",
//                                 size: 18,
//                                 weight: FontWeight.bold,
//                                 color: lightGreen,
//                               ),
//                             ),
//                             Visibility(
//                               visible: widget.balanceMoney=='' ? false:true,
//                               child: CText(
//                                 msg: "கொடுமதி பணம் :  Rs. ${widget.balanceMoney}",
//                                 size: 18,
//                                 weight: FontWeight.bold,
//                                 color: lightGreen,
//                               ),
//                             ),
//                             Visibility(
//                               visible: widget.userNote=='' ? false:true,
//                               child: CText(
//                                 msg: "User Note:  ${widget.userNote}",
//                                 size: 18,
//                                 weight: FontWeight.bold,
//                                 color: lightGreen,
//                               ),
//                             ),
//                             SizedBox(
//                               height: 20.0,
//                             )
//
//                           ],
//                         ),
//                       ),
//
//                     ],
//                   ),
//                 ),
//               ),
//       )
//
//       ),
//           ],
//         ),
//       ),
//     );
//   }
//   Future<bool> showAlertDialog({
//     @required BuildContext context,
//     @required String title,
//     @required String content,
//   }) async {
//     return showCupertinoDialog(
//       context: context,
//       builder: (context) => CupertinoAlertDialog(
//         title: CText(msg: title, color: blue),
//         content: CText(msg: content, color: red, size: 20.0),
//         actions: <Widget>[
//           CupertinoDialogAction(
//             child: CText(
//               msg: "No",
//               color: blue,
//             ),
//             onPressed: () => Navigator.of(context).pop(false),
//           ),
//           CupertinoDialogAction(
//             child: CText(
//               msg: "Yes",
//               color: red,
//             ),
//             onPressed: () {
//               deleteProduct(widget.snapshot, "PaymentRecords");
//               Navigator.of(context).pop();
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//
// }
