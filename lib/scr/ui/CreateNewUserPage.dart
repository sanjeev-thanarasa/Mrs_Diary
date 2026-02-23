import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/createUser.dart';
import 'package:mrs_dth_diary_v1/scr/models/dropDownModel.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CDropDownList.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CTextField.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/RoundedLoadingButton.dart';
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

  Future<void> _pickDate({
    required DateTime? initial,
    required ValueChanged<DateTime> onSelected,
    required TextEditingController controller,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      onSelected(picked);
      controller.text = DateFormat('dd-MM-yyyy').format(picked);
    });
  }

  @override
  void initState() {
    super.initState();
    _uSerServices.getVillageName();
    _uSerServices.getDishTypes();
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
        child: ListView(
          padding: EdgeInsets.only(
            left: rs.rw(16),
            right: rs.rw(16),
            top: rs.rh(12),
            bottom: rs.rh(24),
          ),
          children: [
            _buildHeaderCard(),
            SizedBox(height: rs.rh(12)),
            _buildUserTypeToggle(),
            SizedBox(height: rs.rh(12)),
            _buildSectionCard(
              title: 'Basic details',
              icon: Icons.badge_outlined,
              child: Column(
                children: [
                  CustomTextField(
                    controller: _uSerServices.nameController,
                    hintText: "பெயர்",
                    leadingIconColor: kBlueColor,
                    hintTextColor: const Color(0xFF4A6572),
                    icon: Icons.person,
                    showLeadingIcon: false,
                    keyboardType: TextInputType.text,
                  ),
                  CustomTextField(
                    controller: _uSerServices.addressController,
                    hintText: "விலாசம்",
                    leadingIconColor: kBlueColor,
                    hintTextColor: const Color(0xFF4A6572),
                    icon: Icons.home,
                    showLeadingIcon: false,
                    keyboardType: TextInputType.text,
                  ),
                  SelectDropList(
                    itemSelected: _uSerServices.selectedArea,
                    dropListModel: villageDropListModel,
                    onOptionSelected: (optionItem) {
                      setState(() => _uSerServices.selectedArea = optionItem);
                    },
                    image: 'assets/images/dish.png',
                    iconColor: kBlueColor,
                  ),
                ],
              ),
            ),
            SizedBox(height: rs.rh(12)),
            _buildSectionCard(
              title: 'Contact',
              icon: Icons.call_rounded,
              child: Column(
                children: [
                  CustomTextField(
                    controller: _uSerServices.mobileController,
                    hintText: "தொலைபேசி இலக்கம்",
                    leadingIconColor: kBlueColor,
                    hintTextColor: const Color(0xFF4A6572),
                    icon: Icons.phone,
                    showLeadingIcon: false,
                    keyboardType: TextInputType.number,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => setState(() => mNoVisible = !mNoVisible),
                      icon: Icon(
                        mNoVisible
                            ? Icons.remove_circle_outline_rounded
                            : Icons.add_circle_outline_rounded,
                        size: rs.r(18),
                        color: kPrimaryColor,
                      ),
                      label: Text(
                        mNoVisible
                            ? 'Remove alternate number'
                            : 'Add alternate number',
                        style: TextStyle(
                          fontFamily: 'TamilArima2',
                          fontSize: rs.sp(12.5),
                          fontWeight: FontWeight.w600,
                          color: kPrimaryColor,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: mNoVisible
                        ? CustomTextField(
                            key: const ValueKey('alt-mobile'),
                            leadingIconColor: kBlueColor,
                            hintTextColor: const Color(0xFF4A6572),
                            controller: _uSerServices.mobileController1,
                            hintText: "தொலைபேசி இலக்கம்",
                            icon: Icons.phone,
                            showLeadingIcon: false,
                            keyboardType: TextInputType.number,
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            SizedBox(height: rs.rh(12)),
            _buildSectionCard(
              title: 'Dish info',
              icon: Icons.tv_rounded,
              child: Column(
                children: [
                  CustomTextField(
                    leadingIconColor: kBlueColor,
                    hintTextColor: const Color(0xFF4A6572),
                    controller: _uSerServices.dishNumberController,
                    hintText: "Dish இலக்கம்",
                    image: 'assets/images/dish.png',
                    showLeadingIcon: false,
                    keyboardType: TextInputType.number,
                  ),
                  SelectDropList(
                    itemSelected: _uSerServices.selectedDishType,
                    dropListModel: dishDropListModel,
                    onOptionSelected: (name) {
                      setState(() => _uSerServices.selectedDishType = name);
                    },
                    image: 'assets/images/dish.png',
                    iconColor: kBlueColor,
                  ),
                ],
              ),
            ),
            if (_index == 1) ...[
              SizedBox(height: rs.rh(12)),
              _buildSectionCard(
                title: 'New user details',
                icon: Icons.event_available_rounded,
                child: Column(
                  children: [
                    CustomTextField(
                      leadingIconColor: kBlueColor,
                      hintTextColor: const Color(0xFF4A6572),
                      controller: _uSerServices.registerDateController,
                      hintText: "பதிந்த திகதி",
                      icon: Icons.date_range_rounded,
                      showLeadingIcon: false,
                      keyboardType: TextInputType.text,
                      iconButton: true,
                      readOnly: true,
                      animatedIconButtonStratIcon: Icons.date_range,
                      animatedIconButtonEndIcon: Icons.date_range_outlined,
                      animatedIconButtonOnTap: () {
                        _pickDate(
                          initial: _uSerServices.registerDate,
                          controller: _uSerServices.registerDateController,
                          onSelected: (val) => _uSerServices.registerDate = val,
                        );
                      },
                    ),
                    CustomTextField(
                      leadingIconColor: kBlueColor,
                      hintTextColor: const Color(0xFF4A6572),
                      controller: _uSerServices.expiredDateController,
                      hintText: "முடியும் திகதி",
                      readOnly: true,
                      icon: Icons.event_busy_rounded,
                      showLeadingIcon: false,
                      keyboardType: TextInputType.text,
                      iconButton: true,
                      animatedIconButtonStratIcon: Icons.date_range,
                      animatedIconButtonEndIcon: Icons.date_range_outlined,
                      animatedIconButtonOnTap: () {
                        _pickDate(
                          initial: _uSerServices.expiredDate,
                          controller: _uSerServices.expiredDateController,
                          onSelected: (val) => _uSerServices.expiredDate = val,
                        );
                      },
                    ),
                    CustomTextField(
                      leadingIconColor: kBlueColor,
                      hintTextColor: const Color(0xFF4A6572),
                      controller: _uSerServices.shopController,
                      hintText: "கடையின் பெயர்",
                      icon: Icons.store_rounded,
                      showLeadingIcon: false,
                      keyboardType: TextInputType.text,
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: rs.rh(16)),
            RoundedLoading(
              btnController: _uSerServices.btnController,
              paddingTop: 6.0,
              buttonHeight: 46.0,
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
                final isNewUser = _index == 1;
                if (!_validateRequiredFields(isNewUser: isNewUser)) {
                  _uSerServices.btnController.reset();
                  return;
                }
                _uSerServices.createRecord(index: _index, context: context);
              },
            ),
          ],
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

  Widget _buildHeaderCard() {
    final rs = context.rs;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: rs.rw(16),
        vertical: rs.rh(16),
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPrimaryColor, kPrimaryLightColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(rs.r(18)),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 10),
            blurRadius: rs.r(24),
            color: kPrimaryColor.withValues(alpha: 0.25),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: rs.r(24),
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Icon(
              Icons.person_add_alt_1_rounded,
              color: Colors.white,
              size: rs.r(22),
            ),
          ),
          SizedBox(width: rs.rw(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create new user',
                  style: TextStyle(
                    fontFamily: 'TamilArima',
                    fontWeight: FontWeight.w700,
                    fontSize: rs.sp(16),
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: rs.rh(4)),
                Text(
                  'Fill the form below to save user details.',
                  style: TextStyle(
                    fontFamily: 'TamilArima2',
                    fontWeight: FontWeight.w600,
                    fontSize: rs.sp(12.5),
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget child,
    IconData? icon,
  }) {
    final rs = context.rs;
    return Container(
      padding: EdgeInsets.fromLTRB(
        rs.rw(14),
        rs.rh(14),
        rs.rw(14),
        rs.rh(10),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rs.r(16)),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 8),
            blurRadius: rs.r(22),
            color: Colors.black.withValues(alpha: 0.05),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null)
                Container(
                  padding: EdgeInsets.all(rs.r(6)),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(rs.r(10)),
                  ),
                  child: Icon(icon, size: rs.r(16), color: kPrimaryColor),
                ),
              if (icon != null) SizedBox(width: rs.rw(8)),
              Text(
                title,
                style: TextStyle(
                  fontSize: rs.sp(13.5),
                  fontWeight: FontWeight.w700,
                  fontFamily: 'TamilArima',
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: rs.rh(8)),
          child,
        ],
      ),
    );
  }

  bool _validateRequiredFields({required bool isNewUser}) {
    final name = _uSerServices.nameController.text.trim();
    final address = _uSerServices.addressController.text.trim();
    final mobile = _uSerServices.mobileController.text.trim();
    final dishNumber = _uSerServices.dishNumberController.text.trim();
    final area = _uSerServices.selectedArea.trim();
    final dishType = _uSerServices.selectedDishType.trim();

    if (name.isEmpty) {
      _showValidationMessage('Name is required');
      _uSerServices.btnController.reset();
      return false;
    }
    if (address.isEmpty) {
      _showValidationMessage('Address is required');
      _uSerServices.btnController.reset();
      return false;
    }
    if (area.isEmpty || area == 'Select Area') {
      _showValidationMessage('Area is required');
      _uSerServices.btnController.reset();
      return false;
    }
    if (mobile.isEmpty) {
      _showValidationMessage('Mobile number is required');
      _uSerServices.btnController.reset();
      return false;
    }
    if (dishNumber.isEmpty) {
      _showValidationMessage('Dish number is required');
      _uSerServices.btnController.reset();
      return false;
    }
    if (dishType.isEmpty || dishType == 'Select Dish Type') {
      _showValidationMessage('Dish type is required');
      _uSerServices.btnController.reset();
      return false;
    }

    if (isNewUser) {
      final shopName = _uSerServices.shopController.text.trim();
      final registerDate = _uSerServices.registerDateController.text.trim();
      final expiredDate = _uSerServices.expiredDateController.text.trim();
      if (shopName.isEmpty) {
        _showValidationMessage('Shop name is required');
        _uSerServices.btnController.reset();
        return false;
      }
      if (registerDate.isEmpty) {
        _showValidationMessage('Register date is required');
        _uSerServices.btnController.reset();
        return false;
      }
      if (expiredDate.isEmpty) {
        _showValidationMessage('Expired date is required');
        _uSerServices.btnController.reset();
        return false;
      }
    }

    return true;
  }

  void _showValidationMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  void dispose() {
    _uSerServices.selectedArea = 'Select Area';
    _uSerServices.selectedDishType = 'Select Dish Type';
    super.dispose();
  }
}
