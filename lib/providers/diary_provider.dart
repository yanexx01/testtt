import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/entry.dart';

class DiaryProvider with ChangeNotifier {
  late Box<DiaryEntry> _box;
  late final ValueListenable<Box<DiaryEntry>> _boxListenable;

  DiaryProvider() {
    _box = Hive.box<DiaryEntry>('diary_entries');

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

  void addEntry(DiaryEntry entry) {
    _box.put(entry.id, entry);
  }

  void updateEntry(DiaryEntry updatedEntry) {
    _box.put(updatedEntry.id, updatedEntry);
  }

  void deleteEntry(String id) {
    _box.delete(id);
  }

  @override
  void dispose() {
    _boxListenable.removeListener(() => notifyListeners());
    super.dispose();
  }
}