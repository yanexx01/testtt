import 'package:hive/hive.dart';

part 'activity.g.dart';

@HiveType(typeId: 1)
class ActivityList extends HiveObject {
  @HiveField(0)
  late List<String> activities;

  ActivityList() {
    activities = [];
  }

  factory ActivityList.withActivities(List<String> initialActivities) {
    var activityList = ActivityList();
    activityList.activities = initialActivities;
    return activityList;
  }
}