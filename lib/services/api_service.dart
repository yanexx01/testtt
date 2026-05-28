import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/entry.dart';
import '../models/mood.dart';
import '../models/user.dart';

class ApiService {
  final String baseUrl;
  String? _authToken;
  
  ApiService({required this.baseUrl});

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // Аутентификация
  Future<User> register(String email, String password, String name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers,
      body: json.encode({
        'email': email,
        'password': password,
        'name': name,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['token'] != null) {
        _authToken = data['token'];
      }
      return User.fromJson(data['user']);
    } else {
      throw Exception('Registration failed: ${response.body}');
    }
  }

  Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['token'] != null) {
        _authToken = data['token'];
      }
      return User.fromJson(data['user']);
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  Future<User> updateProfile(String userId, {String? name, String? email}) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId'),
      headers: _headers,
      body: json.encode({
        if (name != null) 'name': name,
        if (email != null) 'email': email,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception('Failed to update profile');
    }
  }

  Future<void> deleteUser(String userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/users/$userId'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete account');
    }
  }

  // Синхронизация записей
  Future<List<DiaryEntry>> fetchEntries() async {
    final response = await http.get(Uri.parse('$baseUrl/entries'), headers: _headers);
    
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => _entryFromJson(json)).toList();
    } else {
      throw Exception('Failed to load entries');
    }
  }

  Future<void> uploadEntry(DiaryEntry entry) async {
    final response = await http.post(
      Uri.parse('$baseUrl/entries'),
      headers: _headers,
      body: json.encode(_entryToJson(entry)),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to upload entry');
    }
  }

  Future<void> updateEntry(DiaryEntry entry) async {
    final response = await http.put(
      Uri.parse('$baseUrl/entries/${entry.id}'),
      headers: _headers,
      body: json.encode(_entryToJson(entry)),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update entry');
    }
  }

  Future<void> deleteEntry(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/entries/$id'), headers: _headers);
    
    if (response.statusCode != 200) {
      throw Exception('Failed to delete entry');
    }
  }

  // Синхронизация активностей
  Future<List<String>> fetchActivities() async {
    final response = await http.get(Uri.parse('$baseUrl/activities'), headers: _headers);
    
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((item) => item.toString()).toList();
    } else {
      throw Exception('Failed to load activities');
    }
  }

  Future<void> uploadActivities(List<String> activities) async {
    final response = await http.post(
      Uri.parse('$baseUrl/activities'),
      headers: _headers,
      body: json.encode(activities),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to upload activities');
    }
  }

  // Вспомогательные методы для конвертации
  DiaryEntry _entryFromJson(Map<String, dynamic> json) {
    return DiaryEntry.create(
      id: json['id'],
      date: DateTime.parse(json['date']),
      mood: Mood.all.firstWhere(
        (m) => m.type.index == json['moodIndex'],
        orElse: () => Mood.all[0],
      ),
      activities: List<String>.from(json['activities'] ?? []),
      note: json['note'],
    );
  }

  Map<String, dynamic> _entryToJson(DiaryEntry entry) {
    return {
      'id': entry.id,
      'date': entry.date.toIso8601String(),
      'moodIndex': entry.moodIndex,
      'activities': entry.activities,
      'note': entry.note,
    };
  }
}
