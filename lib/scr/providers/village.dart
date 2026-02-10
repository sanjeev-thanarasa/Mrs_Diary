import 'package:flutter/material.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/totalCounterServices.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/village.dart';
import 'package:mrs_dth_diary_v1/scr/models/village.dart';

class VillageProvider with ChangeNotifier {
  VillageServices _villageServices = VillageServices();
  TotalCounterServices _totalCounterServices = TotalCounterServices();

  bool isLoading = true;

  List<VillageModel> village = [];
  int villageCount = 0;
  int totalOldCustomersCount = 0;
  int totalNewCustomersCount = 0;
  int todayPaymentCount = 0;
  int todayExpiredCount = 0;
  int totalBalanceCount = 0;
  int totalPendingCount = 0;
  int totalPaidCount = 0;

  TextEditingController editControllerName = TextEditingController();

  VillageProvider.initialize() {
    loadProducts();
  }

  loadProducts() async {
    isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _villageServices.getVillageCount(),
        _totalCounterServices.getOldUserCount(),
        _totalCounterServices.getNewUserCount(),
        _totalCounterServices.getTodayPaymentCount(),
        _totalCounterServices.getTodayExpiredCount(),
        _totalCounterServices.getTotalBalanceCount(),
        _totalCounterServices.getTotalPendingCount(),
        _totalCounterServices.getTotalPaidCount(),
      ]);

      villageCount = results[0];
      totalOldCustomersCount = results[1];
      totalNewCustomersCount = results[2];
      todayPaymentCount = results[3];
      todayExpiredCount = results[4];
      totalBalanceCount = results[5];
      totalPendingCount = results[6];
      totalPaidCount = results[7];
    } catch (_) {
      villageCount = 0;
      totalOldCustomersCount = 0;
      totalNewCustomersCount = 0;
      todayPaymentCount = 0;
      todayExpiredCount = 0;
      totalBalanceCount = 0;
      totalPendingCount = 0;
      totalPaidCount = 0;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshCounts() async {
    await loadProducts();
  }

  Future<bool> uploadVillage({required String id}) async {
    try {
      Map data = {
        "id": id,
        "name": editControllerName.text.trim(),
      };
      _villageServices.createVillage(data: data);
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  clear() {
    editControllerName.clear();
  }
}
