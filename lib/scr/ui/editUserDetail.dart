import 'package:animated_icon_button/animated_icon_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/createUser.dart';
import 'package:mrs_dth_diary_v1/scr/models/dropDownModel.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CDropDownList.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CTextField.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/RoundedLoadingButton.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/customText.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/datePicker.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';
import 'package:pull_to_reveal/pull_to_reveal.dart';

class EditUserDetail extends StatefulWidget {
  final String userId;
  final String collectionName;
  final List data;
  final int index;

  const EditUserDetail({Key key,
    this.userId,
    this.data,
    this.index,
    this.collectionName,
  }) : super(key: key);
  @override
  _EditUserDetailState createState() => _EditUserDetailState();
}

class _EditUserDetailState extends State<EditUserDetail> {
  USerServices _uSerServices = USerServices();

  @override
  void initState() {
    _uSerServices.getVillageName();
    editInitialize();
    print(widget.collectionName);
    print(widget.userId);
    print(widget.data);
    print(widget.index);
    super.initState();
  }

  void editInitialize(){
    if(widget.collectionName=='NewUser'){
      editOldUserInitialize();
      print("widget.collectionName?>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ${widget.collectionName}");
      _uSerServices.shopController.text = widget.data[widget.index]["shopName"] ?? '';
      _uSerServices.registerDate = widget.data[widget.index]['registerDate'] != null ? widget.data[widget.index]['registerDate'].toDate() : null;
      _uSerServices.expiredDate = widget.data[widget.index]['expiredDate'] != null ? widget.data[widget.index]['expiredDate'].toDate() : null;
    }else{
      editOldUserInitialize();
    }

  }
  void editOldUserInitialize(){
    print("widget.collectionName?>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ${widget.collectionName}");
    _uSerServices.nameController.text = widget.data[widget.index]["name"] ?? '';
    _uSerServices.addressController.text = widget.data[widget.index]["address"] ?? '';
    _uSerServices.mobileController.text = widget.data[widget.index]["mobileNo"] ?? '';
    _uSerServices.mobileController1.text = widget.data[widget.index]["mobileNo2"] ?? '';
    _uSerServices.dishNumberController.text = widget.data[widget.index]["dishNumber"] ?? '';
    _uSerServices.selectedArea = widget.data[widget.index]['area'];
    _uSerServices.selectedDishType = widget.data[widget.index]['dishType'];
    _uSerServices.createAt = widget.data[widget.index]['createAt'] != null ? widget.data[widget.index]['createAt'].toDate() : null;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: CText(
            msg: "Edit User Detail ",
            color: Color(0xff6c6a6b),
            weight: FontWeight.bold,
            size: 20.0),
        elevation: 10.0,
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Color(0xff6c6a6b)),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Image.asset("assets/images/mrslogo.png",height: 50,width: 50,),
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

  Widget _buildContentUI(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * .7,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.0),
              bottomRight: Radius.circular(25.0))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            height: 15.0,
          ),
          CustomTextField(
            hintTextColor: Colors.blue,
            leadingIconColor: mainBlue,
            controller: _uSerServices.nameController,
            hintText: "பெயர் : ${ _uSerServices.nameController.text}",
            icon: Icons.person_outline,
            keyboardType: TextInputType.text,
          ), //பெயர்
          CustomTextField(
            hintTextColor: Colors.blue,
            leadingIconColor: mainBlue,
            controller: _uSerServices.addressController,
            hintText: "விலாசம் : ${_uSerServices.addressController.text}",
            icon: Icons.person_outline,
            keyboardType: TextInputType.text,
          ), //விலாசம்
          SelectDropList(
              itemSelected: _uSerServices.selectedArea,
              dropListModel: villageDropListModel,
              onOptionSelected:(optionItem){
                setState(()=>_uSerServices.selectedArea=optionItem);},
              image:'assets/images/dish.png'
          ), //எந்த ஊர்
          Visibility(
            visible:  _uSerServices.mobileController.text != '' ? true : false,
            child: CustomTextField(
              hintTextColor: Colors.blue,
              leadingIconColor: mainBlue,
                controller: _uSerServices.mobileController,
                hintText: "M.No : ${_uSerServices.mobileController.text}",
                icon: Icons.phone,
                keyboardType: TextInputType.number,
            ),
          ), //தொலைபேசி இலக்கம்
          Visibility(
            visible:  _uSerServices.mobileController1.text != '' ? true : false,
            child: CustomTextField(
              hintTextColor: Colors.blue,
              leadingIconColor: mainBlue,
              controller: _uSerServices.mobileController1,
              hintText: "M.No : ${ _uSerServices.mobileController1.text}",
              icon: Icons.phone,
              keyboardType: TextInputType.number,
            ),
          ), //தொலைபேசி இலக்கம்2
          CustomTextField(
            hintTextColor: Colors.blue,
            leadingIconColor: mainBlue,
            controller: _uSerServices.dishNumberController,
            hintText: "Dish இலக்கம் : ${_uSerServices.dishNumberController.text}",
            image: 'assets/images/dish.png',
            keyboardType: TextInputType.number,
          ), //Dish இலக்கம்
          SelectDropList(
              itemSelected: _uSerServices.selectedDishType,
              dropListModel: dishDropListModel,
              onOptionSelected:(name){setState(()=>_uSerServices.selectedDishType=name);},
              image:'assets/images/dish.png'
          ),//Dish ன் வகை

          CustomTextField(
            hintTextColor: Colors.blue,
            leadingIconColor: mainBlue,
            controller: _uSerServices.createAtDateController,
            hintText: "பதிந்த திகதி : ${_uSerServices.createAt != null ? DateFormat('dd-MM-yyyy hh:mm a').format(_uSerServices.createAt) : "No Data"}",
            icon: Icons.phone,
            keyboardType: TextInputType.text,
            iconButton: true,
            animatedIconButtonStratIcon: Icons.date_range,
            animatedIconButtonEndIcon: Icons.date_range_outlined,
            animatedIconButtonOnTap: (){
              showCupertinoModalPopup(
                  context: context,
                  builder: (_) => DatePicker(
                    onDateTimeChanged: (val){
                      setState(() {
                        _uSerServices.createAt = val;
                        _uSerServices.createAtDateController.text = DateFormat('dd-MM-yyyy hh:mm a')
                            .format(val);
                      });
                    },
                  ));
            },
          ),
          buildNewUserFields(collectionName: widget.collectionName),
          SizedBox(
            height: 20.0,
          ),
          RoundedLoading(
            btnController: _uSerServices.btnController,
            paddingLeft: 140.0,
            paddingRight: 140.0,
            paddingTop: 8.0,
            buttonPressed: (){
                _uSerServices.updateRecord(
                  index: 0,
                  userId: widget.userId,
                  context: context,
                  collectionName: widget.collectionName,
                );
            },
          ),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
  buildNewUserFields({String collectionName}){
    if(collectionName == 'OldUser'){
      return SizedBox();
    }
    else if(collectionName == 'NewUser'){
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(
            controller: _uSerServices.shopController,
            hintText: "கடையின் பெயர் : ${_uSerServices.shopController.text} ",
            icon: Icons.phone,
            keyboardType: TextInputType.text,
          ),
          CustomTextField(
            hintTextColor: Colors.blue,
            controller: _uSerServices.registerDateController,
            hintText: "Register Date : ${_uSerServices.registerDate != null ? DateFormat('dd-MM-yyyy hh:mm a').format(_uSerServices.registerDate) : "No Data"}",
            icon: Icons.phone,
            keyboardType: TextInputType.text,
            iconButton: true,
            readOnly: true,
            animatedIconButtonStratIcon: Icons.date_range,
            animatedIconButtonEndIcon: Icons.date_range_outlined,
            animatedIconButtonOnTap: (){
              showCupertinoModalPopup(
                  context: context,
                  builder: (_) => DatePicker(
                    onDateTimeChanged: (val){
                      setState(() {
                        _uSerServices.registerDate = val;
                        _uSerServices.registerDateController.text = DateFormat('dd-MM-yyyy hh:mm a')
                            .format(val);
                      });
                    },
                  ));
            },
          ),
          CustomTextField(
            hintTextColor: Colors.blue,
            controller: _uSerServices.expiredDateController,
            hintText: "முடியும் திகதி : ${_uSerServices.expiredDate != null ? DateFormat('dd-MM-yyyy hh:mm a').format(_uSerServices.expiredDate) : "No Data"}",
            icon: Icons.phone,
            keyboardType: TextInputType.text,
            iconButton: true,
            animatedIconButtonStratIcon: Icons.date_range,
            animatedIconButtonEndIcon: Icons.date_range_outlined,
            animatedIconButtonOnTap: (){
              showCupertinoModalPopup(
                  context: context,
                  builder: (_) => DatePicker(
                    onDateTimeChanged: (val){
                      setState(() {
                        _uSerServices.expiredDate = val;
                        _uSerServices.expiredDateController.text = DateFormat('dd-MM-yyyy hh:mm a')
                            .format(val);
                      });
                    },
                  ));
            },
          ),
        ],
      );
    }
    else{return SizedBox();}

  }


  Widget _buildBackground(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/images/ravi.png"), fit: BoxFit.fitHeight),
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(112)),
        color: Colors.white,
      ),
      height: MediaQuery.of(context).size.height * 0.28,
      width: double.infinity,
      // child:Padding(
      //   padding: const EdgeInsets.all(8.0),
      //   child: Align(
      //       alignment: Alignment.topLeft,
      //       child: AnimatedIconButton(
      //         duration: Duration(milliseconds: 500),
      //         startIcon: Icon(Icons.refresh,color: Colors.white,),
      //         endIcon: Icon(Icons.replay),
      //         startBackgroundColor: Color(0xff484a49),
      //         splashRadius: 5.0,
      //         size: 25.0,
      //         onPressed: () => _onRefresh(),
      //       )),
      // ),
    );
  }

  // void _onRefresh() {
  //   _uSerServices.clearRecords();
  // }
}
