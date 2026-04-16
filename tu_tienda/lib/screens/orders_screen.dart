import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Debes iniciar sesión")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis pedidos"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          //Cargando
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          //sin datos
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No tienes pedidos aun",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final data = order.data() as Map<String, dynamic>;

              final total = data['total'] ?? 0;
              final items = data['items'] ?? [];
              final timestamp = data['createdAt'];

              String fecha = "Sin fecha";
              if (timestamp != null && timestamp is Timestamp) {
                final date = timestamp.toDate();
                fecha =
                    "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}";
              }

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: const Icon(Icons.shopping_bag, color: Colors.orange),
                  title: Text("Pedido #${index + 1}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Total: \$${total.toStringAsFixed(0)}"),
                      Text("Productos: ${items.length}"),
                      Text("Fecha: $fecha"),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
