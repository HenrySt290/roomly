import 'package:roomly/domain/entities/enquiry_entity.dart';

class EnquiryModel extends EnquiryEntity {
  const EnquiryModel({
    required super.id,
    required super.propertyId,
    required super.propertyTitle,
    super.propertyThumbnail,
    required super.tenantId,
    super.tenantName,
    super.tenantAvatar,
    required super.ownerId,
    super.ownerName,
    super.ownerAvatar,
    required super.message,
    super.contactMethod,
    super.status,
    required super.createdAt,
    required super.updatedAt,
    super.repliedAt,
    super.unreadCount,
    super.lastMessage,
    super.lastMessageAt,
  });

  factory EnquiryModel.fromJson(Map<String, dynamic> json) {
    // Handle nested property & user objects that backend might return
    final propertyObj = json['property'] as Map<String, dynamic>?;
    final tenantObj = json['tenant'] as Map<String, dynamic>? ?? json['user'] as Map<String, dynamic>?;
    final ownerObj = json['owner'] as Map<String, dynamic>?;

    return EnquiryModel(
      id: json['id'] ?? 0,
      propertyId: json['property_id'] ?? propertyObj?['id'] ?? 0,
      propertyTitle: json['property_title'] ?? propertyObj?['title'] ?? 'Property',
      propertyThumbnail: json['property_thumbnail'] ??
          propertyObj?['thumbnail'] ??
          (propertyObj?['images'] is List && (propertyObj!['images'] as List).isNotEmpty
              ? propertyObj['images'][0]
              : null),
      tenantId: json['tenant_id'] ?? tenantObj?['id'] ?? 0,
      tenantName: json['tenant_name'] ?? tenantObj?['name'],
      tenantAvatar: json['tenant_avatar'] ?? tenantObj?['avatar_url'] ?? tenantObj?['profile_image'],
      ownerId: json['owner_id'] ?? ownerObj?['id'] ?? 0,
      ownerName: json['owner_name'] ?? ownerObj?['name'],
      ownerAvatar: json['owner_avatar'] ?? ownerObj?['avatar_url'],
      message: json['message'] ?? '',
      contactMethod: EnquiryContactMethod.fromString(json['contact_method']),
      status: EnquiryStatus.fromString(json['status']),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) ?? DateTime.now() : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) ?? DateTime.now() : DateTime.now(),
      repliedAt: json['replied_at'] != null ? DateTime.tryParse(json['replied_at']) : null,
      unreadCount: json['unread_count'] ?? json['unread'] ?? 0,
      lastMessage: json['last_message'] ?? json['latest_message']?['message'],
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.tryParse(json['last_message_at'])
          : json['latest_message']?['created_at'] != null
              ? DateTime.tryParse(json['latest_message']['created_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'property_title': propertyTitle,
      'property_thumbnail': propertyThumbnail,
      'tenant_id': tenantId,
      'owner_id': ownerId,
      'message': message,
      'contact_method': contactMethod.value,
      'status': status.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'unread_count': unreadCount,
    };
  }

  EnquiryModel copyWithModel({
    int? id,
    int? propertyId,
    String? propertyTitle,
    String? propertyThumbnail,
    int? tenantId,
    String? tenantName,
    String? tenantAvatar,
    int? ownerId,
    String? ownerName,
    String? ownerAvatar,
    String? message,
    EnquiryContactMethod? contactMethod,
    EnquiryStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? repliedAt,
    int? unreadCount,
    String? lastMessage,
    DateTime? lastMessageAt,
  }) {
    return EnquiryModel(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      propertyTitle: propertyTitle ?? this.propertyTitle,
      propertyThumbnail: propertyThumbnail ?? this.propertyThumbnail,
      tenantId: tenantId ?? this.tenantId,
      tenantName: tenantName ?? this.tenantName,
      tenantAvatar: tenantAvatar ?? this.tenantAvatar,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerAvatar: ownerAvatar ?? this.ownerAvatar,
      message: message ?? this.message,
      contactMethod: contactMethod ?? this.contactMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      repliedAt: repliedAt ?? this.repliedAt,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
    );
  }
}
