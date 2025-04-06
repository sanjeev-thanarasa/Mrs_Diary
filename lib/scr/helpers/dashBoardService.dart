
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:uuid/uuid.dart';

class DashBoardService{

  RoundedLoadingButtonController btnController = RoundedLoadingButtonController();
  TextEditingController createAtController = TextEditingController();
  TextEditingController paidDateController = TextEditingController();

  DateTime createAt;
  DateTime paidDate;

  TextEditingController packageAmount = TextEditingController();  ////////////////எடுத்த பணம் ???////////////////////////
  TextEditingController rechargePlace = TextEditingController();  ////////////////எடுத்த இடம் ???///////////////////////
  TextEditingController paidAmount = TextEditingController();      ////////////////கொடுத்த பணம் ???//////////////////////
  TextEditingController newPaidAmount = TextEditingController();
  TextEditingController pendingAmount = TextEditingController();
  TextEditingController balanceAmount = TextEditingController();
  TextEditingController userNote = TextEditingController();


  Map<String, dynamic> addRecord;
  bool pending = false;
  bool balance = false;

  String collection = "DashboardPaymentRecords";
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void createRecord({String dbID}) async {
    String id = Uuid().v1();
    addRecord = {
      "id" : id,
      "DB_ID" : dbID,
      "CREATE_AT": createAt,
      "RECHARGE_AMOUNT" : packageAmount.text,
      "BALANCE_AMOUNT" : balanceAmount.text,
      "PAID_AMOUNT" : paidAmount.text,
      "PENDING_AMOUNT" : pendingAmount.text,
      "RECHARGE_PLACE" : rechargePlace.text,
      "USER_NOTE" : userNote.text,
      "PAID_DATE" : paidDate,
    };
    Timer(Duration(milliseconds: 200), () {
      _firestore.collection(collection).doc(addRecord["id"]).set(addRecord).whenComplete((){
        print("DB Uploaded");
        btnController.success();
        clearRecords();}
      );

    });
  }

  void updateRecord({String dbID, QueryDocumentSnapshot snapshot}) async {
    addRecord = {
      "BALANCE_AMOUNT" : balanceAmount.text=='' ? snapshot['BALANCE_AMOUNT'] : balanceAmount.text,
      "PAID_AMOUNT" : newPaidAmount.text=='' ? snapshot['PAID_AMOUNT'] : newPaidAmount.text,
      "PENDING_AMOUNT" : pendingAmount.text=='' ? snapshot['PENDING_AMOUNT'] : pendingAmount.text,
      "RECHARGE_PLACE" : rechargePlace.text=='' ? snapshot['RECHARGE_PLACE'] : rechargePlace.text ,
      "USER_NOTE" : userNote.text ?? snapshot['USER_NOTE'],
      "PAID_DATE" : paidDate != null ? paidDate : snapshot['PAID_DATE'] != null ? snapshot['PAID_DATE'] : null,
    };
    Timer(Duration(milliseconds: 200), () {
      _firestore.collection(collection).doc(dbID).update(addRecord).whenComplete((){
        print("DB Uploaded");
        btnController.success();
        clearRecords();}
      );

    });
  }

  void clearRecords(){
    Timer(Duration(seconds: 2),() {
      createAtController.clear();
      paidDateController.clear();
      packageAmount.clear();
      balanceAmount.clear();
      paidAmount.clear();
      pendingAmount.clear();
      rechargePlace.clear();
      userNote.clear();
      paidDate = null;
      createAt = null;
      newPaidAmount.clear();
      btnController.reset();
    });
  }




}