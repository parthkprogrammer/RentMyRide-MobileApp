import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _userThemeKey = 'user_theme';
  static const String _ownerThemeKey = 'owner_theme';
  static const String _adminThemeKey = 'admin_theme';

  static const String _defaultRole = 'user';
  final Map<String, ThemeMode> _themeModesByRole = {
    'user': ThemeMode.system,
    'owner': ThemeMode.system,
    'admin': ThemeMode.system,
  };
  String _activeRole = _defaultRole;

  ThemeMode get themeMode => themeModeForRole(_activeRole);

  bool get isDarkMode => themeMode == ThemeMode.dark;

  ThemeMode themeModeForRole(String role) {
    final normalizedRole = _normalizeRole(role);
    return _themeModesByRole[normalizedRole] ?? ThemeMode.system;
  }

  bool isDarkModeForRole(String role) =>
      themeModeForRole(role) == ThemeMode.dark;

  void setActiveRole(String role, {bool notify = false}) {
    final normalizedRole = _normalizeRole(role);
    if (_activeRole == normalizedRole) return;
    _activeRole = normalizedRole;
    if (notify) notifyListeners();
  }

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _themeModesByRole['user'] =
          _themeModeFromStorage(prefs.getString(_userThemeKey));
      _themeModesByRole['owner'] =
          _themeModeFromStorage(prefs.getString(_ownerThemeKey));
      _themeModesByRole['admin'] =
          _themeModeFromStorage(prefs.getString(_adminThemeKey));
    } catch (_) {
      _themeModesByRole['user'] = ThemeMode.system;
      _themeModesByRole['owner'] = ThemeMode.system;
      _themeModesByRole['admin'] = ThemeMode.system;
    } finally {
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await setThemeModeForRole(_activeRole, mode, activateRole: false);
  }

  Future<void> setThemeModeForRole(
    String role,
    ThemeMode mode, {
    bool activateRole = true,
  }) async {
    final normalizedRole = _normalizeRole(role);
    _themeModesByRole[normalizedRole] = mode;
    if (activateRole) {
      _activeRole = normalizedRole;
    }
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _storageKeyForRole(normalizedRole),
        _themeModeToStorage(mode),
      );
    } catch (_) {}
  }

  Future<void> toggleDarkMode(bool enabled) async {
    await setThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> toggleDarkModeForRole(String role, bool enabled) async {
    await setThemeModeForRole(
      role,
      enabled ? ThemeMode.dark : ThemeMode.light,
    );
  }

  String _normalizeRole(String role) {
    switch (role.trim().toLowerCase()) {
      case 'owner':
        return 'owner';
      case 'admin':
        return 'admin';
      default:
        return 'user';
    }
  }

  String _storageKeyForRole(String role) {
    switch (_normalizeRole(role)) {
      case 'owner':
        return _ownerThemeKey;
      case 'admin':
        return _adminThemeKey;
      default:
        return _userThemeKey;
    }
  }

  ThemeMode _themeModeFromStorage(String? stored) {
    switch (stored) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToStorage(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
  }
}
