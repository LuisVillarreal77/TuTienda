import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final cartItems = cart.cartItems;

    double total = cartItems.fold(0.0, (sum, item) => sum + item.price);

    return Scaffold(
      appBar: AppBar(title: const Text("Resumen de compra")),

      body: 
      SafeArea(child: 
      Padding(
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

  void _confirmOrder(BuildContext context, CartProvider cart) {
    // Limpiar carrito
    cart.clearCart();

    //mostrar mensaje de confirmacion
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¡Compra exitosa!'),
        content: const Text(
          'Tu pedido ha sido realizado correctamente.', 
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Cerrar el diálogo
            Navigator.pop(context); // Volver a la pantalla anterior
          },
          child: const Text('Aceptar'),
        ),
      ],
      ),
    );
  }
}
