import 'package:firebase_auth/firebase_auth.dart';

String? currentOwnerId() {
  return FirebaseAuth.instance.currentUser?.uid;
}

String requireOwnerId() {
  return FirebaseAuth.instance.currentUser?.uid ?? '';
}
