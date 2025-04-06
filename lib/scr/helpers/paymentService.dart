import 'dart:async';
import 'dart:ffi';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class PaymentServices {
  RoundedLoadingButtonController btnController =
  RoundedLoadingButtonController();

  TextEditingController createRecordDate = TextEditingController();
  TextEditingController rechargeAmount=TextEditingController();
  TextEditingController giveAmount=TextEditingController();
  TextEditingController newGiveAmount=TextEditingController();
  TextEditingController pendingAmount=TextEditingController();
  TextEditingController balanceAmount=TextEditingController();
  TextEditingController userNote=TextEditingController();
  TextEditingController userNote2=TextEditingController();
  TextEditingController packageName=TextEditingController();
  TextEditingController pendingDateController=TextEditingController();
  TextEditingController expiredDateController=TextEditingController();

  DateTime pendingDate;
  DateTime expiredDate;
  DateTime createDate;

  bool pending=false;
  bool balance=false;



  final databaseReference = FirebaseFirestore.instance;
  Map<String,dynamic> addPayment;
  Map<String,dynamic> updatePayment;


  String collection = "PaymentRecords";

  void createPaymentRecord({String userId}) async {
    addPayment = {
      "USER_ID": userId,
      "PACKAGE_NAME": packageName.text,
      "AMOUNT" : rechargeAmount.text,
      "PAID_AMOUNT" :giveAmount.text,
      "PENDING_AMOUNT": pendingAmount.text,
      "PENDING_DATE": pendingDate,
      "BALANCE_AMOUNT": balanceAmount.text,
      "USER_NOTE": userNote.text,
      "USER_NOTE2": userNote2.text,
      "CREATE_AT": DateTime.now(),
      "EXPIRED_AT": expiredDate,

    };
    Timer(Duration(milliseconds: 200), () {
      databaseReference.collection(collection).add(addPayment).whenComplete((){
        btnController.success();
        clearRecords();}
      );

    });
  }


  void updatePaymentRecord({QueryDocumentSnapshot snapshot}) async {
    print (rechargeAmount.text);
    print (giveAmount.text);
    print (giveAmount.text == rechargeAmount.text);
    updatePayment = {
      // "USER_ID": snapshot["USER_ID"],
      "PACKAGE_NAME": packageName.text,
      "AMOUNT" :rechargeAmount.text,

      "PAID_AMOUNT" : newGiveAmount.text,
      "PENDING_AMOUNT" : pendingAmount.text,
      "PENDING_DATE" : newGiveAmount.text == rechargeAmount.text ? null : pendingDate,
      "BALANCE_AMOUNT" : balanceAmount.text,
      "USER_NOTE" : userNote.text,
      "USER_NOTE2" : userNote2.text,
      "CREATE_AT" : createDate,
      "EXPIRED_AT" :expiredDate,

    };
    Timer(Duration(milliseconds: 200), () {
      databaseReference.collection(collection).doc(snapshot.id)
          .update(updatePayment).whenComplete((){
        btnController.success();
        clearRecords();}
      );

    });
  }

  void clearRecords(){
    Timer(Duration(seconds: 2),() {
      btnController.reset();
      createRecordDate.clear();
      rechargeAmount.clear();
      giveAmount.clear();
      pendingAmount.clear();
      newGiveAmount.clear();
      balanceAmount.clear();
      userNote.clear();
      userNote2.clear();
      packageName.clear();

      pending=false;
      balance=false;


    });
  }
}