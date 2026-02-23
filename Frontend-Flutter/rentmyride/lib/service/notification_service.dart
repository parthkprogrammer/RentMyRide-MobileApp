import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:rentmyride/model/app_notification_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService extends ChangeNotifier {
  static const String _notificationsKey = 'app_notifications';

  List<AppNotificationModel> _notifications = [];
  bool _isLoading = false;

  List<AppNotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_notificationsKey);
      if (raw == null || raw.isEmpty) {
        await _seedNotifications();
      } else {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _notifications = decoded
            .map((entry) => AppNotificationModel.fromJson(entry))
            .toList();
      }
    } catch (e) {
      debugPrint('Failed to initialize notifications: $e');
      await _seedNotifications();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _seedNotifications() async {
    final now = DateTime.now();
    _notifications = [
      AppNotificationModel(
        id: 'n-user-1',
        userId: '1',
        title: 'Welcome to RentMyRide',
        message: 'Your account is ready. Explore rides near you.',
        type: AppNotificationType.info,
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      AppNotificationModel(
        id: 'n-owner-1',
        userId: '2',
        title: 'Payout Reminder',
        message: 'Add a bank account to receive payouts faster.',
        type: AppNotificationType.warning,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      AppNotificationModel(
        id: 'n-admin-1',
        userId: '3',
        title: 'System Health',
        message: 'All systems operational.',
        type: AppNotificationType.success,
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
    ];
    await _saveNotifications();
  }

  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw =
          jsonEncode(_notifications.map((entry) => entry.toJson()).toList());
      await prefs.setString(_notificationsKey, raw);
    } catch (e) {
      debugPrint('Failed to save notifications: $e');
    }
  }

  List<AppNotificationModel> notificationsForUser(String userId) {
    final entries =
        _notifications.where((entry) => entry.userId == userId).toList();
    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entries;
  }

  int unreadCountForUser(String userId) {
    return _notifications
        .where((entry) => entry.userId == userId && !entry.isRead)
        .length;
  }

  Future<void> sendToUser({
    required String userId,
    required String title,
    required String message,
    AppNotificationType type = AppNotificationType.info,
  }) async {
    final now = DateTime.now();
    final notification = AppNotificationModel(
      id: '$userId-${now.microsecondsSinceEpoch}',
      userId: userId,
      title: title,
      message: message,
      type: type,
      createdAt: now,
    );
    _notifications = [notification, ..._notifications];
    await _saveNotifications();
    notifyListeners();
  }

  Future<void> sendBroadcast({
    required List<String> userIds,
    required String title,
    required String message,
    AppNotificationType type = AppNotificationType.info,
  }) async {
    if (userIds.isEmpty) return;

    final now = DateTime.now();
    final created = userIds
        .map(
          (userId) => AppNotificationModel(
            id: '$userId-${now.microsecondsSinceEpoch}-${_notifications.length}',
            userId: userId,
            title: title,
            message: message,
            type: type,
            createdAt: now,
          ),
        )
        .toList();

    _notifications = [...created, ..._notifications];
    await _saveNotifications();
    notifyListeners();
  }

  Future<void> markRead({
    required String userId,
    required String notificationId,
  }) async {
    final index = _notifications.indexWhere(
      (entry) => entry.userId == userId && entry.id == notificationId,
    );
    if (index == -1) return;

    _notifications[index] = _notifications[index].copyWith(isRead: true);
    await _saveNotifications();
    notifyListeners();
  }

  Future<void> markAllRead(String userId) async {
    var changed = false;
    final updated = _notifications.map((entry) {
      if (entry.userId == userId && !entry.isRead) {
        changed = true;
        return entry.copyWith(isRead: true);
      }
      return entry;
    }).toList();

    if (!changed) return;
    _notifications = updated;
    await _saveNotifications();
    notifyListeners();
  }
}
