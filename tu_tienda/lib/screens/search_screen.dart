import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String query = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Buscar productos...",
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),

          style: const TextStyle(color: Colors.white),
          onChanged: (value) {
            setState(() {
              query = value.trim().toLowerCase();
            });
          },
        ),
      ),

      body: SafeArea(

        child: SingleChildScrollView(
         
         child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('products')
                .where("isActive", isEqualTo: true)
                .snapshots(),

            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData) {
                return const Center(child: Text("No hay productos"));
              }

              final docs = snapshot.data!.docs;

              final results = docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;

                final name = (data["name"] ?? "").toString().toLowerCase();

                final category = (data["category"] ?? "")
                    .toString()
                    .toLowerCase();

                final shop = (data["shopName"] ?? "").toString().toLowerCase();

                return name.contains(query) ||
                    category.contains(query) ||
                    shop.contains(query);
              }).toList();

              if (results.isEmpty) {
                return const Center(
                  child: Text("No se encontraron resultados"),
                );
              }

              return MasonryGridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),

                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,

                itemCount: results.length,

                itemBuilder: (context, index) {
                  final data = results[index].data() as Map<String, dynamic>;

                  final product = Product.fromFirestore(
                    results[index].id,
                    data,
                  );

                  return ProductCard(
                    product: product,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(product: product),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
