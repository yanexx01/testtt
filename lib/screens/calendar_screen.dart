import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/diary_provider.dart';
import '../models/entry.dart';
import '../models/mood.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _currentMonth = DateTime.now();

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  void _goToToday() {
    setState(() {
      _currentMonth = DateTime.now();
    });
  }

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
      body: Consumer<DiaryProvider>(
        builder: (context, diaryProvider, child) {
          return Column(
            children: [
              _buildMonthHeader(),
              _buildWeekdayHeaders(),
              Expanded(child: _buildCalendarGrid(diaryProvider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMonthHeader() {
    final monthFormat = DateFormat('LLLL yyyy', 'ru');
    final monthName = monthFormat.format(_currentMonth);
    final capitalizedMonth = monthName[0].toUpperCase() + monthName.substring(1);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        alignItems: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _previousMonth,
          ),
          GestureDetector(
            onTap: _goToToday,
            child: Text(
              capitalizedMonth,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _nextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    final weekdays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return Row(
      children: weekdays.map((day) => Expanded(
        child: Center(
          child: Text(
            day,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildCalendarGrid(DiaryProvider diaryProvider) {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    
    // Определяем день недели первого дня месяца (0 = понедельник, 6 = воскресенье)
    int firstWeekday = firstDayOfMonth.weekday - 1;
    
    // Количество дней в предыдущем месяце
    final lastDayOfPrevMonth = DateTime(_currentMonth.year, _currentMonth.month, 0);
    final daysInPrevMonth = lastDayOfPrevMonth.day;
    
    // Дни из предыдущего месяца
    List<Widget> dayWidgets = [];
    for (int i = firstWeekday - 1; i >= 0; i--) {
      final day = daysInPrevMonth - i;
      final date = DateTime(_currentMonth.year, _currentMonth.month - 1, day);
      dayWidgets.add(_buildDayCell(date, diaryProvider, isCurrentMonth: false));
    }
    
    // Дни текущего месяца
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      dayWidgets.add(_buildDayCell(date, diaryProvider, isCurrentMonth: true));
    }
    
    // Дни из следующего месяца для заполнения сетки
    int totalCells = dayWidgets.length;
    int remainingCells = 42 - totalCells; // 6 строк по 7 дней = 42 ячейки
    for (int day = 1; day <= remainingCells; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month + 1, day);
      dayWidgets.add(_buildDayCell(date, diaryProvider, isCurrentMonth: false));
    }
    
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossMaxCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: dayWidgets.length,
      itemBuilder: (context, index) => dayWidgets[index],
    );
  }

  Widget _buildDayCell(DateTime date, DiaryProvider diaryProvider, {required bool isCurrentMonth}) {
    // Находим все записи для этого дня
    final entriesForDay = diaryProvider.entries.where((entry) {
      return entry.date.year == date.year &&
             entry.date.month == date.month &&
             entry.date.day == date.day;
    }).toList();

    final isToday = DateTime.now().year == date.year &&
                    DateTime.now().month == date.month &&
                    DateTime.now().day == date.day;

    return Container(
      decoration: BoxDecoration(
        color: isCurrentMonth ? Colors.white : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: isToday 
            ? Border.all(color: Colors.indigo, width: 2)
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Рисуем кольцо настроения
          if (entriesForDay.isNotEmpty)
            _buildMoodRing(entriesForDay)
          else
            Container(), // Пустой контейнер если нет записей
          
          // Цифра дня
          Text(
            '${date.day}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: isCurrentMonth ? Colors.black87 : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodRing(List<DiaryEntry> entries) {
    if (entries.isEmpty) {
      return Container();
    }

    return CustomPaint(
      size: const Size(48, 48),
      painter: MoodRingPainter(entries: entries),
    );
  }
}

class MoodRingPainter extends CustomPainter {
  final List<DiaryEntry> entries;

  MoodRingPainter({required this.entries});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4; // Отступ от края
    final ringWidth = 3.0;

    final segmentAngle = (2 * pi) / entries.length;

    for (int i = 0; i < entries.length; i++) {
      final mood = entries[i].mood;
      final startAngle = (i * segmentAngle) - (pi / 2); // Начинаем сверху
      final sweepAngle = segmentAngle;

      final paint = Paint()
        ..color = mood.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant MoodRingPainter oldDelegate) {
    return oldDelegate.entries != entries;
  }
}
