import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/product.dart';
import '../services/favorite_service.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';


class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Favoritos"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FavoriteService().getFavorites(),
        builder: (context, favoriteSnapshot) {
          if (favoriteSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (favoriteSnapshot.hasError) {
            return Center(child: Text("Error: ${favoriteSnapshot.error}"));
          }

          if (!favoriteSnapshot.hasData ||
              favoriteSnapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Aun no tienes productos favoritos.",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final productIds = favoriteSnapshot.data!.docs
              .map((doc) => doc['productId'] as String)
              .toList();

          return FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('products')
                .where(FieldPath.documentId, whereIn: productIds)
                .get(),
            builder: (context, productSnapshot) {
              if (productSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (productSnapshot.hasError) {
                return Center(child: Text("Error: ${productSnapshot.error}"));
              }

              final products = productSnapshot.data!.docs;

              return MasonryGridView.count(
                padding: const EdgeInsets.all(16),
                itemCount: products.length,
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,

                itemBuilder: (context, index) {
                  final doc = products[index];

                  final product = Product.fromFirestore(
                    doc.id,
                    doc.data() as Map<String, dynamic>,
                  );

                  return ProductCard(product: product, onTap: () {
                     _showProductDetails(context, product);
                  });
                },
              );
            },
          );
        },
      ),
    );
  }

    // Funcion para mostrar detalles del producto
  void _showProductDetails(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  }
}
