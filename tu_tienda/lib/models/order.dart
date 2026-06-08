import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_item.dart';

class OrderModel {
  final String id;
  final String userId;
  final String userEmail;
  final double total;
  final String status;
  final Timestamp? createdAt;
  final List<OrderItem> items;

  OrderModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.items,
  });

  factory OrderModel.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return OrderModel(
      id: id,
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      total: (data['total'] as num?)?.toDouble() ?? 0,
      status: data['status'] ?? 'pending',
      createdAt: data['createdAt'],
      items: (data['items'] as List<dynamic>? ?? [])
          .map(
            (item) =>
                OrderItem.fromMap(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
