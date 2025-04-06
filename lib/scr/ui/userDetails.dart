import 'package:animated_icon_button/animated_icon_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:intl/intl.dart';
import 'package:kumi_popup_window/kumi_popup_window.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/operations.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CustomStreamBuilder.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/SimpleCalc.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/customText.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/loading.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/paymentTile.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/showAlertDialog.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/gap.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/screen_navigation.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:pull_to_reveal/pull_to_reveal.dart';
import 'package:toast/toast.dart';

import 'createPayment.dart';
import 'editUserDetail.dart';

class UserDetails extends StatefulWidget {
  final String userId;
  final String collectionName;

  const UserDetails({Key key,
    this.collectionName,
    this.userId}) : super(key: key);

  @override
  _UserDetailsState createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  final _key = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    getUsersStreamSnapshots(collectionName: widget.collectionName !="" ? widget.collectionName :"OldUser");
  }

  RefreshController _refreshController =
  RefreshController(initialRefresh: true);
  bool black;
  bool note;
  List _result = [];

  void _onRefresh() async{
    print("___On Refresh_______________");
    getUsersStreamSnapshots(collectionName: widget.collectionName ?? '');
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.refreshCompleted();
  }

  void _onLoading() async{
    await Future.delayed(Duration(milliseconds: 1000));
    print("___On Loading_______________");
    _refreshController.loadComplete();
  }

  String userName='';
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: CText(
            msg: "$userName", color: Colors.white, weight: FontWeight.bold, size: 25.0),
        elevation: 10.0,
        centerTitle: true,
        //backgroundColor: Color(0xff6c6a6b),
        backgroundColor: kPrimaryColor.withOpacity(.9),
        actions: [
          Padding(
            padding: EdgeInsets.only(right:8.0),
            child: IconButton(
              icon: Icon(Icons.calculate_rounded, size: 30.0,),
              onPressed: () {
                showModalBottomSheet<void>(
                    context: context, builder: (BuildContext context) {
                  return SimpleCalc();
                });
              },
            ),
          )
        ],
      ),
      backgroundColor: Colors.white,
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
                return PaymentContainerListTile(
                  snapshot: data,
                  // context: context,
                  //   //packageName: _results[index]['PACKAGE_NAME'],
                  //   //rechargeDate: DateFormat('dd-MM-yyyy hh:mm a').format(_results[index]['CREATE_AT'].toDate()),
                  //   //rechargeAmount: _results[index]['AMOUNT'],
                  //   //paidMoney: _results[index]['PAID_AMOUNT'],
                  //   //pendingMoney: _results[index]['PENDING_AMOUNT'],
                  //   //pendingDate: _results[index]['PENDING_DATE'],
                  //   //balanceMoney: _results[index]['BALANCE_AMOUNT'],
                  //   userNote: _results[index]['USER_NOTE'],
                  //   userNote2: _results[index]['USER_NOTE2'],
                  //   //expiredDate: _results[index]['EXPIRED_AT'],
                  //   id: _results[index].id,
                );
              },
              revealableHeight: 350,
              revealableBuilder: (BuildContext context, RevealableToggler opener, RevealableToggler closer, BoxConstraints constraints) {
                return Stack(
                  alignment: Alignment.topLeft,
                  children: <Widget>[
                    Container(),
                    _buildBackground(context),
                    Positioned(
                      child: _buildContentUI(),
                      top: MediaQuery.of(context).size.height * 0.23,
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
        .collection('PaymentRecords')
        .where('USER_ID', isEqualTo: widget.userId)
        .orderBy('CREATE_AT',descending: true)
        .snapshots();

    yield* _stream;
  }


  // getPaymentStreamSnapshots() async {
  //   var firestore = FirebaseFirestore.instance;
  //   var data = await firestore
  //       .collection('PaymentRecords')
  //       .where('USER_ID', isEqualTo: widget.userId)
  //       .orderBy('CREATE_AT',descending: true)
  //       .get();
  //   setState(() {
  //     _results = data.docs;
  //   });
  //   return "complete";
  // }

  Widget _buildBackground(BuildContext context){
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/images/ravi.jpg"),
            fit: BoxFit.cover
        ),
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(112)),
        color: kBlueColor,
      ),
      height: MediaQuery.of(context).size.height * 0.30,
      width: double.infinity,
    );
  }

  Widget _buildContentUI() {
    return Row(
      children: <Widget>[
        Hero(
          tag: 1,
          child: Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(16))
            ),
            child: GestureDetector(
              onTap: ()=> buildUserOnTapPopupWindow(),
              child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  child: Image.asset("assets/images/unnamed.png",fit: BoxFit.cover,height: 100,)
              ),
            ),
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
              startIcon: Icon(Icons.add),
              endIcon: Icon(Icons.add),
             onPressed: ()=> changeScreenAnimated(context, CreatePayment(userId : widget.userId)),
              splashColor: kBlueColor,
            ),
            foregroundColor: Colors.white,
            backgroundColor: kPrimaryColor.withOpacity(.8),
          ),
        ),
      ],
    );
  }

  buildUserOnTapPopupWindow() {
    return showPopupWindow(
      context,
      gravity: KumiPopupGravity.center,
      //curve: Curves.elasticOut,
      bgColor: Colors.grey.withOpacity(0.5),
      clickOutDismiss: true,
      clickBackDismiss: true,
      customAnimation: false,
      customPop: false,
      customPage: false,
      //targetRenderBox: (btnKey.currentContext.findRenderObject() as RenderBox),
      //needSafeDisplay: true,
      underStatusBar: false,
      underAppBar: true,
      offsetX: 0,
      offsetY: 0,
      duration: Duration(milliseconds: 200),
      onShowStart: (pop) {
        print("showStart");
      },
      onShowFinish: (pop) {
        print("showFinish");
      },
      onDismissStart: (pop) {
        print("dismissStart");
      },
      onDismissFinish: (pop) {
        print("dismissFinish");
      },
      onClickOut: (pop){
        print("onClickOut");
      },
      onClickBack: (pop){
        print("onClickBack");
      },
      childFun: (pop) {
        return Container(
          width: MediaQuery.of(context).size.width*.7,
          height: MediaQuery.of(context).size.height*.5,
          key: GlobalKey(),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0),
                  bottomRight: Radius.circular(25.0))
          ),
          child : _result.length > 0 ?ListView.builder(
              itemCount: _result.length,
              itemBuilder: (_,index){
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assets/images/note.png",height: 40,width: 40,),
                            Gap(h: 5.0,),
                            buildFlutterSwitch(
                              value: note,
                              updateField: "NoteList",
                              toast: "Noted",
                            ),
                          ],
                        ) ,
                        GestureDetector(
                          onLongPress: ()=>showAlertDialog(
                              context: context,
                              title: "",
                              content: "Do you want to Edit User Detail ?",
                              color: Colors.blue,
                              yesColor: Colors.green,
                              noColor: Colors.black,
                              yesOnPressed: (){
                                print("${widget.collectionName}>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
                                changeScreen(context, EditUserDetail(
                                  data: _result,
                                  index: index,
                                  userId: widget.userId,
                                  collectionName: widget.collectionName,
                                ));
                              }
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(left: 10.0,right: 10.0),
                            child: CircleAvatar(
                              child: Image.asset("assets/images/unnamed.png",
                                fit: BoxFit.cover,height: 100,),
                              radius: 50.0,
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assets/images/bad.png",height: 50,width: 50,),
                            Gap(h: 5.0,),
                            buildFlutterSwitch(
                                value: black,
                              updateField: "BlackList",
                              toast: "Black",
                            ),
                          ],
                        ) ,
                      ],
                    ),
                    Gap(h: 10.0),
                    buildUserDetail(text1: "Name: ",text2:"${_result[index]['name']}" ,),
                    buildUserDetail(text1: "Area: ",text2:"${_result[index]['area']}" ),
                    buildUserDetail(text1: "Address: ",text2:"${_result[index]['address']}" ,size: 16.0,topPadding: 10.0),
                    Gap(h: 15.0),
                    buildUserDetail(
                      text1: "DishNumber :",
                      anyOtherWidget:CSText(msg: "${_result[0]['dishNumber']}", size: 20,color: Colors.blue,),
                    ),
                    Gap(h: 3.0),
                    buildUserDetail(text1: "Dish Type :",text2:"${_result[index]['dishType']}" ),
                    Gap(h: 3.0),
                    Visibility(
                        visible: _result[index]['mobileNo'] != '' ?  true : false,
                        child: buildUserDetail(text1: "Mobile No :",text2:"${_result[index]['mobileNo']}" )),
                    Gap(h: 3.0),
                    Visibility(
                        visible: _result[index]['mobileNo2'] != '' ?  true : false,
                        child: buildUserDetail(text1: "Mobile No2 :",text2:"${_result[index]['mobileNo2']}" )),
                    Gap(h: 3.0),

                    ////////////NewUser///////////////////
                    buildNewUserFields(collectionName: widget.collectionName,index: index),
                    ////////////NewUser///////////////////

                    Visibility(
                        visible: _result[index]['BlackList'],
                        child: buildUserDetail(
                            text1: "Black List :",
                            anyOtherWidget:Image.asset("assets/images/tik.png",height: 20,width: 40,)
                        )
                    ),
                    Visibility(
                        visible: _result[index]['NoteList'],
                        child: buildUserDetail(
                            text1: "Noted List :",
                            anyOtherWidget:Image.asset("assets/images/tik.png",height: 20,width: 40,),
                            gapHeight: 10.0
                        )
                    ),
                  ],
                );
              }
          )
          :LoadingCircle(),
        );
      },
    );
  }

  buildNewUserFields({String collectionName , int index}){
    if(collectionName == 'OldUser'){
      return SizedBox();
    }
    else if(collectionName == 'NewUser'){
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildUserDetail(
              text1: "Shop Name :",
              text2:"${widget.collectionName=="NewUser" ?_result[index]['shopName'] : "No Data"}"
          ),
          Gap(h: 3.0),
          buildUserDetail(
              text1: "Register Date :",
              text2:  _result[index]['registerDate'] != null
                  ? "${DateFormat('dd-MM-yyyy hh:mm a').format(_result[index]['registerDate'].toDate())}"
                  : "No Data",
              size: 16.0
          ),
          Gap(h: 3.0),
          buildUserDetail(
              text1: "Expired Date :",
              text2: _result[index]['expiredDate'] != null
                  ? "${DateFormat('dd-MM-yyyy hh:mm a').format(_result[index]['expiredDate'].toDate())}"
                  : "No Data",
              size: 16.0
          ),
          Gap(h: 3.0),
        ],
      );
    }
    else{return SizedBox();}
  }

  FlutterSwitch buildFlutterSwitch({bool value, String updateField, String toast}) {
    return FlutterSwitch(
                            height: 20.0,
                            width: 40.0,
                            padding: 4.0,
                            toggleSize: 15.0,
                            borderRadius: 10.0,
                            activeColor: Colors.green,
                            value: value,
                            onToggle: (val) {
                              if(val){
                                updateSingleProduct(
                                    collectionName: widget.collectionName,
                                    id: widget.userId,
                                    updateField: updateField,
                                    updateData: true).whenComplete(() =>
                                    showToast("Successfully Added to $toast List", gravity: Toast.BOTTOM,duration: Toast.LENGTH_LONG));
                              }else{
                                updateSingleProduct(
                                    collectionName: widget.collectionName,
                                    id: widget.userId,
                                    updateField: updateField,
                                    updateData: false).whenComplete(() =>
                                    showToast("Successfully Removed to $toast List", gravity: Toast.BOTTOM,duration: Toast.LENGTH_LONG));
                              }
                              setState(() {
                                value = val;
                              });
                            },
                          );
  }

  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }

  getUsersStreamSnapshots({String collectionName}) async {
    var firestore = FirebaseFirestore.instance;
    var data = await firestore
        .collection(collectionName)
        .where('id', isEqualTo: widget.userId)
        .get();
    setState(() {
      _result = data.docs;
      print("LLLLLLLLLLLLLLLLLLLLLLLLLLL" + _result.length.toString());
      userName = _result[0]['name'];
      black=_result[0]['BlackList'];
      note=_result[0]['NoteList'];
    });
    return "Complete";
  }

  buildUserDetail({String text1 , String text2, double size, double topPadding, Widget anyOtherWidget, double gapHeight,}){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(flex:0,child: Row(
          children: [
            //Icon(Icons.person,color: Colors.grey,),
            Image.asset("assets/images/star.png",height: 20,width: 20, color: Colors.blue,),
            SizedBox(width: 5.0,),
            CText(msg: text1,size: 16.0,color: Colors.grey,),
          ],
        )),
        SizedBox(height: gapHeight ?? 5.0),
        Flexible(flex:1,child: Padding(
          padding: EdgeInsets.only(top:topPadding??0.0),
          child: anyOtherWidget ??
          CText(msg: text2,size: size ?? 20,textAlign: TextAlign.end,color: Colors.blue,),
        )),
      ],
    );
  }
}
