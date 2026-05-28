import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/sync_service.dart';
import 'edit_activities_screen.dart';
import 'auth_screen.dart';

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
          _buildMenuCard(
            context,
            icon: Icons.sync_rounded,
            title: 'Синхронизация',
            subtitle: 'Синхронизация заметок и активностей',
            onTap: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final user = authProvider.currentUser;
              
              if (user == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Пользователь не авторизован'), backgroundColor: Colors.red),
                );
                return;
              }

              // Показываем индикатор загрузки
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (ctx) => AlertDialog(
                  content: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 20),
                      Text('Синхронизация...'),
                    ],
                  ),
                ),
              );

              try {
                final syncService = SyncService();
                final success = await syncService.syncData(user);
                
                if (context.mounted) {
                  Navigator.pop(context); // Закрываем диалог
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success 
                        ? 'Синхронизация успешна!' 
                        : 'Ошибка синхронизации'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
          ),
          _buildMenuCard(
            context,
            icon: Icons.logout_rounded,
            title: 'Выйти',
            subtitle: 'Выйти из аккаунта',
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Выйти?'),
                  content: Text('Вы уверены, что хотите выйти из аккаунта?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('Отмена'),
                    ),
                    TextButton(
                      onPressed: () {
                        Provider.of<AuthProvider>(context, listen: false).logout();
                        Navigator.pop(ctx);
                        // AuthWrapper автоматически переключит на экран авторизации
                      },
                      child: Text('Выйти', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
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
