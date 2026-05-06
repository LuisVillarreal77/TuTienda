import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateShopScreen extends StatefulWidget {
  const CreateShopScreen({super.key});

  @override
  State<CreateShopScreen> createState() => _CreateShopScreenState();
}

class _CreateShopScreenState extends State<CreateShopScreen> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  bool loading = false;

  Future<void> createShop() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    if (nameController.text.isEmpty || descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Faltan campos por llenar")));
      return;
    }

    setState(() => loading = true);

    try {
      //verificar si ya tiene tienda
      final existingShop = await FirebaseFirestore.instance
          .collection('shops')
          .where('ownerId', isEqualTo: user.uid)
          .get();

      if (existingShop.docs.isNotEmpty) {
        Navigator.pushReplacementNamed(context, '/sellerDashboard');
        return;
      }

      //crear tienda
      await FirebaseFirestore.instance.collection('shops').add({
        "name": nameController.text,
        "description": descriptionController.text.trim(),
        "imageUrl": "agregar imagen",
        "ownerId": user.uid,
        "rating": 0,
        "createdAt": FieldValue.serverTimestamp(),        
      });

      if (!mounted) return;

      //Redirigir a la pantalla de administración de la tienda
      Navigator.pushReplacementNamed(context, '/sellerDashboard');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al crear tienda: $e")));
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear tienda"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Nombre de la tienda",
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Descripción"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: loading ? null : createShop,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
              ),
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Crear tienda"),
            ),
          ],
        ),
      ),
    );
  }
}
