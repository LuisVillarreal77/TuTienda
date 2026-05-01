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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('TuTienda'),
        backgroundColor: Colors.deepOrange[400],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          //Botones de acción en la barra de navegación
          //Boton de busqueda
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              //logica para la acción al presionar el botón de búsqueda
            },
          ),
          //Boton de carrito de compras
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                Positioned(
                  right: 0,
                  child: Consumer<CartProvider>(
                    builder: (context, cart, child) {
                      if (cart.totalItems == 0) {
                        return const SizedBox();
                      }

                      return Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          cart.totalItems.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
          //Boton de perfil de usuario
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              //logica para la acción al presionar el botón de perfil de usuario
            },
          ),

          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
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

            //overlay de color oscuro para mejorar la legibilidad del texto
            Container(color: Colors.black.withValues(alpha: 0.3)),

            //contenido del banner
            Positioned(
              left: 20,
              top: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡25% de Descuento en tu primera compra!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange[400],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Comprar Ahora',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
        'imagen': 'assets/images/categories/joyeria.jpg',
      },
      {
        'icon': Icons.category_sharp,
        'nombre': 'Tejidos',
        'color': Colors.brown,
        'imagen': 'assets/images/categories/tejidos.jpg',
      },
      {
        'icon': Icons.home,
        'nombre': 'Hogar',
        'color': Colors.blue,
        'imagen': 'assets/images/categories/hogar.jpg',
      },
      {
        'icon': Icons.auto_awesome,
        'nombre': 'Decoración',
        'color': Colors.green,
        'imagen': 'assets/images/categories/decoracion.jpg',
      },
    ];

    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
        ), //espacio igual entre elementos
        children: categories.map((category) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: GestureDetector(
              onTap: () {
                //logica para navegar a la pantalla de productos de esta categoría
                _showCategorProducts(context, category['nombre'] as String);
              },
              child: SizedBox(
                width: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: (category['color'] as Color).withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(
                              0,
                              2,
                            ), // changes position of shadow
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.asset(
                          category['imagen'] as String,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            //si la imagen no existe mostrar un icono
                            return Container(
                              color: (category['color'] as Color).withValues(
                                alpha: 0.1,
                              ),
                              child: Icon(
                                category['icon'] as IconData,
                                size: 50,
                                color: category['color'] as Color,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      category['nombre'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Tiendas Destacadas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),

            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/allShops');
              },
              child: const Text("Ver todas"),
          ),

            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: shops.length,
                itemBuilder: (context, index) {
                  final shop = shops[index];

                  return ShopCard(
                    shop: shop,
                    onTap: () {
                      Navigator.pushNamed(
                        context, '/shop', 
                        arguments: shop.id,
                        );
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

        final products = snapshot.data!;

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
      selectedItemColor: Colors.deepOrange[400],
      unselectedItemColor: Colors.grey[400],
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explorar'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoritos'),
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
        print('Navegando a Explorar');
        break;
      case 2: // Favoritos
        // Puedes implementar esta pantalla después
        print('Navegando a Favoritos');
        break;
      case 3: // Pedidos // Navegar a la pantalla de pedidos
        // Puedes implementar esta pantalla después
        Navigator.pushNamed(context, '/orders');
        print('Navegando a Pedidos');
        break;
      case 4: // Carrito // Navegar a la pantalla del carrito
        Navigator.pushNamed(context, '/cart');
        print('Navegando a Carrito');
        break;
    }
  }

  //Función para mostrar productos de por categoría específica
  void _showCategorProducts(BuildContext context, String category) {
    //logica para la navegacion a productos por categoria
    print('Mostrando productos de: $category');
  }
}
