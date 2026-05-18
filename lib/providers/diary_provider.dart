import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/entry.dart';
import '../models/activity.dart';

class DiaryProvider with ChangeNotifier {
  late Box<DiaryEntry> _box;
  late final ValueListenable<Box<DiaryEntry>> _boxListenable;
  late Box<ActivityList> _activityBox;

  DiaryProvider() {
    _box = Hive.box<DiaryEntry>('diary_entries');
    _activityBox = Hive.box<ActivityList>('activities');
    _boxListenable = _box.listenable();

    _boxListenable.addListener(() {
      notifyListeners();
    });
  }

  List<DiaryEntry> get entries {
    final values = _box.values.toList();
    values.sort((a, b) => b.date.compareTo(a.date));
    return values;
  }

  List<String> get activities {
    if (_activityBox.isEmpty) {
      return ['Работа', 'Спорт', 'Дом', 'Друзья', 'Хобби', 'Путешествие', 'Еда'];
    }
    return _activityBox.getAt(0)?.activities ?? ['Работа', 'Спорт', 'Дом', 'Друзья', 'Хобби', 'Путешествие', 'Еда'];
  }

  void addEntry(DiaryEntry entry) {
    _box.put(entry.id, entry);
  }

  void updateEntry(DiaryEntry updatedEntry) {
    _box.put(updatedEntry.id, updatedEntry);
  }

  void deleteEntry(String id) {
    _box.delete(id);
  }

  void saveActivities(List<String> newActivities) {
    if (_activityBox.isEmpty) {
      _activityBox.put('user_activities', ActivityList.withActivities(newActivities));
    } else {
      var existing = _activityBox.getAt(0);
      existing!.activities = newActivities;
      _activityBox.put('user_activities', existing);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _boxListenable.removeListener(() => notifyListeners());
    super.dispose();
  }
}