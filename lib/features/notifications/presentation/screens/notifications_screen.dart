import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roomly/features/notifications/providers/notification_notifier.dart';
import 'package:roomly/domain/entities/notification_entity.dart';
import 'package:roomly/core/theme/app_colors.dart';
import 'package:roomly/core/theme/app_text_styles.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  NotificationType? _selectedFilter;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationNotifier>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          Consumer<NotificationNotifier>(
            builder: (context, notifier, _) {
              final hasUnread = notifier.state.notifications.any((n) => !n.isRead);
              if (!hasUnread) return const SizedBox.shrink();
              
              return IconButton(
                icon: const Icon(Icons.done_all),
                onPressed: () {
                  notifier.markAllAsRead();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All notifications marked as read')),
                  );
                },
                tooltip: 'Mark all as read',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<NotificationNotifier>().refresh();
            },
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textLight,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Unread'),
            Tab(text: 'Types'),
          ],
          onTap: (index) {
            if (index == 0) {
              setState(() => _selectedFilter = null);
              context.read<NotificationNotifier>().setFilter(null);
            } else if (index == 1) {
              // Filter unread - handled in UI
            } else {
              // Show type selector dialog
              _showTypeFilterDialog();
            }
          },
        ),
      ),
      body: Consumer<NotificationNotifier>(
        builder: (context, notifier, _) {
          if (notifier.state.isLoading && notifier.state.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (notifier.state.error != null && notifier.state.notifications.isEmpty) {
            return _buildErrorState(notifier.state.error!);
          }

          var notifications = notifier.state.notifications;
          
          // Filter by unread if tab 1 is selected
          if (_tabController.index == 1) {
            notifications = notifications.where((n) => !n.isRead).toList();
          }

          if (notifications.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => notifier.refresh(),
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (ctx, index) {
                final notification = notifications[index];
                return _buildNotificationCard(notification, notifier);
              },
            ),
          );
        },
      ),
    );
  }

  void _showTypeFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filter by Type', style: AppTextStyles.headingSmall),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _filterChip('All', null),
                _filterChip('Enquiry', NotificationType.enquiry),
                _filterChip('Payment', NotificationType.payment),
                _filterChip('Access Pass', NotificationType.accessPass),
                _filterChip('Listing', NotificationType.listingApproved),
                _filterChip('System', NotificationType.system),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, NotificationType? type) {
    final isSelected = _selectedFilter == type;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedFilter = selected ? type : null);
        context.read<NotificationNotifier>().setFilter(type);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: AppColors.error),
          const SizedBox(height: 16),
          Text('Failed to load notifications', style: AppTextStyles.headingSmall.copyWith(color: AppColors.textDark)),
          const SizedBox(height: 8),
          Text(error, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.read<NotificationNotifier>().refresh(),
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
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
          Text(_tabController.index == 1 
              ? 'You have no unread notifications'
              : 'When you get notifications, they\'ll appear here', 
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight)),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationEntity notification, NotificationNotifier notifier) {
    IconData icon;
    Color iconColor;
    
    switch (notification.type) {
      case NotificationType.enquiry:
        icon = Icons.message;
        iconColor = AppColors.primary;
        break;
      case NotificationType.payment:
        icon = Icons.payment;
        iconColor = AppColors.success;
        break;
      case NotificationType.accessPass:
        icon = Icons.vip_card;
        iconColor = AppColors.warning;
        break;
      case NotificationType.listingApproved:
        icon = Icons.check_circle;
        iconColor = AppColors.success;
        break;
      case NotificationType.listingRejected:
        icon = Icons.cancel;
        iconColor = AppColors.error;
        break;
      case NotificationType.propertyViewed:
        icon = Icons.visibility;
        iconColor = AppColors.info;
        break;
      case NotificationType.review:
        icon = Icons.star;
        iconColor = AppColors.warning;
        break;
      default:
        icon = Icons.info;
        iconColor = AppColors.textLight;
    }

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        notifier.deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification deleted')),
        );
      },
      child: GestureDetector(
        onTap: () {
          if (!notification.isRead) {
            notifier.markAsRead(notification.id);
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead ? AppColors.surface : AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: notification.isRead ? AppColors.border : AppColors.primary.withOpacity(0.3),
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
                            notification.title,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
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
                      notification.body,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTime(notification.timestamp),
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    
    return '${time.day}/${time.month}/${time.year}';
  }
}
