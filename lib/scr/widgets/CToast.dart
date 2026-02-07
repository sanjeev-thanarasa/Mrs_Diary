import 'package:fluttertoast/fluttertoast.dart';

class CToast {
  static void show({
    required String message,
    ToastGravity gravity = ToastGravity.CENTER,
    Toast toastLength = Toast.LENGTH_SHORT,
  }) {
    Fluttertoast.showToast(
      msg: message,
      gravity: gravity,
      toastLength: toastLength,
    );
  }
}
