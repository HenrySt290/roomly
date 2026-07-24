import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:roomly/core/errors/failures.dart';
import 'package:roomly/core/network/api_client.dart';
import 'package:roomly/domain/entities/enquiry_entity.dart';
import 'package:roomly/domain/entities/chat_message_entity.dart';
import 'package:roomly/domain/repositories/enquiry_repository.dart';
import 'package:roomly/data/models/enquiry_model.dart';
import 'package:roomly/data/models/chat_message_model.dart';

class EnquiryRepositoryImpl implements EnquiryRepository {
  final ApiClient apiClient;

  const EnquiryRepositoryImpl({required this.apiClient});

  @override
  Future<Either<Failure, List<EnquiryEntity>>> getMyEnquiries({int page = 1, int limit = 20}) async {
    try {
      final response = await apiClient.get(
        '/enquiries',
        queryParameters: {'page': page, 'limit': limit},
      );
      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> list = data is List ? data : (data['data'] ?? data['enquiries'] ?? []);
        final enquiries = list.map((e) => EnquiryModel.fromJson(e as Map<String, dynamic>)).toList();
        return Right(enquiries);
      } else {
        return Left(ServerFailure(response.data?['message'] ?? 'Failed to fetch enquiries', response.statusCode));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data?['message'] ?? e.message ?? 'Network error', e.response?.statusCode));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<EnquiryEntity>>> getReceivedEnquiries({int page = 1, int limit = 20}) async {
    try {
      final response = await apiClient.get(
        '/enquiries/received',
        queryParameters: {'page': page, 'limit': limit},
      );
      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> list = data is List ? data : (data['data'] ?? data['enquiries'] ?? []);
        final enquiries = list.map((e) => EnquiryModel.fromJson(e as Map<String, dynamic>)).toList();
        return Right(enquiries);
      } else {
        return Left(ServerFailure(response.data?['message'] ?? 'Failed to fetch received enquiries', response.statusCode));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data?['message'] ?? e.message ?? 'Network error', e.response?.statusCode));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, EnquiryEntity>> getEnquiryById(int id) async {
    try {
      final response = await apiClient.get('/enquiries/$id');
      if (response.statusCode == 200) {
        final data = response.data;
        final json = data['data'] ?? data['enquiry'] ?? data;
        return Right(EnquiryModel.fromJson(json as Map<String, dynamic>));
      } else {
        return Left(ServerFailure('Enquiry not found', response.statusCode));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network error', e.response?.statusCode));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, EnquiryEntity>> sendEnquiry(
      {required int propertyId, required String message, EnquiryContactMethod contactMethod = EnquiryContactMethod.chat}) async {
    try {
      final response = await apiClient.post(
        '/enquiries',
        data: {
          'property_id': propertyId,
          'message': message,
          'contact_method': contactMethod.value,
        },
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;
        final json = data['data'] ?? data['enquiry'] ?? data;
        return Right(EnquiryModel.fromJson(json as Map<String, dynamic>));
      } else {
        return Left(ServerFailure(response.data?['message'] ?? 'Failed to send enquiry', response.statusCode));
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        return Left(ValidationFailure(e.response?.data?['message'] ?? 'Validation failed'));
      }
      return Left(ServerFailure(e.response?.data?['message'] ?? e.message ?? 'Network error', e.response?.statusCode));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, EnquiryEntity>> replyToEnquiry({required int enquiryId, required String message}) async {
    try {
      final response = await apiClient.post(
        '/enquiries/$enquiryId/reply',
        data: {'message': message},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final json = data['data'] ?? data['enquiry'] ?? data;
        // reply may return updated enquiry with last message
        if (json is Map<String, dynamic> && json.containsKey('property_id')) {
          return Right(EnquiryModel.fromJson(json));
        } else {
          // If backend returns message object, fetch enquiry again
          final enquiryResult = await getEnquiryById(enquiryId);
          return enquiryResult;
        }
      } else {
        return Left(ServerFailure('Failed to reply', response.statusCode));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data?['message'] ?? e.message ?? 'Network error', e.response?.statusCode));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> markAsRead(int enquiryId) async {
    try {
      final response = await apiClient.post('/enquiries/$enquiryId/read');
      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Right(true);
      } else {
        return Left(ServerFailure('Failed to mark as read', response.statusCode));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network error', e.response?.statusCode));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> closeEnquiry(int enquiryId) async {
    try {
      final response = await apiClient.post('/enquiries/$enquiryId/close');
      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Right(true);
      } else {
        return Left(ServerFailure('Failed to close enquiry', response.statusCode));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network error', e.response?.statusCode));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> acceptEnquiry(int enquiryId) async {
    try {
      final response = await apiClient.post('/enquiries/$enquiryId/accept');
      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Right(true);
      } else {
        return Left(ServerFailure('Failed to accept booking', response.statusCode));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network error', e.response?.statusCode));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteEnquiry(int enquiryId) async {
    try {
      final response = await apiClient.delete('/enquiries/$enquiryId');
      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Right(true);
      } else {
        return Left(ServerFailure('Failed to delete enquiry', response.statusCode));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network error', e.response?.statusCode));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ChatMessageEntity>>> getMessages(int enquiryId, {int page = 1, int limit = 50}) async {
    try {
      final response = await apiClient.get(
        '/enquiries/$enquiryId/messages',
        queryParameters: {'page': page, 'limit': limit},
      );
      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> list = data is List ? data : (data['data'] ?? data['messages'] ?? []);
        final messages = list.map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>)).toList();
        // Sort by timestamp ascending
        messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        return Right(messages);
      } else {
        return Left(ServerFailure('Failed to fetch messages', response.statusCode));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data?['message'] ?? e.message ?? 'Network error', e.response?.statusCode));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, ChatMessageEntity>> sendMessage(
      {required int enquiryId, required String message, MessageType type = MessageType.text, Map<String, dynamic>? metadata}) async {
    try {
      final response = await apiClient.post(
        '/enquiries/$enquiryId/messages',
        data: {
          'message': message,
          'type': type.value,
          if (metadata != null) 'metadata': metadata,
        },
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;
        final json = data['data'] ?? data['message'] ?? data;
        return Right(ChatMessageModel.fromJson(json as Map<String, dynamic>));
      } else {
        return Left(ServerFailure('Failed to send message', response.statusCode));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data?['message'] ?? e.message ?? 'Network error', e.response?.statusCode));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
