import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Obtner usuarios
  Stream<QuerySnapshot> getUsers() {
    return _db
        .collection('users')
        .snapshots();
  }

  //Total usuarios
  Future<int> getUsersCount() async {
    final snapshots = await _db.collection('users').get();

    return snapshots.docs.length;
  }

  //Total tiendas
  Future<int> getShopsCount() async {
    final snapshots = await _db.collection('shops').get();

    return snapshots.docs.length;
  }

  Future<int> getProductsCount() async {
    final snapshots = await _db.collection('products').get();

    return snapshots.docs.length;
  }

  //Bloquear usuario
  Future<void> blockUser(String userId) async {

    await _db
    .collection('users')
    .doc(userId)
    .update({
        'status': 'blocked',
        });
  }

  Future<void> activateUser(String userId) async {

    await _db
    .collection('users')
    .doc(userId)
    .update({
        'status': 'active'
    });
  }

  //Eliminar usuario Firestore
  Future<void> deleteUser(String userId) async {
    await _db
    .collection('users')
    .doc(userId)
    .delete();
  }
}
