import 'package:flutter/material.dart';
import 'package:tu_tienda/admin/screnns/login_stats_screen.dart';
import 'package:tu_tienda/models/product.dart';
import 'package:tu_tienda/screens/create_product_screen.dart';
import 'package:tu_tienda/screens/create_shop.dart';
import 'package:tu_tienda/screens/product_detail_screen.dart';
import 'package:tu_tienda/screens/register_screen.dart';
import 'package:tu_tienda/screens/seller_dashboard_screen.dart';
import 'package:tu_tienda/screens/seller_order_screen.dart';
import 'package:tu_tienda/screens/shop_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/buyer_orders_screen.dart';
import 'package:tu_tienda/admin/screnns/security_dashboard_screen.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:tu_tienda/admin/services/telemetry_service.dart';
import 'package:tu_tienda/screens/edit_product_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  TelemetryService.connect();

  runApp(
    ChangeNotifierProvider(create: (_) => CartProvider(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TuTienda',
      theme: ThemeData(primarySwatch: Colors.orange),
      //La pantalla inicial es el SplashScreen con animacion
      home: const SplashScreen(),
      //definimos las rutas de navegacion
      routes: {
        '/login': (context) => const LoginScreen(), //Pantalla de login
        '/home': (context) => const MyHomePage(), //Pantalla principal
        '/register': (context) => const RegisterScreen(),
        '/orders': (context) => const OrdersScreen(),
        '/securityDashboard': (context) => const SecurityDashboardScreen(),
        '/loginStats': (context) => const LoginStatsScreen(),
        '/createShop': (context) =>const CreateShopScreen(),
        '/cart': (context) => const CartScreen(),
        '/sellerDashboard': (context) => SellerDashboardScreen(),
        '/seller-orders': (context) => const SellerOrderScreen(),  
        '/createProduct': (context) => const CreateProductScreen(),
        '/editProduct': (context) {
          final productId = ModalRoute.of(context)!.settings.arguments as String;
          return EditProductScreen(productId: productId);
        },
        
        '/productDetail': (context) {
          final product = ModalRoute.of(context)!.settings.arguments as Product;
          return ProductDetailScreen(product: product);
        },
        '/shop': (context) {
          final shopId = ModalRoute.of(context)!.settings.arguments as String;
          return ShopScreen(shopId: shopId);
        },
      },
      debugShowCheckedModeBanner: false, //quita la etiqueta de debug
    );
  }
}
