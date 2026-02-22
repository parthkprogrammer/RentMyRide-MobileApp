class VehicleModel {
  final String id;
  final String name;
  final String ownerId;
  final String category;
  final String imageUrl;
  final List<String> additionalImages;
  final double pricePerDay;
  final double rating;
  final int reviewCount;
  final String fuelType;
  final String transmission;
  final int seats;
  final String? range;
  final String? acceleration;
  final String location;
  final String description;
  final List<String> features;
  final bool isAvailable;
  final double securityDeposit;
  final DateTime createdAt;
  final DateTime updatedAt;

  VehicleModel({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.category,
    required this.imageUrl,
    this.additionalImages = const [],
    required this.pricePerDay,
    required this.rating,
    required this.reviewCount,
    required this.fuelType,
    required this.transmission,
    required this.seats,
    this.range,
    this.acceleration,
    required this.location,
    required this.description,
    this.features = const [],
    this.isAvailable = true,
    required this.securityDeposit,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'ownerId': ownerId,
        'category': category,
        'imageUrl': imageUrl,
        'additionalImages': additionalImages,
        'pricePerDay': pricePerDay,
        'rating': rating,
        'reviewCount': reviewCount,
        'fuelType': fuelType,
        'transmission': transmission,
        'seats': seats,
        'range': range,
        'acceleration': acceleration,
        'location': location,
        'description': description,
        'features': features,
        'isAvailable': isAvailable,
        'securityDeposit': securityDeposit,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory VehicleModel.fromJson(Map<String, dynamic> json) => VehicleModel(
        id: json['id'],
        name: json['name'],
        ownerId: json['ownerId'],
        category: json['category'],
        imageUrl: json['imageUrl'],
        additionalImages: List<String>.from(json['additionalImages'] ?? []),
        pricePerDay: json['pricePerDay'].toDouble(),
        rating: json['rating'].toDouble(),
        reviewCount: json['reviewCount'],
        fuelType: json['fuelType'],
        transmission: json['transmission'],
        seats: json['seats'],
        range: json['range'],
        acceleration: json['acceleration'],
        location: json['location'],
        description: json['description'],
        features: List<String>.from(json['features'] ?? []),
        isAvailable: json['isAvailable'] ?? true,
        securityDeposit: json['securityDeposit'].toDouble(),
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );

  VehicleModel copyWith({
    String? id,
    String? name,
    String? ownerId,
    String? category,
    String? imageUrl,
    List<String>? additionalImages,
    double? pricePerDay,
    double? rating,
    int? reviewCount,
    String? fuelType,
    String? transmission,
    int? seats,
    String? range,
    String? acceleration,
    String? location,
    String? description,
    List<String>? features,
    bool? isAvailable,
    double? securityDeposit,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => VehicleModel(
        id: id ?? this.id,
        name: name ?? this.name,
        ownerId: ownerId ?? this.ownerId,
        category: category ?? this.category,
        imageUrl: imageUrl ?? this.imageUrl,
        additionalImages: additionalImages ?? this.additionalImages,
        pricePerDay: pricePerDay ?? this.pricePerDay,
        rating: rating ?? this.rating,
        reviewCount: reviewCount ?? this.reviewCount,
        fuelType: fuelType ?? this.fuelType,
        transmission: transmission ?? this.transmission,
        seats: seats ?? this.seats,
        range: range ?? this.range,
        acceleration: acceleration ?? this.acceleration,
        location: location ?? this.location,
        description: description ?? this.description,
        features: features ?? this.features,
        isAvailable: isAvailable ?? this.isAvailable,
        securityDeposit: securityDeposit ?? this.securityDeposit,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
