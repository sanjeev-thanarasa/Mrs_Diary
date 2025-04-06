

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mrs_dth_diary_v1/scr/models/village.dart';

class VillageServices {
  String collection = "Villages";
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<VillageModel> searchVillages = [];

  Future createVillage({Map data})async {
    _firestore.collection(collection).doc(data['id']).set({
      "id": data['id'],
      "name": data['name'],
      "createAt" : DateTime.now(),

    });
  }

  Future getVillage() async =>
      _firestore.collection(collection).get().then((result) {
        List<VillageModel> villages = [];
        for (DocumentSnapshot data in result.docs) {
          villages.add(VillageModel.fromSnapshot(data));
        }
        return villages;
      });

  Future<List<VillageModel>> searchVillage({String name}) {
    String searchKey = name[0].toUpperCase() + name.substring(1);
    return _firestore
        .collection(collection)
        .orderBy("name")
        .startAt([searchKey])
        .endAt([searchKey + '\uf8ff'])
        .get()
        .then((result) {
      for (DocumentSnapshot product in result.docs) {
        searchVillages.add(VillageModel.fromSnapshot(product));
      }
      return searchVillages;
    });
  }
}