import '../../core/errors/failures.dart';
import '../entities/access_pass_entity.dart';
import 'package:dartz/dartz.dart';

/// Repository interface for access pass operations
abstract class AccessPassRepository {
  /// Get current user's access pass status
  Future<Either<Failure, AccessPassEntity>> getCurrentPass();

  /// Purchase new access pass (₹5 for 24 hours)
  Future<Either<Failure, AccessPassEntity>> purchasePass({
    required String paymentMethod,
    required Map<String, dynamic> paymentDetails,
  });

  /// Check if user has active pass
  Future<Either<Failure, bool>> hasActivePass();

  /// Get pass history for user
  Future<Either<Failure, List<AccessPassEntity>>> getPassHistory({
    int page = 1,
    int limit = 20,
  });

  /// Verify pass validity for property access
  Future<Either<Failure, bool>> verifyPassForProperty({
    required int userId,
    required int propertyId,
  });

  /// Get remaining time on current pass
  Future<Either<Failure, Duration>> getRemainingTime();
}
