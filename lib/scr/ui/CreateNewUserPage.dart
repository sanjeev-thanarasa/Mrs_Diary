import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/createUser.dart';
import 'package:mrs_dth_diary_v1/scr/models/dropDownModel.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CDropDownList.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CTextField.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/RoundedLoadingButton.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/datePicker.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/responsive.dart';
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
    final rs = context.rs;
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Create User',
          style: TextStyle(
            fontFamily: 'TamilArima',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: rs.rh(16)),
          child: Column(
            children: [
              SizedBox(height: rs.rh(12)),
              _buildUserTypeToggle(),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(rs.r(16)),
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 8),
                      blurRadius: rs.r(24),
                      color: Colors.black.withValues(alpha: 0.06),
                    ),
                  ],
                ),
                margin: EdgeInsets.symmetric(
                  horizontal: rs.rw(12),
                  vertical: rs.rh(8),
                ),
                child: _index == 0 ? buildColumn(false) : buildColumn(true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeToggle() {
    final rs = context.rs;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: rs.rw(16)),
      padding: EdgeInsets.all(rs.r(4)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rs.r(18)),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 6),
            blurRadius: rs.r(18),
            color: Colors.black.withValues(alpha: 0.08),
          ),
        ],
      ),
      child: Row(
        children: [
          _toggleItem(label: 'Old User', index: 0),
          _toggleItem(label: 'New User', index: 1),
        ],
      ),
    );
  }

  Widget _toggleItem({required String label, required int index}) {
    final rs = context.rs;
    final isActive = _index == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _index = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(vertical: rs.rh(10)),
          decoration: BoxDecoration(
            color: isActive ? kPrimaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(rs.r(14)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: rs.sp(14),
                fontWeight: FontWeight.w700,
                fontFamily: 'TamilArima',
                color: isActive ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Column buildColumn(bool visible) {
    final rs = context.rs;
    const hintColor = Color(0xFF4A6572);
    final accentColor = kBlueColor;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(height: rs.rh(14)),
        _sectionLabel('Basic details'),
        SizedBox(height: rs.rh(6)),
        CustomTextField(
          controller: _uSerServices.nameController,
          hintText: "பெயர்",
          leadingIconColor: accentColor,
          hintTextColor: hintColor,
          icon: Icons.person,
          keyboardType: TextInputType.text,
        ), //பெயர்
        CustomTextField(
          controller: _uSerServices.addressController,
          hintText: "விலாசம்",
          leadingIconColor: accentColor,
          hintTextColor: hintColor,
          icon: Icons.home,
          keyboardType: TextInputType.text,
        ), //விலாசம்
        SelectDropList(
            itemSelected: _uSerServices.selectedArea,
            dropListModel: villageDropListModel,
            onOptionSelected: (optionItem) {
              setState(() => _uSerServices.selectedArea = optionItem);
            },
            image: 'assets/images/dish.png',
            iconColor: accentColor), //எந்த ஊர்
        SizedBox(height: rs.rh(6)),
        _sectionLabel('Contact'),
        SizedBox(height: rs.rh(6)),
        CustomTextField(
            controller: _uSerServices.mobileController,
            hintText: "தொலைபேசி இலக்கம்",
            leadingIconColor: accentColor,
            hintTextColor: hintColor,
            icon: Icons.phone,
            keyboardType: TextInputType.number,
            iconButton: true,
            animatedIconButtonStratIcon: Icons.add_circle_outline_rounded,
            animatedIconButtonEndIcon: Icons.indeterminate_check_box_outlined,
            animatedIconButtonOnTap: () =>
                setState(() => mNoVisible = !mNoVisible)), //தொலைபேசி இலக்கம்
        Visibility(
          visible: mNoVisible,
          child: CustomTextField(
            leadingIconColor: accentColor,
            hintTextColor: hintColor,
            controller: _uSerServices.mobileController1,
            hintText: "தொலைபேசி இலக்கம்",
            icon: Icons.phone,
            keyboardType: TextInputType.number,
          ),
        ), //தொலைபேசி இலக்கம்2
        SizedBox(height: rs.rh(6)),
        _sectionLabel('Dish info'),
        SizedBox(height: rs.rh(6)),
        CustomTextField(
          leadingIconColor: accentColor,
          hintTextColor: hintColor,
          controller: _uSerServices.dishNumberController,
          hintText: "Dish இலக்கம்",
          image: 'assets/images/dish.png',
          keyboardType: TextInputType.number,
        ), //Dish இலக்கம்
        SelectDropList(
            itemSelected: _uSerServices.selectedDishType,
            dropListModel: dishDropListModel,
            onOptionSelected: (name) {
              setState(() => _uSerServices.selectedDishType = name);
            },
            image: 'assets/images/dish.png',
            iconColor: accentColor), //Dish ன் வகை

        Visibility(
          visible: visible,
          child: CustomTextField(
            leadingIconColor: accentColor,
            hintTextColor: hintColor,
            controller: _uSerServices.registerDateController,
            hintText: "பதிந்த திகதி",
            icon: Icons.phone,
            keyboardType: TextInputType.text,
            iconButton: true,
            readOnly: true,
            animatedIconButtonStratIcon: Icons.date_range,
            animatedIconButtonEndIcon: Icons.date_range_outlined,
            animatedIconButtonOnTap: () {
              showCupertinoModalPopup(
                  context: context,
                  builder: (_) => DatePicker(
                        onDateTimeChanged: (val) {
                          setState(() {
                            print(val);
                            _uSerServices.registerDate = val;
                            _uSerServices.registerDateController.text =
                                DateFormat('dd-MM-yyyy hh:mm a').format(val);
                          });
                        },
                      ));
            },
          ),
        ),
        Visibility(
          visible: visible,
          child: CustomTextField(
            leadingIconColor: accentColor,
            hintTextColor: hintColor,
            controller: _uSerServices.expiredDateController,
            hintText: "முடியும் திகதி",
            readOnly: true,
            icon: Icons.phone,
            keyboardType: TextInputType.text,
            iconButton: true,
            animatedIconButtonStratIcon: Icons.date_range,
            animatedIconButtonEndIcon: Icons.date_range_outlined,
            animatedIconButtonOnTap: () {
              showCupertinoModalPopup(
                  context: context,
                  builder: (_) => DatePicker(
                        onDateTimeChanged: (val) {
                          setState(() {
                            _uSerServices.expiredDate = val;
                            _uSerServices.expiredDateController.text =
                                DateFormat('dd-MM-yyyy hh:mm a').format(val);
                          });
                        },
                      ));
            },
          ),
        ),
        Visibility(
          visible: visible,
          child: CustomTextField(
            leadingIconColor: accentColor,
            hintTextColor: hintColor,
            controller: _uSerServices.shopController,
            hintText: "கடையின் பெயர்",
            icon: Icons.phone,
            keyboardType: TextInputType.text,
          ),
        ),
        SizedBox(height: rs.rh(16)),
        RoundedLoading(
          btnController: _uSerServices.btnController,
          // paddingLeft: 10.0,
          // paddingRight: 10.0,
          paddingTop: 6.0,
          buttonHeight: 40.0,
          btnColor: kBlueColor,
          elevation: 2.0,
          label: 'Save User',
          textStyle: TextStyle(
            fontSize: rs.sp(16),
            fontWeight: FontWeight.w700,
            fontFamily: 'TamilArima',
            color: Colors.white,
          ),
          buttonPressed: () {
            _uSerServices.createRecord(index: _index, context: context);
          },
        ),
        SizedBox(height: rs.rh(20))
      ],
    );
  }

  Widget _sectionLabel(String text) {
    final rs = context.rs;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rs.rw(16)),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            fontSize: rs.sp(13),
            fontWeight: FontWeight.w700,
            fontFamily: 'TamilArima',
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _uSerServices.selectedArea = 'Select Area';
    _uSerServices.selectedDishType = 'Select Dish Type';
    super.dispose();
  }
}
