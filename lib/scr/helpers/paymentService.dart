import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/owner_service.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class PaymentServices {
  final RoundedLoadingButtonController btnController =
      RoundedLoadingButtonController();

  TextEditingController createRecordDate = TextEditingController();
  TextEditingController rechargeAmount = TextEditingController();
  TextEditingController giveAmount = TextEditingController();
  TextEditingController newGiveAmount = TextEditingController();
  TextEditingController pendingAmount = TextEditingController();
  TextEditingController balanceAmount = TextEditingController();
  TextEditingController userNote = TextEditingController();
  TextEditingController userNote2 = TextEditingController();
  TextEditingController packageName = TextEditingController();
  TextEditingController pendingDateController = TextEditingController();
  TextEditingController expiredDateController = TextEditingController();

  DateTime? pendingDate;
  DateTime? expiredDate;
  DateTime? createDate;

  bool pending = false;
  bool balance = false;

  final FirebaseFirestore databaseReference = FirebaseFirestore.instance;
  Map<String, dynamic> addPayment = {};
  Map<String, dynamic> updatePayment = {};

  String collection = "PaymentRecords";

  Future<DateTime?> getLatestCreateAt({required String userId}) async {
    final ownerId = requireOwnerId();
    final latest = await databaseReference
        .collection(collection)
        .where('ownerId', isEqualTo: ownerId)
        .where("USER_ID", isEqualTo: userId)
        .orderBy("CREATE_AT", descending: true)
        .limit(1)
        .get();

    if (latest.docs.isEmpty) return null;
    final data = latest.docs.first.data();
    final createdAt = data["CREATE_AT"];
    if (createdAt is Timestamp) return createdAt.toDate();
    if (createdAt is DateTime) return createdAt;
    return null;
  }

  Future<bool> createPaymentRecord({required String userId}) async {
    final rechargeValue = _parseAmount(rechargeAmount.text);
    final paidValue = _parseAmount(giveAmount.text);
    final ownerId = requireOwnerId();

    double prevBalance = 0;
    DocumentReference<Map<String, dynamic>>? prevRef;

    final latest = await databaseReference
        .collection(collection)
        .where('ownerId', isEqualTo: ownerId)
        .where("USER_ID", isEqualTo: userId)
        .orderBy("CREATE_AT", descending: true)
        .limit(1)
        .get();

    if (latest.docs.isNotEmpty) {
      final doc = latest.docs.first;
      final data = doc.data();
      prevRef = doc.reference;
      prevBalance = _parseAmount(data["BALANCE_AMOUNT"]);
    }

    final paidRemaining = paidValue;

    if (prevRef != null) {
      final updates = <String, dynamic>{};
      if (prevBalance > 0) {
        updates["BALANCE_AMOUNT"] = '';
        updates["PAYMENT_HISTORY"] = FieldValue.arrayUnion([
          {
            "AMOUNT": _formatAmountForStorage(prevBalance),
            "PAID_AT": Timestamp.fromDate(createDate ?? DateTime.now()),
            "NOTE": "Balance moved to next payment",
          }
        ]);
      }
      if (updates.isNotEmpty) {
        await prevRef.update(updates);
      }
    }

    final double appliedBalance = prevBalance > 0
        ? (prevBalance >= rechargeValue ? rechargeValue : prevBalance)
        : 0.0;
    final remainingBalance =
        prevBalance > appliedBalance ? (prevBalance - appliedBalance) : 0;

    final effectivePaid = paidRemaining + appliedBalance;

    double newPending = 0;
    double newBalance = 0;
    if (effectivePaid < rechargeValue) {
      newPending = rechargeValue - effectivePaid;
    } else if (effectivePaid > rechargeValue) {
      newBalance = effectivePaid - rechargeValue;
    }

    if (remainingBalance > 0) {
      newBalance += remainingBalance;
    }

    double appliedToPreviousPending = 0;
    if (newBalance > 0) {
      final result = await _applyBalanceToPending(
        ownerId: ownerId,
        userId: userId,
        availableBalance: newBalance,
        paidAt: createDate ?? DateTime.now(),
      );
      appliedToPreviousPending = result.applied;
      newBalance = result.remaining;
    }

    final history = <Map<String, dynamic>>[];
    if (paidRemaining > 0) {
      history.add({
        "AMOUNT": _formatAmountForStorage(paidRemaining),
        "PAID_AT": Timestamp.fromDate(createDate ?? DateTime.now()),
        "NOTE": "Paid amount",
      });
    }
    if (appliedBalance > 0) {
      history.add({
        "AMOUNT": _formatAmountForStorage(appliedBalance),
        "PAID_AT": Timestamp.fromDate(createDate ?? DateTime.now()),
        "NOTE": "Balance from previous payment",
      });
    }
    if (appliedToPreviousPending > 0) {
      history.add({
        "AMOUNT": _formatAmountForStorage(appliedToPreviousPending),
        "PAID_AT": Timestamp.fromDate(createDate ?? DateTime.now()),
        "NOTE": "Applied to previous pending",
      });
    }

    addPayment = {
      "ownerId": ownerId,
      "USER_ID": userId,
      "PACKAGE_NAME": packageName.text,
      "AMOUNT": _formatAmountForStorage(rechargeValue),
      "PAID_AMOUNT": _formatAmountForStorage(effectivePaid),
      "PENDING_AMOUNT": _formatAmountForStorage(newPending),
      "PENDING_DATE": newPending > 0 ? pendingDate : null,
      "BALANCE_AMOUNT": _formatAmountForStorage(newBalance),
      "PAYMENT_HISTORY": history,
      "USER_NOTE": userNote.text,
      "USER_NOTE2": userNote2.text,
      "CREATE_AT": createDate ?? DateTime.now(),
      "EXPIRED_AT": expiredDate,
    };

    await databaseReference.collection(collection).add(addPayment);
    btnController.success();
    clearRecords();
    return true;
  }

  Future<_BalanceApplyResult> _applyBalanceToPending({
    required String ownerId,
    required String userId,
    required double availableBalance,
    required DateTime paidAt,
  }) async {
    if (availableBalance <= 0) {
      return const _BalanceApplyResult(applied: 0, remaining: 0);
    }

    final snapshot = await databaseReference
        .collection(collection)
        .where('ownerId', isEqualTo: ownerId)
        .where('USER_ID', isEqualTo: userId)
        .get();

    final docs = snapshot.docs.toList();
    docs.sort((a, b) {
      final aDate = a.data()["CREATE_AT"];
      final bDate = b.data()["CREATE_AT"];
      DateTime? aDt;
      DateTime? bDt;
      if (aDate is Timestamp) {
        aDt = aDate.toDate();
      } else if (aDate is DateTime) {
        aDt = aDate;
      }
      if (bDate is Timestamp) {
        bDt = bDate.toDate();
      } else if (bDate is DateTime) {
        bDt = bDate;
      }
      if (aDt == null && bDt == null) return 0;
      if (aDt == null) return -1;
      if (bDt == null) return 1;
      return aDt.compareTo(bDt);
    });

    double remaining = availableBalance;
    double appliedTotal = 0;

    for (final doc in docs) {
      if (remaining <= 0) break;
      final data = doc.data();
      final pendingValue = _parseAmount(data["PENDING_AMOUNT"]);
      if (pendingValue <= 0) continue;

      final paidValue = _parseAmount(data["PAID_AMOUNT"]);
      final applied = pendingValue >= remaining ? remaining : pendingValue;
      final newPending = pendingValue - applied;
      final newPaid = paidValue + applied;

      await doc.reference.update({
        "PAID_AMOUNT": _formatAmountForStorage(newPaid),
        "PENDING_AMOUNT": _formatAmountForStorage(newPending),
        "PENDING_DATE": newPending > 0 ? data["PENDING_DATE"] : null,
        "PAYMENT_HISTORY": FieldValue.arrayUnion([
          {
            "AMOUNT": _formatAmountForStorage(applied),
            "PAID_AT": Timestamp.fromDate(paidAt),
            "NOTE": "Pending cleared by newer payment",
          }
        ]),
      });

      remaining -= applied;
      appliedTotal += applied;
    }

    return _BalanceApplyResult(applied: appliedTotal, remaining: remaining);
  }

  Future<void> updatePaymentRecord(
      {required QueryDocumentSnapshot snapshot}) async {
    final rechargeValue = _parseAmount(snapshot["AMOUNT"]);
    final prevPaid = _parseAmount(snapshot["PAID_AMOUNT"]);
    final additionalPaid = _parseAmount(newGiveAmount.text);
    final totalPaid = prevPaid + additionalPaid;
    final ownerId = requireOwnerId();

    double pendingValue = 0;
    double balanceValue = 0;
    if (totalPaid < rechargeValue) {
      pendingValue = rechargeValue - totalPaid;
    } else if (totalPaid > rechargeValue) {
      balanceValue = totalPaid - rechargeValue;
    }

    updatePayment = {
      "ownerId": ownerId,
      // "USER_ID": snapshot["USER_ID"],
      "PACKAGE_NAME": packageName.text,
      "AMOUNT": rechargeAmount.text,

      "PAID_AMOUNT": _formatAmountForStorage(totalPaid),
      "PENDING_AMOUNT": _formatAmountForStorage(pendingValue),
      "PENDING_DATE": pendingValue > 0 ? pendingDate : null,
      "BALANCE_AMOUNT": _formatAmountForStorage(balanceValue),
      "USER_NOTE": userNote.text,
      "USER_NOTE2": userNote2.text,
      "CREATE_AT": createDate,
      "EXPIRED_AT": expiredDate,
    };
    if (additionalPaid > 0) {
      updatePayment["PAYMENT_HISTORY"] = FieldValue.arrayUnion([
        {
          "AMOUNT": _formatAmountForStorage(additionalPaid),
          "PAID_AT": Timestamp.fromDate(DateTime.now()),
        }
      ]);
    }
    await databaseReference
        .collection(collection)
        .doc(snapshot.id)
        .update(updatePayment);
    btnController.success();
    clearRecords();
  }

  void clearRecords() {
    Timer(Duration(seconds: 2), () {
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

      pending = false;
      balance = false;
    });
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
}

class _BalanceApplyResult {
  final double applied;
  final double remaining;

  const _BalanceApplyResult({required this.applied, required this.remaining});
}
