import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../entities/export.dart';

abstract class ProfileRepository {
  // User Profile
  Future<Either<Failure, UserEntity>> getCurrentUser();
  Future<Either<Failure, UserEntity>> updateCurrentUser({
    required String name,
    String? phone,
  });
  Future<Either<Failure, bool>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  // Owner Profile
  Future<Either<Failure, OwnerProfileEntity?>> getOwnerProfile(String userId);
  Future<Either<Failure, OwnerProfileEntity>> updateOwnerProfile({
    String? aadharNumber,
    String? panNumber,
  });

  // Tenant Profile
  Future<Either<Failure, TenantProfileEntity?>> getTenantProfile(String userId);

  // KYC Documents
  Future<Either<Failure, KycDocumentEntity>> uploadKycDocument({
    required String documentType,
    required String documentUrl,
    String? frontImageUrl,
    String? backImageUrl,
    String? selfImageUrl,
  });
  Future<Either<Failure, List<KycDocumentEntity>>> getKycDocuments(
      String userId);
  Future<Either<Failure, bool>> deleteKycDocument(String documentId);

  // Dashboard Stats
  Future<Either<Failure, Map<String, dynamic>>> getOwnerDashboardStats(
      String userId);
  Future<Either<Failure, Map<String, dynamic>>> getTenantDashboardStats(
      String userId);
}
