import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/admin_service.dart';
import '../widgets/stat_card.dart';
import '../widgets/user_tile.dart';

class SecurityDashboardScreen extends StatefulWidget {
  const SecurityDashboardScreen({super.key});

  @override
  State<SecurityDashboardScreen> createState() =>
      _SecurityDashboardScreenState();
}

class _SecurityDashboardScreenState extends State<SecurityDashboardScreen> {
  final AdminService _adminservice = AdminService();

  int usersCount = 0;
  int shopsCount = 0;
  int productsCount = 0;

  @override
  void initState() {
    super.initState();

    loadStats();
  }

  Future<void> loadStats() async {
    usersCount = await _adminservice.getUsersCount();

    shopsCount = await _adminservice.getShopsCount();

    productsCount = await _adminservice.getProductsCount();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text('Dashboard de Seguridad'),

        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,

        actions: [
          IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => _logout(context),
          ),          
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            //Titulo
            const Text(
              'Resumen del sistema',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            GestureDetector(
  onTap: () {
    Navigator.pushNamed(context, '/loginStats');
  },
  child: Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    margin: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
      color: Colors.deepOrange[400],
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [

        // Ícono
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.bar_chart,
            color: Colors.white,
            size: 30,
          ),
        ),

        const SizedBox(width: 16),

        // Texto
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                "Estadísticas de Login",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 4),

              Text(
                "Visualiza intentos exitosos y fallidos",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        // Flecha
        const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white,
          size: 18,
        ),
      ],
    ),
  ),
),

             const SizedBox(height: 16),

            //CARDS DE ESTADISTICAS
            Row(
              children: [
                StatCard(
                  title: 'Usuarios',
                  value: usersCount.toString(),
                  icon: Icons.people,
                ),

                StatCard(
                  title: 'Tiendas',
                  value: shopsCount.toString(),
                  icon: Icons.store,
                ),

                StatCard(
                  title: 'Productos',
                  value: productsCount.toString(),
                  icon: Icons.shopping_bag,
                ),

                
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              'Usuarios registrados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            //LISTA DE USUARIOS
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _adminservice.getUsers(),

                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No hay usuarios'));
                  }

                  final users = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: users.length,

                    itemBuilder: (context, index) {
                      final user = users[index].data() as Map<String, dynamic>;

                      final userId = users[index].id;

                      return UserTile(
                        userData: user,

                       onBlock: () async {
                        
                          final confirm = await showDialog<bool>(

                            context: context,
                            builder: (context) {

                              return AlertDialog(

                                title: const Text(
                                  'Bloquear usuario',
                                ),
                                content: Text(
                                  '¿Deseas bloquear a ${user['name']}?',
                                ),

                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, false);
                                    },

                                    child: const Text('Cancelar'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context, true);
                                    },

                                    child: const Text('Bloquear'),
                                  ),
                                ],
                              );
                            },
                          );

                          // Si cancela
                          if (confirm != true) return;
                          
                          if (user['role'] == 'admin') {

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'No puedes bloquear administradores',
                                  ),
                                ),
                              );

                              return;
                            }

                          await _adminservice.blockUser(userId);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Usuario bloqueado'),
                            ),
                          );
                        },

                        onActivate: () async {
                          await _adminservice.activateUser(userId);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Usuario activado')),
                          );
                        },

                      onDelete: () async {

                        final confirm = await showDialog<bool>(

                          context: context,
                          builder: (context) {

                            return AlertDialog(
                              title: const Text(
                                'Eliminar usuario',
                              ),

                              content: Text(
                                '¿Deseas eliminar a ${user['name']}?',
                              ),

                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, false);
                                  },

                                  child: const Text('Cancelar'),
                                ),

                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),

                                  onPressed: () {
                                    Navigator.pop(context, true);
                                  },

                                  child: const Text(
                                    'Eliminar',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );

                        // Si cancela
                        if (confirm != true) return;

                        if (user['role'] == 'admin') {

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'No puedes eliminar administradores',
                                ),
                              ),
                            );

                            return;
                          }

                        await _adminservice.deleteUser(userId);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Usuario eliminado'),
                          ),
                        );
                      },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushNamedAndRemoveUntil(
      context, 
      '/login', 
      (route) => false,
      );
  }
}
