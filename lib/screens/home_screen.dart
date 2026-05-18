import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/diary_provider.dart';
import 'add_entry_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Мой Дневник'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Consumer<DiaryProvider>(
        builder: (context, provider, child) {
          final entries = provider.entries;

          if (entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_note_rounded, size: 80, color: Colors.grey[300]),
                  SizedBox(height: 20),
                  Text(
                    'Пока нет записей.\nНажми + чтобы добавить!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: entries.length,
            padding: EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final entry = entries[index];

              return Dismissible(
                key: Key(entry.id),
                direction: DismissDirection.endToStart, // Только свайп влево
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.delete_outline, color: Colors.white, size: 30),
                ),
                confirmDismiss: (direction) async {
                  // Подтверждение перед удалением
                  return await showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('Удалить запись?'),
                      content: Text('Это действие нельзя отменить.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Отмена')),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text('Удалить', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) {
                  Provider.of<DiaryProvider>(context, listen: false).deleteEntry(entry.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Запись удалена'), backgroundColor: Colors.red),
                  );
                },
                child: Card(
                  elevation: 2,
                  margin: EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    onTap: () {
                      // Переход к редактированию
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEntryScreen(existingEntry: entry),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Аватар настроения
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: entry.mood.color,
                            child: Icon(entry.mood.icon, color: Colors.white, size: 30),
                          ),
                          SizedBox(width: 16),
                          // Информация
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat('dd MMMM yyyy', 'ru').format(entry.date),
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                SizedBox(height: 4),
                                if (entry.activities.isNotEmpty)
                                  Text(
                                    entry.activities.join(', '),
                                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                else
                                  Text('Нет активностей', style: TextStyle(color: Colors.grey[400], fontSize: 14)),

                                if (entry.note != null && entry.note!.isNotEmpty) ...[
                                  SizedBox(height: 6),
                                  Text(
                                    entry.note!,
                                    style: TextStyle(color: Colors.black87, fontStyle: FontStyle.italic),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // Иконка редактирования
                          Icon(Icons.chevron_right, color: Colors.grey[400]),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEntryScreen()),
          );
        },
        icon: Icon(Icons.add),
        label: Text('Запись'),
        backgroundColor: Colors.indigo,
      ),
    );
  }
}