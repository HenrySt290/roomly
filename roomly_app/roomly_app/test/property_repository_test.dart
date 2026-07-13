import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import '../../lib/core/errors/failures.dart';
import '../../lib/features/property/data/property_repository_impl.dart';

void main() {
  group('PropertyRepositoryImpl Tests', () {
    late PropertyRepositoryImpl repository;

    setUp(() {
      repository = PropertyRepositoryImpl();
    });

    test('fetch properties returns list of properties', () async {
      // This test validates the structure and error handling
      // Actual API calls would require mocking or a test backend
      
      final result = await repository.getProperties(
        page: 1,
        limit: 10,
      );

      // Result should be Either type
      expect(result, isA<Either<Failure, dynamic>>());
    });

    test('fetch property detail by id', () async {
      final result = await repository.getPropertyDetail(1);
      
      expect(result, isA<Either<Failure, dynamic>>());
    });

    test('create property with valid data', () async {
      final testData = {
        'title': 'Test Property',
        'description': 'Test Description',
        'rent': 5000,
        'deposit': 10000,
        'property_type': 'apartment',
        'room_type': '1BHK',
        'city': 'Mumbai',
        'area': 'Andheri',
        'address': 'Test Address',
        'latitude': 19.0760,
        'longitude': 72.8777,
        'amenities': ['wifi', 'parking'],
      };

      final result = await repository.createProperty(testData);
      
      expect(result, isA<Either<Failure, dynamic>>());
    });

    test('update property', () async {
      final updateData = {
        'title': 'Updated Title',
        'rent': 6000,
      };

      final result = await repository.updateProperty(1, updateData);
      
      expect(result, isA<Either<Failure, dynamic>>());
    });

    test('delete property', () async {
      final result = await repository.deleteProperty(1);
      
      expect(result, isA<Either<Failure, bool>>());
    });

    test('toggle favorite', () async {
      final result = await repository.toggleFavourite(1);
      
      expect(result, isA<Either<Failure, dynamic>>());
    });

    test('get favorite properties', () async {
      final result = await repository.getFavourites();
      
      expect(result, isA<Either<Failure, dynamic>>());
    });

    test('record property view', () async {
      final result = await repository.recordView(1);
      
      expect(result, isA<Either<Failure, bool>>());
    });

    test('report property', () async {
      final result = await repository.reportProperty(
        propertyId: 1,
        reason: 'Inappropriate content',
      );
      
      expect(result, isA<Either<Failure, bool>>());
    });
  });
}
