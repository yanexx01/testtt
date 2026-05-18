import 'package:flutter/material.dart';

enum MoodType { awesome, good, neutral, bad, awful }

class Mood {
  final MoodType type;
  final IconData icon;
  final Color color;
  final String label;

  const Mood({
    required this.type,
    required this.icon,
    required this.color,
    required this.label,
  });

  static const List<Mood> all = [
    Mood(type: MoodType.awesome, icon: Icons.sentiment_very_satisfied, color: Colors.green, label: 'Отлично'),
    Mood(type: MoodType.good, icon: Icons.sentiment_satisfied, color: Colors.lightGreen, label: 'Хорошо'),
    Mood(type: MoodType.neutral, icon: Icons.sentiment_neutral, color: Colors.orange, label: 'Норм'),
    Mood(type: MoodType.bad, icon: Icons.sentiment_dissatisfied, color: Colors.deepOrange, label: 'Плохо'),
    Mood(type: MoodType.awful, icon: Icons.sentiment_very_dissatisfied, color: Colors.red, label: 'Ужасно'),
  ];
}