import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

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
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (type != null && type.isNotEmpty) 'type': type,
      };

      final response = await apiClient.get(
        '/notifications',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['data'] is List) {
          final notifications = (data['data'] as List)
              .map((json) => NotificationEntity.fromJson(json))
              .toList();
          return Right(notifications);
        } else if (data is List) {
          final notifications = data
              .map((json) => NotificationEntity.fromJson(json))
              .toList();
          return Right(notifications);
        }
        return Right([]);
      } else {
        return Left(ServerFailure(response.statusCode ?? 500));
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return Left(const TimeoutFailure());
      }
      if (e.response?.statusCode == 401) {
        return Left(const AuthFailure('Unauthorized'));
      }
      if (e.response?.statusCode == 403) {
        return Left(const AuthFailure('Forbidden'));
      }
      if (e.response?.statusCode == 404) {
        return Right([]); // No notifications is not an error
      }
      if (e.response?.statusCode != null && e.response!.statusCode! >= 500) {
        return Left(ServerFailure(e.response!.statusCode!));
      }
      return Left(NetworkFailure(e.message ?? 'Network error occurred'));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
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
        return Left(ServerFailure(response.statusCode ?? 500));
      }
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Failed to mark as read'));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> markAllAsRead() async {
    try {
      final response = await apiClient.post('/notifications/read-all');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Right(true);
      } else {
        return Left(ServerFailure(response.statusCode ?? 500));
      }
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Failed to mark all as read'));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteNotification(String notificationId) async {
    try {
      final response = await apiClient.delete('/notifications/$notificationId');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Right(true);
      } else {
        return Left(ServerFailure(response.statusCode ?? 500));
      }
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Failed to delete notification'));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      final response = await apiClient.get('/notifications/unread-count');

      if (response.statusCode == 200) {
        final data = response.data;
        int count = 0;
        
        if (data is Map) {
          count = data['count'] as int? ?? data['unread_count'] as int? ?? 0;
        } else if (data is int) {
          count = data;
        }
        
        return Right(count);
      } else {
        return Right(0); // Default to 0 on error
      }
    } on DioException catch (e) {
      return Right(0); // Default to 0 on error
    } catch (e) {
      return Right(0); // Default to 0 on error
    }
  }
}
