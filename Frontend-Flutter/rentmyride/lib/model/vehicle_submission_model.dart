import 'package:rentmyride/model/vehicle_model.dart';

enum VehicleSubmissionStatus { pending, approved, rejected }

class VehicleSubmissionModel {
  final String id;
  final VehicleModel vehicle;
  final String ownerId;
  final List<String> documents;
  final VehicleSubmissionStatus status;
  final String? rejectionReason;
  final DateTime submittedAt;
  final DateTime updatedAt;

  VehicleSubmissionModel({
    required this.id,
    required this.vehicle,
    required this.ownerId,
    required this.documents,
    required this.status,
    this.rejectionReason,
    required this.submittedAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'vehicle': vehicle.toJson(),
        'ownerId': ownerId,
        'documents': documents,
        'status': status.toString().split('.').last,
        'rejectionReason': rejectionReason,
        'submittedAt': submittedAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory VehicleSubmissionModel.fromJson(Map<String, dynamic> json) =>
      VehicleSubmissionModel(
        id: json['id'],
        vehicle: VehicleModel.fromJson(json['vehicle']),
        ownerId: json['ownerId'],
        documents: List<String>.from(json['documents'] ?? []),
        status: VehicleSubmissionStatus.values.firstWhere(
          (entry) => entry.toString().split('.').last == json['status'],
          orElse: () => VehicleSubmissionStatus.pending,
        ),
        rejectionReason: json['rejectionReason'],
        submittedAt: DateTime.parse(json['submittedAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );

  VehicleSubmissionModel copyWith({
    String? id,
    VehicleModel? vehicle,
    String? ownerId,
    List<String>? documents,
    VehicleSubmissionStatus? status,
    String? rejectionReason,
    DateTime? submittedAt,
    DateTime? updatedAt,
  }) =>
      VehicleSubmissionModel(
        id: id ?? this.id,
        vehicle: vehicle ?? this.vehicle,
        ownerId: ownerId ?? this.ownerId,
        documents: documents ?? this.documents,
        status: status ?? this.status,
        rejectionReason: rejectionReason ?? this.rejectionReason,
        submittedAt: submittedAt ?? this.submittedAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
