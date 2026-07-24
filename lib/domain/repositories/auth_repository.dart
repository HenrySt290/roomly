import 'package:roomly/core/errors/failures.dart';
import 'package:roomly/domain/entities/user_entity.dart';
import 'package:dartz/dartz.dart';

/// Repository interface for authentication operations
abstract class AuthRepository {
  /// Register a new user
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  });

  /// Login user with email and password
  Future<Either<Failure, Map<String, dynamic>>> login({
    required String email,
    required String password,
  });

  /// Logout current user
  Future<Either<Failure, bool>> logout();

  /// Send password reset email
  Future<Either<Failure, bool>> forgotPassword({required String email});

  /// Reset password with token
  Future<Either<Failure, bool>> resetPassword({
    required String token,
    required String password,
    required String confirmPassword,
  });

  /// Get current authenticated user
  Future<Either<Failure, UserEntity>> getCurrentUser();

  /// Verify user email
  Future<Either<Failure, bool>> verifyEmail({required String token});

  /// Resend verification email
  Future<Either<Failure, bool>> resendVerificationEmail();

  /// Refresh authentication token
  Future<Either<Failure, bool>> refreshToken();
}
