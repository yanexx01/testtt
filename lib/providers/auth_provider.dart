import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/auth.dart';

class AuthProvider with ChangeNotifier {
  late Box<User> _userBox;
  User? _currentUser;

  AuthProvider() {
    _userBox = Hive.box<User>('users');
  }

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final existingUser = _userBox.values.firstWhere(
        (user) => user.email.toLowerCase() == email.toLowerCase(),
        orElse: () => User(),
      );

      if (existingUser.id.isNotEmpty) {
        return false;
      }

      final newUser = User.create(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email.toLowerCase().trim(),
        passwordHash: _hashPassword(password),
        name: name.trim(),
      );

      await _userBox.put(newUser.id, newUser);
      _currentUser = newUser;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      final passwordHash = _hashPassword(password);

      final user = _userBox.values.firstWhere(
        (user) =>
            user.email.toLowerCase() == email.toLowerCase() &&
            user.passwordHash == passwordHash,
        orElse: () => User(),
      );

      if (user.id.isEmpty) {
        return false;
      }

      _currentUser = user;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updateLastSync() async {
    if (_currentUser != null) {
      _currentUser!.lastSyncAt = DateTime.now();
      await _userBox.put(_currentUser!.id, _currentUser!);
      notifyListeners();
    }
  }
}
