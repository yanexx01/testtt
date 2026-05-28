import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  final Box<User> _userBox = Hive.box<User>('users');

  /// Вход пользователя по email и паролю
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Поиск пользователя с таким email
      User? user = _userBox.values.cast<User?>().firstWhere(
        (u) => u?.email == email,
        orElse: () => null,
      );

      if (user == null) {
        _errorMessage = 'Пользователь не найден';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Простая проверка пароля (в реальном приложении используйте хеширование)
      if (user.passwordHash != _hashPassword(password)) {
        _errorMessage = 'Неверный пароль';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Ошибка входа: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Регистрация нового пользователя
  Future<bool> register(String email, String password, {String? displayName}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Проверка, существует ли уже пользователь с таким email
      User? existingUser = _userBox.values.cast<User?>().firstWhere(
        (u) => u?.email == email,
        orElse: () => null,
      );

      if (existingUser != null) {
        _errorMessage = 'Пользователь с таким email уже существует';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Создание нового пользователя
      final newUser = User.create(
        id: const Uuid().v4(),
        email: email,
        passwordHash: _hashPassword(password),
        displayName: displayName,
      );

      await _userBox.put(newUser.id, newUser);
      _currentUser = newUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Ошибка регистрации: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Выход из аккаунта
  void logout() {
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Простая функция хеширования пароля (заглушка, в production используйте bcrypt или аналоги)
  String _hashPassword(String password) {
    // В реальном приложении используйте надежное хеширование (bcrypt, argon2, etc.)
    return 'hash_${password.hashCode}';
  }
}
