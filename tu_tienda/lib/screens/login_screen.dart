import 'package:flutter/material.dart';

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
                  onPressed: () {
                    _login(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
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
                    print('Registrarse');
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
  void _login(BuildContext context) {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

     //funcion para mostrar un dialogo de error
    void  showErrorDialog(BuildContext context, String message) {
      showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error al iniciar sesión'),
        content: Text(message),
        actions: [
          TextButton(onPressed:() => Navigator.pop(context), 
          child: const Text('OK'),
          ),
        ],
      ),
     );
 }

    //valida si los campos no estan vacios
    if (email.isEmpty || password.isEmpty) {
      showErrorDialog(context, 'Por favor, completa todos los campos.');
      return;
    }

    if (!email.contains('@')) {
      showErrorDialog(context, 'Por favor, ingresa un correo electrónico válido.');
      return;
    }

    // Simula un proceso de autenticación
    if (email == 'admin20@gmail.com' && password == 'admin123') {
      // Si el login es exitoso, navega a la pantalla principal
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Si el login falla, muestra un mensaje de error
      showErrorDialog(context, 'Correo o contraseña incorrectos.');
    }

   

    // @override
    // void dispose() {
    //   _emailController.dispose();
    //   _passwordController.dispose();
    //   super.dispose();
    //      }
  }
}
