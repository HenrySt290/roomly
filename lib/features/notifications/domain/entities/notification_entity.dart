import 'package:equatable/equatable.dart';

/// Notification entity representing a single notification
class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  factory NotificationEntity.fromJson(Map<String, dynamic> json) {
    return NotificationEntity(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: NotificationType.fromString(json['type'] as String),
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  NotificationEntity copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    bool? isRead,
    DateTime? createdAt,
    Map<String, dynamic>? data,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [id, title, body, type, isRead, createdAt, data];
}

/// Types of notifications
enum NotificationType {
  enquiry,
  payment,
  accessPass,
  listingApproved,
  listingRejected,
  propertyViewed,
  review,
  system,
}

extension NotificationTypeExtension on NotificationType {
  static NotificationType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'enquiry':
      case 'new_enquiry':
        return NotificationType.enquiry;
      case 'payment':
      case 'payment_success':
        return NotificationType.payment;
      case 'access_pass':
      case 'pass_purchased':
        return NotificationType.accessPass;
      case 'listing_approved':
      case 'approved':
        return NotificationType.listingApproved;
      case 'listing_rejected':
      case 'rejected':
        return NotificationType.listingRejected;
      case 'property_viewed':
      case 'viewed':
        return NotificationType.propertyViewed;
      case 'review':
      case 'new_review':
        return NotificationType.review;
      case 'system':
      case 'alert':
        return NotificationType.system;
      default:
        return NotificationType.system;
    }
  }

  String get value {
    switch (this) {
      case NotificationType.enquiry:
        return 'enquiry';
      case NotificationType.payment:
        return 'payment';
      case NotificationType.accessPass:
        return 'access_pass';
      case NotificationType.listingApproved:
        return 'listing_approved';
      case NotificationType.listingRejected:
        return 'listing_rejected';
      case NotificationType.propertyViewed:
        return 'property_viewed';
      case NotificationType.review:
        return 'review';
      case NotificationType.system:
        return 'system';
    }
  }

  String get displayName {
    switch (this) {
      case NotificationType.enquiry:
        return 'New Enquiry';
      case NotificationType.payment:
        return 'Payment';
      case NotificationType.accessPass:
        return 'Access Pass';
      case NotificationType.listingApproved:
        return 'Listing Approved';
      case NotificationType.listingRejected:
        return 'Listing Rejected';
      case NotificationType.propertyViewed:
        return 'Property Viewed';
      case NotificationType.review:
        return 'Review';
      case NotificationType.system:
        return 'System';
    }
  }
}
