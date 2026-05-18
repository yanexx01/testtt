import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/diary_provider.dart';

class EditActivitiesScreen extends StatefulWidget {
  const EditActivitiesScreen({super.key});

  @override
  State<EditActivitiesScreen> createState() => _EditActivitiesScreenState();
}

class _EditActivitiesScreenState extends State<EditActivitiesScreen> {
  late TextEditingController _controller;
  late List<String> _activities;
  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _loadActivities();
  }

  void _loadActivities() {
    final provider = Provider.of<DiaryProvider>(context, listen: false);
    _activities = List.from(provider.activities);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addActivity() {
    if (_controller.text.trim().isNotEmpty) {
      setState(() {
        if (_editingIndex != null) {
          _activities[_editingIndex!] = _controller.text.trim();
          _editingIndex = null;
        } else {
          _activities.add(_controller.text.trim());
        }
        _controller.clear();
      });
      _saveActivities();
    }
  }

  void _removeActivity(int index) {
    setState(() {
      _activities.removeAt(index);
      if (_editingIndex == index) {
        _editingIndex = null;
        _controller.clear();
      }
    });
    _saveActivities();
  }

  void _editActivity(int index) {
    setState(() {
      _editingIndex = index;
      _controller.text = _activities[index];
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingIndex = null;
      _controller.clear();
    });
  }

  void _saveActivities() {
    Provider.of<DiaryProvider>(context, listen: false).saveActivities(_activities);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Редактирование активностей'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: _editingIndex != null ? 'Изменить активность' : 'Новая активность',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onSubmitted: (_) => _addActivity(),
                  ),
                ),
                SizedBox(width: 12),
                if (_editingIndex != null) ...[
                  ElevatedButton.icon(
                    onPressed: _cancelEdit,
                    icon: Icon(Icons.close),
                    label: Text('Отмена'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  SizedBox(width: 8),
                ],
                ElevatedButton.icon(
                  onPressed: _addActivity,
                  icon: Icon(_editingIndex != null ? Icons.check : Icons.add),
                  label: Text(_editingIndex != null ? 'Сохранить' : 'Добавить'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _activities.length,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final isActiveEditing = _editingIndex == index;
                return Card(
                  margin: EdgeInsets.only(bottom: 8),
                  color: isActiveEditing ? Colors.indigo.shade50 : null,
                  child: ListTile(
                    title: Text(
                      _activities[index],
                      style: TextStyle(
                        fontWeight: isActiveEditing ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editActivity(index),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeActivity(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
