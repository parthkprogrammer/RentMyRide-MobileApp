class PaymentMethodModel {
  final String id;
  final String brand;
  final String holderName;
  final String last4;
  final String expiry;
  final bool isDefault;
  final DateTime createdAt;

  PaymentMethodModel({
    required this.id,
    required this.brand,
    required this.holderName,
    required this.last4,
    required this.expiry,
    this.isDefault = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'brand': brand,
        'holderName': holderName,
        'last4': last4,
        'expiry': expiry,
        'isDefault': isDefault,
        'createdAt': createdAt.toIso8601String(),
      };

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) =>
      PaymentMethodModel(
        id: json['id'],
        brand: json['brand'],
        holderName: json['holderName'],
        last4: json['last4'],
        expiry: json['expiry'],
        isDefault: json['isDefault'] ?? false,
        createdAt: DateTime.parse(json['createdAt']),
      );

  PaymentMethodModel copyWith({
    String? id,
    String? brand,
    String? holderName,
    String? last4,
    String? expiry,
    bool? isDefault,
    DateTime? createdAt,
  }) =>
      PaymentMethodModel(
        id: id ?? this.id,
        brand: brand ?? this.brand,
        holderName: holderName ?? this.holderName,
        last4: last4 ?? this.last4,
        expiry: expiry ?? this.expiry,
        isDefault: isDefault ?? this.isDefault,
        createdAt: createdAt ?? this.createdAt,
      );
}
