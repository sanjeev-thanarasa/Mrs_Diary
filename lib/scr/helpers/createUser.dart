import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mrs_dth_diary_v1/scr/models/dropDownModel.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CToast.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:uuid/uuid.dart';

class USerServices {
  RoundedLoadingButtonController btnController =
      RoundedLoadingButtonController();

  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController mobileController1 = TextEditingController();
  TextEditingController dishNumberController = TextEditingController();
  TextEditingController shopController = TextEditingController();
  TextEditingController registerDateController = TextEditingController();
  TextEditingController expiredDateController = TextEditingController();
  TextEditingController createAtDateController = TextEditingController();

  DateTime? registerDate;
  DateTime? expiredDate;
  DateTime? createAt;

  String selectedDishType = 'Select Dish Type';
  String selectedArea = 'Select Area';

  final databaseReference = FirebaseFirestore.instance;
  Map<String, dynamic> addOldUser = {};
  Map<String, dynamic> addNewUser = {};

  String collection = "Villages";
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DropListModel> getVillageName() async =>
      _firestore.collection(collection).get().then((result) {
        villageDropListModel.listOptionItems.clear();
        for (DocumentSnapshot data in result.docs) {
          villageDropListModel.listOptionItems
              .add(OptionItem(name: data["name"]));
        }
        return villageDropListModel;
      });

  void createRecord({required int index, required BuildContext context}) async {
    String id = const Uuid().v1();
    addOldUser = {
      "id": id,
      "name": nameController.text,
      "address": addressController.text,
      "area": selectedArea,
      "mobileNo": mobileController.text,
      "mobileNo2": mobileController1.text,
      "dishNumber": dishNumberController.text,
      "dishType": selectedDishType,
      "createAt": DateTime.now(),
      "NoteList": false,
      "BlackList": false,
    };
    addNewUser = {
      "id": id,
      "name": nameController.text,
      "address": addressController.text,
      "area": selectedArea,
      "mobileNo": mobileController.text,
      "mobileNo2": mobileController1.text,
      "dishNumber": dishNumberController.text,
      "dishType": selectedDishType,
      "shopName": shopController.text,
      "createAt": DateTime.now(),
      "registerDate": registerDate,
      "expiredDate": expiredDate,
      "NoteList": false,
      "BlackList": false,
    };
    if (index == 0) {
      Timer(Duration(milliseconds: 200), () {
        databaseReference
            .collection("OldUser")
            .doc(addOldUser["id"])
            .set(addOldUser)
            .whenComplete(() {
          btnController.success();
          CToast.show(message: "Added Successfully");
          clearRecords();
        });
      });
    } else {
      Timer(Duration(milliseconds: 200), () {
        databaseReference
            .collection("NewUser")
            .doc(addOldUser["id"])
            .set(addNewUser)
            .whenComplete(() {
          btnController.success();
          CToast.show(message: "Added Successfully");
          clearRecords();
        });
      });
    }
  }

  void updateRecord({
    required int index,
    required BuildContext context,
    required String userId,
    required String collectionName,
  }) async {
    final now = DateTime.now();
    if (collectionName == 'NewUser') {
      addNewUser = {
        "id": userId,
        "name": nameController.text,
        "address": addressController.text,
        "area": selectedArea,
        "mobileNo": mobileController.text,
        "mobileNo2": mobileController1.text,
        "dishNumber": dishNumberController.text,
        "dishType": selectedDishType,
        "shopName": shopController.text,
        "createAt": now,
        "registerDate": registerDate,
        "expiredDate": expiredDate,
      };
      Timer(Duration(milliseconds: 200), () {
        databaseReference
            .collection("NewUser")
            .doc(userId)
            .update(addNewUser)
            .whenComplete(() {
          btnController.success();
          CToast.show(message: "Added Successfully");
          clearRecords();
          Navigator.maybePop(context, true);
        });
      });
    } else if (collectionName == 'OldUser') {
      addOldUser = {
        "id": userId,
        "name": nameController.text,
        "address": addressController.text,
        "area": selectedArea,
        "mobileNo": mobileController.text,
        "mobileNo2": mobileController1.text,
        "dishNumber": dishNumberController.text,
        "dishType": selectedDishType,
        "createAt": now,
      };
      Timer(Duration(milliseconds: 200), () {
        databaseReference
            .collection("OldUser")
            .doc(userId)
            .update(addOldUser)
            .whenComplete(() {
          btnController.success();
          CToast.show(message: "Added Successfully");
          clearRecords();
          Navigator.maybePop(context, true);
        });
      });
    } else {
      btnController.error();
    }
  }

  void clearRecords() {
    Timer(Duration(seconds: 2), () {
      btnController.reset();
      nameController.clear();
      addressController.clear();
      //selectedArea='Select Area';
      mobileController.clear();
      mobileController1.clear();
      dishNumberController.clear();
      //selectedDishType='Select Dish Type';
      shopController.clear();
      createAtDateController.clear();
    });
  }
}
