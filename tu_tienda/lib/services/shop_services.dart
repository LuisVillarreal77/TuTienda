import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shop.dart';

class ShopServices {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Shop>> getShops() async {
    final snapshot = await _db.collection('shops').get();

    return snapshot.docs.map((doc) {
      return Shop.fromFirestore(doc.data(), doc.id);
    }).toList();

  }

  Future<List<Shop>> getFeaturedShops() async {

  final snapshot = await _db
      .collection('shops')
      .where('featured', isEqualTo: true)
      .limit(5)
      .get();

  return snapshot.docs.map((doc) {
    return Shop.fromFirestore(doc.data(), doc.id);
  }).toList();

}
}
