import 'package:flutter/foundation.dart';
import 'package:roomly/domain/entities/review_entity.dart';
import 'package:roomly/domain/repositories/review_repository.dart';
import 'package:roomly/features/reviews/providers/review_state.dart';

class ReviewNotifier extends ChangeNotifier {
  final ReviewRepository _reviewRepository;

  ReviewState _state = const ReviewInitial();
  List<ReviewEntity> _reviews = [];
  double _averageRating = 0.0;

  ReviewNotifier({required ReviewRepository reviewRepository}) : _reviewRepository = reviewRepository;

  ReviewState get state => _state;
  List<ReviewEntity> get reviews => _reviews;
  double get averageRating => _averageRating;
  bool get isLoading => _state is ReviewLoading || _state is ReviewSubmitting;
  String? get error => _state is ReviewError ? (_state as ReviewError).message : null;

  Future<void> loadReviews(int propertyId) async {
    _state = const ReviewLoading();
    notifyListeners();

    final result = await _reviewRepository.getReviewsForProperty(propertyId);
    result.fold(
      (failure) {
        _state = ReviewError(failure.message);
        notifyListeners();
      },
      (reviews) {
        _reviews = reviews;
        _averageRating = reviews.isEmpty ? 0 : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
        _state = ReviewLoaded(reviews: reviews, averageRating: _averageRating, totalCount: reviews.length);
        notifyListeners();
      },
    );
  }

  Future<bool> submitReview({required int propertyId, required int rating, required String comment}) async {
    _state = const ReviewSubmitting();
    notifyListeners();

    final result = await _reviewRepository.createReview(propertyId: propertyId, rating: rating, comment: comment);
    return result.fold(
      (failure) {
        _state = ReviewError(failure.message);
        notifyListeners();
        return false;
      },
      (review) {
        _reviews = [review, ..._reviews];
        _averageRating = _reviews.isEmpty ? 0 : _reviews.map((r) => r.rating).reduce((a, b) => a + b) / _reviews.length;
        _state = ReviewCreated(review);
        // After creation, show loaded state
        _state = ReviewLoaded(reviews: _reviews, averageRating: _averageRating, totalCount: _reviews.length);
        notifyListeners();
        return true;
      },
    );
  }

  Future<void> deleteReview(int reviewId) async {
    final result = await _reviewRepository.deleteReview(reviewId);
    result.fold(
      (failure) {
        _state = ReviewError(failure.message);
        notifyListeners();
      },
      (_) {
        _reviews = _reviews.where((r) => r.id != reviewId).toList();
        _averageRating = _reviews.isEmpty ? 0 : _reviews.map((r) => r.rating).reduce((a, b) => a + b) / _reviews.length;
        _state = ReviewLoaded(reviews: _reviews, averageRating: _averageRating, totalCount: _reviews.length);
        notifyListeners();
      },
    );
  }

  void clearError() {
    if (_state is ReviewError) {
      _state = ReviewLoaded(reviews: _reviews, averageRating: _averageRating, totalCount: _reviews.length);
      notifyListeners();
    }
  }
}
