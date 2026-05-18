import 'package:hive/hive.dart';
import 'mood.dart';

part 'entry.g.dart';

@HiveType(typeId: 0)
class DiaryEntry extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late DateTime date;

  @HiveField(2)
  late int moodIndex;

  @HiveField(3)
  late List<String> activities;

  @HiveField(4)
  String? note;

  // Пустой конструктор для Hive
  DiaryEntry();

  // Конструктор для использования в приложении
  factory DiaryEntry.create({
    required String id,
    required DateTime date,
    required Mood mood,
    List<String> activities = const [],
    String? note,
  }) {
    var entry = DiaryEntry()
      ..id = id
      ..date = date
      ..moodIndex = mood.type.index
      ..activities = activities
      ..note = note;
    return entry;
  }

  // Геттер для получения объекта Mood
  Mood get mood => Mood.all[moodIndex];
}