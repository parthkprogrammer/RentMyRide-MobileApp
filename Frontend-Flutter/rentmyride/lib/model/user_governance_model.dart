class UserGovernanceModel {
  final String userId;
  final bool isFlagged;
  final bool isSuspended;
  final bool isBlocked;
  final String? flagReason;

  UserGovernanceModel({
    required this.userId,
    this.isFlagged = false,
    this.isSuspended = false,
    this.isBlocked = false,
    this.flagReason,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'isFlagged': isFlagged,
        'isSuspended': isSuspended,
        'isBlocked': isBlocked,
        'flagReason': flagReason,
      };

  factory UserGovernanceModel.fromJson(Map<String, dynamic> json) =>
      UserGovernanceModel(
        userId: json['userId'],
        isFlagged: json['isFlagged'] ?? false,
        isSuspended: json['isSuspended'] ?? false,
        isBlocked: json['isBlocked'] ?? false,
        flagReason: json['flagReason'],
      );

  UserGovernanceModel copyWith({
    String? userId,
    bool? isFlagged,
    bool? isSuspended,
    bool? isBlocked,
    String? flagReason,
  }) =>
      UserGovernanceModel(
        userId: userId ?? this.userId,
        isFlagged: isFlagged ?? this.isFlagged,
        isSuspended: isSuspended ?? this.isSuspended,
        isBlocked: isBlocked ?? this.isBlocked,
        flagReason: flagReason ?? this.flagReason,
      );
}
