import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final int id;
  final int propertyId;
  final int tenantId;
  final String? tenantName;
  final String? tenantAvatar;
  final int rating; // 1-5
  final String comment;
  final DateTime createdAt;
  final bool isApproved;

  const ReviewEntity({
    required this.id,
    required this.propertyId,
    required this.tenantId,
    this.tenantName,
    this.tenantAvatar,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.isApproved = true,
  });

  @override
  List<Object?> get props => [id, propertyId, tenantId, rating, comment, createdAt, isApproved];
}
