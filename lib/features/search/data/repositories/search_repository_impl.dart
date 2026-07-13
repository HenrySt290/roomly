import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../entities/search_filter_entity.dart';
import '../../data/models/property_model.dart';
import '../repositories/search_repository.dart';

/// Implementation of SearchRepository
class SearchRepositoryImpl implements SearchRepository {
  final ApiClient apiClient;

  SearchRepositoryImpl({required this.apiClient});

  @override
  Future<Either<Failure, List<PropertyModel>>> searchProperties({
    required SearchFilterEntity filters,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = filters.toQueryMap();
      queryParams['page'] = page.toString();
      queryParams['limit'] = limit.toString();

      final response = await apiClient.get(
        '/properties/search',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          final properties = data
              .map((json) => PropertyModel.fromJson(json))
              .toList();
          return Right(properties);
        } else if (data is Map && data['data'] is List) {
          final properties = (data['data'] as List)
              .map((json) => PropertyModel.fromJson(json))
              .toList();
          return Right(properties);
        }
        return Right([]);
      } else {
        return Left(ServerFailure(response.statusCode ?? 500));
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return Left(const TimeoutFailure());
      }
      if (e.response?.statusCode == 401) {
        return Left(const AuthFailure('Unauthorized'));
      }
      if (e.response?.statusCode == 403) {
        return Left(const AuthFailure('Forbidden'));
      }
      if (e.response?.statusCode == 404) {
        return Left(const NotFoundFailure('Properties not found'));
      }
      if (e.response?.statusCode != null && e.response!.statusCode! >= 500) {
        return Left(ServerFailure(e.response!.statusCode!));
      }
      return Left(NetworkFailure(e.message ?? 'Network error occurred'));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getCities() async {
    try {
      final response = await apiClient.get('/cities');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          final cities = data
              .whereType<Map<String, dynamic>>()
              .map((json) => json['name'] as String)
              .toList();
          return Right(cities);
        } else if (data is Map && data['data'] is List) {
          final cities = (data['data'] as List)
              .whereType<Map<String, dynamic>>()
              .map((json) => json['name'] as String)
              .toList();
          return Right(cities);
        }
        return Right([]);
      } else {
        return Left(ServerFailure(response.statusCode ?? 500));
      }
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Failed to fetch cities'));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAreas(String city) async {
    try {
      final response = await apiClient.get(
        '/areas',
        queryParameters: {'city': city},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          final areas = data
              .whereType<Map<String, dynamic>>()
              .map((json) => json['name'] as String)
              .toList();
          return Right(areas);
        } else if (data is Map && data['data'] is List) {
          final areas = (data['data'] as List)
              .whereType<Map<String, dynamic>>()
              .map((json) => json['name'] as String)
              .toList();
          return Right(areas);
        }
        return Right([]);
      } else {
        return Left(ServerFailure(response.statusCode ?? 500));
      }
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Failed to fetch areas'));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
