import 'package:roomly/domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.propertyId,
    required super.tenantId,
    super.tenantName,
    super.tenantAvatar,
    required super.rating,
    required super.comment,
    required super.createdAt,
    super.isApproved,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? 0,
      propertyId: json['property_id'] ?? json['propertyId'] ?? 0,
      tenantId: json['tenant_id'] ?? json['user_id'] ?? 0,
      tenantName: json['tenant_name'] ?? json['user']?['name'] ?? json['tenant']?['name'],
      tenantAvatar: json['tenant_avatar'] ?? json['user']?['avatar_url'],
      rating: (json['rating'] as num?)?.toInt() ?? 5,
      comment: json['comment'] ?? json['review'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      isApproved: json['is_approved'] ?? json['approved'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'tenant_id': tenantId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'is_approved': isApproved,
    };
  }

  ReviewModel copyWith({
    int? id,
    int? propertyId,
    int? tenantId,
    String? tenantName,
    String? tenantAvatar,
    int? rating,
    String? comment,
    DateTime? createdAt,
    bool? isApproved,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      tenantId: tenantId ?? this.tenantId,
      tenantName: tenantName ?? this.tenantName,
      tenantAvatar: tenantAvatar ?? this.tenantAvatar,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      isApproved: isApproved ?? this.isApproved,
    );
  }
}
