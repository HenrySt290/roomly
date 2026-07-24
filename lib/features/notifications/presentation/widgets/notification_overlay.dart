import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roomly/core/theme/app_colors.dart';
import 'package:roomly/core/theme/app_text_styles.dart';
import 'package:roomly/features/notifications/providers/app_notification_manager.dart';
import 'package:roomly/domain/entities/notification_entity.dart';
import 'package:roomly/features/enquiries/providers/enquiry_notifier.dart';
import 'package:roomly/features/payment/providers/payment_notifier.dart';
import 'package:roomly/features/reviews/providers/review_notifier.dart';

class NotificationOverlay extends StatelessWidget {
  final Widget child;

  const NotificationOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        // Real-time banners top
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          right: 16,
          child: Consumer<AppNotificationManager>(builder: (context, manager, _) {
            final banners = manager.recentBanners;
            if (banners.isEmpty) return const SizedBox.shrink();
            return Column(
              children: banners.map((n) => _BannerCard(notification: n, onDismiss: () => manager.markAsRead(n.id))).toList(),
            );
          }),
        ),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onDismiss;

  const _BannerCard({required this.notification, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _colorForType(notification.type).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: _colorForType(notification.type).withOpacity(0.15), shape: BoxShape.circle),
            child: Text(notification.type.icon, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.title, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(notification.body, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 10, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text('now', style: AppTextStyles.caption.copyWith(color: AppColors.textHint, fontSize: 10)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        // Navigate based on type
                        final data = notification.data;
                        if (data != null && data['enquiry_id'] != null) {
                          Navigator.pushNamed(context, '/enquiries');
                        } else if (data != null && data['type'] == 'access_pass_activated') {
                          Navigator.pushNamed(context, '/home');
                        }
                      },
                      child: Text('View', style: AppTextStyles.caption.copyWith(color: _colorForType(notification.type), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(onTap: onDismiss, child: const Icon(Icons.close, size: 18, color: AppColors.textHint)),
        ],
      ),
    );
  }

  Color _colorForType(NotificationType type) {
    switch (type) {
      case NotificationType.enquiry:
        return AppColors.info;
      case NotificationType.payment:
        return AppColors.success;
      case NotificationType.accessPass:
        return AppColors.primary;
      case NotificationType.listingApproved:
        return AppColors.success;
      case NotificationType.review:
        return AppColors.warning;
      case NotificationType.system:
      default:
        return AppColors.textSecondary;
    }
  }
}

/// Listener widget that attaches real-time listeners to other notifiers
/// Should be placed above MaterialApp or inside RoomlyApp builder
class AppNotificationListener extends StatefulWidget {
  final Widget child;

  const AppNotificationListener({super.key, required this.child});

  @override
  State<AppNotificationListener> createState() => _AppNotificationListenerState();
}

class _AppNotificationListenerState extends State<AppNotificationListener> {
  bool _attached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_attached) {
      // Attach after first frame to ensure all providers are available
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          final appManager = context.read<AppNotificationManager>();
          final enquiryNotifier = context.read<EnquiryNotifier>();
          final paymentNotifier = context.read<PaymentNotifier>();
          final reviewNotifier = context.read<ReviewNotifier>();

          // Import here to avoid circular
          // ignore: avoid_dynamic_calls
          appManager.attachListeners(
            enquiryNotifier: enquiryNotifier,
            paymentNotifier: paymentNotifier,
            reviewNotifier: reviewNotifier,
          );
        } catch (e) {
          // Providers not yet ready, will retry on next dependency change
          debugPrint('AppNotificationListener attach failed: $e');
        }
      });
      _attached = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
