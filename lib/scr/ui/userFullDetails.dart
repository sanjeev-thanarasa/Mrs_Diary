// import 'dart:async';
// import 'package:animated_icon_button/animated_icon_button.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:mrs_dth_diary_v1/scr/helpers/operations.dart';
// import 'package:mrs_dth_diary_v1/scr/models/dropDownModel.dart';
// import 'package:mrs_dth_diary_v1/scr/widgets/CDropDownList.dart';
// import 'package:mrs_dth_diary_v1/scr/widgets/CTextField.dart';
// import 'package:mrs_dth_diary_v1/scr/widgets/SimpleCalc.dart';
// import 'package:mrs_dth_diary_v1/scr/widgets/animatedSizeTransition.dart';
// import 'package:mrs_dth_diary_v1/scr/widgets/containerListTile.dart';
// import 'package:mrs_dth_diary_v1/scr/widgets/customText.dart';
// import 'package:mrs_dth_diary_v1/scr/widgets/datePicker.dart';
// import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';
//
// class UserFullDetails extends StatefulWidget {
//   final DocumentSnapshot user;
//   final String collectionName;
//
//   const UserFullDetails({Key key,
//     this.user,
//     this.collectionName,
//   }) : super(key: key);
//   @override
//   _UserFullDetailsState createState() => _UserFullDetailsState();
// }
//
// class _UserFullDetailsState extends State<UserFullDetails> {
//
//   ScrollController _controller=ScrollController();
//
//   TextEditingController rechargeAmount=TextEditingController();
//   TextEditingController giveAmount=TextEditingController();
//   TextEditingController pendingAmount=TextEditingController();
//   TextEditingController pendingDate=TextEditingController();
//   TextEditingController balanceAmount=TextEditingController();
//   TextEditingController userNote=TextEditingController();
//   TextEditingController packageName=TextEditingController();
//
// ////////////////////////////////////////////////EDIT///////////////////////////////////////////////////////
//   TextEditingController nameController = TextEditingController();
//   TextEditingController addressController = TextEditingController();
//   TextEditingController areaController = TextEditingController();
//   TextEditingController mobileController = TextEditingController();
//   TextEditingController mobileController1 = TextEditingController();
//   TextEditingController dishNumberController = TextEditingController();
//   TextEditingController shopController = TextEditingController();
//   TextEditingController expiredDate = TextEditingController();
//
//   IconData icon = Icons.add_circle_outline_rounded;
//
//   String _selectedDishType='Select Dish Type';
//   String _selectedArea='Select Area';
//   bool name=false;
//   bool area=false;
//   bool address=false;
//   bool mob=false;
//   bool mob1=false;
//   bool dishNum=false;
//   bool dishType=false;
//   bool shop=false;
//
//   //////////////////DB//////////////////////////////////
//   final databaseReference = FirebaseFirestore.instance;
//   Map<String,dynamic> addPayment;
//   /////////////////////DB///////////////////////////////
//
//
// ///////////////////////////////////////EDIT//////////////////////////////////////////////////////////////////
//
//
//   DateTime _chosenDateTime;
//   bool pending=false;
//   bool balance=false;
//   bool createRecord=false;
//   String userId;
//   bool noteCheckedValue=false;
//   bool blackCheckedValue=false;
//
// @override
//   void initState() {
//    userId=widget.user.id.toString();
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: CText(msg: "${widget.user["name"] ?? "User"}  முழு விவரங்கள்", color: Colors.white, weight: FontWeight.bold, size: 20.0),
//         elevation: 10.0,
//         centerTitle: true,
//         backgroundColor: kBlueColor,
//         actions: [
//           Padding(
//             padding: EdgeInsets.only(right:8.0),
//             child: IconButton(
//               icon: Icon(Icons.calculate_rounded, size: 30.0,),
//               onPressed: () {
//                 showModalBottomSheet<void>(
//                     context: context, builder: (BuildContext context) {
//                   return SimpleCalc();
//                 });
//               },
//             ),
//           )
//         ],
//       ),
//       backgroundColor: Colors.white,
//       body: Stack(
//         alignment: Alignment.topLeft,
//         children: <Widget>[
//           _buildBackground(context),
//           Positioned(
//             child: _buildContentUI(context),
//             top: MediaQuery.of(context).size.height * 0.27,
//             left: 40,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildContentUI(context) {
//     return Row(
//       children: <Widget>[
//         Hero(
//           tag: 1,
//           child: Container(
//             padding: EdgeInsets.all(6),
//             decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.all(Radius.circular(16))
//             ),
//             child: ClipRRect(
//                 borderRadius: BorderRadius.all(Radius.circular(16)),
//                 child: Image.asset("assets/images/unnamed.png",height: 100,)
//             ),
//           ),
//         ),
//         SizedBox(
//           width: 16,
//         ),
//         Container(
//           padding: EdgeInsets.all(6),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             shape: BoxShape.circle,
//           ),
//           child: CircleAvatar(
//             radius: 35,
//             child: AnimatedIconButton(
//               duration: Duration(seconds: 1),
//               size: 35.0,
//               startIcon: Icon(Icons.add),
//               endIcon: Icon(Icons.add),
//               onPressed: ()=>setState(()=>createRecord =!createRecord),
//               splashColor: kBlueColor,
//             ),
//             foregroundColor: Colors.white,
//             backgroundColor: kBlueLight,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildBackground(BuildContext context) {
//     bool mobileNo = widget.user["mobileNo2"]==''?false:true;
//     bool isOldUser=widget.collectionName=="OldUser"?true:false;
//     return Column(
//       children: <Widget>[
//         Stack(
//          children: [
//            Container(
//              decoration: BoxDecoration(
//                image: DecorationImage(
//                  image: AssetImage("assets/images/worker.JPG"),
//                  fit: BoxFit.cover
//                ),
//                borderRadius: BorderRadius.only(bottomRight: Radius.circular(112)),
//                color: kBlueColor,
//              ),
//              height: MediaQuery.of(context).size.height * 0.35,
//              child: Center(
//                child: Column(
//                  children: [
//                    SizedBox(height: 50.0,),
//                    CText(msg: "${widget.user["name"] ?? "User"}   உருவாகிய நேரம்",
//                      color: white,
//                      size: 30,
//                      textStroke: true,
//                      fontFamily: "TamilArima",),
//                    CheckboxListTile(
//                      title: CText(
//                        msg:"Noted List" ,
//                        fontFamily: "TamilArima",
//                        size: 30.0,
//                        textStroke: true,
//                        color: red,),
//                      value: noteCheckedValue,
//                      onChanged: (newValue) {
//                        setState(()=>noteCheckedValue = newValue);
//                        createList("NoteList");
//                      },
//                      controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
//                    ),
//                    CheckboxListTile(
//                      title: CText(
//                        msg:"Black List" ,
//                        fontFamily: "TamilArima",
//                        size: 30.0,
//                        textStroke: true,
//                        color: black,),
//                      value: blackCheckedValue,
//                      onChanged: (newValue) {
//                        setState(()=>blackCheckedValue = newValue);
//                        createList("BlackList");
//                      },
//                      controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
//                    ),
//                    CText(
//                      msg: widget.user["createAt"] == null
//                          ? ""
//                          : DateFormat.yMMMd().add_jm().format(widget.user["createAt"].toDate()),
//                      color: white,
//                      size: 40,
//                      textStroke: true,
//                      fontFamily: "TamilArima",
//                    ),
//
//
//
//                  ],
//                ),
//              ),
//            ),
//
//          ],
//         ),
//         Expanded(
//           child: ListView(
//             physics: BouncingScrollPhysics(),
//             children: <Widget>[
//               Container(
//                 margin: EdgeInsets.symmetric(horizontal: 40, vertical: 24),
//                 color: Colors.white,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: <Widget>[
//                     SizedBox(height: 24,),
//                     Visibility(
//                     visible: createRecord,
//                     child: AnimatedSizeTransition(
//                       duration: 1500,
//                       child: Container(
//                         width: 500,
//                         child: Card(
//                           margin: new EdgeInsets.only(
//                               left: 10.0, right: 10.0, top: 8.0, bottom: 5.0),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10.0)),
//                           elevation: 4.0,
//                           child: Padding(
//                             padding: const EdgeInsets.all(16.0),
//                             child: Column(
//                               children: [
//                                 CText(
//                                   msg: DateFormat('MM/dd/yyyy hh:mm a').format(DateTime.now()),
//                                   color: Colors.blue,
//                                 ),
//                                 CText(
//                                   msg: "Create New Record",
//                                   color: Colors.blue,
//                                 ),
//                                 Divider(),
//                                 CustomTextField(
//                                   controller: packageName,
//                                   hintText: "Recharge Package Name",
//                                   icon: Icons.live_tv_rounded,
//                                   keyboardType: TextInputType.text,
//                                 ),
//                                 CustomTextField(
//                                   controller: rechargeAmount,
//                                   hintText: "Recharge செய்த தொகை",
//                                   icon: Icons.attach_money_rounded,
//                                   keyboardType: TextInputType.number,
//                                 ),
//                                 CustomTextField(
//                                   controller: giveAmount,
//                                   hintText: "தந்த பணம் ",
//                                   icon: Icons.money_off_rounded,
//                                   keyboardType: TextInputType.number,
//                                   iconButtonIcon: Icons.done,
//                                   iconButtonEndIcon: Icons.done_all_rounded,
//                                   iconButton: true,
//                                   iconOnTap: (){
//                                     int recharge=int.parse(rechargeAmount.text.trim());
//                                     int give=int.parse(giveAmount.text.trim());
//                                     if(recharge>give){
//                                       setState((){
//                                         pending=true;
//                                         pendingAmount.text=(recharge-give).toString();
//                                       });
//                                       print(recharge );
//                                     }
//                                     else if(recharge<give){
//                                       setState((){
//                                         pending=false;
//                                         balanceAmount.text=(give-recharge).toString();
//                                       });
//                                     }
//                                   },
//                                 ),
//                                 Visibility(
//                                   visible: pending,
//                                   child: CustomTextField(
//                                     readOnly: true,
//                                     controller: pendingDate,
//                                     hintText: "தருமதி திகதி",
//                                     icon: Icons.attach_money_rounded,
//                                     keyboardType: TextInputType.number,
//                                       iconButtonIcon: Icons.date_range,
//                                       iconButton: true,
//                                       iconOnTap: ()=>_showDatePicker(context),
//                                   ),
//                                 ),
//                                 CustomTextField(
//                                   controller: expiredDate,
//                                   hintText: "முடியும் திகதி",
//                                   icon: Icons.date_range,
//                                   keyboardType: TextInputType.text,
//                                   iconButton: true,
//                                   iconButtonIcon: Icons.date_range,
//                                   iconButtonEndIcon: Icons.date_range_outlined,
//                                   iconOnTap: (){
//                                     showCupertinoModalPopup(
//                                         context: context,
//                                         builder: (_) => DatePicker(dateController: expiredDate,));
//                                   },
//                                 ),
//                                 CustomTextField(
//                                   controller: userNote,
//                                   hintText: "குறிப்பு ",
//                                   icon: Icons.note_add,
//                                   keyboardType: TextInputType.text,
//
//                                 ),
//
//                                 SizedBox(height: 15.0,),
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.end,
//                                   children: [
//                                     FlatButton(
//                                         child: const Text('CANCEL'),
//                                         onPressed: ()=>clearRecords(),),
//                                     ElevatedButton(
//                                       child: Text("Save"),
//                                       onPressed: ()=>
//                                           createPaymentRecord(),
//                                     ),
//                                   ],
//                                 )
//
//
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     )
//
//                 ),
//
//
//                     GestureDetector(
//                       onLongPress: ()=>setState(()=>name=!name),
//                       child: CText(
//                         msg: widget.user["name"] ?? "",
//                         weight: FontWeight.bold,
//                         size: 40,
//                         color: kIndigoDark,
//                       ),
//                     ),
//                     Visibility(
//                       visible: name,
//                       child: CustomTextField(
//                         controller: nameController,
//                         hintText: widget.user["name"] ?? "",
//                         icon: Icons.person_outline,
//                         keyboardType: TextInputType.text,
//                         iconButtonIcon: Icons.done,
//                         iconButton: true,
//                         iconOnTap: (){
//                           updateSingleProduct(
//                               collectionName: widget.collectionName,
//                               id: widget.user.id,
//                               updateField: "name",
//                               updateData: nameController.text);
//                           setState((){
//                             name=!name;
//                             nameController.clear();
//                           });
//                           Navigator.popAndPushNamed(context,'/UserFullDetails');
//                         },
//                       ),
//                     ), //பெயர்
//                     SizedBox(height: 8,),
//                     GestureDetector(
//                       onLongPress: ()=>setState(()=>area=!area),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           CText(
//                             msg: widget.user["area"] ?? "",
//                               weight: FontWeight.bold,
//                               size: 30,
//                               color: kIndigoDark,
//                           ),
//                           Visibility(
//                             visible: area,
//                             child: AnimatedIconButton(
//                               duration: Duration(milliseconds: 200),
//                                 startIcon: Icon(Icons.done),
//                                 endIcon: Icon(Icons.done,color: green,),
//                                 onPressed: (){
//                                   updateSingleProduct(
//                                       collectionName: widget.collectionName,
//                                       id: widget.user.id,
//                                       updateField: "area",
//                                       updateData: _selectedArea
//                                   );
//                                   setState(() {
//                                     area=!area;
//                                     _selectedArea='Select Area';
//                                   });
//                                   Navigator.popAndPushNamed(context,'/UserFullDetails');
//                                 },
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Visibility(
//                       visible: area,
//                       child: SelectDropList(
//                           itemSelected: _selectedArea,
//                           dropListModel: villageDropListModel,
//                           onOptionSelected:(optionItem){
//                             setState(()=>_selectedArea=optionItem);},
//                           image:'assets/images/dish.png'
//                       ),
//                     ), //எந்த ஊர்
//
//
//                     SizedBox(height: 16,),
//                     CText(
//                       msg:"Personal Information",
//                       color: kIndigoLight,
//                       weight: FontWeight.w600,
//                       size: 18,
//                     ),
//                     SizedBox(height: 12,),
//
//
//
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         SelectableText("Dish Number :    ${widget.user["dishNumber"] ?? "Nothing available"} ",
//                           style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.w600),
//                         ),
//                         GestureDetector(
//                             onTap: ()=>setState(()=>dishNum=!dishNum),
//                             child: Icon(Icons.edit)),
//                       ],
//                     ),
//                     Visibility(
//                       visible: dishNum,
//                       child: CustomTextField(
//                         controller: dishNumberController,
//                         hintText: "Dish இலக்கம்",
//                         image: 'assets/images/dish.png',
//                         keyboardType: TextInputType.number,
//                         iconButtonIcon: Icons.done,
//                         iconButton: true,
//                         iconOnTap: (){
//                           updateSingleProduct(
//                               collectionName: widget.collectionName,
//                               id: widget.user.id,
//                               updateField: "dishNumber",
//                               updateData: dishNumberController.text);
//                           setState((){
//                             dishNum=!dishNum;
//                             dishNumberController.clear();
//                           });
//                           Navigator.popAndPushNamed(context,'/UserFullDetails');
//                         },
//                       ),
//                     ), //Dish இலக்கம்
//                     GestureDetector(
//                       onLongPress: ()=>setState(()=>dishType=!dishType),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           CText(
//                             msg:"Dish Type :    ${widget.user["dishType"] ?? "Nothing available"}",
//                             size: 18,
//                             weight: FontWeight.w600,
//                           ),
//                           Visibility(
//                             visible: dishType,
//                             child: AnimatedIconButton(
//                               duration: Duration(milliseconds: 200),
//                               startIcon: Icon(Icons.done),
//                               endIcon: Icon(Icons.done,color: green,),
//                               onPressed: (){
//                                 updateSingleProduct(
//                                     collectionName: widget.collectionName,
//                                     id: widget.user.id,
//                                     updateField: "dishType",
//                                     updateData: _selectedDishType
//                                 );
//                                 setState(() {
//                                   dishType=!dishType;
//                                   _selectedDishType='Select Dish Type';
//                                 });
//                                 Navigator.popAndPushNamed(context,'/UserFullDetails');
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Visibility(
//                       visible: dishType,
//                       child: SelectDropList(
//                           itemSelected: _selectedDishType,
//                           dropListModel: dishDropListModel,
//                           onOptionSelected:(name){
//                             setState(()=>_selectedDishType=name);},
//                           image:'assets/images/dish.png'
//                       ),
//                     ),//Dish ன் வகை
//                     GestureDetector(
//                       onLongPress: ()=>setState(()=>mob=!mob),
//                       child: CText(
//                         msg:"Mobile No :  ${widget.user["mobileNo"] ?? "Nothing available"} ",
//                         size: 18,
//                         weight: FontWeight.w600,
//                       ),
//                     ),
//                     Visibility(
//                       visible: mob,
//                       child: CustomTextField(
//                           controller: mobileController,
//                           hintText: "தொலைபேசி இலக்கம்",
//                           icon: Icons.phone,
//                           keyboardType: TextInputType.number,
//                           iconButton: true,
//                           iconButtonIcon: Icons.done,
//                           iconOnTap: () {
//                             updateSingleProduct(
//                                 collectionName: widget.collectionName,
//                                 id: widget.user.id,
//                                 updateField: "mobileNo",
//                                 updateData: mobileController.text);
//                             setState((){
//                               mob=!mob;
//                               mobileController.clear();
//                             });
//                             Navigator.popAndPushNamed(context,'/UserFullDetails');
//                           }
//                           ),
//                     ), //தொலைபேசி இலக்கம்
//                     GestureDetector(
//                       onLongPress: ()=>setState(()=>mob1=!mob1),
//                       child: Visibility(
//                         visible: mobileNo,
//                         child: CText(
//                           msg:"Mobile No : ${widget.user["mobileNo2"] ?? "Nothing available"} ",
//                           size: 18,
//                           weight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                     Visibility(
//                       visible:  mob1 && mobileNo ? true :false,
//                       child: CustomTextField(
//                         controller: mobileController1,
//                         hintText: "தொலைபேசி இலக்கம்",
//                         icon: Icons.phone,
//                         keyboardType: TextInputType.number,
//                           iconButton: true,
//                           iconButtonIcon: Icons.done,
//                           iconOnTap: () {
//                             updateSingleProduct(
//                                 collectionName: widget.collectionName,
//                                 id: widget.user.id,
//                                 updateField: "mobileNo2",
//                                 updateData: mobileController1.text);
//                             setState((){
//                               mob1=!mob1;
//                               mobileController1.clear();
//                             });
//                             Navigator.popAndPushNamed(context,'/UserFullDetails');
//                           }
//                       ),
//                     ), //தொலைபேசி இலக்கம்2
//                     GestureDetector(
//                       onLongPress: ()=>setState(()=>address=!address),
//                       child: CText(
//                         msg:"Address :  ${widget.user["address"] ?? "Nothing available"} ",
//                         size: 18,
//                         weight: FontWeight.w600,
//                       ),
//                     ),
//                     Visibility(
//                       visible: address,
//                       child: CustomTextField(
//                         controller: addressController,
//                         hintText: "விலாசம்",
//                         icon: Icons.person_outline,
//                         keyboardType: TextInputType.text,
//                           iconButton: true,
//                           iconButtonIcon: Icons.done,
//                           iconOnTap: () {
//                             updateSingleProduct(
//                                 collectionName: widget.collectionName,
//                                 id: widget.user.id,
//                                 updateField: "address",
//                                 updateData: addressController.text);
//                             setState((){
//                               address=!address;
//                               addressController.clear();
//                             });
//                             Navigator.popAndPushNamed(context,'/UserFullDetails');
//                           }
//                       ),
//                     ), //விலாசம்
//                     GestureDetector(
//                       onLongPress: ()=>setState(()=>shop=!shop),
//                       child: Visibility(
//                         visible: isOldUser ? false:true,
//                         child: CText(
//                           msg:"Shop Name :  ${!isOldUser ? widget.user["shopName"]: "" } ",
//                           size: 18,
//                           weight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                     Visibility(
//                       visible: !isOldUser  && shop ? true :false,
//                       child: CustomTextField(
//                         controller: shopController,
//                         hintText: "கடையின் பெயர்",
//                         icon: Icons.phone,
//                         keyboardType: TextInputType.text,
//                           iconButton: true,
//                           iconButtonIcon: Icons.done,
//                           iconOnTap: () {
//                             updateSingleProduct(
//                                 collectionName: widget.collectionName,
//                                 id: widget.user.id,
//                                 updateField: "shopName",
//                                 updateData: shopController.text);
//                             setState((){
//                               shop=!shop;
//                               shopController.clear();
//                             });
//                             Navigator.popAndPushNamed(context,'/UserFullDetails');
//                           }
//                       ),
//                     ),
//
//
//
//
//                     Divider(),
//                     SizedBox(height: 16,),
//                     CText(
//                       msg:"Recharge Details",
//                       color: kIndigoLight,
//                       weight: FontWeight.w600,
//                       size: 18,
//                     ),
//                     StreamBuilder<QuerySnapshot>(
//                       stream: FirebaseFirestore.instance.collection("PaymentRecords")
//
//                           .orderBy('CREATE_AT',descending: true,)
//                       //.where('USER_ID', isEqualTo: userId)
//                          .snapshots(),
//                       builder: (_, snapshot) {
//                       return !snapshot.hasData
//                       ? Center(child: CText(msg: "No Records found!!!",color: black,size: 30.0,))
//                           : snapshot==null ? Center(child: CText(msg: "No Users found!!!",color: black,size: 30.0,))
//                           : ListView.builder(
//                         scrollDirection: Axis.vertical,
//                         controller: _controller,
//                         shrinkWrap: true,
//                         itemCount: snapshot.data.docs.length,
//                         itemBuilder: (_, index) {
//                         DocumentSnapshot data;
//                         if(snapshot.data.docs[index]["USER_ID"]==userId){
//                           data=snapshot.data.docs[index];
//                           return PaymentContainerListTile(
//                               snapshot: data,
//                               packageName: data["PACKAGE_NAME"],
//                               //packageName: data["USER_ID"] +"\n"+ widget.user.id,
//                               // rechargeDate: (data["CREATE_AT"]),
//                               rechargeDate: data["CREATE_AT"],
//                               rechargeAmount: data["AMOUNT"],
//                               paidMoney: data["PAID_AMOUNT"],
//                               pendingMoney: data["PENDING_AMOUNT"],
//                               pendingDate: data["PENDING_DATE"],
//                               balanceMoney: data["BALANCE_AMOUNT"],
//                               userNote: data["USER_NOTE"]
//                           );
//
//                         }
//                         return Container();
//                         }
//                         );
//                       }
//                     ),
//
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         )
//       ],
//     );
//   }
//
//
//   void createList(String name){
//   databaseReference.collection(widget.collectionName)
//       .doc(widget.user.id)
//       .set({
//     name : noteCheckedValue
//   },SetOptions(merge: true)).then((value){
//     print("Added to NoteList");
//   });
//
//   }
//
//   void createPaymentRecord() async {
//     addPayment = {
//       "USER_ID":widget.user.id,
//       "PACKAGE_NAME": packageName.text,
//       "AMOUNT" : rechargeAmount.text,
//       "PAID_AMOUNT" :giveAmount.text,
//       "PENDING_AMOUNT": pendingAmount.text,
//       "PENDING_DATE": pendingDate.text,
//       "BALANCE_AMOUNT": balanceAmount.text,
//       "USER_NOTE": userNote.text,
//       "CREATE_AT": DateTime.now().toIso8601String().split('T').first,
//       "EXPIRED_AT": expiredDate.text,
//
//     };
//     Timer(Duration(milliseconds: 200), () {
//       databaseReference.collection("PaymentRecords").add(addPayment).whenComplete((){
//         clearRecords();}
//       );
//
//     });
//   }
//
//   void clearRecords(){
//     packageName.clear();
//     rechargeAmount.clear();
//     giveAmount.clear();
//     pendingAmount.clear();
//     pendingDate.clear();
//     balanceAmount.clear();
//     userNote.clear();
//     setState(()=>createRecord=false);
//   }
//
//
//
//
//
//   popUpBox(context){
//     return AlertDialog(
//       contentPadding: const EdgeInsets.all(20.0),
//       content: Container(
//        // height: MediaQuery.of(context).size.height*.5,
//         child: Column(
//           children: [
//             CText(
//               msg: DateFormat('MM/dd/yyyy hh:mm a').format(DateTime.now()),
//               color: Colors.blue,
//             ),
//             CText(
//               msg: "Create New Record",
//               color: Colors.blue,
//             ),
//             Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: new TextField(
//                   keyboardType: TextInputType.number,
//                   controller: rechargeAmount,
//                   autofocus: true,
//                   decoration: new InputDecoration(
//                       hintText: "Recharge செய்த தொகை",
//                       labelStyle: TextStyle(fontSize: 25.0)
//
//                   ),
//                 ),
//               ),
//             Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: new TextField(
//                   keyboardType: TextInputType.number,
//                   controller: giveAmount,
//                   autofocus: true,
//                   decoration: new InputDecoration(
//                       hintText: "தந்த பணம் ",
//                       labelStyle: TextStyle(fontSize: 25.0),
//                     suffix: AnimatedIconButton(
//                       duration: Duration(milliseconds: 500),
//                       startIcon: Icon(Icons.star_border),
//                       endIcon: Icon(Icons.star),
//                       onPressed: (){
//                         int recharge=int.parse(rechargeAmount.text.trim());
//                         int give=int.parse(giveAmount.text.trim());
//                         if(recharge>give){
//                           setState(()=>pending=true);
//                           print(recharge );
//                         }
//                         else if(recharge<give){
//                           setState(()=>balance=true);
//                         }
//                         else{
//                           setState(() {
//                             pending=false;
//                             balance=false;
//                           });
//                         }
//                       },
//                     ),
//
//                   ),
//                 ),
//               ),
//             Visibility(
//               visible: pending,
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: new TextField(
//                   controller: pendingAmount,
//                   autofocus: true,
//                   decoration: new InputDecoration(
//                       hintText: "தருமதி பணம்",
//                       labelStyle: TextStyle(fontSize: 25.0)
//
//                   ),
//                 ),
//               ),
//             ),
//             Visibility(
//               visible: pending,
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: new TextField(
//                   controller: pendingDate,
//                   autofocus: true,
//                   decoration: new InputDecoration(
//                     hintText: "தருமதி திகதி",
//                     labelStyle: TextStyle(fontSize: 25.0),
//                     suffix: IconButton(
//                       icon: Icon(Icons.calendar_today_rounded),
//                       onPressed: () {
//                         _showDatePicker(context);
//                       },
//                       iconSize: 20.0,
//                     ),
//
//                   ),
//                 ),
//               ),
//             ),
//             Visibility(
//               visible: balance,
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: new TextField(
//                   controller: balanceAmount,
//                   autofocus: true,
//                   decoration: new InputDecoration(
//                       hintText: "கொடுமதி பணம்",
//                       labelStyle: TextStyle(fontSize: 25.0)
//
//                   ),
//                 ),
//               ),
//             ),
//
//           ],
//         ),
//       ),
//       actions: <Widget>[
//         FlatButton(
//             child: const Text('CANCEL'),
//             onPressed: (){
//               //textEditingController.clear();
//               Navigator.pop(context);
//             }
//
//         ),
//         ElevatedButton(
//           onPressed: (){
//             // bthFunction(textEditingController.text);
//             Navigator.pop(context);
//             // textEditingController.clear();
//           },
//           child: Text("Save"),
//         ),
//
//       ],
//     );
//   }
//   void _showDatePicker(BuildContext context) {
//     showCupertinoModalPopup(
//         context: context,
//         builder: (_) => Container(
//           height: 350,
//           color: Color.fromARGB(255, 255, 255, 255),
//           child: Column(
//             children: [
//               Container(
//                 height: 300,
//                 child: CupertinoDatePicker(
//                     initialDateTime: DateTime.now(),
//                     onDateTimeChanged: (val) {
//                       setState(() {
//                         _chosenDateTime = val;
//                         //pendingDate.text= DateFormat('MM/dd/yyyy hh:mm a').format(_chosenDateTime);
//                         pendingDate.text= _chosenDateTime.toIso8601String().split('T').first;
//                         print(pendingDate.text);
//
//                       });
//                     }),
//               ),
//
//               // Close the modal
//               CupertinoButton(
//                 child: Text('OK'),
//                 onPressed: () => Navigator.of(context).pop(),
//               )
//             ],
//           ),
//         ));
//   }
// }
//
