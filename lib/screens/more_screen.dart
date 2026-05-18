import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/activity.dart';
import '../providers/diary_provider.dart';
import 'edit_activities_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Больше'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildMenuCard(
            context,
            icon: Icons.edit_note_rounded,
            title: 'Добавление активностей',
            subtitle: 'Быстрое добавление новых активностей',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddActivitiesScreen()),
              );
            },
          ),
          _buildMenuCard(
            context,
            icon: Icons.manage_search_rounded,
            title: 'Редактирование активностей',
            subtitle: 'Изменение и удаление активностей',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditActivitiesScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.indigo.shade100,
                child: Icon(icon, color: Colors.indigo, size: 30),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}

class AddActivitiesScreen extends StatefulWidget {
  const AddActivitiesScreen({super.key});

  @override
  State<AddActivitiesScreen> createState() => _AddActivitiesScreenState();
}

class _AddActivitiesScreenState extends State<AddActivitiesScreen> {
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