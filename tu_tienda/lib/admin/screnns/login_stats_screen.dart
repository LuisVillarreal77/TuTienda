import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class LoginStatsScreen extends StatefulWidget {
  const LoginStatsScreen({super.key});

  @override
  State<LoginStatsScreen> createState() => _LoginStatsScreenState();
}

class _LoginStatsScreenState extends State<LoginStatsScreen> {
  Map<String, int> successCounts = {};
  Map<String, int> failedCounts = {};

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    
    successCounts.clear();
    failedCounts.clear();

    final snapshot = await FirebaseFirestore.instance
        .collection('login_logs')
        .orderBy('timestamp', descending: true)
        .get();

    for (var doc in snapshot.docs) {

      final data = doc.data();

      final email = data['email'] ?? 'desconocido';

      final status = data['status'] ?? 'failed';

      //Login exitoso
      if (status == 'success') {
        successCounts[email] = (successCounts[email] ?? 0) + 1;
      } 
      //Login fallido
      else if (status == 'failed') {
        failedCounts[email] = (failedCounts[email] ?? 0) + 1;
      }
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(),
      ),
      );
    }

    final users = {
      ...successCounts.keys, 
      ...failedCounts.keys,
      }.toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Estadísticas de Login")),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 80,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();

                    if (index >= users.length) {
                      return const SizedBox();
                    }

                    return Transform.rotate(
                      angle: -0.5,
                      child: Text(
                        users[index],
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  },
                ),
              ),
            ),

            barGroups: List.generate(users.length, (index) {
              final user = users[index];

              final success = successCounts[user] ?? 0;

              final failed = failedCounts[user] ?? 0;

              return BarChartGroupData(
                x: index,

                barRods: [
                  //Logins exitosos
                  BarChartRodData(
                    toY: success.toDouble(),
                    width: 10,
                    color: Colors.green,
                  ),

                  //Login fallidos
                  BarChartRodData(
                    toY: failed.toDouble(),
                    width: 10,
                    color: Colors.red,
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
