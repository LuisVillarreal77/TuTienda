import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;

  Future<void> register() async {
    setState(() => loading = true);

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
  print("ERROR FIREBASE: ${e.code}");

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
    SnackBar(content: Text(message)),
  );
}

    setState(() => loading = false);
  }

  @override
   Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro")),
      body: Padding(padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField( 
            controller: emailController,
            decoration: const InputDecoration(labelText: "Correo"),
          ),
          TextField(   
            controller: passwordController,
            decoration: const InputDecoration(labelText: "Contraseña"),
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
