import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:roomly/core/services/realtime_notification_service.dart';
import 'package:roomly/domain/entities/notification_entity.dart';
import 'package:roomly/features/enquiries/providers/enquiry_notifier.dart';
import 'package:roomly/features/payment/providers/payment_notifier.dart';
import 'package:roomly/features/reviews/providers/review_notifier.dart';
import 'package:roomly/domain/entities/enquiry_entity.dart';
import 'package:roomly/domain/entities/chat_message_entity.dart';

/// App-wide real-time notification manager matching active chat exchanges
/// and state changes (e.g., successful subscription processing)
/// Production-grade: listens to Enquiry, Payment, Review notifiers and pushes local notifications
class AppNotificationManager extends ChangeNotifier {
  final RealtimeNotificationService _service = RealtimeNotificationService();
  final List<StreamSubscription> _subscriptions = [];
  final List<NotificationEntity> _recentBanners = [];

  AppNotificationManager();

  List<NotificationEntity> get notifications => _service.notifications;
  int get unreadCount => _service.unreadCount;
  List<NotificationEntity> get recentBanners => List.unmodifiable(_recentBanners);
  Stream<NotificationEntity> get stream => _service.notificationStream;

  /// Attach listeners to other providers - call once in main after MultiProvider
  void attachListeners({
    required EnquiryNotifier enquiryNotifier,
    required PaymentNotifier paymentNotifier,
    ReviewNotifier? reviewNotifier,
  }) {
    // Clear old
    for (final s in _subscriptions) {
      s.cancel();
    }
    _subscriptions.clear();

    // Listen to enquiry messages - when new message added, push notification
    // We track previous message counts
    int prevMessageCount = enquiryNotifier.messages.length;
    String? prevEnquiryId = enquiryNotifier.selectedEnquiry?.id.toString();

    // EnquiryNotifier is ChangeNotifier, we add listener
    void enquiryListener() {
      // If messages grew, it's new chat exchange
      if (enquiryNotifier.messages.length > prevMessageCount) {
        final newMessages = enquiryNotifier.messages.sublist(prevMessageCount);
        for (final msg in newMessages) {
          // Don't notify for own messages (sender_id 0 is optimistic temp)
          if (msg.senderId == 0) continue;
          // Push real-time chat notification
          _service.pushChatMessage(
            enquiryId: msg.enquiryId.toString(),
            senderName: msg.senderName ?? 'User',
            message: msg.message,
            isBooking: msg.type == MessageType.bookingRequest,
          );
          _pushBanner(_service.notifications.first);
        }
        prevMessageCount = enquiryNotifier.messages.length;
      }

      // If selected enquiry changed, reset count
      final currentId = enquiryNotifier.selectedEnquiry?.id.toString();
      if (currentId != prevEnquiryId) {
        prevEnquiryId = currentId;
        prevMessageCount = enquiryNotifier.messages.length;
      }

      // If new enquiry created (myEnquiries grew)
      // This is handled via explicit method pushEnquiryReceived called from UI, but we also watch
    }

    enquiryNotifier.addListener(enquiryListener);

    // Payment notifier - successful subscription processing
    PaymentState? prevPaymentState = paymentNotifier.state;
    void paymentListener() {
      final state = paymentNotifier.state;
      if (prevPaymentState?.runtimeType != state.runtimeType) {
        if (state is AccessPassActivated) {
          _service.pushSubscriptionSuccess(type: 'access_pass', amount: 5);
          _pushBanner(_service.notifications.first);
        } else if (state is ListingPublished) {
          _service.pushSubscriptionSuccess(type: 'listing', amount: 9, propertyTitle: 'Property #${state.propertyId}');
          _pushBanner(_service.notifications.first);
        } else if (state is PaymentSuccess) {
          // Generic payment success
          _service.pushLocal(
            title: 'Payment Successful 💳',
            body: '₹${state.amount.toStringAsFixed(0)} ${state.paymentType} payment completed',
            type: NotificationType.payment,
            data: {'order_id': state.orderId, 'payment_type': state.paymentType, 'amount': state.amount},
          );
          _pushBanner(_service.notifications.first);
        }
      }
      prevPaymentState = state;
    }

    paymentNotifier.addListener(paymentListener);

    // Review notifier - when new review created
    if (reviewNotifier != null) {
      int prevReviewCount = reviewNotifier.reviews.length;
      void reviewListener() {
        if (reviewNotifier.reviews.length > prevReviewCount) {
          final newReview = reviewNotifier.reviews.first;
          _service.pushReviewReceived(propertyTitle: 'Property #${newReview.propertyId}', rating: newReview.rating);
          _pushBanner(_service.notifications.first);
          prevReviewCount = reviewNotifier.reviews.length;
        }
      }

      reviewNotifier.addListener(reviewListener);
    }

    // Global stream listener to notify UI
    final sub = _service.notificationStream.listen((_) {
      notifyListeners();
    });
    _subscriptions.add(sub);
  }

  void _pushBanner(NotificationEntity notif) {
    _recentBanners.insert(0, notif);
    // Keep only last 5 banners for overlay queue
    if (_recentBanners.length > 5) {
      _recentBanners.removeLast();
    }
    notifyListeners();
    // Auto-dismiss banner after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      _recentBanners.remove(notif);
      notifyListeners();
    });
  }

  void pushCustom({required String title, required String body, NotificationType type = NotificationType.system, Map<String, dynamic>? data}) {
    _service.pushLocal(title: title, body: body, type: type, data: data);
    _pushBanner(_service.notifications.first);
  }

  void markAsRead(String id) {
    _service.markAsRead(id);
    notifyListeners();
  }

  void markAllAsRead() {
    _service.markAllAsRead();
    notifyListeners();
  }

  void clear() {
    _service.clear();
    _recentBanners.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    for (final s in _subscriptions) {
      s.cancel();
    }
    _service.dispose();
    super.dispose();
  }
}
