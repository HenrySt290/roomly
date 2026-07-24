import 'package:equatable/equatable.dart';

enum MessageType {
  text('text'),
  system('system'),
  bookingRequest('booking_request'),
  bookingConfirmed('booking_confirmed'),
  paymentReminder('payment_reminder');

  final String value;
  const MessageType(this.value);

  static MessageType fromString(String? raw) {
    if (raw == null) return MessageType.text;
    return MessageType.values.firstWhere(
      (e) => e.value.toLowerCase() == raw.toLowerCase(),
      orElse: () => MessageType.text,
    );
  }

  bool get isSystem => this == MessageType.system;
  bool get isBooking => this == MessageType.bookingRequest || this == MessageType.bookingConfirmed;
}

class ChatMessageEntity extends Equatable {
  final String id;
  final int enquiryId;
  final int senderId;
  final String? senderName;
  final String? senderAvatar;
  final String senderRole; // tenant / owner / system
  final String message;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? metadata;

  const ChatMessageEntity({
    required this.id,
    required this.enquiryId,
    required this.senderId,
    this.senderName,
    this.senderAvatar,
    required this.senderRole,
    required this.message,
    this.type = MessageType.text,
    required this.timestamp,
    this.isRead = false,
    this.metadata,
  });

  bool get isFromOwner => senderRole.toLowerCase() == 'owner';
  bool get isFromTenant => senderRole.toLowerCase() == 'tenant';
  bool get isSystem => type.isSystem;

  @override
  List<Object?> get props => [id, enquiryId, senderId, message, type, timestamp, isRead];
}
