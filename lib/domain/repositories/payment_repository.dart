import '../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

/// Payment method types
enum PaymentMethod {
  razorpay,
  upi,
  card,
  netbanking,
  wallet,
}

/// Transaction status
enum TransactionStatus {
  pending,
  processing,
  success,
  failed,
  refunded,
}

/// Repository interface for payment operations
abstract class PaymentRepository {
  /// Create Razorpay order for listing fee (₹9)
  Future<Either<Failure, Map<String, dynamic>>> createListingOrder({
    required int propertyId,
  });

  /// Create Razorpay order for access pass (₹5)
  Future<Either<Failure, Map<String, dynamic>>> createAccessPassOrder();

  /// Verify payment signature
  Future<Either<Failure, bool>> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  });

  /// Get transaction by ID
  Future<Either<Failure, Map<String, dynamic>>> getTransaction(String transactionId);

  /// Get user's transaction history
  Future<Either<Failure, List<Map<String, dynamic>>>> getTransactionHistory({
    TransactionStatus? status,
    int page = 1,
    int limit = 20,
  });

  /// Process refund
  Future<Either<Failure, bool>> processRefund({
    required String transactionId,
    required String reason,
  });

  /// Get payment status
  Future<Either<Failure, TransactionStatus>> getPaymentStatus(String orderId);
}
