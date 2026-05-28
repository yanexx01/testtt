import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/entry.dart';
import '../models/activity.dart';
import '../services/api_service.dart';

class SyncProvider with ChangeNotifier {
  final ApiService _apiService;
  late Box<DiaryEntry> _box;
  late Box<ActivityList> _activityBox;
  
  bool _isSyncing = false;
  String? _lastSyncError;
  DateTime? _lastSyncTime;

  SyncProvider({required String baseUrl}) : _apiService = ApiService(baseUrl: baseUrl) {
    _box = Hive.box<DiaryEntry>('diary_entries');
    _activityBox = Hive.box<ActivityList>('activities');
  }

  bool get isSyncing => _isSyncing;
  String? get lastSyncError => _lastSyncError;
  DateTime? get lastSyncTime => _lastSyncTime;

  // Синхронизация записей: скачивание с сервера и слияние с локальными
  Future<void> syncEntries() async {
    _isSyncing = true;
    _lastSyncError = null;
    notifyListeners();

    try {
      // Получаем записи с сервера
      final serverEntries = await _apiService.fetchEntries();
      
      // Сливаем с локальными данными (приоритет у более новых записей)
      for (var serverEntry in serverEntries) {
        final localEntry = _box.get(serverEntry.id);
        
        if (localEntry == null) {
          // Запись есть только на сервере - добавляем локально
          await _box.put(serverEntry.id, serverEntry);
        } else {
          // Запись есть и локально, и на сервере - оставляем более новую
          if (serverEntry.date.isAfter(localEntry.date)) {
            await _box.put(serverEntry.id, serverEntry);
          }
        }
      }

      // Отправляем локальные записи на сервер
      for (var localEntry in _box.values) {
        await _apiService.uploadEntry(localEntry);
      }

      _lastSyncTime = DateTime.now();
    } catch (e) {
      _lastSyncError = e.toString();
      rethrow;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  // Синхронизация активностей
  Future<void> syncActivities() async {
    _isSyncing = true;
    _lastSyncError = null;
    notifyListeners();

    try {
      // Получаем активности с сервера
      final serverActivities = await _apiService.fetchActivities();
      
      // Обновляем локальные данные
      if (_activityBox.isEmpty) {
        _activityBox.put('user_activities', ActivityList.withActivities(serverActivities));
      } else {
        var existing = _activityBox.getAt(0);
        existing!.activities = serverActivities;
        _activityBox.put('user_activities', existing);
      }

      // Отправляем локальные активности на сервер
      final localActivities = activities;
      await _apiService.uploadActivities(localActivities);

      _lastSyncTime = DateTime.now();
    } catch (e) {
      _lastSyncError = e.toString();
      rethrow;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  // Полная синхронизация всего
  Future<void> syncAll() async {
    await syncEntries();
    await syncActivities();
  }

  // Отправка изменений на сервер при создании записи
  Future<void> uploadEntry(DiaryEntry entry) async {
    try {
      await _apiService.uploadEntry(entry);
    } catch (e) {
      // Сохраняем ошибку для последующей повторной отправки
      _lastSyncError = e.toString();
      notifyListeners();
    }
  }

  // Отправка изменений на сервер при обновлении записи
  Future<void> updateEntry(DiaryEntry entry) async {
    try {
      await _apiService.updateEntry(entry);
    } catch (e) {
      _lastSyncError = e.toString();
      notifyListeners();
    }
  }

  // Удаление записи на сервере
  Future<void> deleteEntry(String id) async {
    try {
      await _apiService.deleteEntry(id);
    } catch (e) {
      _lastSyncError = e.toString();
      notifyListeners();
    }
  }

  // Геттер для активностей (из локального хранилища)
  List<String> get activities {
    if (_activityBox.isEmpty) {
      return ['Работа', 'Спорт', 'Дом', 'Друзья', 'Хобби', 'Путешествие', 'Еда'];
    }
    return _activityBox.getAt(0)?.activities ?? ['Работа', 'Спорт', 'Дом', 'Друзья', 'Хобби', 'Путешествие', 'Еда'];
  }
}
