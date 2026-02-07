import 'package:cloud_firestore/cloud_firestore.dart';

class VillageModel {
  static const ID = "id";
  static const NAME = "name";
  static const CREATE_AT = "createAt";

  late String _id;
  late String _name;
  late DateTime _createAt;
  String get id => _id;
  String get name => _name;
  DateTime get createAt => _createAt;

  VillageModel.fromSnapshot(DocumentSnapshot? snapshot) {
    if (snapshot != null && snapshot.data() != null) {
      final data = snapshot.data() as Map<String, dynamic>;
      _id = data[ID];
      _name = data[NAME];
      _createAt = data[CREATE_AT].toDate();
    }
  }
}
