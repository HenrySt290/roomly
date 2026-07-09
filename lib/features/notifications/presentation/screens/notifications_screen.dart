import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 1,
      'title': 'Property Viewed',
      'message': 'Your property at Andheri was viewed by 5 users today',
      'time': '2 hours ago',
      'type': 'info',
      'read': false,
    },
    {
      'id': 2,
      'title': 'New Enquiry',
      'message': 'Rahul Sharma is interested in your 2 BHK property',
      'time': '5 hours ago',
      'type': 'enquiry',
      'read': false,
    },
    {
      'id': 3,
      'title': 'Payment Successful',
      'message': '₹9 paid for listing your property at Koramangala',
      'time': '1 day ago',
      'type': 'payment',
      'read': true,
    },
    {
      'id': 4,
      'title': 'Access Pass Purchased',
      'message': 'You purchased a 24-hour access pass. Valid until tomorrow 3 PM',
      'time': '2 days ago',
      'type': 'pass',
      'read': true,
    },
    {
      'id': 5,
      'title': 'Listing Approved',
      'message': 'Your property listing has been approved and is now live',
      'time': '3 days ago',
      'type': 'success',
      'read': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () {
              setState(() {
                for (var notification in _notifications) {
                  notification['read'] = true;
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications marked as read')),
              );
            },
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (ctx, index) {
                final notification = _notifications[index];
                return _buildNotificationCard(notification);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 80, color: AppColors.textLight),
          const SizedBox(height: 16),
          Text('No notifications yet', style: AppTextStyles.headingSmall.copyWith(color: AppColors.textDark)),
          const SizedBox(height: 8),
          Text('When you get notifications, they\'ll appear here', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight)),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isRead = notification['read'] as bool;
    final type = notification['type'] as String;
    
    IconData icon;
    Color iconColor;
    
    switch (type) {
      case 'enquiry':
        icon = Icons.message;
        iconColor = AppColors.primary;
        break;
      case 'payment':
        icon = Icons.payment;
        iconColor = AppColors.success;
        break;
      case 'pass':
        icon = Icons.vip_card;
        iconColor = AppColors.warning;
        break;
      case 'success':
        icon = Icons.check_circle;
        iconColor = AppColors.success;
        break;
      default:
        icon = Icons.info;
        iconColor = AppColors.textLight;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRead ? AppColors.surface : AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRead ? AppColors.border : AppColors.primary.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notification['title'] as String,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    if (!isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification['message'] as String,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
                ),
                const SizedBox(height: 8),
                Text(
                  notification['time'] as String,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
