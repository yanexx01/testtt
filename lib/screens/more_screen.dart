import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/activity.dart';
import '../providers/diary_provider.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  late TextEditingController _controller;
  late List<String> _activities;

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
        _activities.add(_controller.text.trim());
        _controller.clear();
      });
      _saveActivities();
    }
  }

  void _removeActivity(int index) {
    setState(() {
      _activities.removeAt(index);
    });
    _saveActivities();
  }

  void _saveActivities() {
    Provider.of<DiaryProvider>(context, listen: false).saveActivities(_activities);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Управление активностями'),
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
                      hintText: 'Новая активность',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onSubmitted: (_) => _addActivity(),
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _addActivity,
                  icon: Icon(Icons.add),
                  label: Text('Добавить'),
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
                return Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(_activities[index]),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeActivity(index),
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