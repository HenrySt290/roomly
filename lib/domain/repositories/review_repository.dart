import 'package:dartz/dartz.dart';
import 'package:roomly/core/errors/failures.dart';
import 'package:roomly/domain/entities/review_entity.dart';

abstract class ReviewRepository {
  Future<Either<Failure, List<ReviewEntity>>> getReviewsForProperty(int propertyId, {int page = 1, int limit = 20});
  Future<Either<Failure, List<ReviewEntity>>> getMyReviews();
  Future<Either<Failure, ReviewEntity>> createReview({
    required int propertyId,
    required int rating,
    required String comment,
  });
  Future<Either<Failure, bool>> deleteReview(int reviewId);
}
