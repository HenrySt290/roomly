import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:roomly/core/services/realtime_notification_service.dart';
import 'package:roomly/domain/entities/notification_entity.dart';
import 'package:roomly/features/enquiries/providers/enquiry_notifier.dart';
import 'package:roomly/features/payment/providers/payment_notifier.dart';
import 'package:roomly/features/reviews/providers/review_notifier.dart';
import 'package:roomly/features/properties/providers/property_notifier.dart';
import 'package:roomly/domain/entities/enquiry_entity.dart';
import 'package:roomly/domain/entities/chat_message_entity.dart';

/// App-wide real-time notification manager matching active chat exchanges
/// and state changes (e.g., successful subscription processing)
/// Production-grade: listens to Enquiry, Payment, Review, Property notifiers and pushes local notifications
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
    PropertyNotifier? propertyNotifier,
  }) {
    // Clear old
    for (final s in _subscriptions) {
      s.cancel();
    }
    _subscriptions.clear();

    // ---------- Enquiry & Chat Exchange Tracking ----------
    int prevMessageCount = enquiryNotifier.messages.length;
    String? prevEnquiryId = enquiryNotifier.selectedEnquiry?.id.toString();
    EnquiryStatus? prevEnquiryStatus = enquiryNotifier.selectedEnquiry?.status;
    int prevMyEnquiriesCount = enquiryNotifier.myEnquiries.length;
    int prevReceivedCount = enquiryNotifier.receivedEnquiries.length;

    void enquiryListener() {
      // New chat messages
      if (enquiryNotifier.messages.length > prevMessageCount) {
        final newMessages = enquiryNotifier.messages.sublist(prevMessageCount);
        for (final msg in newMessages) {
          if (msg.senderId == 0) continue; // optimistic temp
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

      // Enquiry status changes (accepted, closed, replied)
      final currentEnquiry = enquiryNotifier.selectedEnquiry;
      if (currentEnquiry != null && prevEnquiryStatus != currentEnquiry.status) {
        if (currentEnquiry.status == EnquiryStatus.accepted) {
          _service.pushLocal(
            title: 'Booking Accepted! ✅',
            body: '${currentEnquiry.propertyTitle} booking confirmed by owner',
            type: NotificationType.listingApproved,
            data: {'enquiry_id': currentEnquiry.id, 'property_id': currentEnquiry.propertyId},
          );
          _pushBanner(_service.notifications.first);
        } else if (currentEnquiry.status == EnquiryStatus.replied) {
          _service.pushLocal(
            title: 'Owner replied 💬',
            body: currentEnquiry.lastMessage ?? 'New reply on ${currentEnquiry.propertyTitle}',
            type: NotificationType.enquiry,
            data: {'enquiry_id': currentEnquiry.id},
          );
          _pushBanner(_service.notifications.first);
        } else if (currentEnquiry.status == EnquiryStatus.closed) {
          _service.pushLocal(
            title: 'Chat closed',
            body: 'Enquiry #${currentEnquiry.id} closed',
            type: NotificationType.system,
            data: {'enquiry_id': currentEnquiry.id},
          );
          _pushBanner(_service.notifications.first);
        }
        prevEnquiryStatus = currentEnquiry.status;
      }

      // New enquiry created (tenant) or received (owner)
      if (enquiryNotifier.myEnquiries.length > prevMyEnquiriesCount) {
        final newEnquiry = enquiryNotifier.myEnquiries.first;
        _service.pushLocal(
          title: 'Enquiry sent 📩',
          body: 'Your enquiry for ${newEnquiry.propertyTitle} sent successfully',
          type: NotificationType.enquiry,
          data: {'enquiry_id': newEnquiry.id, 'property_id': newEnquiry.propertyId},
        );
        _pushBanner(_service.notifications.first);
        prevMyEnquiriesCount = enquiryNotifier.myEnquiries.length;
      }
      if (enquiryNotifier.receivedEnquiries.length > prevReceivedCount) {
        final newEnquiry = enquiryNotifier.receivedEnquiries.first;
        _service.pushEnquiryReceived(propertyTitle: newEnquiry.propertyTitle, tenantName: newEnquiry.tenantName ?? 'Tenant');
        _pushBanner(_service.notifications.first);
        prevReceivedCount = enquiryNotifier.receivedEnquiries.length;
      }

      // Reset counters on enquiry switch
      final currentId = enquiryNotifier.selectedEnquiry?.id.toString();
      if (currentId != prevEnquiryId) {
        prevEnquiryId = currentId;
        prevMessageCount = enquiryNotifier.messages.length;
        prevEnquiryStatus = enquiryNotifier.selectedEnquiry?.status;
      }
    }

    enquiryNotifier.addListener(enquiryListener);

    // ---------- Payment / Subscription Tracking ----------
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
          _service.pushLocal(
            title: 'Payment Successful 💳',
            body: '₹${state.amount.toStringAsFixed(0)} ${state.paymentType} payment completed',
            type: NotificationType.payment,
            data: {'order_id': state.orderId, 'payment_type': state.paymentType, 'amount': state.amount},
          );
          _pushBanner(_service.notifications.first);
        } else if (state is PaymentFailure) {
          _service.pushLocal(
            title: 'Payment Failed ❌',
            body: state.message,
            type: NotificationType.payment,
            data: {'error': state.message},
          );
          _pushBanner(_service.notifications.first);
        }
      }
      prevPaymentState = state;
    }

    paymentNotifier.addListener(paymentListener);

    // ---------- Review Tracking ----------
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

    // ---------- Property Listing Tracking ----------
    if (propertyNotifier != null) {
      int prevPropertiesCount = propertyNotifier.properties.length;
      int prevOwnerCount = propertyNotifier.ownerProperties.length;
      void propertyListener() {
        if (propertyNotifier.properties.length > prevPropertiesCount) {
          // New property published in feed – could notify? Skip for tenant
        }
        if (propertyNotifier.ownerProperties.length > prevOwnerCount) {
          final newProp = propertyNotifier.ownerProperties.isNotEmpty ? propertyNotifier.ownerProperties.first : null;
          if (newProp != null) {
            _service.pushLocal(
              title: 'Property Listed 🏠',
              body: '${newProp.title} added to your listings',
              type: NotificationType.listingApproved,
              data: {'property_id': newProp.id},
            );
            _pushBanner(_service.notifications.first);
          }
          prevOwnerCount = propertyNotifier.ownerProperties.length;
        }
        prevPropertiesCount = propertyNotifier.properties.length;
      }

      propertyNotifier.addListener(propertyListener);
    }

    // Global stream listener
    final sub = _service.notificationStream.listen((_) {
      notifyListeners();
    });
    _subscriptions.add(sub);
  }

  void _pushBanner(NotificationEntity notif) {
    _recentBanners.insert(0, notif);
    if (_recentBanners.length > 5) {
      _recentBanners.removeLast();
    }
    notifyListeners();
    Future.delayed(const Duration(seconds: 4), () {
      _recentBanners.remove(notif);
      notifyListeners();
    });
  }

  void pushCustom({required String title, required String body, NotificationType type = NotificationType.system, Map<String, dynamic>? data}) {
    _service.pushLocal(title: title, body: body, type: type, data: data);
    _pushBanner(_service.notifications.first);
  }

  void simulateChatMessage({required String senderName, required String message}) {
    _service.pushChatMessage(enquiryId: 'sim_${DateTime.now().millisecondsSinceEpoch}', senderName: senderName, message: message, isBooking: false);
    _pushBanner(_service.notifications.first);
  }

  void simulateSubscriptionSuccess({required String type, double amount = 5}) {
    _service.pushSubscriptionSuccess(type: type, amount: amount);
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
