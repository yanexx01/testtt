// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActivityListAdapter extends TypeAdapter<ActivityList> {
  @override
  final int typeId = 1;

  @override
  ActivityList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActivityList()..activities = (fields[0] as List).cast<String>();
  }

  @override
  void write(BinaryWriter writer, ActivityList obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.activities);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityListAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
