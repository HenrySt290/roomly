import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/export.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/export.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ApiClient apiClient;

  ProfileRepositoryImpl({required this.apiClient});

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final response = await apiClient.get('/api/user/profile');
      
      if (response.statusCode == 200) {
        final data = response.data['data'];
        return Right(UserModel.fromJson(data));
      } else {
        return Left(ServerFailure(response.statusCode ?? 500));
      }
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateCurrentUser({
    required String name,
    String? phone,
  }) async {
    try {
      final response = await apiClient.put('/api/user/profile', data: {
        'name': name,
        'phone': phone,
      });

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return Right(UserModel.fromJson(data));
      } else {
        return Left(ServerFailure(response.statusCode ?? 500));
      }
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await apiClient.post('/api/user/change-password', data: {
        'current_password': currentPassword,
        'new_password': newPassword,
      });

      if (response.statusCode == 200) {
        return const Right(true);
      } else {
        return Left(ServerFailure(response.statusCode ?? 500));
      }
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OwnerProfileEntity?>> getOwnerProfile(
      String userId) async {
    try {
      final response = await apiClient.get('/api/owner/profile/$userId');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data == null) {
          return const Right(null);
        }
        return Right(OwnerProfileModel.fromJson(data));
      } else {
        return Left(ServerFailure(response.statusCode ?? 500));
      }
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OwnerProfileEntity>> updateOwnerProfile({
    String? aadharNumber,
    String? panNumber,
  }) async {
    try {
      final response = await apiClient.put('/api/owner/profile', data: {
        'aadhar_number': aadharNumber,
        'pan_number': panNumber,
      });

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return Right(OwnerProfileModel.fromJson(data));
      } else {
        return Left(ServerFailure(response.statusCode ?? 500));
      }
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TenantProfileEntity?>> getTenantProfile(
      String userId) async {
    try {
      final response = await apiClient.get('/api/tenant/profile/$userId');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data == null) {
          return const Right(null);
        }
        return Right(TenantProfileModel.fromJson(data));
      } else {
        return Left(ServerFailure(response.statusCode ?? 500));
      }
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, KycDocumentEntity>> uploadKycDocument({
    required String documentType,
    required String documentUrl,
    String? frontImageUrl,
    String? backImageUrl,
    String? selfImageUrl,
  }) async {
    try {
      final response = await apiClient.post('/api/kyc/documents', data: {
        'document_type': documentType,
        'document_url': documentUrl,
        'front_image_url': frontImageUrl,
        'back_image_url': backImageUrl,
        'self_image_url': selfImageUrl,
      });

      if (response.statusCode == 201) {
        final data = response.data['data'];
        return Right(KycDocumentModel.fromJson(data));
      } else {
        return Left(ServerFailure(response.statusCode ?? 500));
      }
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<KycDocumentEntity>>> getKycDocuments(
      String userId) async {
    try {
      final response = await apiClient.get('/api/kyc/documents/$userId');

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        final documents = data.map((doc) => KycDocumentModel.fromJson(doc)).toList();
        return Right(documents);
      } else {
        return Left(ServerFailure(response.statusCode ?? 500));
      }
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteKycDocument(String documentId) async {
    try {
      final response = await apiClient.delete('/api/kyc/documents/$documentId');

      if (response.statusCode == 200) {
        return const Right(true);
      } else {
        return Left(ServerFailure(response.statusCode ?? 500));
      }
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getOwnerDashboardStats(
      String userId) async {
    try {
      final response = await apiClient.get('/api/owner/dashboard-stats/$userId');

      if (response.statusCode == 200) {
        return Right(response.data['data'] as Map<String, dynamic>);
      } else {
        return Left(ServerFailure(response.statusCode ?? 500));
      }
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getTenantDashboardStats(
      String userId) async {
    try {
      final response = await apiClient.get('/api/tenant/dashboard-stats/$userId');

      if (response.statusCode == 200) {
        return Right(response.data['data'] as Map<String, dynamic>);
      } else {
        return Left(ServerFailure(response.statusCode ?? 500));
      }
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }
}
