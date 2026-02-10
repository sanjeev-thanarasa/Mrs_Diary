import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/owner_service.dart';

class TotalCounterServices {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime _dateTodayStart =
      DateTime.parse("${DateFormat('yyyyMMdd').format(DateTime.now())}T000000");
  DateTime _dateTodayEnd =
      DateTime.parse("${DateFormat('yyyyMMdd').format(DateTime.now())}T235959");

  Future<int> _count(Query query) async {
    try {
      final snapshot = await query.count().get();
      return snapshot.count ?? 0;
    } on FirebaseException {
      return 0;
    } catch (_) {
      return 0;
    }
  }

  Future<int> getOldUserCount() async {
    final ownerId = currentOwnerId();
    if (ownerId == null) return 0;
    return _count(
      _firestore.collection("OldUser").where('ownerId', isEqualTo: ownerId),
    );
  }

  Future<int> getNewUserCount() async {
    final ownerId = currentOwnerId();
    if (ownerId == null) return 0;
    return _count(
      _firestore.collection("NewUser").where('ownerId', isEqualTo: ownerId),
    );
  }

  Future<int> getTodayPaymentCount() async {
    final ownerId = currentOwnerId();
    if (ownerId == null) return 0;
    return _count(
      _firestore
          .collection("PaymentRecords")
          .where('ownerId', isEqualTo: ownerId)
          .where("PENDING_DATE", isGreaterThanOrEqualTo: _dateTodayStart)
          .where("PENDING_DATE", isLessThanOrEqualTo: _dateTodayEnd),
    );
  }

  Future<int> getTodayExpiredCount() async {
    final ownerId = currentOwnerId();
    if (ownerId == null) return 0;
    return _count(
      _firestore
          .collection("PaymentRecords")
          .where('ownerId', isEqualTo: ownerId)
          .where("EXPIRED_AT", isGreaterThanOrEqualTo: _dateTodayStart)
          .where("EXPIRED_AT", isLessThanOrEqualTo: _dateTodayEnd),
    );
  }

  Future<int> getTotalBalanceCount() async {
    final ownerId = currentOwnerId();
    if (ownerId == null) return 0;
    return _count(
      _firestore
          .collection("PaymentRecords")
          .where('ownerId', isEqualTo: ownerId)
          .where("BALANCE_AMOUNT", isNotEqualTo: ""),
    );
  }

  Future<int> getTotalPendingCount() async {
    final ownerId = currentOwnerId();
    if (ownerId == null) return 0;
    return _count(
      _firestore
          .collection("PaymentRecords")
          .where('ownerId', isEqualTo: ownerId)
          .where("PENDING_AMOUNT", isNotEqualTo: ""),
    );
  }

  Future<int> getTotalPaidCount() async {
    final ownerId = currentOwnerId();
    if (ownerId == null) return 0;
    return _count(
      _firestore
          .collection("PaymentRecords")
          .where('ownerId', isEqualTo: ownerId)
          .where("PAID_AMOUNT", isNotEqualTo: ""),
    );
  }
}
