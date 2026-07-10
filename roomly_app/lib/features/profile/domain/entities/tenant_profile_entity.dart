import 'package:equatable/equatable.dart';

class TenantProfileEntity extends Equatable {
  final String id;
  final String userId;
  final int accessPassesPurchased;
  final DateTime? lastAccessPassPurchasedAt;
  final List<String> favouritePropertyIds;
  final int totalReviews;
  final double averageRating;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TenantProfileEntity({
    required this.id,
    required this.userId,
    this.accessPassesPurchased = 0,
    this.lastAccessPassPurchasedAt,
    this.favouritePropertyIds = const [],
    this.totalReviews = 0,
    this.averageRating = 0.0,
    this.createdAt = const DateTime.now(),
    this.updatedAt,
  });

  TenantProfileEntity copyWith({
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
    return TenantProfileEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accessPassesPurchased: accessPassesPurchased ?? this.accessPassesPurchased,
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

  @override
  List<Object?> get props => [
        id,
        userId,
        accessPassesPurchased,
        lastAccessPassPurchasedAt,
        favouritePropertyIds,
        totalReviews,
        averageRating,
        createdAt,
        updatedAt,
      ];
}
