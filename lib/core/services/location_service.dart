import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:roomly/core/errors/failures.dart';
import 'package:dartz/dartz.dart';

/// Service for handling device location and permissions
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Check if location permission is granted
  Future<bool> hasPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  /// Request location permission
  Future<Either<Failure, bool>> requestPermission() async {
    try {
      final status = await Permission.location.request();
      if (status.isGranted) {
        return const Right(true);
      } else if (status.isDenied) {
        return Left(Failure('Location permission denied'));
      } else if (status.isPermanentlyDenied) {
        return Left(Failure('Location permission permanently denied. Please enable in settings.'));
      }
      return Left(Failure('Location permission not granted'));
    } catch (e) {
      return Left(Failure('Error requesting permission: ${e.toString()}'));
    }
  }

  /// Get current device location
  Future<Either<Failure, LatLng>> getCurrentLocation() async {
    try {
      // Check permission first
      final hasPerm = await hasPermission();
      if (!hasPerm) {
        final permResult = await requestPermission();
        if (permResult.isLeft()) {
          return Left(Failure('Location permission required'));
        }
      }

      // Get position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return Right(LatLng(position.latitude, position.longitude));
    } on PositionSourceDisabledException {
      return Left(Failure('GPS is disabled. Please enable location services.'));
    } on TimeoutException {
      return Left(Failure('Location request timed out'));
    } catch (e) {
      return Left(Failure('Error getting location: ${e.toString()}'));
    }
  }

  /// Stream location updates
  Stream<Either<Failure, LatLng>> streamLocation() async* {
    try {
      final hasPerm = await hasPermission();
      if (!hasPerm) {
        yield Left(Failure('Location permission required'));
        return;
      }

      await for (final position in Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Only update if moved 10 meters
        ),
      )) {
        yield Right(LatLng(position.latitude, position.longitude));
      }
    } catch (e) {
      yield Left(Failure('Location stream error: ${e.toString()}'));
    }
  }

  /// Calculate distance between two points (Haversine formula)
  double calculateDistance(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  /// Format distance to human readable string
  String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)}m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)}km';
    }
  }

  /// Open system location settings
  Future<void> openLocationSettings() async {
    await openAppSettings();
  }
}
