import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:uuid/uuid.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/owner_service.dart';

class DashBoardService {
  RoundedLoadingButtonController btnController =
      RoundedLoadingButtonController();
  TextEditingController createAtController = TextEditingController();
  TextEditingController paidDateController = TextEditingController();

  DateTime? createAt;
  DateTime? paidDate;

  TextEditingController packageAmount =
      TextEditingController(); ////////////////எடுத்த பணம் ???////////////////////////
  TextEditingController rechargePlace =
      TextEditingController(); ////////////////எடுத்த இடம் ???///////////////////////
  TextEditingController paidAmount =
      TextEditingController(); ////////////////கொடுத்த பணம் ???//////////////////////
  TextEditingController newPaidAmount = TextEditingController();
  TextEditingController pendingAmount = TextEditingController();
  TextEditingController balanceAmount = TextEditingController();
  TextEditingController userNote = TextEditingController();

  Map<String, dynamic> addRecord = {};
  bool pending = false;
  bool balance = false;

  String collection = "DashboardPaymentRecords";
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createRecord({required String dbID}) async {
    final id = const Uuid().v1();
    final rechargeValue = _parseAmount(packageAmount.text);
    final paidValue = _parseAmount(paidAmount.text);
    final ownerId = requireOwnerId();

    double prevPending = 0;
    double prevBalance = 0;
    DocumentReference<Map<String, dynamic>>? prevRef;

    final latest = await _firestore
        .collection(collection)
        .where('ownerId', isEqualTo: ownerId)
        .where('DB_ID', isEqualTo: dbID)
        .orderBy('CREATE_AT', descending: true)
        .limit(1)
        .get();

    if (latest.docs.isNotEmpty) {
      final doc = latest.docs.first;
      prevRef = doc.reference;
      prevPending = _parseAmount(doc['PENDING_AMOUNT']);
      prevBalance = _parseAmount(doc['BALANCE_AMOUNT']);
    }

    final totalDue = rechargeValue + prevPending;
    final effectivePaid = paidValue + prevBalance;
    final double appliedToPrevPending = prevPending > 0
        ? (effectivePaid >= prevPending ? prevPending : effectivePaid)
        : 0.0;
    final double pendingValue =
        totalDue > effectivePaid ? (totalDue - effectivePaid) : 0.0;
    final double balanceValue =
        effectivePaid > totalDue ? (effectivePaid - totalDue) : 0.0;

    final history = <Map<String, dynamic>>[];
    if (prevBalance > 0) {
      history.add({
        "AMOUNT": _formatAmountForStorage(prevBalance),
        "PAID_AT": Timestamp.fromDate(createAt ?? DateTime.now()),
        "NOTE": "முந்தைய கொடுமதி சேர்க்கப்பட்டது",
      });
      history.add({
        "AMOUNT": _formatAmountForStorage(prevBalance),
        "PAID_AT": Timestamp.fromDate(createAt ?? DateTime.now()),
        "NOTE": "முந்தைய தருமதி கழிக்கப்பட்டது",
      });
    }
    if (prevPending > 0) {
      history.add({
        "AMOUNT": _formatAmountForStorage(prevPending),
        "PAID_AT": Timestamp.fromDate(createAt ?? DateTime.now()),
        "NOTE": "முந்தைய நிலுவை சேர்க்கப்பட்டது",
      });
    }
    if (appliedToPrevPending > 0) {
      history.add({
        "AMOUNT": _formatAmountForStorage(appliedToPrevPending),
        "PAID_AT": Timestamp.fromDate(createAt ?? DateTime.now()),
        "NOTE": "முந்தைய நிலுவை கழிக்கப்பட்டது",
      });
    }
    if (paidValue > 0) {
      history.add({
        "AMOUNT": _formatAmountForStorage(paidValue),
        "PAID_AT": Timestamp.fromDate(createAt ?? DateTime.now()),
        "NOTE": "இந்த பதிவில் கொடுத்தது",
      });
    }

    addRecord = {
      "id": id,
      "ownerId": ownerId,
      "DB_ID": dbID,
      "CREATE_AT": createAt,
      "RECHARGE_AMOUNT": _formatAmountForStorage(rechargeValue),
      "BALANCE_AMOUNT": _formatAmountForStorage(balanceValue),
      "PAID_AMOUNT": _formatAmountForStorage(paidValue),
      "PENDING_AMOUNT": _formatAmountForStorage(pendingValue),
      "PAYMENT_HISTORY": history,
      "RECHARGE_PLACE": rechargePlace.text,
      "USER_NOTE": userNote.text,
      "PAID_DATE": paidDate,
    };

    await _firestore.collection(collection).doc(addRecord["id"]).set(addRecord);
    if (prevRef != null && (prevPending > 0 || prevBalance > 0)) {
      await prevRef.update({
        "PENDING_AMOUNT": '',
        "BALANCE_AMOUNT": '',
      });
    }

    btnController.success();
    clearRecords();
  }

  Future<void> updateRecord(
      {required String dbID, required QueryDocumentSnapshot snapshot}) async {
    final rechargeValue = _parseAmount(snapshot['RECHARGE_AMOUNT']);
    final existingPaid = _parseAmount(snapshot['PAID_AMOUNT']);
    final newPaid = _parseAmount(newPaidAmount.text);
    final totalPaid = newPaidAmount.text.trim().isEmpty
        ? existingPaid
        : existingPaid + newPaid;
    final ownerId = requireOwnerId();
    final double pendingValue =
        rechargeValue > totalPaid ? (rechargeValue - totalPaid) : 0.0;
    final double balanceValue =
        totalPaid > rechargeValue ? (totalPaid - rechargeValue) : 0.0;

    addRecord = {
      "ownerId": ownerId,
      "BALANCE_AMOUNT": _formatAmountForStorage(balanceValue),
      "PAID_AMOUNT": _formatAmountForStorage(totalPaid),
      "PENDING_AMOUNT": _formatAmountForStorage(pendingValue),
      if (newPaid > 0)
        "PAYMENT_HISTORY": FieldValue.arrayUnion([
          {
            "AMOUNT": _formatAmountForStorage(newPaid),
            "PAID_AT": Timestamp.fromDate(DateTime.now()),
            "NOTE": "புதிதாக கொடுத்தது",
          }
        ]),
      "RECHARGE_PLACE": rechargePlace.text == ''
          ? snapshot['RECHARGE_PLACE']
          : rechargePlace.text,
      "USER_NOTE":
          userNote.text.isEmpty ? snapshot['USER_NOTE'] ?? '' : userNote.text,
      "PAID_DATE": paidDate,
    };
    await _firestore.collection(collection).doc(dbID).update(addRecord);
    btnController.success();
    clearRecords();
  }

  double _parseAmount(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    final text = value
        .toString()
        .replaceAll('Rs.', '')
        .replaceAll('Rs', '')
        .replaceAll(',', '')
        .trim();
    return double.tryParse(text) ?? 0;
  }

  String _formatAmountForStorage(double value) {
    if (value <= 0) return '';
    final rounded = value.round();
    return rounded.toString();
  }

  void clearRecords() {
    Timer(Duration(seconds: 2), () {
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
