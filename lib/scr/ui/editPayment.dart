import 'package:animated_icon_button/animated_icon_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/paymentService.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CTextField.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/RoundedLoadingButton.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/SimpleCalc.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/customText.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/datePicker.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';
import 'package:pull_to_reveal/pull_to_reveal.dart';

class EditPayment extends StatefulWidget {
  final String userId;
  final QueryDocumentSnapshot snapshot;

  const EditPayment({Key key, this.userId,this.snapshot})
      : super(key: key);

  @override
  _EditPaymentState createState() => _EditPaymentState();
}

class _EditPaymentState extends State<EditPayment> {
  PaymentServices _paymentServices = PaymentServices();

  @override
  void dispose() {
    _paymentServices.clearRecords();
    super.dispose();
  }

  @override
  void initState() {
    _paymentServices.createRecordDate.text = widget.snapshot['CREATE_AT'] != null ? DateFormat('dd-MM-yyyy hh:mm a')
            .format(widget.snapshot['CREATE_AT'].toDate()) : "";
    editInitialize();
    super.initState();
  }

  void _onRefresh() {
    _paymentServices.clearRecords();
    _paymentServices.btnController.reset();
  }

  void editInitialize(){
    _paymentServices.createDate = widget.snapshot['CREATE_AT'] != null ? widget.snapshot['CREATE_AT'].toDate() : null;
    _paymentServices.expiredDate = widget.snapshot['EXPIRED_AT'] != null ? widget.snapshot['EXPIRED_AT'].toDate() : null;
    _paymentServices.packageName.text = widget.snapshot['PACKAGE_NAME'];
    _paymentServices.rechargeAmount.text = widget.snapshot['AMOUNT'];
    _paymentServices.giveAmount.text = widget.snapshot['PAID_AMOUNT'];
    _paymentServices.pendingAmount.text = widget.snapshot['PENDING_AMOUNT'];
    _paymentServices.pendingDate = widget.snapshot['PENDING_DATE'] != null ? widget.snapshot['PENDING_DATE'].toDate() : null;
    _paymentServices.balanceAmount.text = widget.snapshot['BALANCE_AMOUNT'];
    _paymentServices.userNote.text = widget.snapshot['USER_NOTE'];
    _paymentServices.userNote2.text = widget.snapshot['USER_NOTE2'];

  }



  TextStyle _style =
  TextStyle(fontSize: 16.0, fontFamily: "TamilArima", color: Colors.blue);
  int recharge=0;
  int paidAmount=0;


  @override
  Widget build(BuildContext context) {
    bool equal = false;
    recharge = widget.snapshot['AMOUNT'] != '' ? int.parse(widget.snapshot['AMOUNT'].trim().toString()) : 0 ;
    paidAmount = widget.snapshot['PAID_AMOUNT'] != '' ? int.parse(widget.snapshot['PAID_AMOUNT'].trim().toString()) : 0 ;
    setState(() {
      if (recharge == paidAmount){
        setState(() {
          equal = true ;
        });
      }
    });
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: CText(
            msg: "Edit Payment ",
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
          return _buildContentUI(context , equal);
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
  gap({double h, double w}){
    return SizedBox(height: h ?? null,width: w ?? null,);
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
        padding: const EdgeInsets.only(bottom: 5),
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

  Color _color = Colors.grey;
  bool noteVisible = false;

  Widget _buildContentUI(BuildContext context , bool equal) {
    return Container(
      width: MediaQuery.of(context).size.width * .7,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.0),
              bottomRight: Radius.circular(25.0))),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CRText(
                msg1: "Package Name :  " ,
                msg2: "${widget.snapshot['PACKAGE_NAME']}" ,
                color1: Colors.blue,
              ),
              buildTikImage(color: Colors.blue)
            ],
          ),
          gap(h: 5.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CText(
                msg: "Create at : ${_paymentServices.createRecordDate.text}",
                color: Colors.blue,
              ),
             // buildTikImage(color: _color)
              GestureDetector(
                  onTap: () {
                    showCupertinoModalPopup(
                        context: context,
                        builder: (_) => DatePicker(
                          onDateTimeChanged: (val){
                            setState(() {
                              _paymentServices.createDate = val;
                              _paymentServices.createRecordDate.text = DateFormat('dd-MM-yyyy hh:mm a')
                                  .format(val);
                            });
                          },

                        )).whenComplete(
                            () => setState(() => _color = Colors.green));
                  },
                  child: buildTikImage(color: _color))
            ],
          ),
          gap(h: 2.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CText(
                msg: "Recharge Amount :  ${widget.snapshot['AMOUNT']}",
                color: Colors.green,
                size: 20.0,
              ),
              buildTikImage(color: Colors.green)
            ],
          ),
          gap(h: 2.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CRText(
                msg1: "Paid Amount ",
                msg2: ":  ${widget.snapshot['PAID_AMOUNT']}",
                color1: Colors.orangeAccent,
                color2: Colors.orange,
                size1: 20.0,
                size2: 20.0,
              ),
              buildTikImage(color: Colors.orange)
            ],
          ),
          Visibility(
            visible: !equal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CRText(
                  msg1: widget.snapshot['BALANCE_AMOUNT'] != '' ? "பழைய கொடுமதி பணம்" : "பழைய தருமதி பணம்",
                  msg2: ":  ${widget.snapshot['BALANCE_AMOUNT'] != '' ? widget.snapshot['BALANCE_AMOUNT'] : widget.snapshot['PENDING_AMOUNT']}",
                  color1: Colors.orangeAccent,
                  color2: Colors.orange,
                  size1: 20.0,
                  size2: 20.0,
                ),
                buildTikImage(color: Colors.orange)
              ],
            ),
          ),
          gap(h: 3.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CRText(
                msg1: "Last Paid Date Time  ",
                msg2: ": ${_paymentServices.createRecordDate.text}",
                color1: Colors.grey,
                color2: Colors.black,
              ),
              buildTikImage(color: Colors.black)
            ],
          ),
          Divider(),
          Visibility(
            visible: !equal,
            child: CustomTextField(
              controller:_paymentServices.newGiveAmount,
              hintText: widget.snapshot['BALANCE_AMOUNT'] != '' ? "நீங்கள் கொடுத்த பணம் :  ??? " :  "புதிதாக தந்த பணம் :  ??? ",
              icon: Icons.monetization_on,
              textStyle: _style,
              keyboardType: TextInputType.number,
              animatedIconButtonStratIcon: Icons.done,
              animatedIconButtonEndIcon: Icons.done_all_rounded,
              iconButton: true,
              animatedIconButtonOnTap: () {
                widget.snapshot['BALANCE_AMOUNT'] != '' ? calculateBalance() : calculatePending();
              },
            ),
          ),
          Visibility(
            visible: _paymentServices.pending,
            child: CRText(
              color2: Colors.blue,
              size1: 16.0,
              msg1: "புதிய தருமதி பணம் ",
              msg2: ":  ${_paymentServices.pendingAmount.text != '' ? _paymentServices.pendingAmount.text : widget.snapshot['PENDING_AMOUNT'] }",
              color1: Colors.orange,
            ),

          ),
          Visibility(
            visible: _paymentServices.balance,
            child: CRText(
              color1: Colors.blue,
              color2: Colors.green,
              size1: 16.0,
              msg1: "புதிய கொடுமதி பணம் :",
              msg2: "  ${_paymentServices.balanceAmount.text !='' ?_paymentServices.balanceAmount.text  : widget.snapshot['BALANCE_AMOUNT'] }" ,
            ),
          ),gap(h: 10),
          Visibility(
            visible: _paymentServices.pending,
            child: CustomTextField(
              readOnly: true,
              controller: _paymentServices.pendingDateController,
              hintText: "தருமதி திகதி :   ${_paymentServices.pendingDate != null ? DateFormat('dd-MM-yyyy hh:mm a')
                  .format(_paymentServices.pendingDate ) : ""}",
              icon: Icons.update,
              keyboardType: TextInputType.number,
              animatedIconButtonStratIcon: Icons.date_range,
              textStyle: _style,
              iconButton: true,
              animatedIconButtonOnTap: () {
                showCupertinoModalPopup(
                    context: context,
                    builder: (_) => DatePicker(
                      onDateTimeChanged: (val){
                        setState(() {
                          _paymentServices.pendingDate = val;
                          _paymentServices.pendingDateController.text = DateFormat('dd-MM-yyyy hh:mm a')
                              .format(val);
                        });
                      },
                    ));
              },
            ),
          ),

          CustomTextField(
            readOnly: true,
            controller: _paymentServices.expiredDateController,
            hintText: "முடியும் திகதி :   ${_paymentServices.expiredDate != null ? DateFormat('dd-MM-yyyy hh:mm a')
                .format(_paymentServices.expiredDate ) : ""}",
            icon: Icons.date_range,
            keyboardType: TextInputType.text,
            textStyle: _style,
            iconButton: true,
            animatedIconButtonStratIcon: Icons.date_range,
            animatedIconButtonEndIcon: Icons.date_range_outlined,
            animatedIconButtonOnTap: () {
              showCupertinoModalPopup(
                  context: context,
                  builder: (_) => DatePicker(
                    onDateTimeChanged: (val){
                      setState(() {
                        _paymentServices.expiredDate = val;
                        _paymentServices.expiredDateController.text = DateFormat('dd-MM-yyyy hh:mm a')
                            .format(val);
                      });
                    },
                  ));
            },
          ),
          CustomTextField(
              controller: _paymentServices.userNote,
              hintText: "குறிப்பு :   ${widget.snapshot['USER_NOTE']}",
              icon: Icons.note_add,
              keyboardType: TextInputType.text,
              textStyle: _style,
              iconButton: true,
              animatedIconButtonStratIcon: Icons.add_circle_outline_rounded,
              animatedIconButtonEndIcon: Icons.indeterminate_check_box_outlined,
              animatedIconButtonOnTap: () => setState(() => noteVisible = !noteVisible)),
          Visibility(
            visible: noteVisible,
            child: CustomTextField(
              controller: _paymentServices.userNote2,
              hintText: "குறிப்பு 2 :   ${widget.snapshot['USER_NOTE2']}",
              icon: Icons.note_add_outlined,
              textStyle: _style,
              keyboardType: TextInputType.text,
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          RoundedLoading(
            btnController: _paymentServices.btnController,
            paddingLeft: 10.0,
            paddingRight: 10.0,
            paddingTop: 8.0,
            buttonHeight: 40,
            btnColor: Colors.blue,
            buttonPressed: () {
              _paymentServices.updatePaymentRecord(snapshot: widget.snapshot);

              },
          ),
          SizedBox(
            height: 20.0,
          )
        ],
      ),
    );
  }
  buildTikImage({Color color}){
    return Image.asset(
      "assets/images/tik.png",
      height: 18,
      width: 30,
      color: color,
    );
  }
  void calculatePending(){

    int amount = _paymentServices.newGiveAmount.text != '' ? int.parse(_paymentServices.newGiveAmount.text.trim())  : 0;

    int give =  paidAmount + amount;


    if (recharge > give) {
      setState(() {
        _paymentServices.pending = true;
        _paymentServices.balance = false;
        _paymentServices.balanceAmount.clear();
        _paymentServices.pendingAmount.text = (recharge - give).toString();
        _paymentServices.newGiveAmount.text= give.toString();
      });

    } else if (recharge < give) {
      setState(() {
        _paymentServices.pending = false;
        _paymentServices.balance = true;
        _paymentServices.pendingAmount.clear();
        _paymentServices.pendingDate = null;
        _paymentServices.balanceAmount.text = (give - recharge).toString();
        _paymentServices.newGiveAmount.text= give.toString();
      });
    } else if (recharge == give) {
      setState(() {
        _paymentServices.pending = false;
        _paymentServices.balance = false;
        _paymentServices.pendingAmount.clear();
        _paymentServices.balanceAmount.clear();
        _paymentServices.pendingDate = null;
        _paymentServices.newGiveAmount.text= give.toString();
      });
    }
    else {
      setState(() {
        _paymentServices.pending = false;
        _paymentServices.balance = false;
        _paymentServices.pendingDate = null;
        _paymentServices.pendingAmount.clear();
        _paymentServices.balanceAmount.clear();
      });
    }


  }

  void calculateBalance(){

    int balance = widget.snapshot['BALANCE_AMOUNT'] != '' ? int.parse( widget.snapshot['BALANCE_AMOUNT'].trim())  : 0;

    int give = _paymentServices.newGiveAmount.text !='' ? int.parse(_paymentServices.newGiveAmount.text.trim())  : 0;

    if (balance > give) {
      setState(() {
        _paymentServices.pending = false;
        _paymentServices.balance = true;
        _paymentServices.pendingAmount.clear();
        _paymentServices.pendingDate = null;
        _paymentServices.balanceAmount.text = (balance - give).toString();
      });

    } else if (balance < give) {
      setState(() {
        _paymentServices.pending = false;
        _paymentServices.balance = true;
        _paymentServices.balanceAmount.clear();
        _paymentServices.pendingDate = null;
        _paymentServices.pendingAmount.text = (give - balance).toString();
      });
    } else if (balance == give) {
      setState(() {
        _paymentServices.pending = false;
        _paymentServices.balance = false;
        _paymentServices.pendingDate = null;
        _paymentServices.pendingAmount.clear();
        _paymentServices.balanceAmount.clear();
      });
    } else {
      setState(() {});
    }
  }
}
