import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import 'package:roomly/domain/entities/property_entity.dart';
import 'package:roomly/domain/repositories/property_repository.dart';
import 'package:roomly/core/errors/failures.dart';
import 'package:roomly/features/properties/providers/property_state.dart';

/// Notifier for property state management
/// Implements ChangeNotifier pattern for Provider package
class PropertyNotifier extends ChangeNotifier {
  final PropertyRepository propertyRepository;

  PropertyState _state = const PropertyInitial();
  List<PropertyEntity> _properties = [];
  List<PropertyEntity> _favourites = [];
  List<PropertyEntity> _ownerProperties = [];
  
  PropertyEntity? _currentProperty;
  bool _isLoading = false;
  String? _error;
  
  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = false;
  
  // Filters
  PropertyFilters _filters = const PropertyFilters();

  PropertyNotifier({required this.propertyRepository});

  /// Get current state
  PropertyState get state => _state;

  /// Get all properties
  List<PropertyEntity> get properties => _properties;

  /// Get favourites
  List<PropertyEntity> get favourites => _favourites;

  /// Get owner properties
  List<PropertyEntity> get ownerProperties => _ownerProperties;

  /// Get current property detail
  PropertyEntity? get currentProperty => _currentProperty;

  /// Check if loading
  bool get isLoading => _isLoading;

  /// Get error message
  String? get error => _error;

  /// Get current page
  int get currentPage => _currentPage;

  /// Check if has more pages
  bool get hasMore => _hasMore;

  /// Get current filters
  PropertyFilters get filters => _filters;

  /// Set filters
  void setFilters(PropertyFilters filters) {
    _filters = filters;
    notifyListeners();
  }

  /// Load properties with filters
  Future<void> loadProperties({bool refresh = false}) async {
    if (_isLoading && !refresh) return;

    _isLoading = true;
    _error = null;
    _state = const PropertyLoading();
    notifyListeners();

    if (refresh) {
      _currentPage = 1;
      _properties = [];
    }

    final result = await propertyRepository.getProperties(
      city: _filters.city,
      area: _filters.area,
      minRent: _filters.minRent,
      maxRent: _filters.maxRent,
      propertyType: _filters.propertyType,
      roomType: _filters.roomType,
      furnished: _filters.furnished,
      parking: _filters.parking,
      wifi: _filters.wifi,
      petFriendly: _filters.petFriendly,
      sortBy: _filters.sortBy,
      page: _currentPage,
      limit: 20,
    );

    result.fold(
      (failure) {
        _error = failure.message;
        _state = PropertyError(failure.message);
        _isLoading = false;
        notifyListeners();
      },
      (properties) {
        if (refresh) {
          _properties = properties;
        } else {
          _properties.addAll(properties);
        }
        
        _currentPage++;
        _hasMore = properties.length == 20;
        _state = PropertyLoaded(
          properties: _properties,
          currentPage: _currentPage,
          hasMore: _hasMore,
        );
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Load property detail by ID
  Future<void> loadPropertyDetail(int propertyId) async {
    _isLoading = true;
    _error = null;
    _state = const PropertyLoading();
    notifyListeners();

    final result = await propertyRepository.getPropertyById(propertyId);

    result.fold(
      (failure) {
        _error = failure.message;
        _state = PropertyError(failure.message);
        _isLoading = false;
        notifyListeners();
      },
      (property) {
        _currentProperty = property;
        _state = PropertyDetailLoaded(property: property);
        _isLoading = false;
        notifyListeners();
      },
    );
  }

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
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await propertyRepository.createProperty(
      title: title,
      description: description,
      rent: rent,
      deposit: deposit,
      propertyType: propertyType,
      roomType: roomType,
      area: area,
      city: city,
      address: address,
      latitude: latitude,
      longitude: longitude,
      amenities: amenities,
      rules: rules,
      availableFrom: availableFrom,
      imageUrls: imageUrls,
    );

    result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (property) {
        _properties.insert(0, property);
        _state = PropertyCreated(property);
        _isLoading = false;
        notifyListeners();
      },
    );

    return result;
  }

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
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await propertyRepository.updateProperty(
      id: id,
      title: title,
      description: description,
      rent: rent,
      deposit: deposit,
      propertyType: propertyType,
      roomType: roomType,
      area: area,
      city: city,
      address: address,
      latitude: latitude,
      longitude: longitude,
      amenities: amenities,
      rules: rules,
      availableFrom: availableFrom,
      imageUrls: imageUrls,
    );

    result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (property) {
        final index = _properties.indexWhere((p) => p.id == id);
        if (index != -1) {
          _properties[index] = property;
        }
        if (_currentProperty?.id == id) {
          _currentProperty = property;
        }
        _state = PropertyUpdated(property);
        _isLoading = false;
        notifyListeners();
      },
    );

    return result;
  }

  /// Delete property
  Future<Either<Failure, bool>> deleteProperty(int id) async {
    _isLoading = true;
    notifyListeners();

    final result = await propertyRepository.deleteProperty(id);

    result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (success) {
        _properties.removeWhere((p) => p.id == id);
        _state = PropertyDeleted(id);
        _isLoading = false;
        notifyListeners();
      },
    );

    return result;
  }

  /// Publish property
  Future<Either<Failure, PropertyEntity>> publishProperty(int id) async {
    _isLoading = true;
    notifyListeners();

    final result = await propertyRepository.publishProperty(id);

    result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (property) {
        final index = _properties.indexWhere((p) => p.id == id);
        if (index != -1) {
          _properties[index] = property;
        }
        _isLoading = false;
        notifyListeners();
      },
    );

    return result;
  }

  /// Mark property as occupied
  Future<Either<Failure, PropertyEntity>> markOccupied(int id) async {
    _isLoading = true;
    notifyListeners();

    final result = await propertyRepository.markOccupied(id);

    result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (property) {
        final index = _properties.indexWhere((p) => p.id == id);
        if (index != -1) {
          _properties[index] = property;
        }
        _isLoading = false;
        notifyListeners();
      },
    );

    return result;
  }

  /// Relist property
  Future<Either<Failure, PropertyEntity>> relistProperty(int id) async {
    _isLoading = true;
    notifyListeners();

    final result = await propertyRepository.relistProperty(id);

    result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (property) {
        final index = _properties.indexWhere((p) => p.id == id);
        if (index != -1) {
          _properties[index] = property;
        }
        _isLoading = false;
        notifyListeners();
      },
    );

    return result;
  }

  /// Add to favourites
  Future<Either<Failure, bool>> toggleFavourite(int propertyId) async {
    final isFavourite = _favourites.any((p) => p.id == propertyId);
    
    final result = isFavourite
        ? await propertyRepository.removeFromFavourites(propertyId)
        : await propertyRepository.addToFavourites(propertyId);

    result.fold(
      (failure) {
        _error = failure.message;
        notifyListeners();
      },
      (success) {
        if (isFavourite) {
          _favourites.removeWhere((p) => p.id == propertyId);
        } else {
          final property = _properties.firstWhere((p) => p.id == propertyId);
          _favourites.add(property);
        }
        notifyListeners();
      },
    );

    return result;
  }

  /// Load favourites
  Future<void> loadFavourites() async {
    _isLoading = true;
    notifyListeners();

    final result = await propertyRepository.getFavourites();

    result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (properties) {
        _favourites = properties;
        _state = PropertyFavouritesLoaded(properties);
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Load owner properties
  Future<void> loadOwnerProperties({PropertyStatus? status}) async {
    _isLoading = true;
    notifyListeners();

    final result = await propertyRepository.getOwnerProperties(
      status: status,
    );

    result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (properties) {
        _ownerProperties = properties;
        _state = PropertyOwnerPropertiesLoaded(
          properties: properties,
          filterStatus: status,
        );
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Record property view
  Future<void> recordView(int propertyId) async {
    await propertyRepository.recordView(propertyId);
  }

  /// Report property
  Future<Either<Failure, bool>> reportProperty({
    required int propertyId,
    required String reason,
    required String description,
  }) async {
    return await propertyRepository.reportProperty(
      propertyId: propertyId,
      reason: reason,
      description: description,
    );
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear current property
  void clearCurrentProperty() {
    _currentProperty = null;
    notifyListeners();
  }
}

/// Filter configuration for property search
class PropertyFilters {
  final String? city;
  final String? area;
  final double? minRent;
  final double? maxRent;
  final PropertyType? propertyType;
  final RoomType? roomType;
  final bool? furnished;
  final bool? parking;
  final bool? wifi;
  final bool? petFriendly;
  final String? sortBy;

  const PropertyFilters({
    this.city,
    this.area,
    this.minRent,
    this.maxRent,
    this.propertyType,
    this.roomType,
    this.furnished,
    this.parking,
    this.wifi,
    this.petFriendly,
    this.sortBy,
  });

  PropertyFilters copyWith({
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
  }) {
    return PropertyFilters(
      city: city ?? this.city,
      area: area ?? this.area,
      minRent: minRent ?? this.minRent,
      maxRent: maxRent ?? this.maxRent,
      propertyType: propertyType ?? this.propertyType,
      roomType: roomType ?? this.roomType,
      furnished: furnished ?? this.furnished,
      parking: parking ?? this.parking,
      wifi: wifi ?? this.wifi,
      petFriendly: petFriendly ?? this.petFriendly,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}
