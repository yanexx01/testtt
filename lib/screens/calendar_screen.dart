import 'package:flutter/material.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Календарь'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_month, size: 80, color: Colors.grey[300]),
            SizedBox(height: 20),
            Text(
              'Календарь в разработке',
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
