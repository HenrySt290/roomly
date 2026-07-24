import 'package:roomly/core/errors/failures.dart';
import 'package:roomly/core/services/location_service.dart';
import 'package:roomly/core/services/map_service.dart';
import 'package:roomly/features/location/domain/entities/location_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:latlong2/latlong.dart';

/// Repository interface for location operations
abstract class LocationRepository {
  Future<Either<Failure, LocationEntity>> getCurrentLocation();
  Future<Either<Failure, String>> getAddressFromCoordinates(double lat, double lng);
  Future<Either<Failure, LocationEntity>> getLocationFromAddress(String address);
  Future<Either<Failure, bool>> requestPermission();
  Future<bool> hasPermission();
}

/// Implementation of LocationRepository
class LocationRepositoryImpl implements LocationRepository {
  final LocationService _locationService;
  final MapService _mapService;

  LocationRepositoryImpl({
    LocationService? locationService,
    MapService? mapService,
  })  : _locationService = locationService ?? LocationService(),
        _mapService = mapService ?? MapService();

  @override
  Future<bool> hasPermission() async {
    return await _locationService.hasPermission();
  }

  @override
  Future<Either<Failure, bool>> requestPermission() async {
    return await _locationService.requestPermission();
  }

  @override
  Future<Either<Failure, LocationEntity>> getCurrentLocation() async {
    final result = await _locationService.getCurrentLocation();
    
    return result.fold(
      (failure) => Left(failure),
      (latLng) async {
        // Try to get address for the coordinates
        final addressResult = await _mapService.reverseGeocode(latLng);
        
        LocationEntity entity = LocationEntity.fromLatLng(latLng);
        
        addressResult.fold(
          (_) {}, // Ignore address error, still return coordinates
          (address) {
            entity = entity.copyWith(address: address);
          },
        );
        
        return Right(entity);
      },
    );
  }

  @override
  Future<Either<Failure, String>> getAddressFromCoordinates(
    double lat,
    double lng,
  ) async {
    final latLng = LatLng(lat, lng);
    return await _mapService.reverseGeocode(latLng);
  }

  @override
  Future<Either<Failure, LocationEntity>> getLocationFromAddress(
    String address,
  ) async {
    final result = await _mapService.geocodeAddress(address);
    
    return result.fold(
      (failure) => Left(failure),
      (latLng) {
        return Right(LocationEntity.fromLatLng(latLng).copyWith(address: address));
      },
    );
  }
}
