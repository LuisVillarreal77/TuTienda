import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {

  final Map<String, dynamic> userData;

  final VoidCallback onBlock;
  final VoidCallback onActivate;
  final VoidCallback onDelete;

  const UserTile({
    super.key,
    required this.userData,
    required this.onBlock,
    required this.onActivate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {

    final name =
        userData['name'] ?? 'Sin nombre';

    final email =
        userData['email'] ?? '';

    final role =
        userData['role'] ?? 'buyer';

    final status =
        userData['status'] ?? 'active';

    return Card(

      margin: const EdgeInsets.only(bottom: 12),

      child: Padding(
        padding: const EdgeInsets.all(12),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 4),

            Text(email),

            const SizedBox(height: 6),

            Text(
              'Rol: $role',
            ),

            Text(
              'Estado: $status',
              style: TextStyle(
                color: status == 'blocked'
                    ? Colors.red
                    : Colors.green,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [

                ElevatedButton(
                  onPressed: onBlock,
                  child: const Text(
                    'Bloquear',
                  ),
                ),

                const SizedBox(width: 8),

                ElevatedButton(
                  onPressed: onActivate,
                  child: const Text(
                    'Activar',
                  ),
                ),

                const SizedBox(width: 8),

                ElevatedButton(
                  onPressed: onDelete,
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text(
                    'Eliminar',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}