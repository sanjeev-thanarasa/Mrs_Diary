import 'package:cloud_firestore/cloud_firestore.dart';

class VillageModel {
  static const ID = "id";
  static const NAME = "name";
  static const CREATE_AT = "createAt";


  String _id;
  String _name;
  DateTime _createAt;
  String get id => _id;
  String get name => _name;
  DateTime get createAt => _createAt;

  VillageModel.fromSnapshot(DocumentSnapshot snapshot) {
    _id = snapshot.data()[ID];
    _name = snapshot.data()[NAME];
    _createAt = snapshot.data()[CREATE_AT].toDate();
  }
}