import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/entry.dart';
import '../models/mood.dart';
import '../providers/diary_provider.dart';
import 'package:intl/intl.dart';

class AddEntryScreen extends StatefulWidget {
  final DiaryEntry? existingEntry;

  const AddEntryScreen({super.key, this.existingEntry});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  late Mood _selectedMood;
  // final List<String> _availableActivities = ['Работа', 'Спорт', 'Дом', 'Друзья', 'Хобби', 'Путешествие', 'Еда'];
  late List<String> _selectedActivities;
  late TextEditingController _noteController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.existingEntry != null;

    if (_isEditing && widget.existingEntry != null) {
      _selectedMood = widget.existingEntry!.mood;
      _selectedActivities = List.from(widget.existingEntry!.activities);
      _noteController = TextEditingController(text: widget.existingEntry!.note ?? '');
      _selectedDate = widget.existingEntry!.date;
      _selectedTime = TimeOfDay.fromDateTime(widget.existingEntry!.date);
    } else {
      _selectedMood = Mood.all[2];
      _selectedActivities = [];
      _noteController = TextEditingController();
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
    }
  }

  List<String> get _availableActivities {
    return Provider.of<DiaryProvider>(context, listen: false).activities;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _toggleActivity(String activity) {
    setState(() {
      if (_selectedActivities.contains(activity)) {
        _selectedActivities.remove(activity);
      } else {
        _selectedActivities.add(activity);
      }
    });
  }

  void _saveEntry() {

    final noteText = _noteController.text.isEmpty ? null : _noteController.text;

    final combinedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    if (_isEditing && widget.existingEntry != null) {

      final updatedEntry = DiaryEntry.create(
        id: widget.existingEntry!.id,
        date: combinedDateTime,
        mood: _selectedMood,
        activities: _selectedActivities,
        note: noteText,
      );

      Provider.of<DiaryProvider>(context, listen: false).updateEntry(updatedEntry);
    } else {
      final newEntry = DiaryEntry.create(
        id: combinedDateTime.toString(),
        date: combinedDateTime,
        mood: _selectedMood,
        activities: _selectedActivities,
        note: noteText,
      );

      Provider.of<DiaryProvider>(context, listen: false).addEntry(newEntry);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditing ? 'Редактировать запись' : 'Новая запись';
    final saveButtonText = _isEditing ? 'Сохранить изменения' : 'Сохранить';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: _selectedMood.color,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Выбор даты и времени
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text('Дата', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    subtitle: Text(DateFormat('dd MMMM yyyy').format(_selectedDate), style: TextStyle(fontSize: 16)),
                    leading: Icon(Icons.calendar_today, color: _selectedMood.color),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now().add(Duration(days: 1)),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text('Время', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    subtitle: Text(_selectedTime.format(context), style: TextStyle(fontSize: 16)),
                    leading: Icon(Icons.access_time, color: _selectedMood.color),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime,
                      );
                      if (picked != null) {
                        setState(() => _selectedTime = picked);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Выбор настроения
            Text('Как прошел день?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: Mood.all.map((mood) {
                final isSelected = _selectedMood.type == mood.type;
                return GestureDetector(
                  onTap: () => setState(() => _selectedMood = mood),
                  child: Column(
                    children: [
                      Icon(
                        mood.icon,
                        size: 40,
                        color: isSelected ? mood.color : Colors.grey[400],
                      ),
                      if (isSelected)
                        Text(mood.label, style: TextStyle(fontSize: 12, color: mood.color, fontWeight: FontWeight.bold))
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),

            // Выбор активностей
            Text('Чем занимался?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableActivities.map((activity) {
                final isSelected = _selectedActivities.contains(activity);
                return ChoiceChip(
                  label: Text(activity),
                  selected: isSelected,
                  onSelected: (_) => _toggleActivity(activity),
                  selectedColor: _selectedMood.color.withOpacity(0.3),
                  checkmarkColor: _selectedMood.color,
                );
              }).toList(),
            ),
            const SizedBox(height: 30),

            // Заметка
            TextField(
              controller: _noteController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Добавить заметку...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 30),

            // Кнопка сохранения
            ElevatedButton(
              onPressed: _saveEntry,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedMood.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(saveButtonText, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}