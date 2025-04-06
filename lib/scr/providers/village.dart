import 'package:flutter/material.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/totalCounterServices.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/village.dart';
import 'package:mrs_dth_diary_v1/scr/models/totalCustomers.dart';
import 'package:mrs_dth_diary_v1/scr/models/village.dart';

class VillageProvider with ChangeNotifier{

  VillageServices _villageServices = VillageServices();
  TotalCounterServices _totalCounterServices = TotalCounterServices();


   List<VillageModel> village = [];
  List<TotalCustomersFilterize> totalOldCustomersCount = [];
  List<TotalCustomersFilterize> totalNewCustomersCount = [];
  List todayPaymentCount =[];
  List todayExpiredCount =[];
  List totalBalanceCount =[];
  List totalPendingCount =[];
  List totalPaidCount =[];

  TextEditingController editControllerName = TextEditingController();

  VillageProvider.initialize(){
    loadProducts();
  }

  loadProducts() async{
    village = await _villageServices.getVillage();
    totalOldCustomersCount = await _totalCounterServices.getOldUserCount();
    totalNewCustomersCount = await _totalCounterServices.getNewUserCount();
    todayPaymentCount = await _totalCounterServices.getTodayPaymentCount();
    todayExpiredCount = await _totalCounterServices.getTodayExpiredCount();
    totalBalanceCount = await _totalCounterServices.getTotalBalanceCount();
    totalPendingCount = await _totalCounterServices.getTotalPendingCount();
    totalPaidCount = await _totalCounterServices.getTotalPaidCount();
    notifyListeners();
  }

  Future<bool> uploadVillage({String id}) async{
    try{
      Map data = {
        "id": id,
        "name": editControllerName.text.trim(),

      };
      _villageServices.createVillage(data:data);
      return true;
    }catch(e){
      print(e.toString());
      return false;
    }

  }

  clear(){
    editControllerName.clear();
  }


}