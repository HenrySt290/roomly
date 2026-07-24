import 'package:roomly/core/errors/failures.dart';
import 'package:roomly/domain/entities/property_entity.dart';
import 'package:dartz/dartz.dart';

/// Repository interface for property operations
abstract class PropertyRepository {
  /// Get all properties with filters
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
  });

  /// Get property by ID (returns teaser or full based on access pass)
  Future<Either<Failure, PropertyEntity>> getPropertyById(int id);

  /// Create new property
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
  });

  /// Update existing property
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
  });

  /// Delete property
  Future<Either<Failure, bool>> deleteProperty(int id);

  /// Publish property (after payment)
  Future<Either<Failure, PropertyEntity>> publishProperty(int id);

  /// Mark property as occupied
  Future<Either<Failure, PropertyEntity>> markOccupied(int id);

  /// Relist property (tenant left)
  Future<Either<Failure, PropertyEntity>> relistProperty(int id);

  /// Add property to favourites
  Future<Either<Failure, bool>> addToFavourites(int propertyId);

  /// Remove from favourites
  Future<Either<Failure, bool>> removeFromFavourites(int propertyId);

  /// Get user's favourite properties
  Future<Either<Failure, List<PropertyEntity>>> getFavourites();

  /// Record property view
  Future<Either<Failure, bool>> recordView(int propertyId);

  /// Report property
  Future<Either<Failure, bool>> reportProperty({
    required int propertyId,
    required String reason,
    required String description,
  });

  /// Get owner's properties
  Future<Either<Failure, List<PropertyEntity>>> getOwnerProperties({
    int? ownerId,
    PropertyStatus? status,
    int page = 1,
    int limit = 20,
  });
}
