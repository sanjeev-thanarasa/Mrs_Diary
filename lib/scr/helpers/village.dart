import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mrs_dth_diary_v1/scr/models/village.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/owner_service.dart';

class VillageServices {
  String collection = "Villages";
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<VillageModel> searchVillages = [];

  Future createVillage({required Map data}) async {
    final ownerId = requireOwnerId();
    _firestore.collection(collection).doc(data['id']).set({
      "id": data['id'],
      "ownerId": ownerId,
      "name": data['name'],
      "createAt": DateTime.now(),
    });
  }

  Future getVillage() async => _firestore
          .collection(collection)
          .where('ownerId', isEqualTo: requireOwnerId())
          .get()
          .then((result) {
        List<VillageModel> villages = [];
        for (DocumentSnapshot data in result.docs) {
          villages.add(VillageModel.fromSnapshot(data));
        }
        return villages;
      });

  Future<int> getVillageCount() async {
    final snapshot = await _firestore
        .collection(collection)
        .where('ownerId', isEqualTo: requireOwnerId())
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  Future<List<VillageModel>> searchVillage({required String name}) {
    String searchKey = name[0].toUpperCase() + name.substring(1);
    return _firestore
        .collection(collection)
        .where('ownerId', isEqualTo: requireOwnerId())
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
