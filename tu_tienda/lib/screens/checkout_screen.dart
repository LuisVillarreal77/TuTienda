import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tu_tienda/admin/services/telemetry_service.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final cartItems = cart.cartItems;

    double totalProducts = cart.totalPrice;
    double total = cart.totalPrice + 15000;

    return Scaffold(
      appBar: AppBar(title: const Text("Resumen de compra")),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              //lista de productos
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    final product = item.product;

                    return ListTile(
                      leading: Image.network(
                        product.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(product.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Precio: \$${product.price}'),
                          Text('Cantidad: ${item.quantity}'),
                          Text(
                            'Subtotal: \$${(product.price * item.quantity).toStringAsFixed(0)}',
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Productos: ', style: TextStyle(fontSize: 18)),
                  Text(
                    '\$${totalProducts.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                ],
              ),

              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Envio: ', style: TextStyle(fontSize: 18)),
                  Text(
                    '\$15000',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                ],
              ),

              const Divider(),

              //total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total: ', style: TextStyle(fontSize: 18)),
                  Text(
                    '\$${total.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              //Boton confirmar compra
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _confirmOrder(context, cart);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Confirmar compra'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmOrder(BuildContext context, CartProvider cart) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Debes iniciar sesión")));
      return;
    }

    TelemetryService.sendEvent(
      eventType: 'purchase_confirmed',
      details: 'Usuario ${user.email} confirmó un pedido',
    );

    try {
      for (final item in cart.cartItems) {
        final productDoc = await FirebaseFirestore.instance
            .collection('products')
            .doc(item.product.id)
            .get();

        if (!productDoc.exists) {
          throw Exception('${item.product.name} ya no existe');
        }

        final currentStock = productDoc['stock'] ?? 0;

        if (currentStock < item.quantity) {
          throw Exception(
            '${item.product.name} ya no tiene unidades disponibles',
          );
        }
      }

      final sellerStatuses = {};

      for (final item in cart.cartItems) {
        sellerStatuses[item.product.sellerId] = "pending";
      }

      final order = {
        "userId": user.uid,
        "userEmail": user.email,
        "total": cart.totalPrice,
        "status": "pending",
        "createdAt": FieldValue.serverTimestamp(),

        "sellerIds": cart.cartItems
            .map((item) => item.product.sellerId)
            .toSet()
            .toList(),

        "sellerStatuses": sellerStatuses,

        "items": cart.cartItems.map((item) {
          return {
            "productId": item.product.id,
            "name": item.product.name,
            "price": item.product.price,
            "quantity": item.quantity,
            "image": item.product.imageUrl,
            "shopId": item.product.shopId,
            "shopName": item.product.shopName,
            "sellerId": item.product.sellerId,
          };
        }).toList(),
      };

      await FirebaseFirestore.instance.collection('orders').add(order);

      for (final item in cart.cartItems) {
        final productRef = FirebaseFirestore.instance
            .collection('products')
            .doc(item.product.id);

        await productRef.update({
          'stock': FieldValue.increment(-item.quantity),
        });
      }

      //Limpiar carrito
      cart.clearCart();

      //Mostrar confirmación
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("¡Compra confirmada!"),
          content: const Text('Tu pedido ha sido guardado correctamente.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar diálogo
                Navigator.pop(context); // Volver a la pantalla anterior
              },
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    } catch (e) {
      print("Error al guardar orden: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error al procesar tu compra, intenta nuevamente"),
        ),
      );
    }
  }
}
