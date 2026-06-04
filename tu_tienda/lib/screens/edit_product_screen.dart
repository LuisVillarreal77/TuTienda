import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:tu_tienda/services/storage_service.dart';
import '../services/storage_service.dart';

class EditProductScreen extends StatefulWidget {
  final String productId;

  const EditProductScreen({super.key, required this.productId});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  String currentImageUrl = '';
  File? selectedImage;

  String selectedCategory = "Joyeria";

  bool loading = true;

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  final List<String> categories = ["Joyeria", "Tejidos", "Hogar", "Decoracion"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar producto")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: pickImage,

                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(16),
                      ),

                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: selectedImage != null
                            //IMAGEN NUEVA SELECCIONADA
                            ? Image.file(selectedImage!, fit: BoxFit.cover)
                            //IMAGEN EXISTENTE
                            : currentImageUrl.isNotEmpty
                            ? Image.network(currentImageUrl, fit: BoxFit.cover)
                            //SIN IMAGEN
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image, size: 60),
                                  SizedBox(height: 8),
                                  Text("Sin imagen"),
                                ],
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

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
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: inputDecoration("Categoría"),

                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),

                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 55,

                    child: ElevatedButton(
                      onPressed: loading ? null : updateProdut,

                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Guardar cambios"),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> loadProduct() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .get();

      if (!doc.exists) {
        return;
      }

      final data = doc.data()!;

      currentImageUrl = data['imageUrl'] ?? '';

      _nameController.text = data['name'] ?? '';

      _descriptionController.text = data['description'] ?? '';

      _priceController.text = data['price'].toString();

      _stockController.text = data['stock'].toString();

      selectedCategory = data['category'] ?? 'Joyeria';

      setState(() {
        loading = false;
      });
    } catch (e) {
      debugPrint(e.toString());

      setState(() {
        loading = false;
      });
    }
  }

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

  Future<void> updateProdut() async {
    try {
      setState(() {
        loading = true;
      });

      //VALIDACIONES
      if (_nameController.text.isEmpty ||
          _descriptionController.text.isEmpty ||
          _priceController.text.isEmpty ||
          _stockController.text.isEmpty) {
        showMessage("Completa todos los campos");

        setState(() {
          loading = false;
        });
        return;
      }

      String imageUrl = currentImageUrl;

      //SI SELECCIONO UNA NUEVA IMAGEN
      if (selectedImage != null) {
        final uploadedUrl =  await StorageService.uploadProductImage(
          selectedImage!,
        );

        if (uploadedUrl != null) {
          imageUrl = uploadedUrl;
        }
      }

      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .update({
            "name": _nameController.text.trim(),

            "description": _descriptionController.text.trim(),

            "price": double.parse(_priceController.text.trim()),

            "stock": int.parse(_stockController.text.trim()),

            "category": selectedCategory,

            "imageUrl": imageUrl,

            "updatedAt": FieldValue.serverTimestamp(),
          });

      showMessage("Producto actualizado correctamente");

      Navigator.pop(context);
    } catch (e) {
      debugPrint(e.toString());

      showMessage("Error al actualizar producto");
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void initState() {
    super.initState();
    loadProduct();
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
