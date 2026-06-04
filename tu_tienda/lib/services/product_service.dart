import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  //Productos populares
  Future<List<Product>> getPopularProducts() async {
    final snapshot = await _db
        .collection('products')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .get();

    return snapshot.docs
        .map((doc) => Product.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  //Productos destacados
  Future<List<Product>> getFeaturedProducts(String shopId) async {
    final snapshot = await _db
        .collection('products')
        .where('shopId', isEqualTo: shopId)
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => Product.fromFirestore(doc.id, doc.data()))
        .toList();
  }
}
