import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/entry.dart';
import '../providers/diary_provider.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
  }

  List<DiaryEntry> _getEntriesForDay(DateTime day, List<DiaryEntry> allEntries) {
    return allEntries
        .where((entry) =>
            entry.date.year == day.year &&
            entry.date.month == day.month &&
            entry.date.day == day.day)
        .toList();
  }

  List<DateTime> _getCalendarDays(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final startDate = firstDay.subtract(Duration(days: firstDay.weekday % 7));

    final days = <DateTime>[];
    var current = startDate;
    while (current.isBefore(lastDay) || current.weekday != DateTime.sunday) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${_monthName(_currentMonth.month)} ${_currentMonth.year}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
              });
            },
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
            });
          },
        ),
      ),
      body: Consumer<DiaryProvider>(
        builder: (context, diaryProvider, _) {
          final calendarDays = _getCalendarDays(_currentMonth);
          final allEntries = diaryProvider.entries;

          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildWeekdayLabels(),
                      const SizedBox(height: 8),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                          childAspectRatio: 1,
                        ),
                        itemCount: calendarDays.length,
                        itemBuilder: (context, index) {
                          final day = calendarDays[index];
                          final isCurrentMonth =
                              day.month == _currentMonth.month;
                          final dayEntries =
                              _getEntriesForDay(day, allEntries);

                          return _buildCalendarDay(
                            day,
                            isCurrentMonth,
                            dayEntries,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeekdayLabels() {
    const weekdays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 1,
      ),
      itemCount: 7,
      itemBuilder: (context, index) {
        return Center(
          child: Text(
            weekdays[index],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalendarDay(
    DateTime day,
    bool isCurrentMonth,
    List<DiaryEntry> dayEntries,
  ) {
    final isToday = day.year == DateTime.now().year &&
        day.month == DateTime.now().month &&
        day.day == DateTime.now().day;

    return GestureDetector(
      onTap: isCurrentMonth ? () => _showDayDialog(day, dayEntries) : null,
      child: Container(
        decoration: BoxDecoration(
          color: isCurrentMonth
              ? (isToday ? Colors.indigo.shade50 : Colors.white)
              : Colors.grey[100],
          border: isToday
              ? Border.all(color: Colors.indigo, width: 2)
              : Border.all(color: Colors.grey[300]!, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (dayEntries.isNotEmpty)
              CustomPaint(
                painter: MoodRingPainter(
                  moodColors: dayEntries.map((e) => e.mood.color).toList(),
                ),
                size: const Size.square(55),
              ),
            Center(
              child: Text(
                day.day.toString(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isCurrentMonth ? Colors.black : Colors.grey[400],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDayDialog(DateTime day, List<DiaryEntry> dayEntries) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '${day.day} ${_monthName(day.month)} ${day.year}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: dayEntries.isEmpty
              ? Center(
                  child: Text(
                    'Нет заметок',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: dayEntries.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final entry = dayEntries[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: entry.mood.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                entry.mood.label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (entry.note != null && entry.note!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            entry.note!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                        if (entry.activities.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 4,
                            children: entry.activities
                                .map(
                                  (activity) => Chip(
                                    label: Text(
                                      activity,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ],
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
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

class MoodRingPainter extends CustomPainter {
  final List<Color> moodColors;
  static const double ringWidth = 6;
  static const double ringRadius = 20;

  MoodRingPainter({required this.moodColors});

  @override
  void paint(Canvas canvas, Size size) {
    if (moodColors.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final segmentAngle = (2 * 3.14159265359) / moodColors.length;

    for (int i = 0; i < moodColors.length; i++) {
      final startAngle = (i * segmentAngle) - (3.14159265359 / 2);
      final paint = Paint()
        ..color = moodColors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCenter(
          center: center,
          width: ringRadius * 2,
          height: ringRadius * 2,
        ),
        startAngle,
        segmentAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(MoodRingPainter oldDelegate) {
    return oldDelegate.moodColors != moodColors;
  }
}
