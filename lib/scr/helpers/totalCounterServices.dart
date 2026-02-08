import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TotalCounterServices {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime _dateTodayStart =
      DateTime.parse("${DateFormat('yyyyMMdd').format(DateTime.now())}T000000");
  DateTime _dateTodayEnd =
      DateTime.parse("${DateFormat('yyyyMMdd').format(DateTime.now())}T235959");

  Future<int> _count(Query query) async {
    final snapshot = await query.count().get();
    return snapshot.count ?? 0;
  }

  Future<int> getOldUserCount() async =>
      _count(_firestore.collection("OldUser"));

  Future<int> getNewUserCount() async =>
      _count(_firestore.collection("NewUser"));

  Future<int> getTodayPaymentCount() async => _count(
        _firestore
            .collection("PaymentRecords")
            .where("PENDING_DATE", isGreaterThanOrEqualTo: _dateTodayStart)
            .where("PENDING_DATE", isLessThanOrEqualTo: _dateTodayEnd),
      );

  Future<int> getTodayExpiredCount() async => _count(
        _firestore
            .collection("PaymentRecords")
            .where("EXPIRED_AT", isGreaterThanOrEqualTo: _dateTodayStart)
            .where("EXPIRED_AT", isLessThanOrEqualTo: _dateTodayEnd),
      );

  Future<int> getTotalBalanceCount() async => _count(
        _firestore
            .collection("PaymentRecords")
            .where("BALANCE_AMOUNT", isNotEqualTo: ""),
      );

  Future<int> getTotalPendingCount() async => _count(
        _firestore
            .collection("PaymentRecords")
            .where("PENDING_AMOUNT", isNotEqualTo: ""),
      );

  Future<int> getTotalPaidCount() async => _count(
        _firestore
            .collection("PaymentRecords")
            .where("PAID_AMOUNT", isNotEqualTo: ""),
      );
}
