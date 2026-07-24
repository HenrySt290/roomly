import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:roomly/core/errors/failures.dart';
import 'package:dartz/dartz.dart';

/// Service for geocoding and reverse geocoding
class MapService {
  static final MapService _instance = MapService._internal();
  factory MapService() => _instance;
  MapService._internal();

  /// Convert address string to coordinates
  Future<Either<Failure, LatLng>> geocodeAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        return Right(LatLng(location.latitude, location.longitude));
      } else {
        return Left(Failure('Address not found'));
      }
    } catch (e) {
      return Left(Failure('Geocoding error: ${e.toString()}'));
    }
  }

  /// Convert coordinates to address string
  Future<Either<Failure, String>> reverseGeocode(LatLng coordinates) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        coordinates.latitude,
        coordinates.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.postalCode,
          place.country,
        ].where((e) => e != null && e.isNotEmpty).join(', ');
        
        return Right(address.isEmpty ? 'Unknown location' : address);
      } else {
        return Left(Failure('No address found for these coordinates'));
      }
    } catch (e) {
      return Left(Failure('Reverse geocoding error: ${e.toString()}'));
    }
  }

  /// Get detailed address components
  Future<Either<Failure, Map<String, String>>> getAddressComponents(LatLng coordinates) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        coordinates.latitude,
        coordinates.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return Right({
          'street': place.street ?? '',
          'city': place.locality ?? '',
          'state': place.administrativeArea ?? '',
          'country': place.country ?? '',
          'postalCode': place.postalCode ?? '',
          'subLocality': place.subLocality ?? '',
        });
      } else {
        return Left(Failure('No address details found'));
      }
    } catch (e) {
      return Left(Failure('Error getting address components: ${e.toString()}'));
    }
  }

  /// Search for nearby places (simplified - uses geocoding)
  Future<Either<Failure, List<LatLng>>> searchNearby({
    required LatLng center,
    required String query,
    double radiusKm = 5.0,
  }) async {
    try {
      // This is a simplified implementation
      // For production, integrate with Google Places API or OpenStreetMap Nominatim
      final searchAddress = '$query, ${center.latitude},${center.longitude}';
      final locations = await locationFromAddress(searchAddress);
      
      final results = locations.map((loc) => LatLng(loc.latitude, loc.longitude)).toList();
      return Right(results);
    } catch (e) {
      return Left(Failure('Nearby search error: ${e.toString()}'));
    }
  }
}
