import 'package:equatable/equatable.dart';

/// Notification entity representing a push/in-app notification
class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final bool isRead;
  final DateTime timestamp;
  final Map<String, dynamic>? data;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.timestamp,
    this.data,
  });

  @override
  List<Object?> get props => [id, title, body, type, isRead, timestamp, data];

  NotificationEntity copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    bool? isRead,
    DateTime? timestamp,
    Map<String, dynamic>? data,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp ?? this.timestamp,
      data: data ?? this.data,
    );
  }
}

/// Notification types for categorization
enum NotificationType {
  enquiry, // New tenant enquiry
  propertyViewed, // Property view statistics
  payment, // Payment success/failure
  accessPass, // Access pass purchased/expired
  listingApproved, // Listing approved by admin
  listingRejected, // Listing rejected
  system, // System announcements
  reminder, // Reminders (pass expiry, relisting)
  review, // New review received
}

/// Extension for human-readable notification type labels
extension NotificationTypeExtension on NotificationType {
  String get label {
    switch (this) {
      case NotificationType.enquiry:
        return 'Enquiry';
      case NotificationType.propertyViewed:
        return 'Property Viewed';
      case NotificationType.payment:
        return 'Payment';
      case NotificationType.accessPass:
        return 'Access Pass';
      case NotificationType.listingApproved:
        return 'Listing Approved';
      case NotificationType.listingRejected:
        return 'Listing Rejected';
      case NotificationType.system:
        return 'System';
      case NotificationType.reminder:
        return 'Reminder';
      case NotificationType.review:
        return 'Review';
    }
  }

  String get icon {
    switch (this) {
      case NotificationType.enquiry:
        return '📩';
      case NotificationType.propertyViewed:
        return '👁️';
      case NotificationType.payment:
        return '💳';
      case NotificationType.accessPass:
        return '🎫';
      case NotificationType.listingApproved:
        return '✅';
      case NotificationType.listingRejected:
        return '❌';
      case NotificationType.system:
        return 'ℹ️';
      case NotificationType.reminder:
        return '⏰';
      case NotificationType.review:
        return '⭐';
    }
  }
}
