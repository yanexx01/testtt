import 'package:hive/hive.dart';

part 'auth.g.dart';

@HiveType(typeId: 2)
class User extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String email;

  @HiveField(2)
  late String passwordHash;

  @HiveField(3)
  late String name;

  @HiveField(4)
  DateTime? createdAt;

  @HiveField(5)
  DateTime? lastSyncAt;

  User();

  factory User.create({
    required String id,
    required String email,
    required String passwordHash,
    required String name,
  }) {
    var user = User()
      ..id = id
      ..email = email
      ..passwordHash = passwordHash
      ..name = name
      ..createdAt = DateTime.now();
    return user;
  }
}
