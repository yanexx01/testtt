import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 2)
class User extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String email;

  @HiveField(2)
  late String passwordHash;

  @HiveField(3)
  String? displayName;

  @HiveField(4)
  DateTime? createdAt;

  @HiveField(5)
  DateTime? lastSyncAt;

  User();

  factory User.create({
    required String id,
    required String email,
    required String passwordHash,
    String? displayName,
  }) {
    var user = User()
      ..id = id
      ..email = email
      ..passwordHash = passwordHash
      ..displayName = displayName
      ..createdAt = DateTime.now();
    return user;
  }
}
