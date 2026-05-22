import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/entry.dart';
import '../models/mood.dart';
import '../providers/diary_provider.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
  }

  Map<int, List<DiaryEntry>> _getEntriesByDay(
    DateTime month,
    List<DiaryEntry> allEntries,
  ) {
    final Map<int, List<DiaryEntry>> entriesByDay = {};

    for (int day = 1; day <= _getDaysInMonth(month); day++) {
      final dayDate = DateTime(month.year, month.month, day);
      final dayEntries = allEntries
          .where((entry) =>
              entry.date.year == dayDate.year &&
              entry.date.month == dayDate.month &&
              entry.date.day == dayDate.day)
          .toList();
      if (dayEntries.isNotEmpty) {
        entriesByDay[day] = dayEntries;
      }
    }

    return entriesByDay;
  }

  int _getDaysInMonth(DateTime month) {
    return DateTime(month.year, month.month + 1, 0).day;
  }

  List<FlSpot> _buildSpots(Map<int, List<DiaryEntry>> entriesByDay) {
    final spots = <FlSpot>[];
    for (int day = 1; day <= _getDaysInMonth(_selectedMonth); day++) {
      if (entriesByDay.containsKey(day)) {
        final dayMood = entriesByDay[day]!.first.mood;
        final score = _getMoodScore(dayMood);
        spots.add(FlSpot(day.toDouble(), score));
      }
    }
    return spots;
  }

  double _getMoodScore(Mood mood) {
    switch (mood.type) {
      case MoodType.awesome:
        return 5;
      case MoodType.good:
        return 4;
      case MoodType.neutral:
        return 3;
      case MoodType.bad:
        return 2;
      case MoodType.awful:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Consumer<DiaryProvider>(
        builder: (context, diaryProvider, _) {
          final entriesByDay = _getEntriesByDay(_selectedMonth, diaryProvider.entries);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMonthSelector(),
                const SizedBox(height: 24),
                if (entriesByDay.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bar_chart, size: 80, color: Colors.grey[300]),
                          const SizedBox(height: 20),
                          Text(
                            'Нет данных за ${_monthName(_selectedMonth.month)}',
                            style: TextStyle(color: Colors.grey[500], fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  _buildMoodChart(
                    _buildSpots(entriesByDay),
                    _getDaysInMonth(_selectedMonth),
                  ),
                  const SizedBox(height: 24),
                  _buildStatistics(entriesByDay),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
            });
          },
        ),
        Text(
          '${_monthName(_selectedMonth.month)} ${_selectedMonth.year}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            setState(() {
              _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
            });
          },
        ),
      ],
    );
  }

  Widget _buildMoodChart(List<FlSpot> spots, int daysInMonth) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey[300]!, blurRadius: 8, spreadRadius: 0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Настроение за месяц',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[200],
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: (daysInMonth / 7).ceil().toDouble(),
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final moodLabels = ['', 'Ужасно', 'Плохо', 'Норм', 'Хорошо', 'Отлично'];
                        return Text(
                          value.toInt() < moodLabels.length
                              ? moodLabels[value.toInt()]
                              : '',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        );
                      },
                      interval: 1,
                      reservedSize: 50,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                    left: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                ),
                minY: 0,
                maxY: 5,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.indigo,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.indigo,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.indigo.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(Map<int, List<DiaryEntry>> entriesByDay) {
    final moodCounts = {
      MoodType.awesome: 0,
      MoodType.good: 0,
      MoodType.neutral: 0,
      MoodType.bad: 0,
      MoodType.awful: 0,
    };

    for (final entries in entriesByDay.values) {
      for (final entry in entries) {
        moodCounts[entry.mood.type] = (moodCounts[entry.mood.type] ?? 0) + 1;
      }
    }

    final totalDays = entriesByDay.length;
    final avgMood = entriesByDay.values
            .map((e) => e.map((entry) => _getMoodScore(entry.mood)).reduce((a, b) => a + b))
            .reduce((a, b) => a + b) /
        totalDays;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey[300]!, blurRadius: 8, spreadRadius: 0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Итоги',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildStatRow('Среднее настроение', _getMoodLabel(avgMood), Colors.indigo),
          const SizedBox(height: 12),
          _buildStatRow('Дней с данными', totalDays.toString(), Colors.green),
          const SizedBox(height: 16),
          const Text(
            'Распределение по настроениям',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...Mood.all.map((mood) {
            final count = moodCounts[mood.type] ?? 0;
            final percentage = totalDays > 0 ? (count / totalDays * 100).toStringAsFixed(1) : '0';
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: mood.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(mood.label),
                  ),
                  Text(
                    '$count ($percentage%)',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: mood.color,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  String _getMoodLabel(double score) {
    if (score >= 4.5) return 'Отлично';
    if (score >= 3.5) return 'Хорошо';
    if (score >= 2.5) return 'Норм';
    if (score >= 1.5) return 'Плохо';
    return 'Ужасно';
  }

  String _monthName(int month) {
    const months = [
      'Январь',
      'Февраль',
      'Март',
      'Апрель',
      'Май',
      'Июнь',
      'Июль',
      'Август',
      'Сентябрь',
      'Октябрь',
      'Ноябрь',
      'Декабрь'
    ];
    return months[month - 1];
  }
}
