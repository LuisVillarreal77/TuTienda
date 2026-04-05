import 'package:flutter/material.dart';
import 'package:tu_tienda/screens/register_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/cart_screen.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
        '/home': (context) => const MyHomePage(), //Tu pantalla principal
        '/cart': (context) => const CartScreen(),
        '/register': (context) => const RegisterScreen(),
      },
      debugShowCheckedModeBanner: false, //quita la etiqueta de debug
    );
  }
}
