import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/storage_service.dart';

class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({super.key});

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  File? selectedImage;

  String selectedCategory = "Joyeria";

  bool loading = false;

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final pickerFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickerFile != null) {
      setState(() {
        selectedImage = File(pickerFile.path);
      });
    }
  }

  final List<String> categories = ["Joyeria", "Tejidos", "Hogar", "Decoracion"];

  Future<void> createProduct() async {
    try {
      setState(() => loading = true);

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      //VALIDACIONES
      if (_nameController.text.isEmpty ||
          _descriptionController.text.isEmpty ||
          _priceController.text.isEmpty ||
          _stockController.text.isEmpty) {
        showMessage("Completa todos los campos");
        return;
      }

      if (selectedImage == null) {
        showMessage("Debes seleccionar una imagen");
        return;
      }

      //OBTENER TIENDA DEL VENDEDOR
      final shopQuery = await FirebaseFirestore.instance
          .collection('shops')
          .where('ownerId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (shopQuery.docs.isEmpty) {
        showMessage("No tienes una tienda creada");
        return;
      }

      final shopDoc = shopQuery.docs.first;

      final shopId = shopDoc.id;
      final shopData = shopDoc.data();

      String imageUrl = "";

      if (selectedImage != null) {
        final uploaderUrl = await StorageService.uploadProductImage(
          selectedImage!,
        );
        if (uploaderUrl != null) {
          imageUrl = uploaderUrl;
        }
      }

      //CREAR PRODCUTO
      await FirebaseFirestore.instance.collection('products').add({
        "name": _nameController.text.trim(),

        "description": _descriptionController.text.trim(),

        "price": double.parse(_priceController.text.trim()),
        "stock": int.parse(_stockController.text.trim()),

        "category": selectedCategory,

        //TEMPORAL
        "imageUrl": imageUrl,

        //RELACIONES
        "sellerId": user.uid,
        "shopId": shopId,
        "shopName": shopData["name"],

        //CONTROL
        "isActive": true,

        //FECHAS
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });

      showMessage("Producto creado correctamente");

      Navigator.pop(context);
    } catch (e) {
      showMessage("Error al crear producto");
      debugPrint(e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Crear producto"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            //IMAGEN
            GestureDetector(
              onTap: pickImage,

              child: Container(
                width: double.infinity,
                height: 200,

                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                ),

                child: selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),

                        child: Image.file(selectedImage!, fit: BoxFit.cover),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: 60,
                            color: Colors.black54,
                          ),

                          SizedBox(height: 8),

                          Text("Seleccionar imagen"),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 20),

            //NOMBRE
            TextField(
              controller: _nameController,
              decoration: inputDecoration("Nombre del producto"),
            ),
            const SizedBox(height: 16),

            //DESCRIPCION
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: inputDecoration("Descripción"),
            ),

            const SizedBox(height: 16),

            //PECIO
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: inputDecoration("Precio"),
            ),

            const SizedBox(height: 16),
            //STOCK
            TextField(
              controller: _stockController,
              keyboardType: TextInputType.number,
              decoration: inputDecoration("Stock"),
            ),

            const SizedBox(height: 16),

            //CATEGORIA
            DropdownButtonFormField(
              value: selectedCategory,

              items: categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },

              decoration: inputDecoration("Categoría"),
            ),

            const SizedBox(height: 30),

            //BOTON
            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                onPressed: loading ? null : createProduct,

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Publicar Producto",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();

    super.dispose();
  }
}
