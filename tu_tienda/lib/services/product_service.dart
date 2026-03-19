import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  //Productos populares
  Future<List<Product>> getPopularProducts() async {
    final snapshot = await _db
        .collection('products')
        .where('popular', isEqualTo: true)
        .limit(6)
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
        .get();

    return snapshot.docs
        .map((doc) => Product.fromFirestore(doc.id, doc.data()))
        .toList();
  }
}
