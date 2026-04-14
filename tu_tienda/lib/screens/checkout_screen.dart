import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final cartItems = cart.cartItems;

    double total = cartItems.fold(0.0, (sum, item) => sum + item.price);

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
                    final product = cartItems[index];

                    return ListTile(
                      leading: Image.asset(
                        product.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(product.name),
                      subtitle: Text('\$${product.price}'),
                    );
                  },
                ),
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

    try {
      final order = {
        "userId": user.uid,
        "total": cart.cartItems.fold(0.0, (sum, item) => sum + item.price * 1),
        "status": "pending",
        "createdAt": FieldValue.serverTimestamp(),
        "items": cart.cartItems.map((item) {
          return {
            "productId": item.id,
            "name": item.name,
            "price": item.price,
            "quantity": 1,
            "image": item.imageUrl,
          };
        }).toList(),
      };

      await FirebaseFirestore.instance.collection('orders').add(order);

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
