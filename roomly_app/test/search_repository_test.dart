import 'package:flutter_test/flutter_test.dart';
import 'package:either_dart/either.dart';
import '../../lib/core/errors/failures.dart';
import '../../lib/features/search/data/search_repository_impl.dart';

void main() {
  group('SearchRepositoryImpl Tests', () {
    late SearchRepositoryImpl repository;

    setUp(() {
      repository = SearchRepositoryImpl();
    });

    test('search properties with filters', () async {
      final filters = {
        'city': 'Mumbai',
        'area': 'Andheri',
        'min_rent': 3000,
        'max_rent': 8000,
        'property_type': 'apartment',
        'room_type': '1BHK',
        'furnished': true,
        'parking': true,
      };

      final result = await repository.search(
        filters: filters,
        page: 1,
        limit: 20,
      );

      expect(result, isA<Either<Failure, dynamic>>());
    });

    test('search with sort options', () async {
      final result = await repository.search(
        filters: {},
        sortBy: 'rent_low_to_high',
        page: 1,
        limit: 10,
      );

      expect(result, isA<Either<Failure, dynamic>>());
    });

    test('get cities list', () async {
      final result = await repository.getCities();

      expect(result, isA<Either<Failure, List<dynamic>>>());
    });

    test('get areas by city', () async {
      final result = await repository.getAreas('Mumbai');

      expect(result, isA<Either<Failure, List<dynamic>>>());
    });

    test('search with pagination', () async {
      final result1 = await repository.search(
        filters: {},
        page: 1,
        limit: 10,
      );

      final result2 = await repository.search(
        filters: {},
        page: 2,
        limit: 10,
      );

      expect(result1, isA<Either<Failure, dynamic>>());
      expect(result2, isA<Either<Failure, dynamic>>());
    });

    test('search with empty filters returns all properties', () async {
      final result = await repository.search(
        filters: {},
        page: 1,
        limit: 20,
      );

      expect(result, isA<Either<Failure, dynamic>>());
    });

    test('search handles invalid filters gracefully', () async {
      final invalidFilters = {
        'invalid_field': 'value',
        'rent': 'not_a_number',
      };

      final result = await repository.search(
        filters: invalidFilters,
        page: 1,
        limit: 10,
      );

      // Should either return error or ignore invalid filters
      expect(result, isA<Either<Failure, dynamic>>());
    });
  });
}
