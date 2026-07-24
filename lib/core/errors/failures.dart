import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';

/// Base failure class - made concrete to support legacy `Failure('msg')` usages
class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure(this.message, [this.statusCode]);

  @override
  List<Object?> get props => [message, statusCode];
}

class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server Failure', int? statusCode])
      : super(message, statusCode);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Network Failure', int? statusCode])
      : super(message, statusCode ?? 0);
}

class AuthFailure extends Failure {
  const AuthFailure([String message = 'Authentication Failure', int? statusCode])
      : super(message, statusCode);
}

class ValidationFailure extends Failure {
  const ValidationFailure([String message = 'Validation Failure'])
      : super(message, 422);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache Failure', int? statusCode])
      : super(message, statusCode ?? 0);
}

class PaymentFailure extends Failure {
  const PaymentFailure([String message = 'Payment Failure', int? statusCode])
      : super(message, statusCode);
}

class PermissionFailure extends Failure {
  const PermissionFailure([String message = 'Permission Denied'])
      : super(message, 403);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([String message = 'Not Found'])
      : super(message, 404);
}

class UnknownFailure extends Failure {
  const UnknownFailure([String message = 'Unknown Failure'])
      : super(message, 500);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([String message = 'Connection Timeout', int? statusCode])
      : super(message, statusCode ?? 408);
}

class ApiFailure extends Failure {
  const ApiFailure([String message = 'API Failure', int? statusCode])
      : super(message, statusCode);

  factory ApiFailure.fromDioError(DioException e) {
    final dynamic data = e.response?.data;
    String message = 'API error';
    if (data is Map && data['message'] is String) {
      message = data['message'] as String;
    } else if (e.message != null && e.message!.isNotEmpty) {
      message = e.message!;
    }
    return ApiFailure(message, e.response?.statusCode);
  }
}
