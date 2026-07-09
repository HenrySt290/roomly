import '../../domain/entities/access_pass_entity.dart';
import '../../domain/repositories/access_pass_repository.dart';
import '../models/access_pass_model.dart';
import '../../core/network/api_client.dart';
import '../../core/errors/failures.dart';
import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';

/// Implementation of AccessPassRepository
/// Handles all access pass-related data operations
class AccessPassRepositoryImpl implements AccessPassRepository {
  final ApiClient apiClient;

  const AccessPassRepositoryImpl({required this.apiClient});

  @override
  Future<Either<Failure, AccessPassEntity>> getCurrentPass() async {
    try {
      final response = await apiClient.get('/access-pass/current');

      if (response.statusCode == 200) {
        final pass = AccessPassModel.fromJson(response.data['pass']);
        return Right(pass);
      } else if (response.statusCode == 404) {
        // No active pass
        return Left(ServerFailure('No active access pass', 404));
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Failed to fetch access pass',
          response.statusCode ?? 500,
        ));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response?.statusCode == 404) {
          return Left(ServerFailure('No active access pass', 404));
        }
        return Left(ServerFailure(
          e.response?.data['message'] ?? 'Failed to fetch access pass',
          e.response?.statusCode ?? 500,
        ));
      }
      return Left(NetworkFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e', 500));
    }
  }

  @override
  Future<Either<Failure, AccessPassEntity>> purchasePass({
    required String paymentMethod,
    required Map<String, dynamic> paymentDetails,
  }) async {
    try {
      final response = await apiClient.post(
        '/access-pass/purchase',
        data: {
          'payment_method': paymentMethod,
          'payment_details': paymentDetails,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final pass = AccessPassModel.fromJson(response.data['pass']);
        return Right(pass);
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Failed to purchase access pass',
          response.statusCode ?? 500,
        ));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(ServerFailure(
          e.response?.data['message'] ?? 'Failed to purchase access pass',
          e.response?.statusCode ?? 500,
        ));
      }
      return Left(NetworkFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e', 500));
    }
  }

  @override
  Future<Either<Failure, bool>> hasActivePass() async {
    try {
      final response = await apiClient.get('/access-pass/status');

      if (response.statusCode == 200) {
        final bool hasActive = response.data['has_active_pass'] ?? false;
        return Right(hasActive);
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Failed to check pass status',
          response.statusCode ?? 500,
        ));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(ServerFailure(
          e.response?.data['message'] ?? 'Failed to check pass status',
          e.response?.statusCode ?? 500,
        ));
      }
      return Left(NetworkFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e', 500));
    }
  }

  @override
  Future<Either<Failure, List<AccessPassEntity>>> getPassHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await apiClient.get(
        '/access-pass/history',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> passesJson = response.data['data'] ?? [];
        final passes = passesJson
            .map((json) => AccessPassModel.fromJson(json))
            .toList();
        return Right(passes);
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Failed to fetch pass history',
          response.statusCode ?? 500,
        ));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(ServerFailure(
          e.response?.data['message'] ?? 'Failed to fetch pass history',
          e.response?.statusCode ?? 500,
        ));
      }
      return Left(NetworkFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e', 500));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyPassForProperty({
    required int userId,
    required int propertyId,
  }) async {
    try {
      final response = await apiClient.post(
        '/access-pass/verify',
        data: {
          'user_id': userId,
          'property_id': propertyId,
        },
      );

      if (response.statusCode == 200) {
        final bool isValid = response.data['is_valid'] ?? false;
        return Right(isValid);
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Pass verification failed',
          response.statusCode ?? 500,
        ));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(ServerFailure(
          e.response?.data['message'] ?? 'Pass verification failed',
          e.response?.statusCode ?? 500,
        ));
      }
      return Left(NetworkFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e', 500));
    }
  }

  @override
  Future<Either<Failure, Duration>> getRemainingTime() async {
    try {
      final response = await apiClient.get('/access-pass/remaining-time');

      if (response.statusCode == 200) {
        final int remainingSeconds = response.data['remaining_seconds'] ?? 0;
        return Right(Duration(seconds: remainingSeconds));
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Failed to get remaining time',
          response.statusCode ?? 500,
        ));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(ServerFailure(
          e.response?.data['message'] ?? 'Failed to get remaining time',
          e.response?.statusCode ?? 500,
        ));
      }
      return Left(NetworkFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e', 500));
    }
  }
}
