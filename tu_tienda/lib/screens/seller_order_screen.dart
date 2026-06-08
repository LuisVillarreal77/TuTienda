import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SellerOrderScreen extends StatelessWidget {
  const SellerOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print("SellerOrderScreen cargada");
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Debes iniciar sesión")));
    }

    final sellerId = user.uid;
    print("SELLER ACTUAL: $sellerId");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pedidos recibidos"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('sellerIds', arrayContains: sellerId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          print("Snapshot recibido");
          //Cargando
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          //sin datos
          if (!snapshot.hasData) {
            return const SizedBox();
          }

          final sellerOrders = snapshot.data!.docs;
          print("PEDIDOS ENCONTRADOS: ${sellerOrders.length}");

          if (sellerOrders.isEmpty) {
            return const Center(
              child: Text(
                "Aun no tienes pedidos",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            itemCount: sellerOrders.length,
            itemBuilder: (context, index) {
              final order = sellerOrders[index];

              final data = order.data() as Map<String, dynamic>;

              final items = data['items'] as List<dynamic>;

              final total = data['total'] ?? 0;

              final customerEmail = data['userEmail'] ?? 'Correo no disponible';

              final sellerStatuses =
                  data['sellerStatuses'] as Map<String, dynamic>? ?? {};

              final status = sellerStatuses[sellerId] ?? 'pending';

              final timestamp = data['createdAt'];

              String fecha = "Sin fecha";

              if (timestamp != null && timestamp is Timestamp) {
                final date = timestamp.toDate();

                fecha =
                    "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}";
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Pedido ${order.id.substring(0, 8)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text("Cliente: $customerEmail"),

                      Text("Fecha: $fecha"),

                      Text("Total: \$${total.toStringAsFixed(0)}"),

                      const Divider(),

                      const Text(
                        "Productos",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 6),

                      ...items
                          .where((item) => item['sellerId'] == sellerId)
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                "● ${item['name']} x${item['quantity']}",
                              ),
                            ),
                          ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          const Text(
                            "Estado:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: status,
                              items: const [
                                DropdownMenuItem(
                                  value: 'pending',
                                  child: Text('Pendiente'),
                                ),
                                DropdownMenuItem(
                                  value: 'processing',
                                  child: Text('En preparación'),
                                ),
                                DropdownMenuItem(
                                  value: 'shipped',
                                  child: Text('Enviado'),
                                ),
                                DropdownMenuItem(
                                  value: 'completed',
                                  child: Text('Entregado'),
                                ),
                              ],
                              onChanged: (value) async {
                                if (value == null) return;

                                await FirebaseFirestore.instance
                                    .collection('orders')
                                    .doc(order.id)
                                    .update({'sellerStatuses.$sellerId': value});
                              },
                            ),
                          ),
                        ],
                      ),
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
