import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/location_entity.dart';
import '../../data/repositories/location_repository_impl.dart';

/// State class for location operations
class LocationState {
  final bool isLoading;
  final LocationEntity? currentLocation;
  final LatLng? selectedLocation;
  final String? address;
  final Failure? error;
  final bool hasPermission;
  final bool isRequestingPermission;

  const LocationState({
    this.isLoading = false,
    this.currentLocation,
    this.selectedLocation,
    this.address,
    this.error,
    this.hasPermission = false,
    this.isRequestingPermission = false,
  });

  LocationState copyWith({
    bool? isLoading,
    LocationEntity? currentLocation,
    LatLng? selectedLocation,
    String? address,
    Failure? error,
    bool? hasPermission,
    bool? isRequestingPermission,
  }) {
    return LocationState(
      isLoading: isLoading ?? this.isLoading,
      currentLocation: currentLocation ?? this.currentLocation,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      address: address ?? this.address,
      error: error, // Always reset error on update
      hasPermission: hasPermission ?? this.hasPermission,
      isRequestingPermission: isRequestingPermission ?? this.isRequestingPermission,
    );
  }
}

/// Notifier for managing location state
class LocationNotifier extends ChangeNotifier {
  final LocationRepositoryImpl _repository;
  LocationState _state = const LocationState();

  LocationNotifier({LocationRepositoryImpl? repository})
      : _repository = repository ?? LocationRepositoryImpl();

  LocationState get state => _state;

  /// Check if user has granted permission
  Future<void> checkPermission() async {
    _state = _state.copyWith(hasPermission: await _repository.hasPermission());
    notifyListeners();
  }

  /// Request location permission
  Future<void> requestPermission() async {
    _state = _state.copyWith(isRequestingPermission: true);
    notifyListeners();

    final result = await _repository.requestPermission();
    
    result.fold(
      (failure) {
        _state = _state.copyWith(
          isRequestingPermission: false,
          hasPermission: false,
          error: failure,
        );
      },
      (granted) {
        _state = _state.copyWith(
          isRequestingPermission: false,
          hasPermission: granted,
          error: null,
        );
      },
    );
    
    notifyListeners();
  }

  /// Get current device location
  Future<void> getCurrentLocation() async {
    // Check permission first
    if (!_state.hasPermission) {
      await requestPermission();
      if (!_state.hasPermission) {
        return;
      }
    }

    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    final result = await _repository.getCurrentLocation();
    
    result.fold(
      (failure) {
        _state = _state.copyWith(
          isLoading: false,
          error: failure,
        );
      },
      (location) {
        _state = _state.copyWith(
          isLoading: false,
          currentLocation: location,
          selectedLocation: location.toLatLng(),
          address: location.address,
          error: null,
        );
      },
    );
    
    notifyListeners();
  }

  /// Update selected location (from map tap/drag)
  void setSelectedLocation(LatLng location) {
    _state = _state.copyWith(
      selectedLocation: location,
      error: null,
    );
    notifyListeners();
  }

  /// Get address for selected location
  Future<void> updateAddressForLocation() async {
    if (_state.selectedLocation == null) return;

    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    final result = await _repository.getAddressFromCoordinates(
      _state.selectedLocation!.latitude,
      _state.selectedLocation!.longitude,
    );
    
    result.fold(
      (failure) {
        _state = _state.copyWith(isLoading: false);
      },
      (address) {
        _state = _state.copyWith(
          isLoading: false,
          address: address,
        );
      },
    );
    
    notifyListeners();
  }

  /// Set location from address search
  Future<void> setLocationFromAddress(String address) async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    final result = await _repository.getLocationFromAddress(address);
    
    result.fold(
      (failure) {
        _state = _state.copyWith(
          isLoading: false,
          error: failure,
        );
      },
      (location) {
        _state = _state.copyWith(
          isLoading: false,
          selectedLocation: location.toLatLng(),
          currentLocation: location,
          address: location.address,
          error: null,
        );
      },
    );
    
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _state = _state.copyWith(error: null);
    notifyListeners();
  }

  /// Reset state
  void reset() {
    _state = const LocationState();
    notifyListeners();
  }
}
