import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/createUser.dart';
import 'package:mrs_dth_diary_v1/scr/models/dropDownModel.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CDropDownList.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CTextField.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/RoundedLoadingButton.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/datePicker.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';

class EditUserDetail extends StatefulWidget {
  final String userId;
  final String collectionName;
  final List data;
  final int index;

  const EditUserDetail({
    super.key,
    required this.userId,
    required this.data,
    required this.index,
    required this.collectionName,
  });
  @override
  _EditUserDetailState createState() => _EditUserDetailState();
}

class _EditUserDetailState extends State<EditUserDetail> {
  USerServices _uSerServices = USerServices();
  final ImagePicker _imagePicker = ImagePicker();
  bool _uploadingImage = false;

  String _formatDate(DateTime? value) {
    if (value == null) {
      return '';
    }
    return DateFormat('dd-MM-yyyy hh:mm a').format(value);
  }

  Future<void> _pickProfileImage(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (picked == null) return;

      setState(() => _uploadingImage = true);

      final file = File(picked.path);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(
              '${widget.userId}_${DateTime.now().millisecondsSinceEpoch}.jpg');

      await storageRef.putFile(file);
      final downloadUrl = await storageRef.getDownloadURL();

      if (!mounted) return;
      setState(() {
        _uSerServices.profileImageUrl = downloadUrl;
        _uploadingImage = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _uploadingImage = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to update profile image')),
      );
    }
  }

  void _removeProfileImage() {
    setState(() => _uSerServices.profileImageUrl = null);
  }

  void _showImagePickerSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickProfileImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickProfileImage(ImageSource.camera);
                },
              ),
              if (_uSerServices.profileImageUrl != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded,
                      color: Colors.redAccent),
                  title: const Text('Remove photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _removeProfileImage();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Map<String, dynamic> _getItemMap() {
    final item = widget.data[widget.index];
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

  void editInitialize() {
    final data = _getItemMap();
    _uSerServices.profileImageUrl = data['profileImageUrl'];
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
        _buildHeaderCard(),
        const SizedBox(height: 12),
        _sectionCard(
          title: "Basic details",
          child: Column(
            children: [
              _fieldLabel("Name"),
              CustomTextField(
                hintTextColor: Colors.blue,
                leadingIconColor: mainBlue,
                controller: _uSerServices.nameController,
                hintText: "பெயர்",
                icon: Icons.person_outline,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 10),
              _fieldLabel("Address"),
              CustomTextField(
                hintTextColor: Colors.blue,
                leadingIconColor: mainBlue,
                controller: _uSerServices.addressController,
                hintText: "விலாசம்",
                icon: Icons.home_rounded,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 10),
              _fieldLabel("Area"),
              SelectDropList(
                  itemSelected: _uSerServices.selectedArea,
                  dropListModel: villageDropListModel,
                  onOptionSelected: (optionItem) {
                    setState(() => _uSerServices.selectedArea = optionItem);
                  },
                  iconColor: mainBlue,
                  image: 'assets/images/dish.png'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _sectionCard(
          title: "Contact",
          child: Column(
            children: [
              _fieldLabel("Mobile number"),
              CustomTextField(
                hintTextColor: Colors.blue,
                leadingIconColor: mainBlue,
                controller: _uSerServices.mobileController,
                hintText: "M.No",
                icon: Icons.phone,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              _fieldLabel("Alternate mobile"),
              CustomTextField(
                hintTextColor: Colors.blue,
                leadingIconColor: mainBlue,
                controller: _uSerServices.mobileController1,
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
              _fieldLabel("Dish number"),
              CustomTextField(
                hintTextColor: Colors.blue,
                leadingIconColor: mainBlue,
                controller: _uSerServices.dishNumberController,
                hintText: "Dish இலக்கம்",
                image: 'assets/images/dish.png',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              _fieldLabel("Dish type"),
              SelectDropList(
                  itemSelected: _uSerServices.selectedDishType,
                  dropListModel: dishDropListModel,
                  onOptionSelected: (name) {
                    setState(() => _uSerServices.selectedDishType = name);
                  },
                  iconColor: mainBlue,
                  image: 'assets/images/dish.png'),
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

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        children: [
          _buildProfileAvatar(),
          const SizedBox(height: 10),
          Text(
            _uSerServices.nameController.text.isEmpty
                ? "Edit user details"
                : _uSerServices.nameController.text,
            style: const TextStyle(
              fontFamily: 'TamilArima',
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.collectionName,
                  style: const TextStyle(
                    fontFamily: 'TamilArima2',
                    color: kPrimaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (_uSerServices.selectedArea != 'Select Area') ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _uSerServices.selectedArea,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'TamilArima2',
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar() {
    final imageUrl = _uSerServices.profileImageUrl;
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: kPrimaryColor.withValues(alpha: 0.12),
          child: imageUrl == null || imageUrl.isEmpty
              ? const Icon(Icons.person_rounded, color: kPrimaryColor, size: 34)
              : ClipOval(
                  child: Image.network(
                    imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.person_rounded,
                      color: kPrimaryColor,
                      size: 34,
                    ),
                  ),
                ),
        ),
        if (_uploadingImage)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          ),
        Positioned(
          bottom: 2,
          right: 2,
          child: GestureDetector(
            onTap: _showImagePickerSheet,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: kPrimaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child:
                  const Icon(Icons.edit_rounded, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.circular(16),
      //   border: Border.all(color: Colors.grey.shade200),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.black.withValues(alpha: 0.04),
      //       blurRadius: 10,
      //       offset: const Offset(0, 6),
      //     )
      //   ],
      // ),
      child: SizedBox(
        width: double.infinity,
        child: RoundedLoading(
          btnController: _uSerServices.btnController,
          paddingLeft: 30.0,
          paddingRight: 30.0,
          paddingTop: 10.0,
          btnColor: kBlueLight,
          elevation: 2.0,
          label: "Save changes",
          textStyle: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w700,
            fontFamily: 'TamilArima',
            color: Colors.white,
          ),
          buttonPressed: () {
            final now = DateTime.now();
            _uSerServices.createAt = now;
            _uSerServices.createAtDateController.text =
                DateFormat('dd-MM-yyyy hh:mm a').format(now);
            _uSerServices.updateRecord(
              index: 0,
              userId: widget.userId,
              context: context,
              collectionName: widget.collectionName,
            );
          },
        ),
      ),
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

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'TamilArima2',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.black54,
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
          _fieldLabel("Shop name"),
          CustomTextField(
            controller: _uSerServices.shopController,
            hintText: "கடையின் பெயர்",
            icon: Icons.phone,
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 10),
          _fieldLabel("Register date"),
          CustomTextField(
            hintTextColor: Colors.blue,
            controller: _uSerServices.registerDateController,
            hintText: "Register Date : Select Date",
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
                            _uSerServices.registerDate = val;
                            _uSerServices.registerDateController.text =
                                DateFormat('dd-MM-yyyy hh:mm a').format(val);
                          });
                        },
                      ));
            },
          ),
          const SizedBox(height: 10),
          _fieldLabel("Expired date"),
          CustomTextField(
            hintTextColor: Colors.blue,
            controller: _uSerServices.expiredDateController,
            hintText: "முடியும் திகதி : Select Date",
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
