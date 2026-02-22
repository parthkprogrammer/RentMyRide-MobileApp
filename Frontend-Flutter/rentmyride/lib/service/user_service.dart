import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:rentmyride/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService extends ChangeNotifier {
  static const String _usersKey = 'users';
  static const String _currentUserKey = 'current_user';

  List<UserModel> _users = [];
  UserModel? _currentUser;
  bool _isLoading = false;

  List<UserModel> get users => _users;
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey);

      if (usersJson == null || usersJson.isEmpty) {
        await _initializeSampleData();
      } else {
        try {
          final List<dynamic> decoded = jsonDecode(usersJson);
          _users = decoded.map((json) => UserModel.fromJson(json)).toList();
        } catch (e) {
          debugPrint('Error loading users: $e');
          await _initializeSampleData();
        }
      }

      final currentUserJson = prefs.getString(_currentUserKey);
      if (currentUserJson != null) {
        _currentUser = UserModel.fromJson(jsonDecode(currentUserJson));
      }
    } catch (e) {
      debugPrint('Failed to initialize users: $e');
      await _initializeSampleData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _initializeSampleData() async {
    final now = DateTime.now();
    _users = [
      UserModel(
        id: '1',
        name: 'Alex Rivers',
        email: 'alex@example.com',
        role: UserRole.user,
        passwordHash: _hashPassword('password123'),
        isVerified: true,
        rating: 4.9,
        createdAt: now.subtract(const Duration(days: 1095)),
        updatedAt: now,
      ),
      UserModel(
        id: '2',
        name: 'Marcus Sterling',
        email: 'marcus@example.com',
        role: UserRole.owner,
        passwordHash: _hashPassword('password123'),
        isVerified: true,
        rating: 4.8,
        createdAt: now.subtract(const Duration(days: 1460)),
        updatedAt: now,
      ),
      UserModel(
        id: '3',
        name: 'Sarah Admin',
        email: 'admin@rentmyride.com',
        role: UserRole.admin,
        passwordHash: _hashPassword('admin123'),
        isVerified: true,
        createdAt: now.subtract(const Duration(days: 1825)),
        updatedAt: now,
      ),
    ];
    await _saveUsers();
  }

  String _hashPassword(String password) {
    // Lightweight demo hashing to avoid extra dependencies.
    // Do NOT use this approach in production.
    final bytes = utf8.encode(password.trim());
    return base64UrlEncode(bytes);
  }

  bool _isValidEmail(String email) {
    final value = email.trim();
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }

  Future<void> _saveUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = jsonEncode(_users.map((u) => u.toJson()).toList());
      await prefs.setString(_usersKey, usersJson);
    } catch (e) {
      debugPrint('Failed to save users: $e');
    }
  }

  Future<UserModel?> login(String email, String password) async {
    final cleanedEmail = email.trim().toLowerCase();
    if (cleanedEmail.isEmpty) throw Exception('Email is required');
    if (!_isValidEmail(cleanedEmail)) throw Exception('Enter a valid email');
    if (password.trim().isEmpty) throw Exception('Password is required');

    final user = _users.firstWhere(
      (u) => u.email.trim().toLowerCase() == cleanedEmail,
      orElse: () => throw Exception('User not found'),
    );

    final expected = user.passwordHash;
    if (expected == null || expected.isEmpty) {
      throw Exception('This account needs a password reset');
    }
    if (_hashPassword(password) != expected) {
      throw Exception('Incorrect password');
    }

    _currentUser = user;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
    } catch (e) {
      debugPrint('Failed to save current user: $e');
    }
    notifyListeners();
    return user;
  }

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final cleanedName = name.trim();
    final cleanedEmail = email.trim().toLowerCase();
    if (cleanedName.isEmpty) throw Exception('Name is required');
    if (cleanedEmail.isEmpty) throw Exception('Email is required');
    if (!_isValidEmail(cleanedEmail)) throw Exception('Enter a valid email');
    if (password.trim().length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    final exists = _users.any((u) => u.email.trim().toLowerCase() == cleanedEmail);
    if (exists) throw Exception('An account already exists for this email');

    final now = DateTime.now();
    final user = UserModel(
      id: now.microsecondsSinceEpoch.toString(),
      name: cleanedName,
      email: cleanedEmail,
      role: role,
      passwordHash: _hashPassword(password),
      isVerified: true,
      createdAt: now,
      updatedAt: now,
    );

    _users = [..._users, user];
    await _saveUsers();
    _currentUser = user;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
    } catch (e) {
      debugPrint('Failed to save current user after sign up: $e');
    }
    notifyListeners();
    return user;
  }

  Future<void> logout() async {
    _currentUser = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentUserKey);
    } catch (e) {
      debugPrint('Failed to remove current user: $e');
    }
    notifyListeners();
  }

  Future<void> updateUser(UserModel user) async {
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      _users[index] = user;
      await _saveUsers();
      if (_currentUser?.id == user.id) {
        _currentUser = user;
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
        } catch (e) {
          debugPrint('Failed to update current user: $e');
        }
      }
      notifyListeners();
    }
  }

  UserModel? getUserById(String id) =>
      _users.firstWhere((u) => u.id == id, orElse: () => _users.first);
}
