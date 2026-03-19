import 'package:flutter/foundation.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  //Lista de productos en el carrito
  final List<Product> _cartItems = [];

  //Getter para acceder a los items
  List<Product> get cartItems => _cartItems;

  //Getter para obtener el total de items en el carrito
  int get totalItems => _cartItems.length;

  //Método para agregar un producto al carrito
  void addToCart(Product product) {
      _cartItems.add(product);
       notifyListeners();  // Notificar cambios en el carrito

  }

  //Método para eliminar un producto del carrito
  void removeFromCart(int index) {
    if (index >= 0 && index < _cartItems.length) {
      _cartItems.removeAt(index);
      notifyListeners();
    }
  }

  // //actualizar la cantidad de un producto en el carrito
  // void updateQuantity(int index, int newQuantity) {
  //   if (index >= 0 && index < _cartItems.length && newQuantity > 0) {
  //     _cartItems[index]['cantidad'] = newQuantity;
  //     notifyListeners();
  //   }
  // }

  //Vaciar el carrito
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

}


