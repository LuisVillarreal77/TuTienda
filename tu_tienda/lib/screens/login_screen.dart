import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para los campos de texto
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  //Variable para mostrar/ocultar contraseña
  bool _obscurePassword = true;

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 80),
              Image.asset('assets/logo_tu_tienda.png', width: 100, height: 100),
              // Título
              const SizedBox(height: 20),
              Text(
                'Bienvenido a TuTienda',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange[400],
                ),
              ),

              const SizedBox(height: 10),

              //formulario de login
              Text(
                'Inicia sesión para continuar',
                style: TextStyle(fontSize: 16, color: Colors.brown[600]),
              ),
              const SizedBox(height: 40),

              // Campo de correo electrónico
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Correo electronico',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 20),
              // Campo de contraseña
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                obscureText: _obscurePassword,
              ),

              const SizedBox(height: 20),

              // Botón de olvidé mi contraseña
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    //logica para recuperar contraseña
                    print('olvidé mi contraseña');
                  },
                  child: Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(color: Colors.deepOrange[400]),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              //Botón de iniciar sesión
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: loading ? null : () => _login(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Iniciar Sesión',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),
              // Botón de registro
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  onPressed: () {
                    //logica para ir a la pantalla de registro
                    Navigator.pushNamed(context, '/register');
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.deepOrange[400]!),
                  ),
                  child: Text(
                    'crear una cuenta',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.deepOrange[400],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Funcion para simular el login
  void _login(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Activar loading
    setState(() => loading = true);

    // Validaciones
    if (email.isEmpty || password.isEmpty) {
      setState(() => loading = false);
      _showError(context, 'Por favor, completa todos los campos.');
      return;
    }

    if (!email.contains('@')) {
      setState(() => loading = false);
      _showError(context, 'Correo electrónico inválido.');
      return;
    }

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user != null) {
        await _redirectUser(user);
      }
      
    } on FirebaseAuthException catch (e) {
      String message = "Error al iniciar sesión";

      if (e.code == 'user-not-found') {
        message = "Usuario no encontrado";
      } else if (e.code == 'wrong-password') {
        message = "Contraseña incorrecta";
      } else if (e.code == 'invalid-email') {
        message = "Correo inválido";
      }

      _showError(context, message);
    }

    // Desactivar loading
    setState(() => loading = false);
  }

  Future<void> _redirectUser(User user) async {
  try {
    // 1. Obtener datos del usuario
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!userDoc.exists) {
      Navigator.pushReplacementNamed(context, '/home');
      return;
    }

    final role = userDoc['role'].toString().toLowerCase();

    // 2. Si es buyer → home
    if (role == 'buyer') {
      Navigator.pushReplacementNamed(context, '/home');
      return;
    }

    // 3. Si es seller → validar tienda
    if (role == 'seller') {
      final shopQuery = await FirebaseFirestore.instance
          .collection('shops')
          .where('ownerId', isEqualTo: user.uid)
          .limit(1)
          .get();

      //si no tiene tienda
      if (shopQuery.docs.isEmpty) {
        Navigator.pushReplacementNamed(context, '/createShop');
      } 
      // si ya tiene tienda
      else {
        Navigator.pushReplacementNamed(context, '/sellerDashboard');
      }
    }

  } catch (e) {
    print("ERROR REDIRECCIÓN: $e");
    _showError(context, "Error al cargar datos del usuario");
  }
}

  void _showError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
