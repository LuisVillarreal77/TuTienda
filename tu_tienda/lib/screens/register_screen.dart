import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String selectedRole = 'buyer'; // Por defecto, el rol es "buyer" (comprador)

  bool loading = false;

  Future<void> register() async {
    setState(() => loading = true);

    try {
      // Crear el usuario con Firebase Authentication
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      final user = userCredential.user;

      // Guardar en Firestore
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        "uid": user.uid,
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "role": selectedRole,
        "status": "active",
        "createdAt": FieldValue.serverTimestamp(),
      });

      //Redirigir segun el rol a la interfaz correspondiente
      if (!mounted) return;

      if (selectedRole == 'seller') {
        Navigator.pushReplacementNamed(context, '/createShop');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }

    } on FirebaseAuthException catch (e) {
      
      String message = "Error";

      if (e.code == 'email-already-in-use') {
        message = "El correo ya está registrado";
      } else if (e.code == 'weak-password') {
        message = "La contraseña es muy débil";
      } else if (e.code == 'invalid-email') {
        message = "Correo inválido";
      } else {
        message = e.message ?? "Error desconocido";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message))
        );
      }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Nombre"),
            ),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Correo"),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Contraseña"),
            ),

            const SizedBox(height: 20),

            // Dropdown para seleccionar el rol
            DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: const InputDecoration( 
                labelText: "Tipo de usuario",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem( 
                  value: 'buyer',
                  child: Text('Comprador'),
                ),
                DropdownMenuItem(  
                  value: 'seller',
                  child: Text('Vendedor'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedRole = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: loading ? null : register,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Registrarse"),
            ),
          ],
        ),
      ),
    );
  }
}
