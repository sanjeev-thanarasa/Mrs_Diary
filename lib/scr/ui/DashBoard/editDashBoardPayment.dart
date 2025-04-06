import 'package:animated_icon_button/animated_icon_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/dashBoardService.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CTextField.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/RoundedLoadingButton.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/SimpleCalc.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/customText.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/gap.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';
import 'package:pull_to_reveal/pull_to_reveal.dart';

class EditDashBoardPayment extends StatefulWidget {
  final String dbId;
  final QueryDocumentSnapshot snapshot;

  const EditDashBoardPayment({Key key,
    this.snapshot,
    this.dbId})
      : super(key: key);

  @override
  _EditDashBoardPaymentState createState() => _EditDashBoardPaymentState();
}

class _EditDashBoardPaymentState extends State<EditDashBoardPayment> {
  DashBoardService _dashBoardService = DashBoardService();

  @override
  void dispose() {
    _dashBoardService.clearRecords();
    super.dispose();
  }

  @override
  void initState() {
    editInitialize();
    super.initState();
  }

  void editInitialize(){
    _dashBoardService.createAt= widget.snapshot['CREATE_AT'] != null ? widget.snapshot['CREATE_AT'].toDate() : null;

    _dashBoardService.createAtController.text=widget.snapshot['CREATE_AT'] != null ? DateFormat('dd-MM-yyyy hh:mm a')
        .format(widget.snapshot['CREATE_AT'].toDate()): "" ;

    //_dashBoardService.userNote.text = widget.snapshot['USER_NOTE'];
    //_dashBoardService.rechargePlace.text=widget.snapshot['RECHARGE_PLACE'];

    _dashBoardService.pendingAmount.text = widget.snapshot['PENDING_AMOUNT'];
    _dashBoardService.balanceAmount.text = widget.snapshot['BALANCE_AMOUNT'];
    _dashBoardService.balanceAmount.text = widget.snapshot['BALANCE_AMOUNT'];
    _dashBoardService.packageAmount.text = widget.snapshot['RECHARGE_AMOUNT'];
  }

  void _onRefresh() {
    _dashBoardService.clearRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: CText(
            msg: "Edit DashBoard Payment",
            color: Colors.white,
            weight: FontWeight.bold,
            size: 20.0),
        elevation: 10.0,
        centerTitle: true,
        backgroundColor: Color(0xff6c6a6b),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(
                Icons.calculate_rounded,
                size: 30.0,
              ),
              onPressed: () {
                showModalBottomSheet<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return SimpleCalc();
                    });
              },
            ),
          )
        ],
      ),
      body: PullToRevealTopItemList(
        startRevealed: true,
        itemCount: 1,
        itemBuilder: (BuildContext context, int index) {
          return _buildContentUI(context);
        },
        revealableHeight: 250,
        revealableBuilder: (BuildContext context, RevealableToggler opener,
            RevealableToggler closer, BoxConstraints constraints) {
          return Stack(
            alignment: Alignment.topLeft,
            children: <Widget>[
              _buildBackground(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBackground(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/images/money.jpg"), fit: BoxFit.cover),
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(112)),
        color: kBlueColor,
      ),
      height: MediaQuery.of(context).size.height * 0.28,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0,left: 5.0),
        child: Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedIconButton(
              duration: Duration(milliseconds: 500),
              startIcon: Icon(Icons.refresh),
              endIcon: Icon(Icons.replay),
              startBackgroundColor: Color(0xff484a49),
              splashRadius: 10.0,
              size: 25.0,
              onPressed: () => _onRefresh(),
            )),
      ),
    );
  }

  Widget _buildContentUI(BuildContext context) {
    return Container(
      width: 500,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 0.0,
          child: Column(
            children: [
              SizedBox(
                height: 5.0,
              ),
              CText(
                msg: "Edit Record",
                color: kPrimaryColor,
              ),
              Divider(
                thickness: 1.0,
              ),
              CText(
                msg: "Create at : ${_dashBoardService.createAtController.text}",
                color: Colors.grey,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CRText(
                    msg1: "எடுத்த பணம் :  " ,
                    msg2: "Rs. ${_dashBoardService.packageAmount.text}" ,
                    color1: Colors.blue,
                    color2: Colors.orange,
                  ),
                  Gap(w: 10,),
                  buildTikImage(color: Colors.blue,height: 20,width: 20)
                ],
              ),
              Gap(h: 5.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CRText(
                    msg1: "கொடுத்த பணம் :  " ,
                    msg2: "Rs. ${_dashBoardService.paidAmount.text}" ,
                    color1: Colors.blue,
                    color2: Colors.orange,
                  ),
                  Gap(w: 10,),

                  buildTikImage(color: Colors.blue,height: 20,width: 20)
                ],
              ),
              Gap(h: 5.0),
              buildPaidPendingVisible(),
              Divider(
                thickness: 1.0,
              ),
              CustomTextField(
                controller: _dashBoardService.newPaidAmount,
                hintText: "புதிதாக கொடுத்த பணம் ???",
                icon: Icons.money_off_rounded,
                keyboardType: TextInputType.number,
                iconButton: true,
                animatedIconButtonStratIcon: Icons.done,
                animatedIconButtonEndIcon:
                Icons.done_all_rounded,
                animatedIconButtonOnTap: () {

                  int recharge = int.parse(_dashBoardService.packageAmount.text.trim()??0);
                  int paid = int.parse(widget.snapshot['PAID_AMOUNT'].toString() ?? 0);
                  int newGive = int.parse(_dashBoardService.newPaidAmount.text.trim()??0);
                  int give = paid+newGive;
                  _dashBoardService.paidDate = DateTime.now();

                  if (recharge > give) {
                    setState(() {
                      _dashBoardService.balanceAmount.clear();
                      _dashBoardService.pendingAmount.text = (recharge - give).toString();
                      _dashBoardService.pending = true;
                      _dashBoardService.balance = false;
                    });
                  } else if (recharge < give) {
                    setState(() {
                      _dashBoardService.pending = false;
                      _dashBoardService.balance = true;

                      _dashBoardService.pendingAmount.clear();
                      _dashBoardService.balanceAmount.text = (give - recharge).toString();
                    });
                  } else if (recharge == give) {
                    setState(() {
                      _dashBoardService.pendingAmount.clear();
                      _dashBoardService.balanceAmount.clear();

                      _dashBoardService.pending=false;
                      _dashBoardService.balance=false;
                    });
                  }
                },
              ),
              Visibility(
                visible: _dashBoardService.pending,
                child: CRText(
                  color2: Colors.grey,
                  size1: 16.0,
                  msg1: "கொடுமதி பணம் ",

                  msg2: ":  ${_dashBoardService.pendingAmount.text ?? ''} ",
                  color1: Colors.grey,
                ),

              ),
              Visibility(
                visible: _dashBoardService.balance,
                child: CRText(
                  color1: Colors.grey,
                  size1: 16.0,
                  msg1: "தருமதி பணம் ",
                  msg2: ":  ${_dashBoardService.balanceAmount.text ?? ''}" ,
                ),
              ),
              CustomTextField(
                controller: _dashBoardService.rechargePlace,
                hintText: "எடுத்த இடம் : ${widget.snapshot['RECHARGE_PLACE']} ",
                icon: Icons.home,
                keyboardType: TextInputType.text,
              ),
              CustomTextField(
                controller: _dashBoardService.userNote,
                hintText: "குறிப்பு : ${widget.snapshot['USER_NOTE'] ?? ''} ",
                icon: Icons.note_add,
                keyboardType: TextInputType.text,
              ),
              SizedBox(
                height: 10.0,
              ),
              RoundedLoading(
                btnController: _dashBoardService.btnController,
                paddingLeft: 10.0,
                paddingRight: 10.0,
                paddingTop: 8.0,
                buttonHeight: 40,
                btnColor: Colors.blue,
                buttonPressed: () {
                 _dashBoardService.updateRecord(dbID: widget.dbId , snapshot: widget.snapshot);
                },
              ),
              SizedBox(
                height: 20.0,
              )
            ],
          ),
        ),
      ),
    );
    // Card(
    //   elevation: 0.0,
    //   child: Column(
    //     children: [
    //       CText(
    //         msg: "Recharge Details",
    //         color: kIndigoLight,
    //         weight: FontWeight.w600,
    //         size: 18,
    //       ),
    //       StreamBuilder<QuerySnapshot>(
    //           // ignore: deprecated_member_use
    //           stream: FirebaseFirestore.instance
    //               .collection("DashBoardPayments")
    //               .orderBy(
    //                 'CREATE_AT',
    //                 descending: true,
    //               )
    //               .snapshots(),
    //           builder: (_, snapshot) {
    //             return !snapshot.hasData
    //                 ? Center(
    //                     child: CText(
    //                     msg: "No Records found!!!",
    //                     color: black,
    //                     size: 30.0,
    //                   ))
    //                 : snapshot == null
    //                     ? Center(
    //                         child: CText(
    //                         msg: "No Users found!!!",
    //                         color: black,
    //                         size: 30.0,
    //                       ))
    //                     : ListView.builder(
    //                         scrollDirection: Axis.vertical,
    //                         controller: _controller,
    //                         shrinkWrap: true,
    //                         itemCount:
    //                             snapshot.data.docs.length,
    //                         itemBuilder: (_, index) {
    //                           DocumentSnapshot data;
    //                           if (snapshot.data.docs[index]
    //                                   ["USER_ID"] ==
    //                               widget.data.id) {
    //                             data =
    //                                 snapshot.data.docs[index];
    //                             return GestureDetector(
    //                               onLongPress: () async =>
    //                                   showAlertDialog(
    //                                       context: context,
    //                                       title: "Delete",
    //                                       content:
    //                                           "இந்த பதிவை நீக்க விரும்புகிறீர்களா ?",
    //                                       data: data),
    //                               child: Padding(
    //                                 padding:
    //                                     const EdgeInsets.all(
    //                                         8.0),
    //                                 child: Container(
    //                                   margin:
    //                                       EdgeInsets.symmetric(
    //                                           vertical: 12),
    //                                   width:
    //                                       MediaQuery.of(context)
    //                                               .size
    //                                               .width *
    //                                           0.5,
    //                                   decoration: BoxDecoration(
    //                                       color:
    //                                           Color(0xffE7F8FA),
    //                                       borderRadius:
    //                                           BorderRadius
    //                                               .circular(
    //                                                   10.0)),
    //                                   child: Column(
    //                                     children: [
    //                                       Row(
    //                                         crossAxisAlignment:
    //                                             CrossAxisAlignment
    //                                                 .start,
    //                                         children: <Widget>[
    //                                           Container(
    //                                             width: 3,
    //                                             color:
    //                                                 kBlueLight,
    //                                           ),
    //                                           Padding(
    //                                             padding:
    //                                                 const EdgeInsets
    //                                                     .all(16),
    //                                             child: Transform
    //                                                 .rotate(
    //                                               angle: 3.14 /
    //                                                   180 *
    //                                                   45,
    //                                               child: Icon(
    //                                                 Icons
    //                                                     .attach_file,
    //                                                 color:
    //                                                     nearlyBlue,
    //                                               ),
    //                                             ),
    //                                           ),
    //                                           Column(
    //                                             mainAxisAlignment:
    //                                                 MainAxisAlignment
    //                                                     .spaceAround,
    //                                             crossAxisAlignment:
    //                                                 CrossAxisAlignment
    //                                                     .start,
    //                                             children: <
    //                                                 Widget>[
    //                                               CText(
    //                                                 msg: data["RECHARGE_PLACE"] ==
    //                                                         ''
    //                                                     ? ''
    //                                                     : data[
    //                                                         "RECHARGE_PLACE"],
    //                                                 size: 18,
    //                                                 color:
    //                                                     kIndigoDark,
    //                                               ),
    //                                               CText(
    //                                                 msg: data["CREATE_AT"] ==
    //                                                         ''
    //                                                     ? ''
    //                                                     : DateFormat.yMMMd()
    //                                                         .add_jm()
    //                                                         .format(data["CREATE_AT"].toDate()),
    //                                                 size: 16,
    //                                                 color:
    //                                                     kIndigoLight,
    //                                                 weight:
    //                                                     FontWeight
    //                                                         .w600,
    //                                               ),
    //                                             ],
    //                                           ),
    //                                           Expanded(
    //                                             child: Padding(
    //                                               padding: EdgeInsets
    //                                                   .only(
    //                                                       right:
    //                                                           8.0),
    //                                               child: Column(
    //                                                 mainAxisAlignment:
    //                                                     MainAxisAlignment
    //                                                         .spaceEvenly,
    //                                                 crossAxisAlignment:
    //                                                     CrossAxisAlignment
    //                                                         .end,
    //                                                 children: [
    //                                                   CText(
    //                                                     msg: data["PACKAGE_AMOUNT"] ==
    //                                                             ''
    //                                                         ? ''
    //                                                         : "Rs." +
    //                                                             data["PACKAGE_AMOUNT"],
    //                                                     size:
    //                                                         20,
    //                                                     color: Colors
    //                                                         .green,
    //                                                     weight:
    //                                                         FontWeight.bold,
    //                                                   ),
    //                                                   AnimatedIconButton(
    //                                                     duration:
    //                                                         Duration(milliseconds: 500),
    //                                                     startIcon:
    //                                                         Icon(
    //                                                       Icons
    //                                                           .more_outlined,
    //                                                       color:
    //                                                           kPrimaryColor,
    //                                                       size:
    //                                                           20.0,
    //                                                     ),
    //                                                     endIcon: Icon(
    //                                                         Icons
    //                                                             .unfold_more_sharp,
    //                                                         color:
    //                                                             kPrimaryColor),
    //                                                     onPressed:
    //                                                         () {
    //                                                       setState(
    //                                                           () {
    //                                                         tileVisible =
    //                                                             !tileVisible;
    //                                                       });
    //                                                     },
    //                                                   )
    //                                                 ],
    //                                               ),
    //                                             ),
    //                                           ),
    //                                         ],
    //                                       ),
    //                                       Visibility(
    //                                           visible:
    //                                               tileVisible,
    //                                           child:
    //                                               AnimatedSizeTransition(
    //                                             child:
    //                                                 Container(
    //                                               width: 500,
    //                                               child: Card(
    //                                                 shape: RoundedRectangleBorder(
    //                                                     borderRadius:
    //                                                         BorderRadius.circular(10.0)),
    //                                                 elevation:
    //                                                     1.5,
    //                                                 child:
    //                                                     Column(
    //                                                   crossAxisAlignment:
    //                                                       CrossAxisAlignment
    //                                                           .start,
    //                                                   children: [
    //                                                     Center(
    //                                                       child:
    //                                                           CText(
    //                                                         msg:
    //                                                             "Payment Details",
    //                                                         color:
    //                                                             kIndigoLight,
    //                                                         size:
    //                                                             18,
    //                                                       ),
    //                                                     ),
    //                                                     Divider(),
    //                                                     Padding(
    //                                                       padding: const EdgeInsets.only(
    //                                                           left: 15.0,
    //                                                           top: 10.0),
    //                                                       child:
    //                                                           Column(
    //                                                         crossAxisAlignment:
    //                                                             CrossAxisAlignment.start,
    //                                                         children: [
    //                                                           CText(
    //                                                             msg: "எடுத்த பணம் :  Rs. ${data["PACKAGE_AMOUNT"]}",
    //                                                             size: 18,
    //                                                             weight: FontWeight.bold,
    //                                                             color: green,
    //                                                           ),
    //                                                           SizedBox(
    //                                                             height: 3.0,
    //                                                           ),
    //                                                           CText(
    //                                                             msg: "கொடுத்த பணம் :  ${data["PAID_AMOUNT"]}",
    //                                                             size: 18,
    //                                                             weight: FontWeight.bold,
    //                                                             color: kPrimaryLightColor,
    //                                                           ),
    //                                                           SizedBox(
    //                                                             height: 3.0,
    //                                                           ),
    //                                                           Visibility(
    //                                                             visible: data["PENDING_AMOUNT"] == '' ? false : true,
    //                                                             child: CText(
    //                                                               msg: "கொடுமதி பணம் :  Rs. ${data["PENDING_AMOUNT"]}",
    //                                                               size: 18,
    //                                                               weight: FontWeight.bold,
    //                                                               color: palettesPink,
    //                                                             ),
    //                                                           ),
    //                                                           SizedBox(
    //                                                             height: 3.0,
    //                                                           ),
    //                                                           Visibility(
    //                                                             visible: data["BALANCE_AMOUNT"] == '' ? false : true,
    //                                                             child: CText(
    //                                                               msg: "தருமதி பணம் :  Rs. ${data["BALANCE_AMOUNT"]}",
    //                                                               size: 18,
    //                                                               weight: FontWeight.bold,
    //                                                               color: kPrimaryLightColor,
    //                                                             ),
    //                                                           ),
    //                                                           SizedBox(
    //                                                             height: 3.0,
    //                                                           ),
    //                                                           Visibility(
    //                                                             visible: data["RECHARGE_PLACE"] == '' ? false : true,
    //                                                             child: CText(
    //                                                               msg: "கொடுத்த இடம் : ${data["RECHARGE_PLACE"]}",
    //                                                               size: 18,
    //                                                               weight: FontWeight.bold,
    //                                                               color: kIndigoDark,
    //                                                             ),
    //                                                           ),
    //                                                           SizedBox(
    //                                                             height: 3.0,
    //                                                           ),
    //                                                           Visibility(
    //                                                             visible: data["USER_NOTE"] == '' ? false : true,
    //                                                             child: CText(
    //                                                               msg: "குறிப்பு:  ${data["USER_NOTE"]}",
    //                                                               size: 18,
    //                                                               weight: FontWeight.bold,
    //                                                               color: kBlueLight,
    //                                                             ),
    //                                                           ),
    //                                                           SizedBox(
    //                                                             height: 3.0,
    //                                                           ),
    //                                                           SizedBox(
    //                                                             height: 20.0,
    //                                                           )
    //                                                         ],
    //                                                       ),
    //                                                     ),
    //                                                   ],
    //                                                 ),
    //                                               ),
    //                                             ),
    //                                           )),
    //                                     ],
    //                                   ),
    //                                 ),
    //                               ),
    //                             );
    //                           }
    //                           return Container();
    //                         });
    //           }),
    //     ],
    //   ),
    // ),
  }
  buildPaidPendingVisible(){
    if(_dashBoardService.pendingAmount.text != '' ){
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CRText(
                msg1: "கொடுமதி பணம் :  " ,
                msg2: "Rs. ${_dashBoardService.pendingAmount.text ?? ''}" ,
                color1: Colors.blue,
                color2: Colors.orange,
              ),
              Gap(w: 10,),

              buildTikImage(color: Colors.blue,height: 20,width: 20)
            ],
          ),
          Gap(h: 5.0),
        ],
      );
    }
    else if(_dashBoardService.balanceAmount.text != '' ){
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CRText(
                msg1: "தருமதி பணம் : " ,
                msg2: "Rs. ${_dashBoardService.balanceAmount.text ?? ''}" ,
                color1: Colors.blue,
                color2: Colors.red,
              ),
              Gap(w: 10,),

              buildTikImage(color: Colors.blue,height: 20,width: 20)
            ],
          ),
          Gap(h: 5.0),
        ],
      );
    }
    else{return SizedBox();}

  }

  buildTikImage({Color color , double height , double width}){
    return Image.asset(
      "assets/images/tik.png",
      height: height,
      width: width,
      color: color,
    );
  }
}
