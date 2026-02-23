class BookingDraftModel {
  final String id;
  final String userId;
  final String vehicleId;
  final String ownerId;
  final DateTime pickupDate;
  final DateTime returnDate;
  final String pickupLocation;
  final String dropLocation;
  final String insurancePlan;
  final double rentalFee;
  final double insuranceFee;
  final double serviceFee;
  final double taxes;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime updatedAt;

  BookingDraftModel({
    required this.id,
    required this.userId,
    required this.vehicleId,
    required this.ownerId,
    required this.pickupDate,
    required this.returnDate,
    required this.pickupLocation,
    required this.dropLocation,
    required this.insurancePlan,
    required this.rentalFee,
    required this.insuranceFee,
    required this.serviceFee,
    required this.taxes,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'vehicleId': vehicleId,
        'ownerId': ownerId,
        'pickupDate': pickupDate.toIso8601String(),
        'returnDate': returnDate.toIso8601String(),
        'pickupLocation': pickupLocation,
        'dropLocation': dropLocation,
        'insurancePlan': insurancePlan,
        'rentalFee': rentalFee,
        'insuranceFee': insuranceFee,
        'serviceFee': serviceFee,
        'taxes': taxes,
        'totalAmount': totalAmount,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory BookingDraftModel.fromJson(Map<String, dynamic> json) =>
      BookingDraftModel(
        id: json['id'],
        userId: json['userId'],
        vehicleId: json['vehicleId'],
        ownerId: json['ownerId'],
        pickupDate: DateTime.parse(json['pickupDate']),
        returnDate: DateTime.parse(json['returnDate']),
        pickupLocation: json['pickupLocation'],
        dropLocation: json['dropLocation'],
        insurancePlan: json['insurancePlan'],
        rentalFee: (json['rentalFee'] as num).toDouble(),
        insuranceFee: (json['insuranceFee'] as num).toDouble(),
        serviceFee: (json['serviceFee'] as num).toDouble(),
        taxes: (json['taxes'] as num).toDouble(),
        totalAmount: (json['totalAmount'] as num).toDouble(),
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );
}
