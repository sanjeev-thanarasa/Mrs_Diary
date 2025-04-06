import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/createUser.dart';
import 'package:mrs_dth_diary_v1/scr/models/dropDownModel.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CDropDownList.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CTextField.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/RoundedLoadingButton.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/datePicker.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';


class CreateNewUser extends StatefulWidget {
  @override
  _CreateNewUserState createState() => _CreateNewUserState();
}

class _CreateNewUserState extends State<CreateNewUser> {

  int _index = 0;
  USerServices _uSerServices = USerServices();
  bool mNoVisible = false;
  IconData icon = Icons.add_circle_outline_rounded;

  @override
  void initState() {
    super.initState();
    _uSerServices.getVillageName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [white, kPrimaryColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter),
            borderRadius: BorderRadius.circular(25.0),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 0),
                blurRadius: 20,
                color: white,
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.26,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/images/ravi.png"),
                        fit: BoxFit.fitHeight),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40.0),
                        bottomRight: Radius.circular(40.0)),
                    gradient: LinearGradient(
                      colors: [
                        white,
                        Colors.white,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(10, 10),
                        blurRadius: 30,
                        color: Color(0xFFB7B7B7).withOpacity(.16),
                      ),
                    ],
                  ),
                ),
              ), //bg image
              SizedBox(
                height: 8,
              ),
              _buildRegionTabBar(),
              Container(
                decoration: BoxDecoration(
                  color: white.withOpacity(.8),
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 0),
                      blurRadius: 20,
                      color: white,
                    ),
                  ],
                ),
                margin: EdgeInsets.all(12),
                child: _index == 0 ? buildColumn(false) : buildColumn(true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildRegionTabBar() {
    return DefaultTabController(
      length: 2,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 5),
        height: 50.0,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                kPrimaryColor,
                Colors.grey,
              ]),
          borderRadius: BorderRadius.circular(25.0),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 0),
              blurRadius: 20,
              color: white,
            ),
          ],
        ),
        child: TabBar(
          indicator: BubbleTabIndicator(
            tabBarIndicatorSize: TabBarIndicatorSize.tab,
            indicatorHeight: 40.0,
            indicatorColor: Colors.white,
          ),
          labelStyle: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
          labelColor: Colors.black,
          unselectedLabelColor: Colors.white,
          tabs: [
            Text('Old User'),
            Text('New User'),
          ],
          onTap: (index) {
            setState(() {
              _index = index;
            });
          },
        ),
      ),
    );
  }

  Column buildColumn(bool visible) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          height: 15.0,
        ),
        CustomTextField(
          controller: _uSerServices.nameController,
          hintText: "பெயர்",
          leadingIconColor: mainBlue,
          hintTextColor: Colors.blue,
          icon: Icons.person,
          keyboardType: TextInputType.text,
        ), //பெயர்
        CustomTextField(
          controller: _uSerServices.addressController,
          hintText: "விலாசம்",
          leadingIconColor: mainBlue,
          hintTextColor: Colors.blue,
          icon: Icons.home,
          keyboardType: TextInputType.text,
        ), //விலாசம்
        SelectDropList(
            itemSelected: _uSerServices.selectedArea,
            dropListModel: villageDropListModel,
            onOptionSelected:(optionItem){
              setState(()=>_uSerServices.selectedArea=optionItem);},
            image:'assets/images/dish.png'
        ), //எந்த ஊர்
        CustomTextField(
            controller: _uSerServices.mobileController,
            hintText: "தொலைபேசி இலக்கம்",
            leadingIconColor: mainBlue,
            hintTextColor: Colors.blue,
            icon: Icons.phone,
            keyboardType: TextInputType.number,
            iconButton: true,
            animatedIconButtonStratIcon: Icons.add_circle_outline_rounded,
            animatedIconButtonEndIcon: Icons.indeterminate_check_box_outlined,
            animatedIconButtonOnTap: ()=>setState(()=>mNoVisible = !mNoVisible)), //தொலைபேசி இலக்கம்
        Visibility(
          visible: mNoVisible,
          child: CustomTextField(
            leadingIconColor: mainBlue,
            hintTextColor: Colors.blue,
            controller: _uSerServices.mobileController1,
            hintText: "தொலைபேசி இலக்கம்",
            icon: Icons.phone,
            keyboardType: TextInputType.number,
          ),
        ), //தொலைபேசி இலக்கம்2
        CustomTextField(
          leadingIconColor: mainBlue,
          hintTextColor: Colors.blue,
          controller: _uSerServices.dishNumberController,
          hintText: "Dish இலக்கம்",
          image: 'assets/images/dish.png',
          keyboardType: TextInputType.number,
        ), //Dish இலக்கம்
        SelectDropList(
            itemSelected: _uSerServices.selectedDishType,
            dropListModel: dishDropListModel,
            onOptionSelected:(name){setState(()=>_uSerServices.selectedDishType=name);},
            image:'assets/images/dish.png'
        ),//Dish ன் வகை

        Visibility(
          visible: visible,
          child: CustomTextField(
            leadingIconColor: mainBlue,
            hintTextColor: Colors.blue,
            controller: _uSerServices.registerDateController,
            hintText: "பதிந்த திகதி",
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
                        print(val);
                        _uSerServices.registerDate = val;
                        _uSerServices.registerDateController.text = DateFormat('dd-MM-yyyy hh:mm a')
                            .format(val);
                      });
                    },
                   ));
            },
          ),
        ),
        Visibility(
          visible: visible,
          child: CustomTextField(
            leadingIconColor: mainBlue,
            hintTextColor: Colors.blue,
            controller: _uSerServices.expiredDateController,
            hintText: "முடியும் திகதி",
            readOnly: true,
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
        ),
        Visibility(
          visible: visible,
          child: CustomTextField(
            leadingIconColor: mainBlue,
            hintTextColor: Colors.blue,
            controller: _uSerServices.shopController,
            hintText: "கடையின் பெயர்",
            icon: Icons.phone,
            keyboardType: TextInputType.text,
          ),
        ),
        SizedBox(
          height: 20.0,
        ),
        RoundedLoading(
          btnController: _uSerServices.btnController,
          paddingLeft: 140.0,
          paddingRight: 140.0,
          paddingTop: 8.0,
          buttonPressed: (){
            _uSerServices.createRecord(index: _index,context: context);
          },
        ),
        SizedBox(
          height: 20,
        )
      ],
    );
  }
  @override
  void dispose() {
    _uSerServices.selectedArea='Select Area';
    _uSerServices.selectedDishType='Select Dish Type';
    super.dispose();
  }
}
