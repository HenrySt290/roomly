import 'package:roomly/features/profile/domain/entities/export.dart';

class TenantProfileModel extends TenantProfileEntity {
  const TenantProfileModel({
    required super.id,
    required super.userId,
    super.accessPassesPurchased,
    super.lastAccessPassPurchasedAt,
    super.favouritePropertyIds,
    super.totalReviews,
    super.averageRating,
    super.createdAt,
    super.updatedAt,
  });

  factory TenantProfileModel.fromJson(Map<String, dynamic> json) {
    return TenantProfileModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      accessPassesPurchased: json['access_passes_purchased'] ?? 0,
      lastAccessPassPurchasedAt: json['last_access_pass_purchased_at'] != null
          ? DateTime.parse(json['last_access_pass_purchased_at'])
          : null,
      favouritePropertyIds: (json['favourite_property_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      totalReviews: json['total_reviews'] ?? 0,
      averageRating: (json['average_rating'] ?? 0).toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'access_passes_purchased': accessPassesPurchased,
      'last_access_pass_purchased_at': lastAccessPassPurchasedAt?.toIso8601String(),
      'favourite_property_ids': favouritePropertyIds,
      'total_reviews': totalReviews,
      'average_rating': averageRating,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  TenantProfileModel copyWith({
    String? id,
    String? userId,
    int? accessPassesPurchased,
    DateTime? lastAccessPassPurchasedAt,
    List<String>? favouritePropertyIds,
    int? totalReviews,
    double? averageRating,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TenantProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accessPassesPurchased:
          accessPassesPurchased ?? this.accessPassesPurchased,
      lastAccessPassPurchasedAt:
          lastAccessPassPurchasedAt ?? this.lastAccessPassPurchasedAt,
      favouritePropertyIds:
          favouritePropertyIds ?? this.favouritePropertyIds,
      totalReviews: totalReviews ?? this.totalReviews,
      averageRating: averageRating ?? this.averageRating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
