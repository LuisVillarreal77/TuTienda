import 'package:flutter/material.dart';
import '../providers/cart_provider.dart';
import '../models/product.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detalles del producto'),
        backgroundColor: Colors.deepOrange[400],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareProduct(context),
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () => _toggleFavorite(),
          ),
          //Badge del carrito con AnimatedBuilder
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.pushNamed(context, '/cart');
                    },
                  ),
                  if (cart.totalItems > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          cart.totalItems.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body:
      SafeArea(child: 
       SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //galeria de imagenes
            _buildImageGallery(),

            //Informacion del producto
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // categoria y nombre
                  Text( 
                    (product.category),
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    (product.name),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  //Rating y precio
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildRatingStars(),
                      const SizedBox(width: 8),
                      Text(
                        ('${product.rating}'),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const Spacer(),
                      Text(
                        ('\$${product.price}'),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ],
                  ),

                  //Descripcion
                 const Text(
                    'Descripcion',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    (product.description),
                      style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                    const SizedBox(height: 24),
                 

                  //Especificaciones (se puede expandir esto)
                  const SizedBox(height: 24),
                  _buildProductSpecs(),

                  //Productos relacionados
                  const SizedBox(height: 32),
                  _buildRelatedProducts(),
                ],
              ),
            ),
          ],
        ),
      ),
 ),
      //Barra inferior para añadir al carrito
      bottomNavigationBar: SafeArea(
        child:  _buildAddToCartBar(context),
      ),
     
    );
  }

  //Barra inferior con funcion para añadir al carrito
  Widget _buildAddToCartBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          //Seleccion de cantidad (placeholder)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Text('1'),
                SizedBox(width: 4),
                Icon(Icons.arrow_drop_down, size: 20),
              ],
            ),
          ),
          const SizedBox(width: 12),

          //Boton de añadir al carrito
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _addToCart(context),
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text(
                'Añadir al carrito',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange[400],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //funcion para añadir al carrito
  void _addToCart(BuildContext context) {
    //añadir producto al carrito
   final cart = Provider.of<CartProvider>(context, listen: false);
cart.addToCart(product);

    //Mostrar mensaje de confirmacion
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} añadido al carrito'),
        duration: const Duration(seconds: 1),
        action: SnackBarAction(
          label: 'Ver carrito',
          onPressed: () {
            Navigator.pushNamed(context, '/cart');
          },
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  //Galeria de imagenes
  Widget _buildImageGallery() {
    return Container(
      height: 300,
      width: double.infinity,
      child: Stack(
        children: [
          //Imagen principal
          Image.asset(
            (product.imageUrl),
            width: double.infinity,
            height: 300,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    size: 60,
                    color: Colors.grey,
                  ),
                ),
              );
            },
          ),

          //indicador de multiples imagenes
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '1/1', //cambiaria si tuviera multiples imagens
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //Widget de estrellas de rating
  Widget _buildRatingStars() {
    double rating = double.tryParse(product.rating.toString() ) ?? 0;

    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor() ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }

  //Especificaciones del producto
  Widget _buildProductSpecs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Especificaciones',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        // especificaciones
        _buildSpecItem('Material: ', 'Hecho a mono con materiales naturales.'),
        _buildSpecItem('Tamaño: ', 'Disponible en varias tallas.'),
        _buildSpecItem('Cuidados: ', 'Lavar a mano con agua fria.'),
        _buildSpecItem('Origen: ', 'Hecho a mano en Maria La Baja.'),
      ],
    );
  }

  //item de especificacion individual
  Widget _buildSpecItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  //Productos relacionados (placeholder)
  Widget _buildRelatedProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Productos relacionados',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 150,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildRelatedProductItem(),
              _buildRelatedProductItem(),
              _buildRelatedProductItem(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedProductItem() {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.photo, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          const Text(
            'Producto',
            style: TextStyle(fontSize: 14),
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  //Funciones de interacciones
  void _shareProduct(BuildContext context) {
    //logica para compartir productos
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Compartiendo producto...')));
  }

  void _toggleFavorite() {
    //Logica para añadir/eliminar de favoritos
    print('Toggle favorite: ${product.name}');
  }
}
