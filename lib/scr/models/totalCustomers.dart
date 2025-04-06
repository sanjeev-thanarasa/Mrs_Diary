import 'package:cloud_firestore/cloud_firestore.dart';

class TotalCustomersFilterize {

  String dishNumber;
  String dishType;
  String mobileNo;
  String mobileNo2;
  String name;
  String villageName;
  // bool blackList;
  // bool noteList;


  TotalCustomersFilterize(
      this.dishNumber,
      this.dishType,
      this.mobileNo,
      this.mobileNo2,
      this.villageName,
      // this.blackList,
      // this.noteList,
      this.name,);

  // formatting for upload to Firebase when creating the trip
  Map<String, dynamic> toJson() =>
      {
        'dishNumber': dishNumber,
        'dishType': dishType,
        'mobileNo': mobileNo,
        'mobileNo2': mobileNo2,
        'name': name,
        'area' : villageName,
        // 'BlackList' : blackList ,
        // 'NoteList' : noteList,
      };

  TotalCustomersFilterize.fromSnapshot(DocumentSnapshot snapshot){
    dishNumber = snapshot['dishNumber'] ?? '';
    dishType = snapshot['dishType'] ?? '';
    mobileNo = snapshot['mobileNo'] ?? '';
    mobileNo2 = snapshot['mobileNo2'] ?? '';
    name = snapshot['name'] ?? '';
    villageName = snapshot['area'] ?? '';
    // blackList = snapshot['BlackList'] ?? false;
    // noteList = snapshot['NoteList'] ?? false;
  }
}

