import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/sync_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Личный кабинет'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.check),
              onPressed: _saveProfile,
            )
          else
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: Consumer2<AuthProvider, SyncProvider>(
        builder: (context, authProvider, syncProvider, child) {
          final user = authProvider.currentUser;
          
          if (user == null) {
            return Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Карточка профиля
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.indigo.shade100,
                          child: Icon(Icons.person, size: 40, color: Colors.indigo),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: _nameController,
                          enabled: _isEditing,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            labelText: 'Имя',
                            border: _isEditing
                                ? OutlineInputBorder(borderRadius: BorderRadius.circular(8))
                                : InputBorder.none,
                          ),
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          enabled: _isEditing,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: _isEditing
                                ? OutlineInputBorder(borderRadius: BorderRadius.circular(8))
                                : InputBorder.none,
                          ),
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 24),
                
                // Синхронизация
                Text(
                  'Синхронизация',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              syncProvider.isSyncing
                                  ? Icons.sync
                                  : Icons.cloud_done,
                              color: syncProvider.isSyncing
                                  ? Colors.orange
                                  : Colors.green,
                              size: 32,
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    syncProvider.isSyncing
                                        ? 'Синхронизация...'
                                        : 'Данные синхронизированы',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  if (syncProvider.lastSyncTime != null)
                                    Text(
                                      'Последняя: ${_formatLastSync(syncProvider.lastSyncTime!)}',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton.icon(
                            onPressed: syncProvider.isSyncing
                                ? null
                                : () async {
                                    await syncProvider.syncAll();
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Синхронизация завершена'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  },
                            icon: Icon(Icons.refresh),
                            label: Text('Синхронизировать сейчас'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        if (syncProvider.lastSyncError != null) ...[
                          SizedBox(height: 12),
                          Text(
                            'Ошибка: ${syncProvider.lastSyncError}',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 24),
                
                // Выход и удаление аккаунта
                Text(
                  'Аккаунт',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.orange),
                  title: Text('Выйти'),
                  onTap: () => _showLogoutDialog(context),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                ListTile(
                  leading: Icon(Icons.delete_forever, color: Colors.red),
                  title: Text('Удалить аккаунт', style: TextStyle(color: Colors.red)),
                  onTap: () => _showDeleteAccountDialog(context),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatLastSync(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inMinutes < 1) {
      return 'Только что';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes} мин назад';
    } else if (diff.inDays < 1) {
      return '${diff.inHours} ч назад';
    } else {
      return '${diff.inDays} дн назад';
    }
  }

  void _saveProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      await authProvider.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
      );
      
      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Профиль обновлен'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка обновления: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Выйти?'),
        content: Text('Вы хотите выйти из аккаунта?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pop(ctx);
              Navigator.of(context).pushReplacementNamed('/auth');
            },
            child: Text('Выйти', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Удалить аккаунт?'),
        content: Text('Это действие нельзя отменить. Все данные будут удалены.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).deleteAccount();
              if (mounted) {
                Navigator.pop(ctx);
                Navigator.of(context).pushReplacementNamed('/auth');
              }
            },
            child: Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
