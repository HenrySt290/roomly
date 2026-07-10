import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';

/// State class for notification management
class NotificationState extends Equatable {
  final bool isLoading;
  final List<NotificationEntity> notifications;
  final int unreadCount;
  final String? error;
  final NotificationType? filterType;

  const NotificationState({
    this.isLoading = false,
    this.notifications = const [],
    this.unreadCount = 0,
    this.error,
    this.filterType,
  });

  @override
  List<Object?> get props => [isLoading, notifications, unreadCount, error, filterType];

  NotificationState copyWith({
    bool? isLoading,
    List<NotificationEntity>? notifications,
    int? unreadCount,
    String? error,
    NotificationType? filterType,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      error: error,
      filterType: filterType ?? this.filterType,
    );
  }
}

/// Notifier for managing notification state and operations
class NotificationNotifier extends ChangeNotifier {
  final NotificationRepository notificationRepository;

  NotificationState _state = const NotificationState();
  NotificationState get state => _state;

  NotificationNotifier({required this.notificationRepository});

  /// Initialize and load notifications
  Future<void> initialize() async {
    await loadNotifications();
    await loadUnreadCount();
  }

  /// Load all notifications with optional filtering
  Future<void> loadNotifications({NotificationType? type}) async {
    _state = _state.copyWith(isLoading: true, error: null, filterType: type);
    notifyListeners();

    final result = await notificationRepository.getNotifications(
      type: type?.name,
    );

    result.fold(
      (failure) {
        _state = _state.copyWith(
          isLoading: false,
          error: _mapFailureToMessage(failure),
        );
        notifyListeners();
      },
      (notifications) {
        _state = _state.copyWith(
          isLoading: false,
          notifications: notifications,
          error: null,
        );
        notifyListeners();
      },
    );
  }

  /// Mark a single notification as read
  Future<void> markAsRead(String notificationId) async {
    final result = await notificationRepository.markAsRead(notificationId);

    result.fold(
      (failure) {
        // Show error but don't update state
        debugPrint('Failed to mark notification as read: ${failure.toString()}');
      },
      (_) {
        // Update local state
        _state = _state.copyWith(
          notifications: _state.notifications.map((n) {
            if (n.id == notificationId) {
              return n.copyWith(isRead: true);
            }
            return n;
          }).toList(),
          unreadCount: _state.unreadCount > 0 ? _state.unreadCount - 1 : 0,
        );
        notifyListeners();
      },
    );
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    final result = await notificationRepository.markAllAsRead();

    result.fold(
      (failure) {
        debugPrint('Failed to mark all as read: ${failure.toString()}');
      },
      (_) {
        _state = _state.copyWith(
          notifications: _state.notifications.map((n) => n.copyWith(isRead: true)).toList(),
          unreadCount: 0,
        );
        notifyListeners();
      },
    );
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    final result = await notificationRepository.deleteNotification(notificationId);

    result.fold(
      (failure) {
        debugPrint('Failed to delete notification: ${failure.toString()}');
      },
      (_) {
        _state = _state.copyWith(
          notifications: _state.notifications.where((n) => n.id != notificationId).toList(),
          unreadCount: _state.notifications.firstWhere(
            (n) => n.id == notificationId,
            orElse: () => const NotificationEntity(
              id: '',
              title: '',
              body: '',
              type: NotificationType.system,
              isRead: true,
              timestamp: DateTime.now(),
            ),
          ).isRead
              ? _state.unreadCount
              : _state.unreadCount - 1,
        );
        notifyListeners();
      },
    );
  }

  /// Load unread count
  Future<void> loadUnreadCount() async {
    final result = await notificationRepository.getUnreadCount();

    result.fold(
      (failure) {
        // Silently fail, keep current count
      },
      (count) {
        _state = _state.copyWith(unreadCount: count);
        notifyListeners();
      },
    );
  }

  /// Set filter type
  void setFilter(NotificationType? type) {
    _state = _state.copyWith(filterType: type);
    notifyListeners();
    loadNotifications(type: type);
  }

  /// Clear error
  void clearError() {
    _state = _state.copyWith(error: null);
    notifyListeners();
  }

  /// Refresh all data
  Future<void> refresh() async {
    await loadNotifications(type: _state.filterType);
    await loadUnreadCount();
  }

  /// Map failure to user-friendly message
  String _mapFailureToMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return 'Check your internet connection';
    } else if (failure is ServerFailure) {
      return 'Server error. Please try again';
    }
    return 'Something went wrong';
  }
}
