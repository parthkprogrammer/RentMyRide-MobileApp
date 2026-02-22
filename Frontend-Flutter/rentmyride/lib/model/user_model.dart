class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;

  /// Local-only auth. For real auth, use Firebase/Supabase.
  final String? passwordHash;
  final String? photoUrl;
  final bool isVerified;
  final double? rating;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.passwordHash,
    this.photoUrl,
    this.isVerified = false,
    this.rating,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role.toString().split('.').last,
        'passwordHash': passwordHash,
        'photoUrl': photoUrl,
        'isVerified': isVerified,
        'rating': rating,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        role: UserRole.values.firstWhere(
          (e) => e.toString().split('.').last == json['role'],
        ),
        passwordHash: json['passwordHash'],
        photoUrl: json['photoUrl'],
        isVerified: json['isVerified'] ?? false,
        rating: json['rating']?.toDouble(),
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? passwordHash,
    String? photoUrl,
    bool? isVerified,
    double? rating,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => UserModel(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        role: role ?? this.role,
        passwordHash: passwordHash ?? this.passwordHash,
        photoUrl: photoUrl ?? this.photoUrl,
        isVerified: isVerified ?? this.isVerified,
        rating: rating ?? this.rating,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}

enum UserRole { user, owner, admin }
