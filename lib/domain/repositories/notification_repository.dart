import 'package:roomly/domain/entities/notification_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:roomly/core/errors/failures.dart';

/// Repository interface for notification operations
abstract class NotificationRepository {
  /// Get all notifications for current user
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    int page = 1,
    int limit = 20,
    String? type,
  });

  /// Mark a single notification as read
  Future<Either<Failure, bool>> markAsRead(String notificationId);

  /// Mark all notifications as read
  Future<Either<Failure, bool>> markAllAsRead();

  /// Delete a notification
  Future<Either<Failure, bool>> deleteNotification(String notificationId);

  /// Get unread notification count
  Future<Either<Failure, int>> getUnreadCount();
}
