import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:roomly/domain/entities/user_entity.dart';
import 'package:roomly/domain/repositories/auth_repository.dart';
import 'package:roomly/data/models/user_model.dart';
import 'package:roomly/core/network/api_client.dart';
import 'package:roomly/core/errors/failures.dart';

/// Implementation of AuthRepository
/// Handles all authentication-related data operations
class AuthRepositoryImpl implements AuthRepository {
  final ApiClient apiClient;

  const AuthRepositoryImpl({required this.apiClient});

  @override
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    try {
      final response = await apiClient.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'role': role.value,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final user = UserModel.fromJson(response.data['user']);
        return Right(user);
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Registration failed',
          response.statusCode ?? 500,
        ));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(ServerFailure(
          e.response?.data['message'] ?? 'Registration failed',
          e.response?.statusCode ?? 500,
        ));
      }
      return Left(NetworkFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e', 500));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiClient.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        // Store tokens in secure storage (handled by ApiClient interceptor)
        await apiClient.setAuthTokens(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
        );
        return Right(data);
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Login failed',
          response.statusCode ?? 500,
        ));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(ServerFailure(
          e.response?.data['message'] ?? 'Login failed',
          e.response?.statusCode ?? 500,
        ));
      }
      return Left(NetworkFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e', 500));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final response = await apiClient.post('/auth/logout');

      if (response.statusCode == 200) {
        await apiClient.clearAuthTokens();
        return const Right(true);
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Logout failed',
          response.statusCode ?? 500,
        ));
      }
    } on DioException catch (e) {
      // Clear tokens even if request fails
      await apiClient.clearAuthTokens();
      if (e.response != null) {
        return Left(ServerFailure(
          e.response?.data['message'] ?? 'Logout failed',
          e.response?.statusCode ?? 500,
        ));
      }
      return Left(NetworkFailure('Network error: ${e.message}'));
    } catch (e) {
      await apiClient.clearAuthTokens();
      return Left(ServerFailure('Unexpected error: $e', 500));
    }
  }

  @override
  Future<Either<Failure, bool>> forgotPassword({required String email}) async {
    try {
      final response = await apiClient.post(
        '/auth/forgot-password',
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        return const Right(true);
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Failed to send reset email',
          response.statusCode ?? 500,
        ));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(ServerFailure(
          e.response?.data['message'] ?? 'Failed to send reset email',
          e.response?.statusCode ?? 500,
        ));
      }
      return Left(NetworkFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e', 500));
    }
  }

  @override
  Future<Either<Failure, bool>> resetPassword({
    required String token,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await apiClient.post(
        '/auth/reset-password',
        data: {
          'token': token,
          'password': password,
          'password_confirmation': confirmPassword,
        },
      );

      if (response.statusCode == 200) {
        return const Right(true);
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Failed to reset password',
          response.statusCode ?? 500,
        ));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(ServerFailure(
          e.response?.data['message'] ?? 'Failed to reset password',
          e.response?.statusCode ?? 500,
        ));
      }
      return Left(NetworkFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e', 500));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final response = await apiClient.get('/auth/me');

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(response.data['user']);
        return Right(user);
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Failed to get user',
          response.statusCode ?? 500,
        ));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(ServerFailure(
          e.response?.data['message'] ?? 'Failed to get user',
          e.response?.statusCode ?? 500,
        ));
      }
      return Left(NetworkFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e', 500));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyEmail({required String token}) async {
    try {
      final response = await apiClient.post(
        '/auth/verify-email',
        data: {'token': token},
      );

      if (response.statusCode == 200) {
        return const Right(true);
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Email verification failed',
          response.statusCode ?? 500,
        ));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(ServerFailure(
          e.response?.data['message'] ?? 'Email verification failed',
          e.response?.statusCode ?? 500,
        ));
      }
      return Left(NetworkFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e', 500));
    }
  }

  @override
  Future<Either<Failure, bool>> resendVerificationEmail() async {
    try {
      final response = await apiClient.post('/auth/resend-verification');

      if (response.statusCode == 200) {
        return const Right(true);
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Failed to resend verification email',
          response.statusCode ?? 500,
        ));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(ServerFailure(
          e.response?.data['message'] ?? 'Failed to resend verification email',
          e.response?.statusCode ?? 500,
        ));
      }
      return Left(NetworkFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e', 500));
    }
  }

  @override
  Future<Either<Failure, bool>> refreshToken() async {
    try {
      final response = await apiClient.post('/auth/refresh');

      if (response.statusCode == 200) {
        final data = response.data;
        await apiClient.setAuthTokens(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
        );
        return const Right(true);
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Token refresh failed',
          response.statusCode ?? 500,
        ));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(ServerFailure(
          e.response?.data['message'] ?? 'Token refresh failed',
          e.response?.statusCode ?? 500,
        ));
      }
      return Left(NetworkFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e', 500));
    }
  }
}
