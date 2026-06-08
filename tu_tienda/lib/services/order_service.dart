import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart';

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<OrderModel>> getUserOrders(String userId) async {
    final snapshot = await _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return OrderModel.fromFirestore(doc.id, doc.data());
    }).toList();
  }

  Future<void> updateOrderStatus(
    String orderId,
    String status,
  ) async {
    await _db
    .collection('orders')
    .doc(orderId)
    .update({'status': status,
    });
  }

  Future<List<OrderModel>> getSellerOrders(
    String sellerId,
  ) async {
      final snapshot = await _db
      .collection('orders')
      .orderBy('createdAt', descending: true)
      .get();
      
      return snapshot.docs
      .map((doc) => OrderModel.fromFirestore(
        doc.id,
        doc.data(),
        ),
       )
       .where(
        (order) => order.items.any(
          (item) => item.sellerId == sellerId,
         ),
        )
      .toList();
    }
}
