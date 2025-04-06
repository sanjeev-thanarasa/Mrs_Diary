import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> uploadingData(String _productName, String _productPrice,
    String _imageUrl, bool _isFavourite) async {
  // ignore: deprecated_member_use
  await FirebaseFirestore.instance.collection("products").add({
    'productName': _productName,
    'productPrice': _productPrice,
    'imageUrl': _imageUrl,
    'isFavourite': _isFavourite,
  });
}


Future<void> updateProduct(
  {@required String collectionName,
  @required String id,
  @required Map<String,dynamic> updateData,
 }
    ) async {
  // ignore: deprecated_member_use
  await FirebaseFirestore.instance
      .collection(collectionName)
      // ignore: deprecated_member_use
      .doc(id)
      // ignore: deprecated_member_use
      .update(updateData);
}
Future<void> updateSingleProduct(
    {@required String collectionName,
      @required String id,
      @required String updateField,
      @required bool updateData,
    }
    ) async {
  await FirebaseFirestore.instance
      .collection(collectionName)
      .doc(id)
      .update({updateField:updateData});
}

Future<void> deleteProduct({String id, String collectionName}) async {
  await FirebaseFirestore.instance
      .collection(collectionName)
      .doc(id)
      .delete();
}

formatDate(DateTime dateTime){
  return dateTime.toIso8601String().split('T').first;
}
showSnackbar(String title , String message){
  Get.snackbar(title, message ,
      colorText: Colors.white,
      backgroundColor: Colors.grey[900],
      snackPosition: SnackPosition.BOTTOM);
}
showdialog(String title ,Widget content){
  Get.defaultDialog(
    title: title,
    content: content
  );
}

showBottomsheet(Widget bottomsheet){
  Get.bottomSheet(bottomsheet);
}
