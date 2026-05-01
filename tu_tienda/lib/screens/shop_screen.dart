import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tu_tienda/models/product.dart';
import 'package:tu_tienda/widgets/product_card.dart';

class ShopScreen extends StatelessWidget {
  final String shopId;

  const ShopScreen({super.key, required this.shopId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tienda"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('shops')
            .doc(shopId)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final shop = snapshot.data!.data() as Map<String, dynamic>;

          return Column(
            children: [_buildShopHeader(shop), _buildProducts(shopId)],
          );
        },
      ),
    );
  }

  //Header de la tienda
  Widget _buildShopHeader(Map<String, dynamic> shop) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          
          Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: 180,
                child: Image.asset(shop['imageUrl'],
                fit: BoxFit.cover,
                ),
              ),

              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                ),
              ),

              Positioned(
                bottom: 16,
                left: 16,
                child: Text(
                  shop['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.orange),
              Text("${shop['rating']}"),
            ],
          ),
        ],
      ),
    );
  }

  //Lista de productos de la tienda
  Widget _buildProducts(String shopId) {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('shopId', isEqualTo: shopId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data!.docs;

          if (products.isEmpty) {
            return const Center(child: Text("No products available"));
          }

          return GridView.builder(
             shrinkWrap: true,
             physics: NeverScrollableScrollPhysics(),
             padding: const EdgeInsets.all(16),
             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
             crossAxisCount: 2,
             crossAxisSpacing: 12,
             mainAxisSpacing: 12,
             childAspectRatio: 0.50,
            //mainAxisExtent: 280,
          ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final doc = products[index];
              final data = doc.data() as Map<String, dynamic>;

              final product = Product(
                id: doc.id,
                name: data['name'] ?? '',
                description: data['description'] ?? '',
                price: (data['price'] as num).toDouble(),
                imageUrl: data['imageUrl'] ?? '',
                category: data['category'] ?? '',
                rating: (data['rating'] as num?)?.toDouble() ?? 0,
                shopId: data['shopId'] ?? '',
                shopName: data['shopName'] ?? '',
              );

              return ProductCard(
                product: product,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/productDetail',
                    arguments: product,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
