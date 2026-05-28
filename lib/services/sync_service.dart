import 'package:flutter/material.dart';
import '../models/user.dart';

/// Заглушка для сервиса синхронизации.
/// В будущем здесь будет логика синхронизации с сервером.
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  bool _isSyncing = false;

  /// Синхронизация заметок и активностей пользователя.
  /// Сейчас это просто заглушка, которая имитирует процесс синхронизации.
  Future<bool> syncData(User user) async {
    _isSyncing = true;
    
    // Имитация задержки сети
    await Future.delayed(Duration(seconds: 2));
    
    _isSyncing = false;
    return true; // Успешная синхронизация (заглушка)
  }

  bool get isSyncing => _isSyncing;
}
