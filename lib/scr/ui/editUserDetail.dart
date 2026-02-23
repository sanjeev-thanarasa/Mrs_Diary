import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/createUser.dart';
import 'package:mrs_dth_diary_v1/scr/models/dropDownModel.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/RoundedLoadingButton.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/datePicker.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';

class EditUserDetail extends StatefulWidget {
  final String userId;
  final String collectionName;
  final List? data;
  final int? index;

  const EditUserDetail({
    super.key,
    required this.userId,
    this.data,
    this.index,
    required this.collectionName,
  });
  @override
  _EditUserDetailState createState() => _EditUserDetailState();
}

class _EditUserDetailState extends State<EditUserDetail> {
  USerServices _uSerServices = USerServices();
  Map<String, dynamic>? _userData;

  String _formatDate(DateTime? value) {
    if (value == null) {
      return '';
    }
    return DateFormat('dd-MM-yyyy hh:mm a').format(value);
  }

  Map<String, dynamic> _getItemMap() {
    if (_userData != null) {
      return _userData!;
    }
    if (widget.data == null || widget.index == null) {
      return <String, dynamic>{};
    }
    final item = widget.data![widget.index!];
    if (item is Map<String, dynamic>) {
      return item;
    }
    if (item is QueryDocumentSnapshot<Map<String, dynamic>>) {
      return item.data();
    }
    if (item is DocumentSnapshot<Map<String, dynamic>>) {
      return item.data() ?? <String, dynamic>{};
    }
    return <String, dynamic>{};
  }

  Future<void> _fetchUserData() async {
    if (widget.data != null && widget.index != null) {
      return; // Data already provided
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection(widget.collectionName)
          .doc(widget.userId)
          .get();
      if (doc.exists && mounted) {
        setState(() {
          _userData = doc.data();
        });
        editInitialize();
      }
    } catch (e) {}
  }

  @override
  void initState() {
    _uSerServices.getVillageName();
    _uSerServices.getDishTypes();
    if (widget.data != null && widget.index != null) {
      editInitialize();
    } else {
      _fetchUserData();
    }
    print(widget.collectionName);
    print(widget.userId);
    print(widget.data);
    print(widget.index);
    super.initState();
  }

  void editInitialize() {
    final data = _getItemMap();
    if (widget.collectionName == 'NewUser') {
      editOldUserInitialize();
      print(
          "widget.collectionName?>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ${widget.collectionName}");
      _uSerServices.shopController.text = data["shopName"] ?? '';
      _uSerServices.registerDate =
          data['registerDate'] != null ? data['registerDate'].toDate() : null;
      _uSerServices.expiredDate =
          data['expiredDate'] != null ? data['expiredDate'].toDate() : null;
      _uSerServices.registerDateController.text =
          _formatDate(_uSerServices.registerDate);
      _uSerServices.expiredDateController.text =
          _formatDate(_uSerServices.expiredDate);
    } else {
      editOldUserInitialize();
    }
  }

  void editOldUserInitialize() {
    final data = _getItemMap();
    print(
        "widget.collectionName?>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ${widget.collectionName}");
    _uSerServices.nameController.text = data["name"] ?? '';
    _uSerServices.addressController.text = data["address"] ?? '';
    _uSerServices.mobileController.text = data["mobileNo"] ?? '';
    _uSerServices.mobileController1.text = data["mobileNo2"] ?? '';
    _uSerServices.dishNumberController.text = data["dishNumber"] ?? '';
    _uSerServices.selectedArea = data['area'];
    _uSerServices.selectedDishType = data['dishType'];
    _uSerServices.createAt =
        data['createAt'] != null ? data['createAt'].toDate() : null;
    _uSerServices.createAtDateController.text =
        _formatDate(_uSerServices.createAt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          "Edit User",
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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: _buildContentUI(context),
        ),
      ),
    );
  }

  Widget _buildContentUI(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionCard(
          title: "Basic details",
          child: Column(
            children: [
              _inputField(
                controller: _uSerServices.nameController,
                labelText: "Name",
                hintText: "பெயர்",
                icon: Icons.person_outline,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 10),
              _inputField(
                controller: _uSerServices.addressController,
                labelText: "Address",
                hintText: "விலாசம்",
                icon: Icons.home_rounded,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 10),
              _dropdownField(
                labelText: "Area",
                hintText: "Select Area",
                value: _uSerServices.selectedArea,
                options: villageDropListModel.listOptionItems
                    .map((item) => item.name)
                    .toList(),
                icon: Icons.location_on_rounded,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _uSerServices.selectedArea = value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _sectionCard(
          title: "Contact",
          child: Column(
            children: [
              _inputField(
                controller: _uSerServices.mobileController,
                labelText: "Mobile number",
                hintText: "M.No",
                icon: Icons.phone,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              _inputField(
                controller: _uSerServices.mobileController1,
                labelText: "Alternate mobile",
                hintText: "M.No 2",
                icon: Icons.phone_in_talk_rounded,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _sectionCard(
          title: "Dish details",
          child: Column(
            children: [
              _inputField(
                controller: _uSerServices.dishNumberController,
                labelText: "Dish number",
                hintText: "Dish இலக்கம்",
                icon: Icons.tv_rounded,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              _dropdownField(
                labelText: "Dish type",
                hintText: "Select Dish Type",
                value: _uSerServices.selectedDishType,
                options: dishDropListModel.listOptionItems
                    .map((item) => item.name)
                    .toList(),
                icon: Icons.tv_rounded,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _uSerServices.selectedDishType = value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (widget.collectionName == 'NewUser') ...[
          const SizedBox(height: 12),
          _sectionCard(
            title: "New user details",
            child: buildNewUserFields(collectionName: widget.collectionName),
          ),
        ],
        const SizedBox(height: 16),
        _buildSaveButton(context),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: RoundedLoading(
          btnController: _uSerServices.btnController,
          paddingLeft: 10.0,
          paddingRight: 10.0,
          paddingTop: 8.0,
          buttonHeight: 44,
          btnColor: kPrimaryColor,
          elevation: 2.0,
          label: "Save changes",
          textStyle: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w700,
            fontFamily: 'TamilArima',
            color: Colors.white,
          ),
          buttonPressed: () {
            if (!_validateRequiredFields()) {
              _uSerServices.btnController.reset();
              return;
            }
            final now = DateTime.now();
            _uSerServices.createAt = now;
            _uSerServices.createAtDateController.text =
                DateFormat('dd-MM-yyyy hh:mm a').format(now);
            final previousArea = _getItemMap()['area']?.toString() ?? '';
            _uSerServices.updateRecord(
              index: 0,
              userId: widget.userId,
              context: context,
              collectionName: widget.collectionName,
              previousArea: previousArea,
            );
          },
        ),
      ),
    );
  }

  bool _validateRequiredFields() {
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

    if (widget.collectionName == 'NewUser') {
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

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'TamilArima',
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontFamily: 'TamilArima',
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: hintText,
        hintStyle: const TextStyle(
          fontFamily: 'TamilArima2',
          color: Colors.black45,
        ),
        prefixIcon: Icon(icon, color: Colors.blueGrey.shade600),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: kPrimaryColor, width: 1.2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String labelText,
    required String hintText,
    required String value,
    required List<String> options,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    final normalized = value.trim();
    final currentValue = normalized.isEmpty ||
            normalized == 'Select Area' ||
            normalized == 'Select Dish Type'
        ? null
        : normalized;

    return DropdownButtonFormField<String>(
      initialValue: currentValue,
      isExpanded: true,
      onChanged: onChanged,
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      items: options
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(
                  fontFamily: 'TamilArima',
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          )
          .toList(),
      decoration: InputDecoration(
        labelText: labelText,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: hintText,
        hintStyle: const TextStyle(
          fontFamily: 'TamilArima2',
          color: Colors.black45,
        ),
        prefixIcon: Icon(icon, color: Colors.blueGrey.shade600),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: kPrimaryColor, width: 1.2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget buildNewUserFields({required String collectionName}) {
    if (collectionName == 'OldUser') {
      return const SizedBox();
    } else if (collectionName == 'NewUser') {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _inputField(
            controller: _uSerServices.shopController,
            labelText: "Shop name",
            hintText: "கடையின் பெயர்",
            icon: Icons.storefront_rounded,
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 10),
          _inputField(
            controller: _uSerServices.registerDateController,
            labelText: "Register date",
            hintText: "Register Date : Select Date",
            icon: Icons.date_range,
            keyboardType: TextInputType.text,
            readOnly: true,
            onTap: () {
              showCupertinoModalPopup(
                  context: context,
                  builder: (_) => DatePicker(
                        onDateTimeChanged: (val) {
                          setState(() {
                            _uSerServices.registerDate = val;
                            _uSerServices.registerDateController.text =
                                DateFormat('dd-MM-yyyy hh:mm a').format(val);
                          });
                        },
                      ));
            },
          ),
          const SizedBox(height: 10),
          _inputField(
            controller: _uSerServices.expiredDateController,
            labelText: "Expired date",
            hintText: "முடியும் திகதி : Select Date",
            icon: Icons.event_busy_rounded,
            keyboardType: TextInputType.text,
            readOnly: true,
            onTap: () {
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
        ],
      );
    } else {
      return const SizedBox();
    }
  }

  // void _onRefresh() {
  //   _uSerServices.clearRecords();
  // }
}
