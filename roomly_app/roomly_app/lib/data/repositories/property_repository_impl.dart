import '../../domain/entities/property_entity.dart';
import '../../domain/repositories/property_repository.dart';
import '../models/property_model.dart';
import '../../core/network/api_client.dart';
import '../../core/errors/failures.dart';
import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';

/// Implementation of PropertyRepository
/// Handles all property-related data operations with access control logic
class PropertyRepositoryImpl implements PropertyRepository {
  final ApiClient apiClient;

  const PropertyRepositoryImpl({required this.apiClient});

  @override
  Future<Either<Failure, List<PropertyEntity>>> getProperties({
    String? city,
    String? area,
    double? minRent,
    double? maxRent,
    PropertyType? propertyType,
    RoomType? roomType,
    bool? furnished,
    bool? parking,
    bool? wifi,
    bool? petFriendly,
    String? sortBy,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (city != null) queryParams['city'] = city;
      if (area != null) queryParams['area'] = area;
      if (minRent != null) queryParams['min_rent'] = minRent;
      if (maxRent != null) queryParams['max_rent'] = maxRent;
      if (propertyType != null) queryParams['property_type'] = propertyType.value;
      if (roomType != null) queryParams['room_type'] = roomType.value;
      if (furnished != null) queryParams['furnished'] = furnished;
      if (parking != null) queryParams['parking'] = parking;
      if (wifi != null) queryParams['wifi'] = wifi;
      if (petFriendly != null) queryParams['pet_friendly'] = petFriendly;
      if (sortBy != null) queryParams['sort_by'] = sortBy;

      final response = await apiClient.get(
        '/properties',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> propertiesJson = response.data['data'] ?? [];
        final properties = propertiesJson
            .map((json) => PropertyModel.fromJson(json))
            .toList();
        return Right(properties);
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Failed to fetch properties',
          response.statusCode ?? 500,
        ));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(ServerFailure(
          e.response?.data['message'] ?? 'Failed to fetch properties',
          e.response?.statusCode ?? 500,
        ));
      }
      return Left(NetworkFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e', 500));
    }
  }

  @override
  Future<Either<Failure, PropertyEntity>> getPropertyById(int id) async {
    try {
      final response = await apiClient.get('/properties/$id');

      if (response.statusCode == 200) {
        final property = PropertyModel.fromJson(response.data['property']);
        return Right(property);
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Property not found',
          response.statusCode ?? 404,
        ));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(ServerFailure(
          e.response?.data['message'] ?? 'Property not found',
          e.response?.statusCode ?? 500,
        ));
      }
      return Left(NetworkFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e', 500));
    }
  }

  @override
  Future<Either<Failure, PropertyEntity>> createProperty({
    required String title,
    required String description,
    required double rent,
    required double deposit,
    required PropertyType propertyType,
    required RoomType roomType,
    required String area,
    required String city,
    required String address,
    required double latitude,
    required double longitude,
    required List<String> amenities,
    required List<String> rules,
    required DateTime availableFrom,
    required List<String> imageUrls,
  }) async {
    try {
      final response = await apiClient.post(
        '/properties',
        data: {
          'title': title,
          'description': description,
          'rent': rent,
          'deposit': deposit,
          'property_type': propertyType.value,
          'room_type': roomType.value,
          'area': area,
          'city': city,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
          'amenities': amenities,
          'rules': rules,
          'available_from': availableFrom.toIso8601String(),
          'images': imageUrls,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final property = PropertyModel.fromJson(response.data['property']);
        return Right(property);
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Failed to create property',
          response.statusCode ?? 500,
        ));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(ServerFailure(
          e.response?.data['message'] ?? 'Failed to create property',
          e.response?.statusCode ?? 500,
        ));
      }
      return Left(NetworkFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e', 500));
    }
  }

  @override
  Future<Either<Failure, PropertyEntity>> updateProperty({
    required int id,
    String? title,
    String? description,
    double? rent,
    double? deposit,
    PropertyType? propertyType,
    RoomType? roomType,
    String? area,
    String? city,
    String? address,
    double? latitude,
    double? longitude,
    List<String>? amenities,
    List<String>? rules,
    DateTime? availableFrom,
    List<String>? imageUrls,
  }) async {
    try {
      final data = <String, dynamic>{};
      
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (rent != null) data['rent'] = rent;
      if (deposit != null) data['deposit'] = deposit;
      if (propertyType != null) data['property_type'] = propertyType.value;
      if (roomType != null) data['room_type'] = roomType.value;
      if (area != null) data['area'] = area;
      if (city != null) data['city'] = city;
      if (address != null) data['address'] = address;
      if (latitude != null) data['latitude'] = latitude;
      if (longitude != null) data['longitude'] = longitude;
      if (amenities != null) data['amenities'] = amenities;
      if (rules != null) data['rules'] = rules;
      if (availableFrom != null) data['available_from'] = availableFrom.toIso8601String();
      if (imageUrls != null) data['images'] = imageUrls;

      final response = await apiClient.put(
        '/properties/$id',
        data: data,
      );

      if (response.statusCode == 200) {
        final property = PropertyModel.fromJson(response.data['property']);
        return Right(property);
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Failed to update property',
          response.statusCode ?? 500,
        ));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(ServerFailure(
          e.response?.data['message'] ?? 'Failed to update property',
          e.response?.statusCode ?? 500,
        ));
      }
      return Left(NetworkFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e', 500));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteProperty(int id) async {
    try {
      final response = await apiClient.delete('/properties/$id');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Right(true);
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Failed to delete property',
          response.statusCode ?? 500,
        ));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(ServerFailure(
          e.response?.data['message'] ?? 'Failed to delete property',
          e.response?.statusCode ?? 500,
        ));
      }
      return Left(NetworkFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e', 500));
    }
  }

  @override
  Future<Either<Failure, PropertyEntity>> publishProperty(int id) async {
    try {
      final response = await apiClient.post('/properties/$id/publish');

      if (response.statusCode == 200) {
        final property = PropertyModel.fromJson(response.data['property']);
        return Right(property);
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Failed to publish property',
          response.statusCode ?? 500,
        ));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(ServerFailure(
          e.response?.data['message'] ?? 'Failed to publish property',
          e.response?.statusCode ?? 500,
        ));
      }
      return Left(NetworkFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e', 500));
    }
  }

  @override
  Future<Either<Failure, PropertyEntity>> markOccupied(int id) async {
    try {
      final response = await apiClient.post('/properties/$id/occupy');

      if (response.statusCode == 200) {
        final property = PropertyModel.fromJson(response.data['property']);
        return Right(property);
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Failed to mark property as occupied',
          response.statusCode ?? 500,
        ));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(ServerFailure(
          e.response?.data['message'] ?? 'Failed to mark property as occupied',
          e.response?.statusCode ?? 500,
        ));
      }
      return Left(NetworkFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e', 500));
    }
  }

  @override
  Future<Either<Failure, PropertyEntity>> relistProperty(int id) async {
    try {
      final response = await apiClient.post('/properties/$id/relist');

      if (response.statusCode == 200) {
        final property = PropertyModel.fromJson(response.data['property']);
        return Right(property);
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Failed to relist property',
          response.statusCode ?? 500,
        ));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(ServerFailure(
          e.response?.data['message'] ?? 'Failed to relist property',
          e.response?.statusCode ?? 500,
        ));
      }
      return Left(NetworkFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e', 500));
    }
  }

  @override
  Future<Either<Failure, bool>> addToFavourites(int propertyId) async {
    try {
      final response = await apiClient.post('/properties/$propertyId/favourite');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return const Right(true);
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Failed to add to favourites',
          response.statusCode ?? 500,
        ));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(ServerFailure(
          e.response?.data['message'] ?? 'Failed to add to favourites',
          e.response?.statusCode ?? 500,
        ));
      }
      return Left(NetworkFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e', 500));
    }
  }

  @override
  Future<Either<Failure, bool>> removeFromFavourites(int propertyId) async {
    try {
      final response = await apiClient.delete('/properties/$propertyId/favourite');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Right(true);
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Failed to remove from favourites',
          response.statusCode ?? 500,
        ));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(ServerFailure(
          e.response?.data['message'] ?? 'Failed to remove from favourites',
          e.response?.statusCode ?? 500,
        ));
      }
      return Left(NetworkFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e', 500));
    }
  }

  @override
  Future<Either<Failure, List<PropertyEntity>>> getFavourites() async {
    try {
      final response = await apiClient.get('/properties/favourites');

      if (response.statusCode == 200) {
        final List<dynamic> propertiesJson = response.data['data'] ?? [];
        final properties = propertiesJson
            .map((json) => PropertyModel.fromJson(json))
            .toList();
        return Right(properties);
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Failed to fetch favourites',
          response.statusCode ?? 500,
        ));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(ServerFailure(
          e.response?.data['message'] ?? 'Failed to fetch favourites',
          e.response?.statusCode ?? 500,
        ));
      }
      return Left(NetworkFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e', 500));
    }
  }

  @override
  Future<Either<Failure, bool>> recordView(int propertyId) async {
    try {
      final response = await apiClient.post('/properties/$propertyId/view');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return const Right(true);
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Failed to record view',
          response.statusCode ?? 500,
        ));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(ServerFailure(
          e.response?.data['message'] ?? 'Failed to record view',
          e.response?.statusCode ?? 500,
        ));
      }
      return Left(NetworkFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e', 500));
    }
  }

  @override
  Future<Either<Failure, bool>> reportProperty({
    required int propertyId,
    required String reason,
    required String description,
  }) async {
    try {
      final response = await apiClient.post(
        '/properties/$propertyId/report',
        data: {
          'reason': reason,
          'description': description,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return const Right(true);
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Failed to report property',
          response.statusCode ?? 500,
        ));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(ServerFailure(
          e.response?.data['message'] ?? 'Failed to report property',
          e.response?.statusCode ?? 500,
        ));
      }
      return Left(NetworkFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e', 500));
    }
  }

  @override
  Future<Either<Failure, List<PropertyEntity>>> getOwnerProperties({
    int? ownerId,
    PropertyStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (ownerId != null) queryParams['owner_id'] = ownerId;
      if (status != null) queryParams['status'] = status.value;

      final response = await apiClient.get(
        '/properties/my-properties',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> propertiesJson = response.data['data'] ?? [];
        final properties = propertiesJson
            .map((json) => PropertyModel.fromJson(json))
            .toList();
        return Right(properties);
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Failed to fetch owner properties',
          response.statusCode ?? 500,
        ));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(ServerFailure(
          e.response?.data['message'] ?? 'Failed to fetch owner properties',
          e.response?.statusCode ?? 500,
        ));
      }
      return Left(NetworkFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e', 500));
    }
  }
}
