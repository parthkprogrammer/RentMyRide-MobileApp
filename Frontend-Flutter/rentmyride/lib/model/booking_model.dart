class BookingModel {
  final String id;
  final String userId;
  final String vehicleId;
  final String ownerId;
  final DateTime pickupDate;
  final DateTime returnDate;
  final String pickupLocation;
  final String insurancePlan;
  final double rentalFee;
  final double insuranceFee;
  final double serviceFee;
  final double taxes;
  final double totalAmount;
  final BookingStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  BookingModel({
    required this.id,
    required this.userId,
    required this.vehicleId,
    required this.ownerId,
    required this.pickupDate,
    required this.returnDate,
    required this.pickupLocation,
    required this.insurancePlan,
    required this.rentalFee,
    required this.insuranceFee,
    required this.serviceFee,
    required this.taxes,
    required this.totalAmount,
    required this.status,
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
        'insurancePlan': insurancePlan,
        'rentalFee': rentalFee,
        'insuranceFee': insuranceFee,
        'serviceFee': serviceFee,
        'taxes': taxes,
        'totalAmount': totalAmount,
        'status': status.toString().split('.').last,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
        id: json['id'],
        userId: json['userId'],
        vehicleId: json['vehicleId'],
        ownerId: json['ownerId'],
        pickupDate: DateTime.parse(json['pickupDate']),
        returnDate: DateTime.parse(json['returnDate']),
        pickupLocation: json['pickupLocation'],
        insurancePlan: json['insurancePlan'],
        rentalFee: json['rentalFee'].toDouble(),
        insuranceFee: json['insuranceFee'].toDouble(),
        serviceFee: json['serviceFee'].toDouble(),
        taxes: json['taxes'].toDouble(),
        totalAmount: json['totalAmount'].toDouble(),
        status: BookingStatus.values.firstWhere(
          (e) => e.toString().split('.').last == json['status'],
        ),
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );

  BookingModel copyWith({
    String? id,
    String? userId,
    String? vehicleId,
    String? ownerId,
    DateTime? pickupDate,
    DateTime? returnDate,
    String? pickupLocation,
    String? insurancePlan,
    double? rentalFee,
    double? insuranceFee,
    double? serviceFee,
    double? taxes,
    double? totalAmount,
    BookingStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => BookingModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        vehicleId: vehicleId ?? this.vehicleId,
        ownerId: ownerId ?? this.ownerId,
        pickupDate: pickupDate ?? this.pickupDate,
        returnDate: returnDate ?? this.returnDate,
        pickupLocation: pickupLocation ?? this.pickupLocation,
        insurancePlan: insurancePlan ?? this.insurancePlan,
        rentalFee: rentalFee ?? this.rentalFee,
        insuranceFee: insuranceFee ?? this.insuranceFee,
        serviceFee: serviceFee ?? this.serviceFee,
        taxes: taxes ?? this.taxes,
        totalAmount: totalAmount ?? this.totalAmount,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}

enum BookingStatus { pending, confirmed, active, completed, cancelled }
