import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  String getStatusLabel(String status) {
    switch (status) {
      case "pending":
        return "Pendiente";

      case "processing":
        return "En preparacion";

      case "shipped":
        return "Enviado";

      case "completed":
        return "Entregado";

      default:
        return status;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "pending":
        return Colors.orange;

      case "processing":
        return Colors.blue;

      case "shipped":
        return Colors.purple;

      case "completed":
        return Colors.green;

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalle del pedido"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final items = data['items'] as List<dynamic>;

          final sellerStatuses = Map<String, dynamic>.from(
            data['sellerStatuses'] ?? {},
          );

          final total = data['total'] ?? 0;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                "Pedido #${orderId.substring(0, 8)}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Text("Total: \$${total.toStringAsFixed(0)}",
              style: const TextStyle(fontSize: 18),
              ),

                const SizedBox(height: 20),

              const Text(
                "Productos",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              ...items.map((item) {
                final sellerId = item['sellerId'];

                final status = sellerStatuses[sellerId] ?? "pending";

                return Card(
                  margin: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadiusGeometry.circular(8),
                        child: Image.network(
                          item['image'],
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(item['shopName']),

                            Text("Cantidad: ${item['quantity']}"),

                            const SizedBox(height: 6),

                            Chip(
                              label: Text(getStatusLabel(status)),
                              backgroundColor: getStatusColor(
                                status,
                              ).withValues(alpha: 0.15),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
