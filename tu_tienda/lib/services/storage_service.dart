import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static Future<String?> uploadProductImage(File imageFile) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return null;

      final fileName = DateTime.now().millisecondsSinceEpoch.toString();

      final ref = FirebaseStorage.instance
          .ref()
          .child('products')
          .child(user.uid)
          .child('$fileName.jpg');

      await ref.putFile(imageFile);

      return await ref.getDownloadURL();
    } catch (e) {
      print("Error subiendo imagen: $e");
      return null;
    }
  }
}
