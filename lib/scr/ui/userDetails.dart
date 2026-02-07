import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:intl/intl.dart';
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
import 'package:fluttertoast/fluttertoast.dart';

import 'createPayment.dart';
import 'editUserDetail.dart';

class UserDetails extends StatefulWidget {
  final String userId;
  final String collectionName;

  const UserDetails({
    super.key,
    required this.collectionName,
    required this.userId,
  });

  @override
  _UserDetailsState createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  final _key = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    getUsersStreamSnapshots(
      collectionName:
          widget.collectionName.isNotEmpty ? widget.collectionName : "OldUser",
    );
  }

  RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  bool black = false;
  bool note = false;
  List _result = [];

  void _onRefresh() async {
    print("___On Refresh_______________");
    getUsersStreamSnapshots(collectionName: widget.collectionName);
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(Duration(milliseconds: 1000));
    print("___On Loading_______________");
    _refreshController.loadComplete();
  }

  String userName = '';
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
            msg: "$userName",
            color: Colors.white,
            weight: FontWeight.bold,
            size: 25.0),
        elevation: 10.0,
        centerTitle: true,
        //backgroundColor: Color(0xff6c6a6b),
        backgroundColor: kPrimaryColor.withValues(alpha: .9),
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
      backgroundColor: Colors.white,
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        enablePullDown: true,
        child: CustomStreamBuilder(
          context: context,
          stream: filterStream(),
          body: (snapshot) {
            return PullToRevealTopItemList(
              startRevealed: true,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (BuildContext context, int index) {
                var data = snapshot.data!.docs[index];
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
              revealableBuilder: (BuildContext context,
                  RevealableToggler opener,
                  RevealableToggler closer,
                  BoxConstraints constraints) {
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

  Stream<QuerySnapshot<Map<String, dynamic>>> filterStream() async* {
    var firestore = FirebaseFirestore.instance;
    var stream = firestore
        .collection('PaymentRecords')
        .where('USER_ID', isEqualTo: widget.userId)
        .orderBy('CREATE_AT', descending: true)
        .snapshots();

    yield* stream;
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

  Widget _buildBackground(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/images/ravi.jpg"), fit: BoxFit.cover),
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
                borderRadius: BorderRadius.all(Radius.circular(16))),
            child: GestureDetector(
              onTap: () => buildUserOnTapPopupWindow(),
              child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  child: Image.asset(
                    "assets/images/unnamed.png",
                    fit: BoxFit.cover,
                    height: 100,
                  )),
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
            foregroundColor: Colors.white,
            backgroundColor: kPrimaryColor.withValues(alpha: .8),
            child: IconButton(
              icon: const Icon(Icons.add, size: 35.0),
              splashColor: kBlueColor,
              onPressed: () => changeScreenAnimated(
                context,
                CreatePayment(userId: widget.userId),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void buildUserOnTapPopupWindow() {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            width: MediaQuery.of(context).size.width * .7,
            height: MediaQuery.of(context).size.height * .5,
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25.0),
                bottomRight: Radius.circular(25.0),
              ),
            ),
            child: _result.isNotEmpty
                ? ListView.builder(
                    itemCount: _result.length,
                    itemBuilder: (_, index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset("assets/images/note.png",
                                      height: 40, width: 40),
                                  const Gap(h: 5.0),
                                  buildFlutterSwitch(
                                    value: note,
                                    updateField: "NoteList",
                                    toast: "Noted",
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onLongPress: () => showAlertDialog(
                                  context: context,
                                  title: "",
                                  content: "Do you want to Edit User Detail ?",
                                  color: Colors.blue,
                                  yesColor: Colors.green,
                                  noColor: Colors.black,
                                  yesOnPressed: () {
                                    changeScreen(
                                      context,
                                      EditUserDetail(
                                        data: _result,
                                        index: index,
                                        userId: widget.userId,
                                        collectionName: widget.collectionName,
                                      ),
                                    );
                                  },
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10.0, right: 10.0),
                                  child: CircleAvatar(
                                    radius: 50.0,
                                    backgroundColor: Colors.transparent,
                                    child: Image.asset(
                                      "assets/images/unnamed.png",
                                      fit: BoxFit.cover,
                                      height: 100,
                                    ),
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset("assets/images/bad.png",
                                      height: 50, width: 50),
                                  const Gap(h: 5.0),
                                  buildFlutterSwitch(
                                    value: black,
                                    updateField: "BlackList",
                                    toast: "Black",
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Gap(h: 10.0),
                          buildUserDetail(
                              text1: "Name: ",
                              text2: "${_result[index]['name']}"),
                          buildUserDetail(
                              text1: "Area: ",
                              text2: "${_result[index]['area']}"),
                          buildUserDetail(
                            text1: "Address: ",
                            text2: "${_result[index]['address']}",
                            size: 16.0,
                            topPadding: 10.0,
                          ),
                          const Gap(h: 15.0),
                          buildUserDetail(
                            text1: "DishNumber :",
                            text2: "${_result[0]['dishNumber']}",
                            anyOtherWidget: CSText(
                              msg: "${_result[0]['dishNumber']}",
                              size: 20,
                              color: Colors.blue,
                            ),
                          ),
                          const Gap(h: 3.0),
                          buildUserDetail(
                              text1: "Dish Type :",
                              text2: "${_result[index]['dishType']}"),
                          const Gap(h: 3.0),
                          buildUserDetail(
                              text1: "User Type :",
                              text2: "${widget.collectionName}"),
                          const Gap(h: 3.0),
                          buildUserDetail(
                              text1: "Shop Name :",
                              text2: "${_result[index]['shopName']}"),
                          const Gap(h: 3.0),
                          buildUserDetail(
                              text1: "Mobile No :",
                              text2: "${_result[index]['mobileNo']}"),
                          const Gap(h: 3.0),
                          buildUserDetail(
                              text1: "Mobile No :",
                              text2: "${_result[index]['mobileNo2']}"),
                          const Gap(h: 3.0),
                          buildUserDetail(
                            text1: "Register Date :",
                            text2:
                                "${DateFormat('dd-MM-yyyy').format(_result[index]['registerDate'].toDate())}",
                          ),
                          const Gap(h: 3.0),
                          buildUserDetail(
                            text1: "Expired Date :",
                            text2:
                                "${DateFormat('dd-MM-yyyy').format(_result[index]['expiredDate'].toDate())}",
                          ),
                        ],
                      );
                    },
                  )
                : const Center(child: LoadingCircle()),
          ),
        );
      },
    );
  }

  Widget buildNewUserFields(
      {required String collectionName, required int index}) {
    if (collectionName == 'OldUser') {
      return const SizedBox();
    } else if (collectionName == 'NewUser') {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildUserDetail(
            text1: "Shop Name :",
            text2:
                "${widget.collectionName == "NewUser" ? _result[index]['shopName'] : "No Data"}",
          ),
          const Gap(h: 3.0),
          buildUserDetail(
            text1: "Register Date :",
            text2: _result[index]['registerDate'] != null
                ? "${DateFormat('dd-MM-yyyy hh:mm a').format(_result[index]['registerDate'].toDate())}"
                : "No Data",
            size: 16.0,
          ),
          const Gap(h: 3.0),
          buildUserDetail(
            text1: "Expired Date :",
            text2: _result[index]['expiredDate'] != null
                ? "${DateFormat('dd-MM-yyyy hh:mm a').format(_result[index]['expiredDate'].toDate())}"
                : "No Data",
            size: 16.0,
          ),
          const Gap(h: 3.0),
        ],
      );
    } else {
      return const SizedBox();
    }
  }

  FlutterSwitch buildFlutterSwitch({
    required bool value,
    required String updateField,
    required String toast,
  }) {
    return FlutterSwitch(
      height: 20.0,
      width: 40.0,
      padding: 4.0,
      toggleSize: 15.0,
      borderRadius: 10.0,
      activeColor: Colors.green,
      value: value,
      onToggle: (val) {
        if (val) {
          updateSingleProduct(
                  collectionName: widget.collectionName,
                  id: widget.userId,
                  updateField: updateField,
                  updateData: true)
              .whenComplete(() => showToast(
                    "Successfully Added to $toast List",
                    gravity: ToastGravity.BOTTOM,
                    toastLength: Toast.LENGTH_LONG,
                  ));
        } else {
          updateSingleProduct(
                  collectionName: widget.collectionName,
                  id: widget.userId,
                  updateField: updateField,
                  updateData: false)
              .whenComplete(() => showToast(
                    "Successfully Removed to $toast List",
                    gravity: ToastGravity.BOTTOM,
                    toastLength: Toast.LENGTH_LONG,
                  ));
        }
        setState(() {
          if (updateField == "NoteList") {
            note = val;
          } else if (updateField == "BlackList") {
            black = val;
          }
        });
      },
    );
  }

  void showToast(
    String msg, {
    Toast toastLength = Toast.LENGTH_SHORT,
    ToastGravity gravity = ToastGravity.BOTTOM,
  }) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: toastLength,
      gravity: gravity,
    );
  }

  Future<String> getUsersStreamSnapshots(
      {required String collectionName}) async {
    var firestore = FirebaseFirestore.instance;
    var data = await firestore
        .collection(collectionName)
        .where('id', isEqualTo: widget.userId)
        .get();
    setState(() {
      _result = data.docs;
      print("LLLLLLLLLLLLLLLLLLLLLLLLLLL" + _result.length.toString());
      userName = _result[0]['name'];
      black = _result[0]['BlackList'] ?? false;
      note = _result[0]['NoteList'] ?? false;
    });
    return "Complete";
  }

  Widget buildUserDetail({
    required String text1,
    required String text2,
    double? size,
    double? topPadding,
    Widget? anyOtherWidget,
    double? gapHeight,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
            flex: 0,
            child: Row(
              children: [
                //Icon(Icons.person,color: Colors.grey,),
                Image.asset(
                  "assets/images/star.png",
                  height: 20,
                  width: 20,
                  color: Colors.blue,
                ),
                SizedBox(
                  width: 5.0,
                ),
                CText(msg: text1, size: 16.0, color: Colors.grey),
              ],
            )),
        SizedBox(height: gapHeight ?? 5.0),
        Flexible(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(top: topPadding ?? 0.0),
              child: anyOtherWidget ??
                  CText(
                      msg: text2,
                      size: size ?? 20,
                      textAlign: TextAlign.end,
                      color: Colors.blue),
            )),
      ],
    );
  }
}
