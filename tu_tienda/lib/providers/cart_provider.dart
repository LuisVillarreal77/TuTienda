import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

  int get totalItems => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice {
  return _cartItems.fold(
    0.0,
    (sum, item) => sum + (item.product.price * item.quantity),
  );
}

  bool addToCart(Product product) {
    final index = _cartItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (index != -1) {
      final cartItem = _cartItems[index];

      if (cartItem.quantity >= product.stock) {
        return false;
      }

      cartItem.quantity++;
    } else {
      if (product.stock <= 0) {
        return false;
      }

      _cartItems.add(CartItem(product: product, quantity: 1));
    }

    notifyListeners();
    return true;
  }
  

  void decreaseQuantity(String productId) {
    final index = _cartItems.indexWhere((item) => item.product.id == productId);

    if (index == -1) return;

    if (_cartItems[index].quantity > 1) {
      _cartItems[index].quantity--;
    } else {
      _cartItems.removeAt(index);
    }

    notifyListeners();
  }

  //ELIMINAR PRODUCTO DEL CARRITO
  void removeProduct(String productId) {
    _cartItems.removeWhere((item) => item.product.id == productId);

    notifyListeners();
  }

  //VACIAR CARRITO
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}
