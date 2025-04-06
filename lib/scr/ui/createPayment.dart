import 'package:animated_icon_button/animated_icon_button.dart';
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

class CreatePayment extends StatefulWidget {
  final String userId;

  const CreatePayment({Key key, this.userId})
      : super(key: key);

  @override
  _CreatePaymentState createState() => _CreatePaymentState();
}

class _CreatePaymentState extends State<CreatePayment> {
  PaymentServices _paymentServices = PaymentServices();

  @override
  void dispose() {
   _paymentServices.clearRecords();
   _paymentServices.btnController.reset();
    super.dispose();
  }

  @override
  void initState() {
   _paymentServices.createRecordDate.text = DateFormat('MM/dd/yyyy hh:mm a').format(DateTime.now());
   _paymentServices.createDate = DateTime.now();
    super.initState();
  }

  void _onRefresh() {
    _paymentServices.clearRecords();
    _paymentServices.btnController.reset();
  }

  TextStyle _style = TextStyle(fontSize: 16.0, fontFamily: "TamilArima", color: Colors.blue);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: CText(
            msg: "Create Payment",
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

  Color _color = Colors.grey;
  bool noteVisible = false;

  Widget _buildContentUI(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * .7,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.0),
              bottomRight: Radius.circular(25.0))),
      child: Column(
        children: [
          CText(
            msg: "Create New Record",
            color: Colors.blue,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CText(
                msg: DateFormat('MM/dd/yyyy hh:mm a').format(_paymentServices.createDate),
                color: Colors.blue,
              ),
              GestureDetector(
                  onTap: () {
                    showCupertinoModalPopup(
                        context: context,
                        builder: (_) => DatePicker(
                          onDateTimeChanged: (val){setState(() {_paymentServices.createDate=val;});},
                            )).whenComplete(
                        () => setState(() => _color = Colors.green));
                  },
                child: buildTikImage(height: 20,width: 40,color: _color),
              )
            ],
          ),
          Divider(),
          CustomTextField(
            controller: _paymentServices.packageName,
            hintText: "Recharge Package Name",
            icon: Icons.live_tv_rounded,
            keyboardType: TextInputType.text,
            textStyle: _style,
          ),
          Visibility(
            visible: true,
            child: CustomTextField(
              controller: _paymentServices.rechargeAmount,
              hintText: "Recharge செய்த தொகை",
              icon: Icons.mobile_friendly_sharp,
              keyboardType: TextInputType.number,
              textStyle: _style,
            ),
          ),
          CustomTextField(
            controller:_paymentServices.giveAmount,
            hintText: "தந்த பணம்",
            icon: Icons.monetization_on,
            textStyle: _style,
            keyboardType: TextInputType.number,
            animatedIconButtonStratIcon: Icons.done,
            animatedIconButtonEndIcon: Icons.done_all_rounded,
            iconButton: true,
            animatedIconButtonOnTap: () {
              print("Animated Icon Button Pressed");
              print("Animated Icon Button Pressed");
              print("Animated Icon Button Pressed");
              print("Animated Icon Button Pressed");
              print("Animated Icon Button Pressed");
              print("Animated Icon Button Pressed");
              print("Animated Icon Button Pressed");
              print("Animated Icon Button Pressed");
              print("Animated Icon Button Pressed");
              print("Animated Icon Button Pressed");
              print("Animated Icon Button Pressed");
              print("Animated Icon Button Pressed");

              int recharge = int.parse(_paymentServices.rechargeAmount.text.trim());

              int give = int.parse(_paymentServices.giveAmount.text.trim());

              if (recharge > give) {
                setState(() {
                  _paymentServices.pending = true;
                  _paymentServices.balance = false;
                  _paymentServices.balanceAmount.clear();
                  _paymentServices.pendingAmount.text =
                      (recharge - give).toString();
                });
                print(recharge);
              } else if (recharge < give) {
                setState(() {
                  _paymentServices.pending = false;
                  _paymentServices.balance = true;
                  _paymentServices.pendingAmount.clear();
                  _paymentServices.balanceAmount.text = (give - recharge).toString();
                });
              } else {
                setState(() {
                  _paymentServices.pending = false;
                  _paymentServices.pendingAmount.clear();
                  _paymentServices.balanceAmount.clear();
                });
              }
            },
          ),
          Visibility(
            visible: _paymentServices.pending,
            child: CRText(
              color2: Colors.grey,
              size1: 16.0,
              msg1: "தருமதி பணம் ",
              msg2: ":  ${_paymentServices.pendingAmount.text} ",
              color1: Colors.grey,
            ),

          ),
          Visibility(
            visible: _paymentServices.balance,
            child: CRText(
              color1: Colors.grey,
              size1: 16.0,
              msg1: "கொடுமதி பணம் :",
              msg2: "  ${_paymentServices.balanceAmount.text}" ,
            ),
          ),
          Visibility(
            visible: _paymentServices.pending,
            child: CustomTextField(
              readOnly: true,
              controller: _paymentServices.pendingDateController,
              hintText: "தருமதி திகதி",
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
                              _paymentServices.pendingDateController.text = DateFormat('MM/dd/yyyy hh:mm a').format(_paymentServices.pendingDate);
                            });
                      },
                        ));
              },
            ),
          ),

          CustomTextField(
            controller: _paymentServices.expiredDateController,
            hintText: "முடியும் திகதி",
            icon: Icons.date_range,
            keyboardType: TextInputType.text,
            readOnly: true,
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
                            _paymentServices.expiredDate=val;
                            _paymentServices.expiredDateController.text = DateFormat('MM/dd/yyyy hh:mm a').format(_paymentServices.expiredDate);
                          });
                    },
                      ));
            },
          ),
          CustomTextField(
              controller: _paymentServices.userNote,
              hintText: "குறிப்பு",
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
              hintText: "குறிப்பு 2 ",
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
              _paymentServices.createPaymentRecord(userId: widget.userId);
            },
          ),
          SizedBox(
            height: 20.0,
          )
        ],
      ),
    );
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
