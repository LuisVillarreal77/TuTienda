import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  //AGREGAR O QUITAR UN FAVORITO
  Future<void> toggleFavorite(String productId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

  print("Producto: $productId");
  print("Usuario: ${user.uid}");

    final snapshot = await _db
        .collection('favorites')
        .where('userId', isEqualTo: user.uid)
        .where('productId', isEqualTo: productId)
        .get();

print("Favoritos encontrados: ${snapshot.docs.length}");

    if (snapshot.docs.isEmpty) {
          print("Añadiendo favorito");
      //AÑADIR A FAVORITOS
      await _db.collection('favorites').add({
        'userId': user.uid,
        'productId': productId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      //QUITAR DE FAVORITOS
          print("Eliminando favorito");
      await snapshot.docs.first.reference.delete();
    }
  }

  //SABER SI UN PRODUCTO YA ES FAVORITO
  Stream<bool> isFavorite(String productId) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Stream.value(false);
    }

    return _db
        .collection('favorites')
        .where('userId', isEqualTo: user.uid)
        .where('productId', isEqualTo: productId)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty);
  }

  //OBTENER TODOS LOS FAVORITOS DEL USUARIO
  Stream<QuerySnapshot> getFavorites() {
    final user = FirebaseAuth.instance.currentUser;

    return _db
        .collection('favorites')
        .where('userId', isEqualTo: user!.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
