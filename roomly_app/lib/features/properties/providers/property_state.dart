import '../../domain/entities/property_entity.dart';
import '../../domain/repositories/property_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import 'package:equatable/equatable.dart';

/// States for property operations
abstract class PropertyState extends Equatable {
  const PropertyState();

  @override
  List<Object?> get props => [];
}

class PropertyInitial extends PropertyState {
  const PropertyInitial();
}

class PropertyLoading extends PropertyState {
  const PropertyLoading();
}

class PropertyLoaded extends PropertyState {
  final List<PropertyEntity> properties;
  final int currentPage;
  final int totalPages;
  final bool hasMore;

  const PropertyLoaded({
    required this.properties,
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [properties, currentPage, totalPages, hasMore];
}

class PropertyDetailLoaded extends PropertyState {
  final PropertyEntity property;
  final bool hasAccessPass;

  const PropertyDetailLoaded({
    required this.property,
    this.hasAccessPass = false,
  });

  @override
  List<Object?> get props => [property, hasAccessPass];
}

class PropertyError extends PropertyState {
  final String message;

  const PropertyError(this.message);

  @override
  List<Object?> get props => [message];
}

class PropertyCreated extends PropertyState {
  final PropertyEntity property;

  const PropertyCreated(this.property);

  @override
  List<Object?> get props => [property];
}

class PropertyUpdated extends PropertyState {
  final PropertyEntity property;

  const PropertyUpdated(this.property);

  @override
  List<Object?> get props => [property];
}

class PropertyDeleted extends PropertyState {
  final int propertyId;

  const PropertyDeleted(this.propertyId);

  @override
  List<Object?> get props => [propertyId];
}

class PropertyFavouritesLoaded extends PropertyState {
  final List<PropertyEntity> favourites;

  const PropertyFavouritesLoaded(this.favourites);

  @override
  List<Object?> get props => [favourites];
}

class PropertyOwnerPropertiesLoaded extends PropertyState {
  final List<PropertyEntity> properties;
  final PropertyStatus? filterStatus;

  const PropertyOwnerPropertiesLoaded({
    required this.properties,
    this.filterStatus,
  });

  @override
  List<Object?> get props => [properties, filterStatus];
}
