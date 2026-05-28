import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/auth.dart';

class AuthProvider with ChangeNotifier {
  late Box<User> _userBox;
  late Box<String> _sessionBox;
  User? _currentUser;

  AuthProvider() {
    _userBox = Hive.box<User>('users');
    _sessionBox = Hive.box<String>('session');
    _restoreSession();
  }

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  void _restoreSession() {
    final userId = _sessionBox.get('current_user_id');
    if (userId != null && userId.isNotEmpty) {
      try {
        final user = _userBox.get(userId);
        if (user != null) {
          _currentUser = user;
          notifyListeners();
        }
      } catch (e) {
        // Session invalid, clear it
        _sessionBox.delete('current_user_id');
      }
    }
  }

  Future<void> _saveSession(String userId) async {
    await _sessionBox.put('current_user_id', userId);
  }

  Future<void> _clearSession() async {
    await _sessionBox.delete('current_user_id');
  }

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
      final normalizedEmail = email.toLowerCase().trim();
      
      final existingUser = _userBox.values.firstWhere(
        (user) => user.email == normalizedEmail,
        orElse: () => User()..id = '',
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
      await _saveSession(newUser.id);
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
      await _saveSession(user.id);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void logout() async {
    await _clearSession();
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
