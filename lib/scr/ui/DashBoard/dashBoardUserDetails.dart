import 'dart:async';
import 'package:animated_icon_button/animated_icon_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/dashBoardService.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/operations.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CTextField.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CustomStreamBuilder.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/RoundedLoadingButton.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/animatedSizeTransition.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/customText.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/dashBoardPaymentContainerListTile.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/screen_navigation.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:pull_to_reveal/pull_to_reveal.dart';

import 'createDashboardPayment.dart';

class DashBoardUserDetails extends StatefulWidget {
  final DocumentSnapshot data;

  const DashBoardUserDetails({Key key, this.data}) : super(key: key);

  @override
  _DashBoardUserDetailsState createState() => _DashBoardUserDetailsState();
}

class _DashBoardUserDetailsState extends State<DashBoardUserDetails> {

  RefreshController _refreshController =
  RefreshController(initialRefresh: true);

  String dbID;

  void _onRefresh() async{
    print("___On Refresh_______________");
   // getUsersStreamSnapshots(collectionName: widget.collectionName ?? '');
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.refreshCompleted();
  }

  void _onLoading() async{
    await Future.delayed(Duration(milliseconds: 1000));
    print("___On Loading_______________");
    _refreshController.loadComplete();
  }

  @override
  void initState() {
    dbID = widget.data['id'] ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CRText(
          msg1: widget.data["name"] ?? '',
          msg2: "   Details",
          size1: 25.0,
          color1: white,
          weight1: FontWeight.bold,
          color2: Colors.grey,
        ),
        centerTitle: true,
        actions: [
          Image.asset(
            "assets/images/mrslogo.png",
            height: 50.0,
            width: 50.0,
            color: white,
          )
        ],
      ),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        enablePullDown: true,
        child: CustomStreamBuilder(
          context: context,
          stream: filterStream(),
          body:(snapshot){
            return PullToRevealTopItemList(
              startRevealed: true,
              itemCount: snapshot.data.docs.length,
              itemBuilder: (BuildContext context, int index) {
                var data = snapshot.data.docs[index];
                print(data.runtimeType);
                print(snapshot.data.docs.length);
                print(data);
                print(data);
                return DashBoardPaymentContainerListTile(
                  snapshot: data,
                );
              },
              revealableHeight: MediaQuery.of(context).size.height * 0.33,
              revealableBuilder: (BuildContext context, RevealableToggler opener, RevealableToggler closer, BoxConstraints constraints) {
                return Stack(
                  alignment: Alignment.topLeft,
                  children: <Widget>[
                    Container(),
                    _buildBackground(context),
                    Positioned(
                      child: _buildContentUI(),
                      top: MediaQuery.of(context).size.height * 0.19,
                      left: 40,
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Stream<QuerySnapshot> filterStream() async* {
    var firestore = FirebaseFirestore.instance;
    var _stream = firestore
        .collection('DashboardPaymentRecords')
        .where('DB_ID', isEqualTo: dbID)
        .orderBy('CREATE_AT',descending: true)
        .snapshots();

    yield* _stream;
  }

  Widget _buildContentUI() {
    return Row(
      children: <Widget>[
        Hero(
          tag: 1,
          child: Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(.8),
                borderRadius: BorderRadius.all(Radius.circular(16))),
            child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                child: Image.asset(
                  "assets/images/dashBoard.png",
                  height: 100,
                )),
          ),
        ),
        SizedBox(
          width: 16,
        ),
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(
            radius: 35,
            child: AnimatedIconButton(
              duration: Duration(seconds: 1),
              size: 35.0,
              startIcon: Icon(
                Icons.add,
                color: white,
              ),
              endIcon: Icon(
                Icons.add,
                color: white,
              ),
              onPressed: () => changeScreen(context, CreateDashBoardPayment(dbId: widget.data["id"],)),
              splashColor: kBlueColor,
            ),
            backgroundColor: kPrimaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildBackground(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/money.jpg"),
                fit: BoxFit.cover),
            borderRadius:
                BorderRadius.only(bottomRight: Radius.circular(112)),
          ),
          height: MediaQuery.of(context).size.height * 0.25,
        ),
      ],
    );
  }

  // Future<bool> showAlertDialog({
  //   @required BuildContext context,
  //   @required String title,
  //   @required String content,
  //   @required DocumentSnapshot data,
  // }) async {
  //   return showCupertinoDialog(
  //     context: context,
  //     builder: (context) => CupertinoAlertDialog(
  //       title: CText(msg: title, color: blue),
  //       content: CText(msg: content, color: red, size: 20.0),
  //       actions: <Widget>[
  //         CupertinoDialogAction(
  //           child: CText(
  //             msg: "No",
  //             color: blue,
  //           ),
  //           onPressed: () => Navigator.of(context).pop(false),
  //         ),
  //         CupertinoDialogAction(
  //           child: CText(
  //             msg: "Yes",
  //             color: red,
  //           ),
  //           onPressed: () {
  //             deleteProduct(
  //                 id: data.id.toString(), collectionName: "DashBoardPayments");
  //             Navigator.of(context).pop();
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // buildContainer() {
  //   return SingleChildScrollView(
  //     child: Column(
  //       children: [
  //         Stack(
  //           children: [
  //             Container(
  //               decoration: BoxDecoration(
  //                 image: DecorationImage(
  //                     image: AssetImage(
  //                       "assets/images/mrs1.png",
  //                     ),
  //                     fit: BoxFit.fitWidth),
  //                 borderRadius:
  //                     BorderRadius.only(bottomRight: Radius.circular(112)),
  //                 color: kBlueColor,
  //               ),
  //               height: MediaQuery.of(context).size.height * 0.22,
  //             ),
  //           ],
  //         ),
  //         Column(
  //           children: [
  //             SizedBox(
  //               height: 80.0,
  //             ),
  //             Padding(
  //               padding: const EdgeInsets.only(left: 20.0, right: 20.0),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.stretch,
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: <Widget>[
  //                   // Visibility(
  //                   //   visible: editRecord,
  //                   //   child: AnimatedSizeTransition(
  //                   //     duration: 800,
  //                   //     child: SingleChildScrollView(
  //                   //       child: Column(
  //                   //         children: [
  //                   //           Visibility(
  //                   //             visible: widget.data["RECHARGE_NAME"] == ''
  //                   //                 ? false
  //                   //                 : true,
  //                   //             child: CustomTextField(
  //                   //               controller: rechargerName,
  //                   //               hintText:
  //                   //               "Recharger Name : ${widget.data["RECHARGE_NAME"]}",
  //                   //               icon: Icons.account_balance,
  //                   //               keyboardType: TextInputType.text,
  //                   //             ),
  //                   //           ),
  //                   //           Visibility(
  //                   //             visible: widget.data["RECHARGE_PLACE"] == ''
  //                   //                 ? false
  //                   //                 : true,
  //                   //             child: CustomTextField(
  //                   //               controller: rechargePlace,
  //                   //               hintText:
  //                   //               "Recharge செய்த இடம் : Rs.${widget.data["RECHARGE_PLACE"]}",
  //                   //               icon: Icons.home,
  //                   //               keyboardType: TextInputType.text,
  //                   //             ),
  //                   //           ),
  //                   //           Visibility(
  //                   //             visible:
  //                   //             widget.data["PAID_AMOUNT"] == '' ? false : true,
  //                   //             child: CustomTextField(
  //                   //               controller: giveMoney,
  //                   //               hintText:
  //                   //               "கொடுத்த பணம் :  ${widget.data["PAID_AMOUNT"]}",
  //                   //               icon: Icons.monetization_on_rounded,
  //                   //               keyboardType: TextInputType.number,
  //                   //               iconButton: true,
  //                   //               iconButtonIcon: Icons.done,
  //                   //               iconButtonEndIcon: Icons.done_all_rounded,
  //                   //               iconOnTap: (){
  //                   //                 int recharge=int.parse(widget.data["PACKAGE_AMOUNT"]);
  //                   //                 int give=int.parse(giveMoney.text);
  //                   //                 if(recharge>give){
  //                   //                   setState(() {
  //                   //                     pendingAmount.text=(recharge-give).toString();
  //                   //                     pending=true;
  //                   //                   });
  //                   //                 }
  //                   //                 else if(recharge==give){
  //                   //                   setState((){
  //                   //                     pending=false;
  //                   //                     pendingAmount.text='';
  //                   //                   });}
  //                   //               },
  //                   //             ),
  //                   //           ),
  //                   //           Visibility(
  //                   //             visible: widget.data["PENDING_AMOUNT"] == '' && !pending
  //                   //                 ? false
  //                   //                 : true,
  //                   //             child: CustomTextField(
  //                   //               controller: pendingAmount,
  //                   //               hintText:
  //                   //               "கொடுமதி பணம் :  ${widget.data["PENDING_AMOUNT"]}",
  //                   //               icon: Icons.monetization_on_rounded,
  //                   //               keyboardType: TextInputType.number,
  //                   //             ),
  //                   //           ),
  //                   //           Visibility(
  //                   //             visible:
  //                   //             widget.data["USER_NOTE"] == '' ? false : true,
  //                   //             child: CustomTextField(
  //                   //               controller: userNote,
  //                   //               hintText:
  //                   //               "User Note:  ${widget.data["USER_NOTE"]}",
  //                   //               icon: Icons.note_add_outlined,
  //                   //               keyboardType: TextInputType.text,
  //                   //             ),
  //                   //           ),
  //                   //           SizedBox(
  //                   //             height: 15.0,
  //                   //           ),
  //                   //           RoundedLoading(
  //                   //             btnController: _btnController,
  //                   //             paddingLeft: 140.0,
  //                   //             paddingRight: 120.0,
  //                   //             paddingTop: 8.0,
  //                   //             buttonPressed: () {
  //                   //               Timer(Duration(milliseconds: 10), () {
  //                   //                 checkEmptyField();
  //                   //                 _btnController.success();
  //                   //               });
  //                   //               Timer(Duration(milliseconds: 500), () {
  //                   //                 clearRecords();
  //                   //                 _btnController.reset();
  //                   //                 Navigator.popAndPushNamed(
  //                   //                     context, '/DashBoard');
  //                   //               });
  //                   //             },
  //                   //           ),
  //                   //         ],
  //                   //       ),
  //                   //     ),
  //                   //   ),
  //                   // ),
  //                   SizedBox(
  //                     height: 15,
  //                   ),
  //                   Container(
  //                     padding: EdgeInsets.symmetric(
  //                         horizontal: 15.0, vertical: 10.0),
  //                     width: double.infinity,
  //                     child: Material(
  //                         borderRadius: BorderRadius.circular(5.0),
  //                         elevation: 2.0,
  //                         child: Padding(
  //                           padding: EdgeInsets.symmetric(
  //                               horizontal: 10.0, vertical: 10.0),
  //                           child: Column(
  //                             children: <Widget>[
  //                               Row(
  //                                 mainAxisAlignment: MainAxisAlignment.center,
  //                                 children: <Widget>[
  //                                   CText(
  //                                       msg:
  //                                           "Recharger Name : ${widget.data["RECHARGE_NAME"]}",
  //                                       color: kIndigoLight,
  //                                       size: 20.0),
  //                                 ],
  //                               ),
  //                               Divider(),
  //                               SizedBox(
  //                                 height: 10.0,
  //                               ),
  //                               Column(
  //                                 children: <Widget>[
  //                                   Row(
  //                                     children: [
  //                                       CText(
  //                                         msg: "Package Amount :  ",
  //                                         size: 20.0,
  //                                       ),
  //                                       CText(
  //                                         msg:
  //                                             "\Rs.${widget.data["PACKAGE_AMOUNT"]}",
  //                                         size: 20.0,
  //                                         color: blue,
  //                                       ),
  //                                     ],
  //                                   ),
  //                                   SizedBox(
  //                                     height: 2.0,
  //                                   ),
  //                                   Visibility(
  //                                     visible: widget.data["PAID_AMOUNT"] == ''
  //                                         ? false
  //                                         : true,
  //                                     child: Row(
  //                                       children: [
  //                                         CText(
  //                                           msg: "கொடுத்த பணம் :  ",
  //                                           size: 20.0,
  //                                         ),
  //                                         CText(
  //                                           msg:
  //                                               "\Rs.${widget.data["PAID_AMOUNT"]}",
  //                                           size: 20.0,
  //                                           color: green,
  //                                         ),
  //                                       ],
  //                                     ),
  //                                   ),
  //                                   SizedBox(
  //                                     height: 2.0,
  //                                   ),
  //                                   Visibility(
  //                                     visible:
  //                                         widget.data["PENDING_AMOUNT"] == ''
  //                                             ? false
  //                                             : true,
  //                                     child: Row(
  //                                       children: [
  //                                         CText(
  //                                           msg: "கொடுமதி பணம் :  ",
  //                                           size: 20.0,
  //                                         ),
  //                                         CText(
  //                                           msg:
  //                                               "\Rs.${widget.data["PENDING_AMOUNT"]}",
  //                                           size: 20.0,
  //                                           color: red,
  //                                         ),
  //                                       ],
  //                                     ),
  //                                   ),
  //                                   SizedBox(
  //                                     height: 2.0,
  //                                   ),
  //                                   Visibility(
  //                                     visible: widget.data["USER_NOTE"] == ''
  //                                         ? false
  //                                         : true,
  //                                     child: Row(
  //                                       children: [
  //                                         CText(
  //                                           msg: "User Note :  ",
  //                                           color: blue,
  //                                           size: 20.0,
  //                                         ),
  //                                         CText(
  //                                           msg:
  //                                               "\Rs.${widget.data["USER_NOTE"]}",
  //                                           size: 20.0,
  //                                           color: blue,
  //                                         ),
  //                                       ],
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                               Row(
  //                                 mainAxisAlignment: MainAxisAlignment.center,
  //                                 children: <Widget>[
  //                                   Expanded(
  //                                       child: Container(
  //                                     padding: EdgeInsets.symmetric(
  //                                         vertical: 10.0, horizontal: 10.0),
  //                                     child: Row(
  //                                       mainAxisAlignment:
  //                                           MainAxisAlignment.spaceBetween,
  //                                       children: <Widget>[
  //                                         Row(
  //                                           children: <Widget>[
  //                                             CText(
  //                                                 msg: widget.data["CREATE_AT"],
  //                                                 size: 16.0,
  //                                                 color: Colors.grey),
  //                                             SizedBox(
  //                                               height: 5.0,
  //                                             ),
  //                                           ],
  //                                         )
  //                                       ],
  //                                     ),
  //                                   )),
  //                                   Container(
  //                                       child: InkResponse(
  //                                     onTap: () {},
  //                                     child: widget.data["PENDING_AMOUNT"] == ''
  //                                         ? Icon(Icons.check_circle_rounded,
  //                                             size: 35.0, color: green)
  //                                         : Icon(Icons.pending_actions_sharp,
  //                                             size: 35.0, color: orange),
  //                                   ))
  //                                 ],
  //                               )
  //                             ],
  //                           ),
  //                         )),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }
  //
  // void clearRecords() {
  //   packageDate.clear();
  //   packageAmount.clear();
  //   rechargePlace.clear();
  //   pendingAmount.clear();
  //   paidAmount.clear();
  //   balanceAmount.clear();
  //   pendingAmount.clear();
  //   userNote.clear();
  // }
  //
  // void createPaymentRecord() async {
  //   addRecord = {
  //     "USER_ID": widget.data.id,
  //     "PACKAGE_AMOUNT": packageAmount.text,
  //     "RECHARGE_PLACE": rechargePlace.text,
  //     "PAID_AMOUNT": paidAmount.text,
  //     "PENDING_AMOUNT": pendingAmount.text,
  //     "BALANCE_AMOUNT": balanceAmount.text,
  //     "USER_NOTE": userNote.text,
  //     "CREATE_AT": DateTime.now(),
  //   };
  //   Timer(Duration(milliseconds: 200), () {
  //     databaseReference
  //         .collection("DashBoardPayments")
  //         .add(addRecord)
  //         .whenComplete(() {
  //       clearRecords();
  //     });
  //   });
  // }
}
