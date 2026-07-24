import 'package:roomly/domain/entities/notification_entity.dart';
import 'package:roomly/domain/repositories/notification_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:roomly/core/errors/failures.dart';
import 'package:roomly/core/network/api_client.dart';

/// Implementation of NotificationRepository
class NotificationRepositoryImpl implements NotificationRepository {
  final ApiClient apiClient;

  NotificationRepositoryImpl({required this.apiClient});

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    int page = 1,
    int limit = 20,
    String? type,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }

      final response = await apiClient.get(
        '/notifications',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> notificationsJson = data['data'] ?? data;

        final notifications = notificationsJson
            .map((json) => _notificationFromJson(json))
            .toList();

        return Right(notifications);
      } else {
        return Left(ServerFailure('Failed to fetch notifications'));
      }
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> markAsRead(String notificationId) async {
    try {
      final response = await apiClient.post(
        '/notifications/$notificationId/read',
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Right(true);
      } else {
        return Left(ServerFailure('Failed to mark notification as read'));
      }
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> markAllAsRead() async {
    try {
      final response = await apiClient.post('/notifications/read-all');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Right(true);
      } else {
        return Left(ServerFailure('Failed to mark all notifications as read'));
      }
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteNotification(String notificationId) async {
    try {
      final response = await apiClient.delete(
        '/notifications/$notificationId',
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Right(true);
      } else {
        return Left(ServerFailure('Failed to delete notification'));
      }
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      final response = await apiClient.get('/notifications/unread-count');

      if (response.statusCode == 200) {
        final data = response.data;
        final count = data['count'] ?? data['unread_count'] ?? 0;
        return Right(count as int);
      } else {
        return const Right(0);
      }
    } catch (e) {
      return const Right(0);
    }
  }

  /// Helper method to convert JSON to NotificationEntity
  NotificationEntity _notificationFromJson(Map<String, dynamic> json) {
    return NotificationEntity(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? json['message'] ?? '',
      type: _parseNotificationType(json['type']),
      isRead: json['is_read'] ?? json['read'] ?? false,
      timestamp: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  /// Parse notification type from string
  NotificationType _parseNotificationType(String? type) {
    if (type == null) return NotificationType.system;

    switch (type.toLowerCase()) {
      case 'enquiry':
        return NotificationType.enquiry;
      case 'property_viewed':
      case 'viewed':
        return NotificationType.propertyViewed;
      case 'payment':
        return NotificationType.payment;
      case 'access_pass':
      case 'pass':
        return NotificationType.accessPass;
      case 'listing_approved':
      case 'approved':
        return NotificationType.listingApproved;
      case 'listing_rejected':
      case 'rejected':
        return NotificationType.listingRejected;
      case 'reminder':
        return NotificationType.reminder;
      case 'review':
        return NotificationType.review;
      default:
        return NotificationType.system;
    }
  }
}
