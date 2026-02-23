enum AppNotificationType { info, success, warning, emergency }

class AppNotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final AppNotificationType type;
  final bool isRead;
  final DateTime createdAt;

  AppNotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'message': message,
        'type': type.toString().split('.').last,
        'isRead': isRead,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) =>
      AppNotificationModel(
        id: json['id'],
        userId: json['userId'],
        title: json['title'],
        message: json['message'],
        type: AppNotificationType.values.firstWhere(
          (entry) => entry.toString().split('.').last == json['type'],
          orElse: () => AppNotificationType.info,
        ),
        isRead: json['isRead'] ?? false,
        createdAt: DateTime.parse(json['createdAt']),
      );

  AppNotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    AppNotificationType? type,
    bool? isRead,
    DateTime? createdAt,
  }) =>
      AppNotificationModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        title: title ?? this.title,
        message: message ?? this.message,
        type: type ?? this.type,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt ?? this.createdAt,
      );
}
