import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tu_tienda/admin/services/telemetry_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'create_product_screen.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text("Mi tienda"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            _buildHeader(),
            const SizedBox(height: 16),

            _buildStatsSection(),
            const SizedBox(height: 16),

            // ADMINISTRACIÓN
            _buildAdminSection(context),
            const SizedBox(height: 16),

            // PRODUCTOS
            _buildProductsSection(),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    TelemetryService.sendEvent(
      eventType: 'logout',
      details: 'Usuario ${user?.email ?? "desconocido"} cerró sesión',
    );

    await FirebaseAuth.instance.signOut();

    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Future<void> _deleteProduct(BuildContext context, String productId) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Eliminar Producto"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar"),
            ),

            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .delete();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Producto Eliminado")));
    }
  }

  Future<void> _toggleProductStatus(
    BuildContext context,
    String productId,
    bool currentStatus,
  ) async {
    await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .update({'isActive': !currentStatus});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          !currentStatus ? "Producto Activado" : "Producto Desactivado",
        ),
      ),
    );
  }

  Widget _buildShopImage(String imageUrl) {
    if (imageUrl.isEmpty || imageUrl == 'agregar imagen') {
      return CircleAvatar(
        radius: 35,
        backgroundImage: const AssetImage('assets/images/shops/wayuu.jpg'),
      );
    }

    return CircleAvatar(radius: 35, backgroundImage: AssetImage(imageUrl));
  }

  // HEADER
  Widget _buildHeader() {
    return StreamBuilder<QuerySnapshot>(
      stream: _shopStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data!.docs.isEmpty) {
          return const ListTile(title: Text("Tienda no encontrada"));
        }

        final shop = snapshot.data!.docs.first.data() as Map<String, dynamic>;

        return Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop['name'] ?? '',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      shop['description'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              _buildShopImage(shop['imageUrl']),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsSection() {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('sellerId', isEqualTo: user!.uid)
          .snapshots(),
      builder: (context, ordersSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('products')
              .where('sellerId', isEqualTo: user.uid)
              .snapshots(),
          builder: (context, productsSnapshot) {
            final totalProducts = productsSnapshot.hasData
                ? productsSnapshot.data!.docs.length
                : 0;

            final totalOrders = ordersSnapshot.hasData
                ? ordersSnapshot.data!.docs.length
                : 0;

            return Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),

              child: Row(
                children: [
                  Expanded(
                    child: _statCard(
                      "Productos",
                      totalProducts.toString(),
                      Icons.inventory,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _statCard(
                      "Pedidos",
                      totalOrders.toString(),
                      Icons.receipt_long,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _statCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
      ),

      child: Column(
        children: [
          Icon(icon),
          const SizedBox(height: 8),

          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          Text(title),
        ],
      ),
    );
  }

  //  SECCIÓN ADMIN
  Widget _buildAdminSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Administrar tienda",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _adminButton(
                icon: Icons.add,
                label: "Crear producto",
                onTap: () {
                  Navigator.pushNamed(context, '/createProduct');
                },
              ),

              _adminButton(
                icon: Icons.list,
                label: "Ver Pedidos ",
                onTap: () {
                  Navigator.pushNamed(context, '/orders');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  //  BOTÓN ADMIN
  Widget _adminButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 28, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // PRODUCTOS
  Widget _buildProductsSection() {
    final user = FirebaseAuth.instance.currentUser;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Productos publicados",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          //BUSCADOR
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Buscar producto',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value.toLowerCase();
              });
            },
          ),
          const SizedBox(height: 16),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('products')
                .where('sellerId', isEqualTo: user!.uid)
                .orderBy('createdAt', descending: true)
                .snapshots(),

            builder: (context, snapshot) {
              //LOADING
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("Aun no tienes productos publicados"),
                  ),
                );
              }

              final products = snapshot.data!.docs;

              final filteredProducts = products.where((product) {
                final data = product.data() as Map<String, dynamic>;

                final name = (data['name'] ?? '').toString().toLowerCase();

                return name.contains(searchQuery);
              }).toList();

              if (filteredProducts.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      "No se encontraron productos",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredProducts.length,

                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.68,
                ),

                itemBuilder: (context, index) {
                  final product = filteredProducts[index];

                  final data = product.data() as Map<String, dynamic>;

                  return _productCard(
                    context: context,
                    productId: product.id,
                    name: data['name'] ?? '',
                    price: data['price'] ?? 0,
                    isActive: data['isActive'] ?? true,
                    imageUrl: data['imageUrl'] ?? '',
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // CARD PRODUCTO
  Widget _productCard({
    required BuildContext context,
    required String productId,
    required String name,
    required dynamic price,
    required String imageUrl,
    required bool isActive,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //IMAGEN
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),

              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey[300],

                      child: const Center(
                        child: Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.black45,
                        ),
                      ),
                    ),
            ),
          ),
          //INFORMACION
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //NOMBRE
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 4),

                //PRECIO
                Text(
                  "\$ ${price.toString()}",
                  style: const TextStyle(
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),

                  decoration: BoxDecoration(
                    color: isActive ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),

                  child: Text(
                    isActive ? "Activo" : "Inactivo",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                //BOTONES
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //EDITAR
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/editProduct',
                          arguments: productId,
                        );
                      },
                    ),

                    IconButton(onPressed: () {
                      _toggleProductStatus(context, productId, isActive);
                    }, 
                    icon: Icon(
                      isActive
                      ? Icons.visibility
                      : Icons.visibility_off,                      
                      ),
                      ),

                    //ELIMINAR
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteProduct(context, productId);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _shopStream() {
    final user = FirebaseAuth.instance.currentUser;

    return FirebaseFirestore.instance
        .collection('shops')
        .where('ownerId', isEqualTo: user!.uid)
        .limit(1)
        .snapshots();
  }
}
