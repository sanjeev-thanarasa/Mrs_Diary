import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mrs_dth_diary_v1/scr/models/totalCustomers.dart';

class TotalCounterServices {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime _dateTodayStart = DateTime.parse("${DateFormat('yyyyMMdd').format(DateTime.now())}T000000");
  DateTime _dateTodayEnd = DateTime.parse("${DateFormat('yyyyMMdd').format(DateTime.now())}T235959");


  Future getOldUserCount() async =>
      _firestore.collection("OldUser").get().then((result) {
        List<TotalCustomersFilterize> totOldCustomers = [];
        for (DocumentSnapshot data in result.docs) {
          totOldCustomers.add(TotalCustomersFilterize.fromSnapshot(data));
        }
        return totOldCustomers;
      });

  Future getNewUserCount() async =>
      _firestore.collection("NewUser").get().then((result) {
        List<TotalCustomersFilterize> totNewCustomers = [];
        for (DocumentSnapshot data in result.docs) {
          totNewCustomers.add(TotalCustomersFilterize.fromSnapshot(data));
        }
        return totNewCustomers;
      });

  Future getTodayPaymentCount() async =>
      _firestore.collection("PaymentRecords")
          .where("PENDING_DATE",  isGreaterThanOrEqualTo:_dateTodayStart)
          .where("PENDING_DATE",  isLessThanOrEqualTo:_dateTodayEnd)
          .get().then((result) {
        List todayPaymentCount =[];
        for (DocumentSnapshot data in result.docs) {
          todayPaymentCount.add(data);
        }
        return todayPaymentCount;
      });

  Future getTodayExpiredCount() async =>
      _firestore.collection("PaymentRecords")
          .where("EXPIRED_AT",  isGreaterThanOrEqualTo:_dateTodayStart)
          .where("EXPIRED_AT",  isLessThanOrEqualTo:_dateTodayEnd)
          .get().then((result) {
        List todayExpiredCount =[];
        for (DocumentSnapshot data in result.docs) {
          todayExpiredCount.add(data);
        }
        return todayExpiredCount;
      });

  Future getTotalBalanceCount() async =>
      _firestore.collection("PaymentRecords")
          .where("BALANCE_AMOUNT",  isNotEqualTo: "")
          .get().then((result) {
        List totalBalanceCount =[];
        for (DocumentSnapshot data in result.docs) {
          totalBalanceCount.add(data);
        }
        return totalBalanceCount;
      });

  Future getTotalPendingCount() async =>
      _firestore.collection("PaymentRecords")
          .where("PENDING_AMOUNT",  isNotEqualTo: "")
          .get().then((result) {
        List totalPendingCount =[];
        for (DocumentSnapshot data in result.docs) {
          totalPendingCount.add(data);
        }
        return totalPendingCount;
      });

  Future getTotalPaidCount() async =>
      _firestore.collection("PaymentRecords")
          .where("PAID_AMOUNT",  isNotEqualTo: "")
          .get().then((result) {
        List totalPaidCount =[];
        for (DocumentSnapshot data in result.docs) {
          totalPaidCount.add(data);
        }
        return totalPaidCount;
      });
}