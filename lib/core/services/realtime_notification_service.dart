import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:roomly/domain/entities/notification_entity.dart';

/// App-wide real-time notification manager
/// Matches active chat exchanges or state changes (e.g., successful subscription processing)
/// Implements functional reactive pattern with Stream + ChangeNotifier
class RealtimeNotificationService {
  static final RealtimeNotificationService _instance = RealtimeNotificationService._internal();
  factory RealtimeNotificationService() => _instance;
  RealtimeNotificationService._internal();

  final StreamController<NotificationEntity> _notificationController = StreamController<NotificationEntity>.broadcast();
  final List<NotificationEntity> _notifications = [];
  int _unreadCount = 0;

  Stream<NotificationEntity> get notificationStream => _notificationController.stream;
  List<NotificationEntity> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _unreadCount;

  void pushNotification(NotificationEntity notification) {
    _notifications.insert(0, notification);
    if (!notification.isRead) {
      _unreadCount++;
    }
    if (!_notificationController.isClosed) {
      _notificationController.add(notification);
    }
    if (kDebugMode) {
      print('[RealtimeNotification] ${notification.title}: ${notification.body}');
    }
  }

  // Convenience for local app events (chat, payment, review, etc.)
  void pushLocal({
    required String title,
    required String body,
    NotificationType type = NotificationType.system,
    Map<String, dynamic>? data,
    String id = '',
  }) {
    final notif = NotificationEntity(
      id: id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : id,
      title: title,
      body: body,
      type: type,
      isRead: false,
      timestamp: DateTime.now(),
      data: data,
    );
    pushNotification(notif);
  }

  // Chat exchange real-time
  void pushChatMessage({
    required String enquiryId,
    required String senderName,
    required String message,
    required bool isBooking,
  }) {
    pushLocal(
      title: isBooking ? 'New booking request from $senderName' : 'New message from $senderName',
      body: message,
      type: isBooking ? NotificationType.enquiry : NotificationType.enquiry,
      data: {'enquiry_id': enquiryId, 'sender_name': senderName, 'type': isBooking ? 'booking_request' : 'chat'},
    );
  }

  // Subscription processing success
  void pushSubscriptionSuccess({
    required String type, // access_pass or listing
    required double amount,
    String? propertyTitle,
  }) {
    if (type == 'access_pass') {
      pushLocal(
        title: 'Access Pass Activated! 🎫',
        body: 'Your ₹${amount.toStringAsFixed(0)} pass is active for 24 hours. Unlock unlimited properties!',
        type: NotificationType.accessPass,
        data: {'type': 'access_pass_activated', 'amount': amount},
      );
    } else if (type == 'listing') {
      pushLocal(
        title: 'Listing Published! ✅',
        body: propertyTitle != null ? '$propertyTitle is now live after ₹${amount.toStringAsFixed(0)} payment' : 'Your property is now live!',
        type: NotificationType.listingApproved,
        data: {'type': 'listing_published', 'amount': amount, 'property_title': propertyTitle},
      );
    }
  }

  void pushReviewReceived({required String propertyTitle, required int rating}) {
    pushLocal(
      title: 'New review received ⭐',
      body: 'Someone gave $rating stars to $propertyTitle',
      type: NotificationType.review,
      data: {'property_title': propertyTitle, 'rating': rating},
    );
  }

  void pushEnquiryReceived({required String propertyTitle, required String tenantName}) {
    pushLocal(
      title: 'New enquiry for $propertyTitle',
      body: '$tenantName is interested in your property',
      type: NotificationType.enquiry,
      data: {'property_title': propertyTitle, 'tenant_name': tenantName},
    );
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _unreadCount = 0;
  }

  void markAsRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1 && !_notifications[idx].isRead) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      _unreadCount = (_unreadCount - 1).clamp(0, 9999);
    }
  }

  void clear() {
    _notifications.clear();
    _unreadCount = 0;
  }

  void dispose() {
    _notificationController.close();
  }
}
