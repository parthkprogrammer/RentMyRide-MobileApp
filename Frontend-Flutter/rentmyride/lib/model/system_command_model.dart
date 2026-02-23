enum SystemCommandState { idle, running, completed, failed }

class SystemCommandModel {
  final String id;
  final String label;
  final String iconKey;
  final String description;
  final SystemCommandState state;
  final DateTime? lastRunAt;

  SystemCommandModel({
    required this.id,
    required this.label,
    required this.iconKey,
    required this.description,
    this.state = SystemCommandState.idle,
    this.lastRunAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'iconKey': iconKey,
        'description': description,
        'state': state.toString().split('.').last,
        'lastRunAt': lastRunAt?.toIso8601String(),
      };

  factory SystemCommandModel.fromJson(Map<String, dynamic> json) =>
      SystemCommandModel(
        id: json['id'],
        label: json['label'],
        iconKey: json['iconKey'],
        description: json['description'],
        state: SystemCommandState.values.firstWhere(
          (entry) => entry.toString().split('.').last == json['state'],
          orElse: () => SystemCommandState.idle,
        ),
        lastRunAt:
            json['lastRunAt'] != null ? DateTime.parse(json['lastRunAt']) : null,
      );

  SystemCommandModel copyWith({
    String? id,
    String? label,
    String? iconKey,
    String? description,
    SystemCommandState? state,
    DateTime? lastRunAt,
  }) =>
      SystemCommandModel(
        id: id ?? this.id,
        label: label ?? this.label,
        iconKey: iconKey ?? this.iconKey,
        description: description ?? this.description,
        state: state ?? this.state,
        lastRunAt: lastRunAt ?? this.lastRunAt,
      );
}
