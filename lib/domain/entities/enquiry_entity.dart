import 'package:equatable/equatable.dart';

enum EnquiryContactMethod {
  chat('chat'),
  whatsapp('whatsapp'),
  call('call');

  final String value;
  const EnquiryContactMethod(this.value);

  static EnquiryContactMethod fromString(String? raw) {
    if (raw == null) return EnquiryContactMethod.chat;
    return EnquiryContactMethod.values.firstWhere(
      (e) => e.value.toLowerCase() == raw.toLowerCase(),
      orElse: () => EnquiryContactMethod.chat,
    );
  }
}

enum EnquiryStatus {
  pending('pending'),
  replied('replied'),
  accepted('accepted'),
  closed('closed'),
  rejected('rejected');

  final String value;
  const EnquiryStatus(this.value);

  static EnquiryStatus fromString(String? raw) {
    if (raw == null) return EnquiryStatus.pending;
    return EnquiryStatus.values.firstWhere(
      (e) => e.value.toLowerCase() == raw.toLowerCase(),
      orElse: () => EnquiryStatus.pending,
    );
  }

  bool get isPending => this == EnquiryStatus.pending;
  bool get isReplied => this == EnquiryStatus.replied;
  bool get isAccepted => this == EnquiryStatus.accepted;
  bool get isClosed => this == EnquiryStatus.closed;
}

class EnquiryEntity extends Equatable {
  final int id;
  final int propertyId;
  final String propertyTitle;
  final String? propertyThumbnail;
  final int tenantId;
  final String? tenantName;
  final String? tenantAvatar;
  final int ownerId;
  final String? ownerName;
  final String? ownerAvatar;
  final String message;
  final EnquiryContactMethod contactMethod;
  final EnquiryStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? repliedAt;
  final int unreadCount;
  final String? lastMessage;
  final DateTime? lastMessageAt;

  const EnquiryEntity({
    required this.id,
    required this.propertyId,
    required this.propertyTitle,
    this.propertyThumbnail,
    required this.tenantId,
    this.tenantName,
    this.tenantAvatar,
    required this.ownerId,
    this.ownerName,
    this.ownerAvatar,
    required this.message,
    this.contactMethod = EnquiryContactMethod.chat,
    this.status = EnquiryStatus.pending,
    required this.createdAt,
    required this.updatedAt,
    this.repliedAt,
    this.unreadCount = 0,
    this.lastMessage,
    this.lastMessageAt,
  });

  bool get hasUnread => unreadCount > 0;
  bool get isBookingAccepted => status == EnquiryStatus.accepted;

  @override
  List<Object?> get props => [
        id,
        propertyId,
        propertyTitle,
        tenantId,
        ownerId,
        message,
        contactMethod,
        status,
        createdAt,
        updatedAt,
        unreadCount,
        lastMessage,
      ];

  EnquiryEntity copyWith({
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
    return EnquiryEntity(
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
