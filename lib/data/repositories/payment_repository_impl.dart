import '../../domain/repositories/payment_repository.dart';
import '../../core/network/api_client.dart';
import '../../core/errors/failures.dart';
import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';

/// Implementation of PaymentRepository
/// Handles all payment-related operations including Razorpay integration
class PaymentRepositoryImpl implements PaymentRepository {
  final ApiClient apiClient;

  const PaymentRepositoryImpl({required this.apiClient});

  @override
  Future<Either<Failure, Map<String, dynamic>>> createListingOrder({
    required int propertyId,
  }) async {
    try {
      final response = await apiClient.post(
        '/payments/create-listing-order',
        data: {'property_id': propertyId},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Right(response.data['order']);
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Failed to create listing order',
          response.statusCode ?? 500,
        ));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(ServerFailure(
          e.response?.data['message'] ?? 'Failed to create listing order',
          e.response?.statusCode ?? 500,
        ));
      }
      return Left(NetworkFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e', 500));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> createAccessPassOrder() async {
    try {
      final response = await apiClient.post('/payments/create-access-pass-order');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Right(response.data['order']);
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Failed to create access pass order',
          response.statusCode ?? 500,
        ));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(ServerFailure(
          e.response?.data['message'] ?? 'Failed to create access pass order',
          e.response?.statusCode ?? 500,
        ));
      }
      return Left(NetworkFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e', 500));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    try {
      final response = await apiClient.post(
        '/payments/verify',
        data: {
          'order_id': orderId,
          'payment_id': paymentId,
          'signature': signature,
        },
      );

      if (response.statusCode == 200) {
        final bool isVerified = response.data['verified'] ?? false;
        return Right(isVerified);
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Payment verification failed',
          response.statusCode ?? 500,
        ));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(ServerFailure(
          e.response?.data['message'] ?? 'Payment verification failed',
          e.response?.statusCode ?? 500,
        ));
      }
      return Left(NetworkFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e', 500));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getTransaction(
      String transactionId) async {
    try {
      final response = await apiClient.get('/payments/transaction/$transactionId');

      if (response.statusCode == 200) {
        return Right(response.data['transaction']);
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Transaction not found',
          response.statusCode ?? 404,
        ));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(ServerFailure(
          e.response?.data['message'] ?? 'Transaction not found',
          e.response?.statusCode ?? 500,
        ));
      }
      return Left(NetworkFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e', 500));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getTransactionHistory({
    TransactionStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (status != null) {
        queryParams['status'] = _transactionStatusToString(status);
      }

      final response = await apiClient.get(
        '/payments/transactions',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> transactionsJson = response.data['data'] ?? [];
        final transactions = transactionsJson
            .map((json) => json as Map<String, dynamic>)
            .toList();
        return Right(transactions);
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Failed to fetch transactions',
          response.statusCode ?? 500,
        ));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(ServerFailure(
          e.response?.data['message'] ?? 'Failed to fetch transactions',
          e.response?.statusCode ?? 500,
        ));
      }
      return Left(NetworkFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e', 500));
    }
  }

  @override
  Future<Either<Failure, bool>> processRefund({
    required String transactionId,
    required String reason,
  }) async {
    try {
      final response = await apiClient.post(
        '/payments/refund',
        data: {
          'transaction_id': transactionId,
          'reason': reason,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final bool success = response.data['success'] ?? false;
        return Right(success);
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Refund processing failed',
          response.statusCode ?? 500,
        ));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(ServerFailure(
          e.response?.data['message'] ?? 'Refund processing failed',
          e.response?.statusCode ?? 500,
        ));
      }
      return Left(NetworkFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e', 500));
    }
  }

  @override
  Future<Either<Failure, TransactionStatus>> getPaymentStatus(
      String orderId) async {
    try {
      final response = await apiClient.get('/payments/status/$orderId');

      if (response.statusCode == 200) {
        final String statusString = response.data['status'] ?? 'pending';
        final status = _stringToTransactionStatus(statusString);
        return Right(status);
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Failed to get payment status',
          response.statusCode ?? 500,
        ));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(ServerFailure(
          e.response?.data['message'] ?? 'Failed to get payment status',
          e.response?.statusCode ?? 500,
        ));
      }
      return Left(NetworkFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e', 500));
    }
  }

  /// Helper method to convert TransactionStatus enum to string
  String _transactionStatusToString(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return 'pending';
      case TransactionStatus.processing:
        return 'processing';
      case TransactionStatus.success:
        return 'success';
      case TransactionStatus.failed:
        return 'failed';
      case TransactionStatus.refunded:
        return 'refunded';
    }
  }

  /// Helper method to convert string to TransactionStatus enum
  TransactionStatus _stringToTransactionStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return TransactionStatus.pending;
      case 'processing':
        return TransactionStatus.processing;
      case 'success':
        return TransactionStatus.success;
      case 'failed':
        return TransactionStatus.failed;
      case 'refunded':
        return TransactionStatus.refunded;
      default:
        return TransactionStatus.pending;
    }
  }
}
