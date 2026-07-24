import 'package:roomly/domain/entities/chat_message_entity.dart';

class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({
    required super.id,
    required super.enquiryId,
    required super.senderId,
    super.senderName,
    super.senderAvatar,
    required super.senderRole,
    required super.message,
    super.type,
    required super.timestamp,
    super.isRead,
    super.metadata,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final senderObj = json['sender'] as Map<String, dynamic>?;
    return ChatMessageModel(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      enquiryId: json['enquiry_id'] ?? json['enquiryId'] ?? 0,
      senderId: json['sender_id'] ?? senderObj?['id'] ?? 0,
      senderName: json['sender_name'] ?? senderObj?['name'],
      senderAvatar: json['sender_avatar'] ?? senderObj?['avatar_url'],
      senderRole: json['sender_role'] ?? json['role'] ?? senderObj?['role'] ?? 'tenant',
      message: json['message'] ?? '',
      type: MessageType.fromString(json['type'] ?? json['message_type']),
      timestamp: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : json['timestamp'] != null
              ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
              : DateTime.now(),
      isRead: json['is_read'] ?? json['read'] ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'enquiry_id': enquiryId,
      'sender_id': senderId,
      'sender_role': senderRole,
      'message': message,
      'type': type.value,
      'created_at': timestamp.toIso8601String(),
      'is_read': isRead,
      'metadata': metadata,
    };
  }

  ChatMessageModel copyWithModel({
    String? id,
    int? enquiryId,
    int? senderId,
    String? senderName,
    String? senderAvatar,
    String? senderRole,
    String? message,
    MessageType? type,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      enquiryId: enquiryId ?? this.enquiryId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      senderRole: senderRole ?? this.senderRole,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      metadata: metadata ?? this.metadata,
    );
  }
}
