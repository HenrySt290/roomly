import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/config/api_config.dart';
import '../../../core/errors/failures.dart';
import 'package:either_dart/either.dart';
import '../../domain/entities/kyc_document_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../models/kyc_document_model.dart';
import '../models/user_model.dart';

/// Profile Repository Implementation
/// Handles all profile-related API operations
class ProfileRepositoryImpl {
  final Dio _client = ApiClient.instance;

  /// Get current user profile
  Future<Either<Failure, UserEntity>> getProfile() async {
    try {
      final response = await _client.get('/profile');
      
      if (response.statusCode == 200) {
        final data = response.data;
        final user = UserModel.fromJson(data['data'] ?? data);
        return Right(user);
      } else {
        return Left(ServerFailure(response.statusCode ?? 500, 'Failed to fetch profile'));
      }
    } on DioException catch (e) {
      return Left(ApiFailure.fromDioError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Update user profile
  Future<Either<Failure, UserEntity>> updateProfile({
    required String name,
    String? phone,
  }) async {
    try {
      final response = await _client.put(
        '/profile',
        data: {
          'name': name,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final user = UserModel.fromJson(data['data'] ?? data);
        return Right(user);
      } else {
        return Left(ServerFailure(response.statusCode ?? 500, 'Failed to update profile'));
      }
    } on DioException catch (e) {
      return Left(ApiFailure.fromDioError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Upload KYC document
  Future<Either<Failure, KycDocumentEntity>> uploadKYCDocument({
    required String documentType, // 'aadhaar', 'pan', 'passport', etc.
    required String documentPath, // File path to the document image
    String? frontImagePath,
    String? backImagePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'document_type': documentType,
        if (frontImagePath != null)
          'front_image': await MultipartFile.fromFile(
            frontImagePath,
            filename: 'front_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        if (backImagePath != null)
          'back_image': await MultipartFile.fromFile(
            backImagePath,
            filename: 'back_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
      });

      final response = await _client.post(
        '/kyc/upload',
        data: formData,
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final kycDoc = KycDocumentModel.fromJson(data['data'] ?? data);
        return Right(kycDoc);
      } else {
        return Left(ServerFailure(response.statusCode ?? 500, 'Failed to upload KYC document'));
      }
    } on DioException catch (e) {
      return Left(ApiFailure.fromDioError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Get KYC status
  Future<Either<Failure, KycDocumentEntity>> getKYCStatus() async {
    try {
      final response = await _client.get('/kyc/status');
      
      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data['data'] == null) {
          return Left(ServerFailure(404, 'No KYC document found'));
        }
        
        final kycDoc = KycDocumentModel.fromJson(data['data']);
        return Right(kycDoc);
      } else {
        return Left(ServerFailure(response.statusCode ?? 500, 'Failed to fetch KYC status'));
      }
    } on DioException catch (e) {
      return Left(ApiFailure.fromDioError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Delete user account
  Future<Either<Failure, bool>> deleteAccount({
    required String reason,
  }) async {
    try {
      final response = await _client.delete(
        '/profile',
        data: {'reason': reason},
      );
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Right(true);
      } else {
        return Left(ServerFailure(response.statusCode ?? 500, 'Failed to delete account'));
      }
    } on DioException catch (e) {
      return Left(ApiFailure.fromDioError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Change password
  Future<Either<Failure, bool>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _client.post(
        '/profile/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPassword,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return const Right(true);
      } else {
        return Left(ServerFailure(response.statusCode ?? 500, 'Failed to change password'));
      }
    } on DioException catch (e) {
      return Left(ApiFailure.fromDioError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Upload profile picture
  Future<Either<Failure, String>> uploadProfilePicture({
    required String imagePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          imagePath,
          filename: 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      final response = await _client.post(
        '/profile/avatar',
        data: formData,
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final avatarUrl = data['data']?['avatar_url'] ?? data['avatar_url'];
        return Right(avatarUrl);
      } else {
        return Left(ServerFailure(response.statusCode ?? 500, 'Failed to upload profile picture'));
      }
    } on DioException catch (e) {
      return Left(ApiFailure.fromDioError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
