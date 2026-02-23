enum AdminReportType { vehicleByUser, userByOwner }

enum AdminReportStatus { open, investigating, resolved }

class AdminReportModel {
  final String id;
  final AdminReportType type;
  final String reportedById;
  final String reportedByName;
  final String targetId;
  final String targetLabel;
  final String reason;
  final String authorityName;
  final String authorityContact;
  final List<String> documents;
  final AdminReportStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  AdminReportModel({
    required this.id,
    required this.type,
    required this.reportedById,
    required this.reportedByName,
    required this.targetId,
    required this.targetLabel,
    required this.reason,
    required this.authorityName,
    required this.authorityContact,
    required this.documents,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.toString().split('.').last,
        'reportedById': reportedById,
        'reportedByName': reportedByName,
        'targetId': targetId,
        'targetLabel': targetLabel,
        'reason': reason,
        'authorityName': authorityName,
        'authorityContact': authorityContact,
        'documents': documents,
        'status': status.toString().split('.').last,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory AdminReportModel.fromJson(Map<String, dynamic> json) =>
      AdminReportModel(
        id: json['id'],
        type: AdminReportType.values.firstWhere(
          (entry) => entry.toString().split('.').last == json['type'],
          orElse: () => AdminReportType.vehicleByUser,
        ),
        reportedById: json['reportedById'],
        reportedByName: json['reportedByName'],
        targetId: json['targetId'],
        targetLabel: json['targetLabel'],
        reason: json['reason'],
        authorityName: json['authorityName'],
        authorityContact: json['authorityContact'],
        documents: List<String>.from(json['documents'] ?? []),
        status: AdminReportStatus.values.firstWhere(
          (entry) => entry.toString().split('.').last == json['status'],
          orElse: () => AdminReportStatus.open,
        ),
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );

  AdminReportModel copyWith({
    String? id,
    AdminReportType? type,
    String? reportedById,
    String? reportedByName,
    String? targetId,
    String? targetLabel,
    String? reason,
    String? authorityName,
    String? authorityContact,
    List<String>? documents,
    AdminReportStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      AdminReportModel(
        id: id ?? this.id,
        type: type ?? this.type,
        reportedById: reportedById ?? this.reportedById,
        reportedByName: reportedByName ?? this.reportedByName,
        targetId: targetId ?? this.targetId,
        targetLabel: targetLabel ?? this.targetLabel,
        reason: reason ?? this.reason,
        authorityName: authorityName ?? this.authorityName,
        authorityContact: authorityContact ?? this.authorityContact,
        documents: documents ?? this.documents,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
