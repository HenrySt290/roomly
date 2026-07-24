import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:roomly/core/errors/failures.dart';
import 'package:roomly/core/network/api_client.dart';
import 'package:roomly/domain/entities/review_entity.dart';
import 'package:roomly/domain/repositories/review_repository.dart';
import 'package:roomly/data/models/review_model.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ApiClient apiClient;

  const ReviewRepositoryImpl({required this.apiClient});

  @override
  Future<Either<Failure, List<ReviewEntity>>> getReviewsForProperty(int propertyId,
      {int page = 1, int limit = 20}) async {
    try {
      final response = await apiClient.get(
        '/properties/$propertyId/reviews',
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> list = data is List ? data : (data['data'] ?? data['reviews'] ?? []);
        final reviews = list.map((e) => ReviewModel.fromJson(e as Map<String, dynamic>)).toList();
        return Right(reviews);
      } else {
        return Left(ServerFailure(response.data?['message'] ?? 'Failed to fetch reviews', response.statusCode));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data?['message'] ?? 'Network error', e.response?.statusCode ?? 500));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e', 500));
    }
  }

  @override
  Future<Either<Failure, List<ReviewEntity>>> getMyReviews() async {
    try {
      final response = await apiClient.get('/reviews/my');
      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> list = data is List ? data : (data['data'] ?? []);
        final reviews = list.map((e) => ReviewModel.fromJson(e as Map<String, dynamic>)).toList();
        return Right(reviews);
      } else {
        return Left(ServerFailure('Failed to fetch my reviews', response.statusCode));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network error', e.response?.statusCode));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, ReviewEntity>> createReview(
      {required int propertyId, required int rating, required String comment}) async {
    try {
      final response = await apiClient.post(
        '/reviews',
        data: {'property_id': propertyId, 'rating': rating, 'comment': comment},
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;
        final json = data['review'] ?? data['data'] ?? data;
        final review = ReviewModel.fromJson(json as Map<String, dynamic>);
        return Right(review);
      } else {
        return Left(ServerFailure(response.data?['message'] ?? 'Failed to create review', response.statusCode));
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        return Left(ValidationFailure(e.response?.data?['message'] ?? 'Validation failed'));
      }
      return Left(ServerFailure(e.response?.data?['message'] ?? 'Network error', e.response?.statusCode ?? 500));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteReview(int reviewId) async {
    try {
      final response = await apiClient.delete('/reviews/$reviewId');
      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Right(true);
      } else {
        return Left(ServerFailure('Failed to delete review', response.statusCode));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network error', e.response?.statusCode));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
