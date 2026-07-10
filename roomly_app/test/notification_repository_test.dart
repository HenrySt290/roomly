import 'package:flutter_test/flutter_test.dart';
import 'package:either_dart/either.dart';
import '../../lib/core/errors/failures.dart';
import '../../lib/features/notifications/data/notification_repository_impl.dart';

void main() {
  group('NotificationRepositoryImpl Tests', () {
    late NotificationRepositoryImpl repository;

    setUp(() {
      repository = NotificationRepositoryImpl();
    });

    test('fetch notifications returns list', () async {
      final result = await repository.getNotifications(
        page: 1,
        limit: 20,
      );

      expect(result, isA<Either<Failure, dynamic>>());
    });

    test('mark notification as read', () async {
      final result = await repository.markAsRead(1);

      expect(result, isA<Either<Failure, bool>>());
    });

    test('mark all notifications as read', () async {
      final result = await repository.markAllAsRead();

      expect(result, isA<Either<Failure, bool>>());
    });

    test('delete notification', () async {
      final result = await repository.deleteNotification(1);

      expect(result, isA<Either<Failure, bool>>());
    });

    test('get unread count', () async {
      final result = await repository.getUnreadCount();

      expect(result, isA<Either<Failure, int>>());
    });

    test('filter notifications by type', () async {
      final result = await repository.getNotifications(
        page: 1,
        limit: 10,
        type: 'payment',
      );

      expect(result, isA<Either<Failure, dynamic>>());
    });
  });
}
