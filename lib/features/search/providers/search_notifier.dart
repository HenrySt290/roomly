import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import 'package:roomly/core/errors/failures.dart';
import 'package:roomly/features/search/domain/entities/search_filter_entity.dart';
import 'package:roomly/features/search/domain/repositories/search_repository.dart';
import 'package:roomly/domain/entities/property_entity.dart';

/// State class for search feature
class SearchState extends Equatable {
  final List<PropertyEntity> properties;
  final List<String> cities;
  final List<String> areas;
  final SearchFilterEntity filters;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final int currentPage;
  final bool hasReachedMax;

  const SearchState({
    this.properties = const [],
    this.cities = const [],
    this.areas = const [],
    this.filters = const SearchFilterEntity.empty(),
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.currentPage = 1,
    this.hasReachedMax = false,
  });

  SearchState copyWith({
    List<PropertyEntity>? properties,
    List<String>? cities,
    List<String>? areas,
    SearchFilterEntity? filters,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    int? currentPage,
    bool? hasReachedMax,
  }) {
    return SearchState(
      properties: properties ?? this.properties,
      cities: cities ?? this.cities,
      areas: areas ?? this.areas,
      filters: filters ?? this.filters,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [
        properties,
        cities,
        areas,
        filters,
        isLoading,
        isLoadingMore,
        errorMessage,
        currentPage,
        hasReachedMax,
      ];
}

/// Notifier for search functionality
class SearchNotifier extends ChangeNotifier {
  final SearchRepository searchRepository;
  SearchState _state = const SearchState();

  SearchNotifier({required this.searchRepository});

  SearchState get state => _state;

  /// Initialize search by loading cities
  Future<void> initialize() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    final result = await searchRepository.getCities();
    
    result.fold(
      (failure) {
        _state = _state.copyWith(
          isLoading: false,
          errorMessage: _mapFailureToMessage(failure),
        );
      },
      (cities) {
        _state = _state.copyWith(
          isLoading: false,
          cities: cities,
        );
      },
    );
    notifyListeners();
  }

  /// Update a single filter
  void updateFilter<T>(String field, T value) {
    final currentFilters = _state.filters;
    SearchFilterEntity newFilters;

    switch (field) {
      case 'city':
        newFilters = currentFilters.copyWith(city: value as String?);
        // Reset areas when city changes
        _state = _state.copyWith(areas: []);
        break;
      case 'area':
        newFilters = currentFilters.copyWith(area: value as String?);
        break;
      case 'minRent':
        newFilters = currentFilters.copyWith(minRent: value as double?);
        break;
      case 'maxRent':
        newFilters = currentFilters.copyWith(maxRent: value as double?);
        break;
      case 'propertyType':
        newFilters = currentFilters.copyWith(propertyType: value as String?);
        break;
      case 'roomType':
        newFilters = currentFilters.copyWith(roomType: value as String?);
        break;
      case 'genderPreference':
        newFilters = currentFilters.copyWith(genderPreference: value as String?);
        break;
      case 'furnished':
        newFilters = currentFilters.copyWith(furnished: value as bool?);
        break;
      case 'attachedBathroom':
        newFilters = currentFilters.copyWith(attachedBathroom: value as bool?);
        break;
      case 'parking':
        newFilters = currentFilters.copyWith(parking: value as bool?);
        break;
      case 'wifi':
        newFilters = currentFilters.copyWith(wifi: value as bool?);
        break;
      case 'petFriendly':
        newFilters = currentFilters.copyWith(petFriendly: value as bool?);
        break;
      case 'availableFrom':
        newFilters = currentFilters.copyWith(availableFrom: value as DateTime?);
        break;
      case 'sortBy':
        newFilters = currentFilters.copyWith(sortBy: value as String?);
        break;
      default:
        newFilters = currentFilters;
    }

    _state = _state.copyWith(filters: newFilters);
    notifyListeners();
  }

  /// Reset all filters
  void resetFilters() {
    _state = _state.copyWith(
      filters: const SearchFilterEntity.empty(),
      areas: [],
    );
    notifyListeners();
  }

  /// Load areas for selected city
  Future<void> loadAreas(String city) async {
    if (city.isEmpty) return;

    final result = await searchRepository.getAreas(city);
    
    result.fold(
      (failure) {
        // Silently fail, areas will just be empty
      },
      (areas) {
        _state = _state.copyWith(areas: areas);
        notifyListeners();
      },
    );
  }

  /// Execute search with current filters
  Future<void> searchProperties({bool isRefresh = false}) async {
    if (isRefresh) {
      _state = _state.copyWith(
        isLoading: true,
        currentPage: 1,
        hasReachedMax: false,
      );
    } else if (_state.isLoading || _state.hasReachedMax) {
      return;
    } else {
      _state = _state.copyWith(isLoadingMore: true);
    }
    notifyListeners();

    final result = await searchRepository.searchProperties(
      filters: _state.filters,
      page: isRefresh ? 1 : _state.currentPage + 1,
      limit: 20,
    );

    result.fold(
      (failure) {
        _state = _state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          errorMessage: _mapFailureToMessage(failure),
        );
      },
      (properties) {
        if (isRefresh) {
          _state = _state.copyWith(
            isLoading: false,
            isLoadingMore: false,
            properties: properties,
            currentPage: 1,
            hasReachedMax: properties.length < 20,
          );
        } else {
          _state = _state.copyWith(
            isLoading: false,
            isLoadingMore: false,
            properties: [..._state.properties, ...properties],
            currentPage: _state.currentPage + 1,
            hasReachedMax: properties.length < 20,
          );
        }
      },
    );
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _state = _state.copyWith(errorMessage: null);
    notifyListeners();
  }

  /// Map failure to user-friendly message
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case TimeoutFailure:
        return 'Request timed out. Please try again.';
      case NetworkFailure:
        return 'No internet connection. Please check your network.';
      case AuthFailure:
        return 'Please login to continue.';
      case ServerFailure:
        return 'Server error. Please try again later.';
      case NotFoundFailure:
        return 'No properties found matching your criteria.';
      default:
        return 'An unexpected error occurred.';
    }
  }
}
