import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'product_detail_screen.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/product_card.dart';
import '../models/shop.dart';
import '../services/shop_services.dart';
import '../widgets/shop_card.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      key: _scaffoldKey,

      drawer: Drawer(
        child: Column(
          children: [
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get(),

              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const UserAccountsDrawerHeader(
                    accountName: Text("Cargando..."),
                    accountEmail: Text(""),
                  );
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;

                return UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(color: Colors.orange),

                  accountName: Text(data['name'] ?? 'Usuario'),
                  accountEmail: Text(data['email'] ?? ''),

                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      (data['name'] ?? 'U').substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Mi perfil"),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text("Favoritos"),
              onTap: () {
                Navigator.pushNamed(context, '/favorites');
              },
            ),

            ListTile(
              leading: const Icon(Icons.shopping_bag),
              title: const Text("Mis pedidos"),
              onTap: () {
                Navigator.pushNamed(context, '/orders');
              },
            ),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Cerrar sesión"),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),

      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        title: Row(
          children: [
            //BOTON DE MENU
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
                icon: const Icon(Icons.menu),
              ),
            ),

            const SizedBox(width: 10),

            //BARRA DE BUSQUEDA
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/search');
                },
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(width: 12),
                      Icon(Icons.search, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        "Buscar productos...",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            //NOTIFICACIONES
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none),
                    color: Colors.white,
                  ),
                ),

                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      "3",
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //banner de promociones
              _buildPromotionBanner(),

              const SizedBox(height: 10),

              //categorías de productos
              _buildCategoriesSection(),
              const SizedBox(height: 10),

              //tiendas destacadas
              _buildFeaturedShops(),
              const SizedBox(height: 10),

              //productos destacados
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Productos Destacados',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        //logica para ver todos los productos destacados
                      },
                      child: Text(
                        'Ver Todos',
                        style: TextStyle(color: Colors.deepOrange[400]),
                      ),
                    ),
                  ],
                ),
              ),

              //Productos destacados
              _buildFeaturedProducts(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  //Banner de promociones
  Widget _buildPromotionBanner() {
    return Container(
      width: double.infinity,
      height: 150,
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(77),
            blurRadius: 8,
            offset: const Offset(0, 4), // changes position of shadow
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            //Imagen de fondo del banner
            Image.asset(
              'assets/images/banners/promotion_banner.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            //overlay de color oscuro para mejorar la legibilidad del t
          ],
        ),
      ),
    );
  }

  //Sección de categorías
  Widget _buildCategoriesSection() {
    final List<Map<String, dynamic>> categories = [
      {
        'icon': Icons.diamond,
        'nombre': 'Joyería',
        'color': Colors.purple,
        'imagen': 'assets/images/categories/joyeria.png',
      },
      {
        'icon': Icons.category_sharp,
        'nombre': 'Tejidos',
        'color': Colors.brown,
        'imagen': 'assets/images/categories/tejidos.png',
      },
      {
        'icon': Icons.home,
        'nombre': 'Hogar',
        'color': Colors.blue,
        'imagen': 'assets/images/categories/hogar.png',
      },
      {
        'icon': Icons.auto_awesome,
        'nombre': 'Decoración',
        'color': Colors.green,
        'imagen': 'assets/images/categories/decoracion.png',
      },
    ];

    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
        ), //espacio igual entre elementos
        children: categories.map((category) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () {
                //logica para navegar a la pantalla de productos de esta categoría
                _showCategorProducts(context, category['nombre'] as String);
              },
              child: SizedBox(
                width: 110,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 8,
                            offset: const Offset(
                              0,
                              3,
                            ), // changes position of shadow
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          category['imagen'] as String,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            //si la imagen no existe mostrar un icono
                            return Container(
                              color: Colors.grey.shade200,
                              child: Icon(
                                category['icon'] as IconData,
                                size: 40,
                                color: category['color'] as Color,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      category['nombre'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  //tiendas destacadas
  Widget _buildFeaturedShops() {
    return FutureBuilder<List<Shop>>(
      future: ShopServices().getFeaturedShops(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final shops = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tiendas Destacadas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/allShops');
                    },
                    child: const Text(
                      "Ver todas",
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 180,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: shops.length,
                itemBuilder: (context, index) {
                  final shop = shops[index];

                  return ShopCard(
                    shop: shop,
                    onTap: () {
                      Navigator.pushNamed(context, '/shop', arguments: shop.id);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  //productos destacados
  Widget _buildFeaturedProducts() {
    return FutureBuilder<List<Product>>(
      future: ProductService().getPopularProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar los productos'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay productos disponibles'));
        }

        SizedBox(height: 16);

        final products = snapshot.data!;

        return MasonryGridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),

          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,

          itemCount: products.length,

          itemBuilder: (context, index) {
            final product = products[index];

            return ProductCard(
              product: product,
              onTap: () {
                _showProductDetails(context, product);
              },
            );
          },
        );
      },
    );
  }

  //Barra de navegación inferior
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.deepOrange,
      unselectedItemColor: Colors.grey,

      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoritos'),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Perfil',
        ),
        BottomNavigationBarItem(
          icon: Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_cart),

                  if (cart.cartItems.isNotEmpty)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          cart.cartItems.length.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          label: 'Carrito',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: 'Pedidos',
        ),
      ],
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
        //logica para manejar la navegación entre pantallas
        _handleBottomNavigation(index);
      },
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

  //Función para manejar la navegación inferior
  void _handleBottomNavigation(int index) {
    //logica para manejar la navegación entre pantallas
    switch (index) {
      case 0: // Inicio - ya estamos aquí
        break;
      case 1: // Explorar
        // Puedes implementar esta pantalla después
        Navigator.pushNamed(context, '/favorites');
        break;
      case 2: // Favoritos
        // Puedes implementar esta pantalla después
        print('Perfil');
        break;
      case 3: // Pedidos // Navegar a la pantalla de pedidos
        // Puedes implementar esta pantalla después
        Navigator.pushNamed(context, '/cart');
        break;
      case 4: // Carrito // Navegar a la pantalla del carrito
        Navigator.pushNamed(context, '/orders');
        break;
    }
  }

  //Función para mostrar productos de por categoría específica
  void _showCategorProducts(BuildContext context, String category) {
    //logica para la navegacion a productos por categoria
    print('Mostrando productos de: $category');
  }
}
