import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:rentmyride/model/payment_method_model.dart';
import 'package:rentmyride/model/user_model.dart';
import 'package:rentmyride/model/user_governance_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService extends ChangeNotifier {
  static const String _usersKey = 'users';
  static const String _currentUserKey = 'current_user';
  static const String _favoritesKey = 'favorites_by_user';
  static const String _paymentMethodsKey = 'payment_methods_by_user';
  static const String _governanceKey = 'governance_by_user';
  static const String _ownerBankAccountKey = 'owner_bank_accounts';

  List<UserModel> _users = [];
  UserModel? _currentUser;
  Map<String, Set<String>> _favoritesByUser = {};
  Map<String, List<PaymentMethodModel>> _paymentMethodsByUser = {};
  Map<String, UserGovernanceModel> _governanceByUser = {};
  Map<String, String> _ownerBankAccountsByUser = {};
  bool _isLoading = false;

  List<UserModel> get users => _users;
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  Set<String> get favoriteVehicleIdsForCurrentUser {
    final userId = _currentUser?.id;
    if (userId == null) return <String>{};
    return _favoritesByUser[userId] ?? <String>{};
  }

  List<PaymentMethodModel> get currentUserPaymentMethods {
    final userId = _currentUser?.id;
    if (userId == null) return const [];
    return _paymentMethodsByUser[userId] ?? const [];
  }

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

      _loadFavorites(prefs);
      _loadPaymentMethods(prefs);
      _loadGovernance(prefs);
      _loadOwnerBankAccounts(prefs);
      _ensureUserSideDefaults();
      await Future.wait([
        _saveFavorites(),
        _savePaymentMethods(),
        _saveGovernance(),
        _saveOwnerBankAccounts(),
      ]);
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
    _ensureUserSideDefaults();
    await Future.wait([
      _saveFavorites(),
      _savePaymentMethods(),
      _saveGovernance(),
      _saveOwnerBankAccounts(),
    ]);
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

  void _loadFavorites(SharedPreferences prefs) {
    try {
      final raw = prefs.getString(_favoritesKey);
      if (raw == null || raw.isEmpty) {
        _favoritesByUser = {};
        return;
      }
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _favoritesByUser = decoded.map(
        (userId, entries) => MapEntry(
          userId,
          Set<String>.from(entries as List<dynamic>),
        ),
      );
    } catch (_) {
      _favoritesByUser = {};
    }
  }

  void _loadPaymentMethods(SharedPreferences prefs) {
    try {
      final raw = prefs.getString(_paymentMethodsKey);
      if (raw == null || raw.isEmpty) {
        _paymentMethodsByUser = {};
        return;
      }
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _paymentMethodsByUser = decoded.map((userId, entries) {
        final methods = (entries as List<dynamic>)
            .map((item) => PaymentMethodModel.fromJson(item))
            .toList();
        return MapEntry(userId, methods);
      });
    } catch (_) {
      _paymentMethodsByUser = {};
    }
  }

  void _loadGovernance(SharedPreferences prefs) {
    try {
      final raw = prefs.getString(_governanceKey);
      if (raw == null || raw.isEmpty) {
        _governanceByUser = {};
        return;
      }
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _governanceByUser = decoded.map(
        (userId, value) => MapEntry(
          userId,
          UserGovernanceModel.fromJson(value),
        ),
      );
    } catch (_) {
      _governanceByUser = {};
    }
  }

  void _loadOwnerBankAccounts(SharedPreferences prefs) {
    try {
      final raw = prefs.getString(_ownerBankAccountKey);
      if (raw == null || raw.isEmpty) {
        _ownerBankAccountsByUser = {};
        return;
      }
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _ownerBankAccountsByUser =
          decoded.map((userId, value) => MapEntry(userId, '$value'));
    } catch (_) {
      _ownerBankAccountsByUser = {};
    }
  }

  void _ensureUserSideDefaults() {
    for (final user in _users) {
      _favoritesByUser.putIfAbsent(user.id, () => <String>{});
      _governanceByUser.putIfAbsent(
        user.id,
        () => UserGovernanceModel(userId: user.id),
      );
      _paymentMethodsByUser.putIfAbsent(
        user.id,
        () => _defaultPaymentMethodsForRole(user),
      );
      if (user.role == UserRole.owner) {
        _ownerBankAccountsByUser.putIfAbsent(user.id, () => '');
      }
    }
  }

  List<PaymentMethodModel> _defaultPaymentMethodsForRole(UserModel user) {
    if (user.role != UserRole.user) return [];
    final now = DateTime.now();
    return [
      PaymentMethodModel(
        id: 'pm-${user.id}-1',
        brand: 'Visa',
        holderName: user.name,
        last4: '4242',
        expiry: '12/29',
        isDefault: true,
        createdAt: now,
      ),
    ];
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = _favoritesByUser.map(
        (userId, entries) => MapEntry(userId, entries.toList()),
      );
      await prefs.setString(_favoritesKey, jsonEncode(encoded));
    } catch (e) {
      debugPrint('Failed to save favorites: $e');
    }
  }

  Future<void> _savePaymentMethods() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = _paymentMethodsByUser.map(
        (userId, methods) =>
            MapEntry(userId, methods.map((entry) => entry.toJson()).toList()),
      );
      await prefs.setString(_paymentMethodsKey, jsonEncode(encoded));
    } catch (e) {
      debugPrint('Failed to save payment methods: $e');
    }
  }

  Future<void> _saveGovernance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = _governanceByUser.map(
        (userId, governance) => MapEntry(userId, governance.toJson()),
      );
      await prefs.setString(_governanceKey, jsonEncode(encoded));
    } catch (e) {
      debugPrint('Failed to save governance: $e');
    }
  }

  Future<void> _saveOwnerBankAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _ownerBankAccountKey,
        jsonEncode(_ownerBankAccountsByUser),
      );
    } catch (e) {
      debugPrint('Failed to save owner bank accounts: $e');
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

    final governance = governanceForUser(user.id);
    if (governance.isBlocked) {
      throw Exception('This account is blocked by admin');
    }
    if (governance.isSuspended) {
      throw Exception('This account is suspended');
    }

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

    final exists =
        _users.any((u) => u.email.trim().toLowerCase() == cleanedEmail);
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
    _favoritesByUser[user.id] = <String>{};
    _governanceByUser[user.id] = UserGovernanceModel(userId: user.id);
    _paymentMethodsByUser[user.id] = _defaultPaymentMethodsForRole(user);
    if (user.role == UserRole.owner) {
      _ownerBankAccountsByUser[user.id] = '';
    }
    await _saveUsers();
    await Future.wait([
      _saveFavorites(),
      _savePaymentMethods(),
      _saveGovernance(),
      _saveOwnerBankAccounts(),
    ]);
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

  bool isFavorite(String vehicleId) =>
      favoriteVehicleIdsForCurrentUser.contains(vehicleId);

  Future<void> toggleFavorite(String vehicleId) async {
    final userId = _currentUser?.id;
    if (userId == null) return;
    final favorites = _favoritesByUser.putIfAbsent(userId, () => <String>{});
    if (favorites.contains(vehicleId)) {
      favorites.remove(vehicleId);
    } else {
      favorites.add(vehicleId);
    }
    await _saveFavorites();
    notifyListeners();
  }

  Future<void> addPaymentMethod(PaymentMethodModel method) async {
    final userId = _currentUser?.id;
    if (userId == null) return;

    final methods = [
      ...(_paymentMethodsByUser[userId] ?? <PaymentMethodModel>[])
    ];
    var normalizedMethod = method;
    if (method.isDefault) {
      for (var index = 0; index < methods.length; index++) {
        methods[index] = methods[index].copyWith(isDefault: false);
      }
    } else if (methods.isEmpty) {
      normalizedMethod = method.copyWith(isDefault: true);
    }
    methods.add(normalizedMethod);
    _paymentMethodsByUser[userId] = methods;
    await _savePaymentMethods();
    notifyListeners();
  }

  Future<void> removePaymentMethod(String methodId) async {
    final userId = _currentUser?.id;
    if (userId == null) return;
    final methods = [
      ...(_paymentMethodsByUser[userId] ?? <PaymentMethodModel>[])
    ];
    final removed = methods.where((entry) => entry.id == methodId).toList();
    methods.removeWhere((entry) => entry.id == methodId);
    if (removed.isNotEmpty &&
        removed.first.isDefault &&
        methods.isNotEmpty &&
        !methods.any((entry) => entry.isDefault)) {
      methods[0] = methods[0].copyWith(isDefault: true);
    }
    _paymentMethodsByUser[userId] = methods;
    await _savePaymentMethods();
    notifyListeners();
  }

  Future<void> setDefaultPaymentMethod(String methodId) async {
    final userId = _currentUser?.id;
    if (userId == null) return;
    final methods = [
      ...(_paymentMethodsByUser[userId] ?? <PaymentMethodModel>[])
    ];
    for (var index = 0; index < methods.length; index++) {
      methods[index] = methods[index].copyWith(
        isDefault: methods[index].id == methodId,
      );
    }
    _paymentMethodsByUser[userId] = methods;
    await _savePaymentMethods();
    notifyListeners();
  }

  String ownerBankAccount(String ownerId) =>
      _ownerBankAccountsByUser[ownerId] ?? '';

  Future<void> setOwnerBankAccount(String ownerId, String accountValue) async {
    _ownerBankAccountsByUser[ownerId] = accountValue.trim();
    await _saveOwnerBankAccounts();
    notifyListeners();
  }

  UserGovernanceModel governanceForUser(String userId) {
    return _governanceByUser[userId] ?? UserGovernanceModel(userId: userId);
  }

  Future<void> setUserFlagged(
    String userId,
    bool flagged, {
    String? reason,
  }) async {
    final previous = governanceForUser(userId);
    _governanceByUser[userId] = previous.copyWith(
      isFlagged: flagged,
      flagReason: flagged ? reason ?? previous.flagReason : null,
    );
    await _saveGovernance();
    notifyListeners();
  }

  Future<void> setUserSuspended(String userId, bool suspended) async {
    final previous = governanceForUser(userId);
    _governanceByUser[userId] = previous.copyWith(isSuspended: suspended);
    await _saveGovernance();
    notifyListeners();
  }

  Future<void> setUserBlocked(String userId, bool blocked) async {
    final previous = governanceForUser(userId);
    _governanceByUser[userId] = previous.copyWith(isBlocked: blocked);
    await _saveGovernance();
    notifyListeners();
  }

  Future<String> generateUserDetailsPdf(UserModel user) async {
    final governance = governanceForUser(user.id);
    final now = DateTime.now();
    final key = 'generated_pdf_${user.id}_${now.microsecondsSinceEpoch}';
    final reportPayload = '''
RentMyRide User Details (Mock PDF)
Generated: ${now.toIso8601String()}
User ID: ${user.id}
Name: ${user.name}
Email: ${user.email}
Role: ${user.role.name}
Verified: ${user.isVerified}
Rating: ${user.rating ?? '-'}
Governance:
  flagged=${governance.isFlagged}
  suspended=${governance.isSuspended}
  blocked=${governance.isBlocked}
  reason=${governance.flagReason ?? '-'}
''';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, reportPayload);
    return '$key.pdf';
  }

  List<UserModel> usersByRole(UserRole role) =>
      _users.where((entry) => entry.role == role).toList();

  UserModel? getUserById(String id) =>
      _users.firstWhere((u) => u.id == id, orElse: () => _users.first);
}
