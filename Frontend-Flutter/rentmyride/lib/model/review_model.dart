class ReviewModel {
  final String id;
  final String vehicleId;
  final String reviewerName;
  final double rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.vehicleId,
    required this.reviewerName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'vehicleId': vehicleId,
        'reviewerName': reviewerName,
        'rating': rating,
        'comment': comment,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
        id: json['id'],
        vehicleId: json['vehicleId'],
        reviewerName: json['reviewerName'],
        rating: (json['rating'] as num).toDouble(),
        comment: json['comment'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}
