/*
class FilterUser {
  bool _blackList;
  bool _noteList;
  String _address;
  String _area;
  String _dishNumber;
  String _dishType;
  String _id;
  String _mobileNo;
  String _mobileNo2;
  String _name;

  FilterUser(
      this._blackList,
      this._noteList,
      this._address,
      this._area,
      this._dishNumber,
      this._dishType,
      this._id,
      this._mobileNo,
      this._mobileNo2,
      this._name
      );





  FilterUser.fromMap(Map<String, dynamic> map) {
    this._blackList =map['BlackList'];
    this._noteList =map['NoteList'];
    this._address =map['address'];
    this._area =map['area'];
    this._dishNumber =map['dishNumber'];
    this._dishType =map['dishType'];
    this._id =map['id'];
    this._mobileNo =map['mobileNo'];
    this._mobileNo2 =map['mobileNo2'];
    this._name =map['name'];
  }

  bool get blackList => _blackList;
  set blackList(bool value) {
    _blackList = value;
  }

  bool get noteList => _noteList;
  set noteList(bool value) {
    _noteList = value;
  }

  String get address =>_address;
  set address(String value){
    _address=value;
  }

  String get area =>_area;
  set area(String value){
    _area=value;
  }

  String get dishNumber =>_dishNumber;
  set dishNumber(String value){
    _dishNumber=value;
  }

  String get dishType =>_dishType;
  set dishType(String value){
    _dishType=value;
  }

  String get id =>_id;

  String get mobileNo =>_mobileNo;
  set mobileNo(String value){
    _mobileNo=value;
  }

  String get mobileNo2 =>_mobileNo2;
  set mobileNo2(String value){
    _mobileNo2=value;
  }

  String get name =>_name;
  set name(String value){
    _name=value;
  }


  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map<String, dynamic>();
    map['BlackList'] = this.blackList;
    map['NoteList'] = this.noteList;
    map['address'] = this.address;
    map['area'] = this.area;
    map['dishNumber'] = this.dishNumber;
    map['dishType'] = this.dishType;
    map['id'] = this._id;
    map['mobileNo'] = this.mobileNo;
    map['mobileNo2'] = this.mobileNo2;
    map['name'] = this.name;

    return map;
  }
}
*/
import 'package:cloud_firestore/cloud_firestore.dart';

class FilterUser {
  // String title;
  // DateTime startDate;
  // DateTime endDate;
  // double budget;
  // Map budgetTypes;
  // String travelType;
  // String photoReference;
  // String notes;
  // String documentId;
  // double saved;

  bool blackList;
  bool noteList;
  String address;
  String area;
  String dishNumber;
  String dishType;
  String id;
  String mobileNo;
  String mobileNo2;
  String name;
  DateTime createAt;


  FilterUser(this.blackList,
      this.noteList,
      this.address,
      this.area,
      this.dishNumber,
      this.dishType,
      this.id,
      this.mobileNo,
      this.mobileNo2,
      this.name,
      this.createAt);

  // formatting for upload to Firebase when creating the trip
  Map<String, dynamic> toJson() =>
      {
        'BlackList': blackList,
        'NoteList': noteList,
        'address': address,
        'area': area,
        'dishNumber': dishNumber,
        'dishType': dishType,
        'id': id,
        'mobileNo': mobileNo,
        'mobileNo2': mobileNo2,
        'name': name,
        'createAt': createAt,

        // 'title': title,
        // 'startDate': startDate,
        // 'endDate': endDate,
        // 'budget': budget,
        // 'budgetTypes': budgetTypes,
        // 'travelType': travelType,
        // 'photoReference': photoReference,
      };

  // creating a Trip object from a firebase snapshot
  FilterUser.fromSnapshot(DocumentSnapshot snapshot){
    blackList = snapshot['BlackList'];
    noteList = snapshot['NoteList'];
    address= snapshot['address'];
    area = snapshot['area'];
    dishNumber = snapshot['dishNumber'];
    dishType = snapshot['dishType'];
    id = snapshot['id'];
    mobileNo = snapshot['mobileNo'];
    mobileNo2 = snapshot['mobileNo2'];
    name = snapshot['name'];
    createAt = snapshot['createAt'].toDate();
  }




 // blackList = snapshot['BlackList'],
//       noteList = snapshot['startDate'].toDate(),
//       address = snapshot['endDate'].toDate(),
//       budget = snapshot['budget'],
//       budgetTypes = snapshot['budgetTypes'],
//       travelType = snapshot['travelType'],
//       photoReference = snapshot['photoReference'],
//       notes = snapshot['notes'],
//       documentId = snapshot.documentID,
//       saved = snapshot['saved'];


// Map<String, Icon> types() => {
//   "car": Icon(Icons.directions_car, size: 50),
//   "bus": Icon(Icons.directions_bus, size: 50),
//   "train": Icon(Icons.train, size: 50),
//   "plane": Icon(Icons.airplanemode_active, size: 50),
//   "ship": Icon(Icons.directions_boat, size: 50),
//   "other": Icon(Icons.directions, size: 50),
// };

// return the google places image
// Image getLocationImage() {
//   final baseUrl = "https://maps.googleapis.com/maps/api/place/photo";
//   final maxWidth = "1000";
//   final url = "$baseUrl?maxwidth=$maxWidth&photoreference=$photoReference&key=$PLACES_API_KEY";
//   return Image.network(url, fit: BoxFit.cover);
// }
//
// int getTotalTripDays() {
//   return endDate.difference(startDate).inDays;
// }
//
// int getDaysUntilTrip() {
//   int diff = startDate.difference(DateTime.now()).inDays;
//   if (diff < 0) {
//     diff = 0;
//   }
//   return diff;
//}
}

