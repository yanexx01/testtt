import 'package:flutter/material.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Статистика'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 80, color: Colors.grey[300]),
            SizedBox(height: 20),
            Text(
              'Статистика в разработке',
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
