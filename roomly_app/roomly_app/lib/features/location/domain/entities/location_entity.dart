import 'package:latlong2/latlong.dart';

/// Entity representing a location with coordinates and address
class LocationEntity {
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final double? distanceMeters; // Distance from user's current location

  const LocationEntity({
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.distanceMeters,
  });

  /// Create from LatLng
  factory LocationEntity.fromLatLng(LatLng latLng) {
    return LocationEntity(
      latitude: latLng.latitude,
      longitude: latLng.longitude,
    );
  }

  /// Convert to LatLng
  LatLng toLatLng() {
    return LatLng(latitude, longitude);
  }

  /// Calculate distance to another location
  double distanceTo(LocationEntity other) {
    return _calculateDistance(
      latitude,
      longitude,
      other.latitude,
      other.longitude,
    );
  }

  /// Haversine formula for distance calculation
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // meters
    
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    
    final a = 
      (dLat / 2).sin() * (dLat / 2).sin() +
      _toRadians(lat1).cos() * _toRadians(lat2).cos() *
      (dLon / 2).sin() * (dLon / 2).sin();
    
    final c = 2 * (a.sqrt().asin());
    
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (3.141592653589793 / 180.0);
  }

  /// Format distance to human readable string
  String get formattedDistance {
    if (distanceMeters == null) return '';
    if (distanceMeters! < 1000) {
      return '${distanceMeters!.toStringAsFixed(0)}m';
    } else {
      return '${(distanceMeters! / 1000).toStringAsFixed(1)}km';
    }
  }

  /// Check if location is valid (not in ocean or invalid area)
  bool get isValid {
    return latitude >= -90 &&
           latitude <= 90 &&
           longitude >= -180 &&
           longitude <= 180;
  }

  /// Copy with new values
  LocationEntity copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    double? distanceMeters,
  }) {
    return LocationEntity(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      distanceMeters: distanceMeters ?? this.distanceMeters,
    );
  }

  @override
  String toString() {
    return 'LocationEntity(lat: $latitude, lng: $longitude, address: $address)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationEntity &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}
