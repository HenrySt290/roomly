import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';

/// State class for notifications feature
class NotificationState extends Equatable {
  final List<NotificationEntity> notifications;
  final int unreadCount;
  final bool isLoading;
  final String? errorMessage;
  final NotificationType? filterType;
  final int currentPage;
  final bool hasReachedMax;

  const NotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.errorMessage,
    this.filterType,
    this.currentPage = 1,
    this.hasReachedMax = false,
  });

  NotificationState copyWith({
    List<NotificationEntity>? notifications,
    int? unreadCount,
    bool? isLoading,
    String? errorMessage,
    NotificationType? filterType,
    int? currentPage,
    bool? hasReachedMax,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      filterType: filterType ?? this.filterType,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [
        notifications,
        unreadCount,
        isLoading,
        errorMessage,
        filterType,
        currentPage,
        hasReachedMax,
      ];
}

/// Notifier for notifications functionality
class NotificationNotifier extends ChangeNotifier {
  final NotificationRepository notificationRepository;
  NotificationState _state = const NotificationState();

  NotificationNotifier({required this.notificationRepository});

  NotificationState get state => _state;

  /// Initialize by loading notifications and unread count
  Future<void> initialize() async {
    await Future.wait([
      loadNotifications(isRefresh: true),
      refreshUnreadCount(),
    ]);
  }

  /// Load notifications
  Future<void> loadNotifications({bool isRefresh = false}) async {
    if (isRefresh) {
      _state = _state.copyWith(
        isLoading: true,
        currentPage: 1,
        hasReachedMax: false,
      );
    } else if (_state.isLoading || _state.hasReachedMax) {
      return;
    } else {
      _state = _state.copyWith(isLoading: true);
    }
    notifyListeners();

    final result = await notificationRepository.getNotifications(
      page: isRefresh ? 1 : _state.currentPage + 1,
      limit: 20,
      type: _state.filterType?.value,
    );

    result.fold(
      (failure) {
        _state = _state.copyWith(
          isLoading: false,
          errorMessage: _mapFailureToMessage(failure),
        );
      },
      (notifications) {
        if (isRefresh) {
          _state = _state.copyWith(
            isLoading: false,
            notifications: notifications,
            currentPage: 1,
            hasReachedMax: notifications.length < 20,
          );
        } else {
          _state = _state.copyWith(
            isLoading: false,
            notifications: [..._state.notifications, ...notifications],
            currentPage: _state.currentPage + 1,
            hasReachedMax: notifications.length < 20,
          );
        }
      },
    );
    notifyListeners();
  }

  /// Mark a single notification as read
  Future<void> markAsRead(String notificationId) async {
    final result = await notificationRepository.markAsRead(notificationId);

    result.fold(
      (failure) {
        // Silently fail, UI will update on next refresh
      },
      (_) {
        // Update local state
        final updatedNotifications = _state.notifications
            .map((n) => n.id == notificationId ? n.copyWith(isRead: true) : n)
            .toList();
        
        _state = _state.copyWith(notifications: updatedNotifications);
        if (_state.unreadCount > 0) {
          _state = _state.copyWith(unreadCount: _state.unreadCount - 1);
        }
        notifyListeners();
      },
    );
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    final result = await notificationRepository.markAllAsRead();

    result.fold(
      (failure) {
        // Silently fail
      },
      (_) {
        // Update local state
        final updatedNotifications = _state.notifications
            .map((n) => n.copyWith(isRead: true))
            .toList();
        
        _state = _state.copyWith(
          notifications: updatedNotifications,
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
        // Silently fail
      },
      (_) {
        // Remove from local state
        final updatedNotifications = _state.notifications
            .where((n) => n.id != notificationId)
            .toList();
        
        _state = _state.copyWith(notifications: updatedNotifications);
        notifyListeners();
      },
    );
  }

  /// Refresh unread count
  Future<void> refreshUnreadCount() async {
    final result = await notificationRepository.getUnreadCount();

    result.fold(
      (failure) {
        // Silently fail
      },
      (count) {
        _state = _state.copyWith(unreadCount: count);
        notifyListeners();
      },
    );
  }

  /// Filter by notification type
  void filterByType(NotificationType? type) {
    _state = _state.copyWith(
      filterType: type,
      currentPage: 1,
      hasReachedMax: false,
    );
    loadNotifications(isRefresh: true);
  }

  /// Clear error message
  void clearError() {
    _state = _state.copyWith(errorMessage: null);
    notifyListeners();
  }

  /// Map failure to user-friendly message
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case TimeoutFailure:
        return 'Request timed out. Please try again.';
      case NetworkFailure:
        return 'No internet connection. Please check your network.';
      case AuthFailure:
        return 'Please login to continue.';
      case ServerFailure:
        return 'Server error. Please try again later.';
      default:
        return 'An unexpected error occurred.';
    }
  }
}
