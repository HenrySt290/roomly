import 'package:dartz/dartz.dart';
import 'package:roomly/core/errors/failures.dart';
import 'package:roomly/features/search/domain/entities/search_filter_entity.dart';
import 'package:roomly/domain/entities/property_entity.dart';

/// Repository interface for search operations
abstract class SearchRepository {
  /// Search properties with filters
  Future<Either<Failure, List<PropertyEntity>>> searchProperties({
    required SearchFilterEntity filters,
    int page = 1,
    int limit = 20,
  });

  /// Get list of available cities
  Future<Either<Failure, List<String>>> getCities();

  /// Get list of areas for a city
  Future<Either<Failure, List<String>>> getAreas(String city);
}
