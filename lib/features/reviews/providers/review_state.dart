import 'package:equatable/equatable.dart';
import 'package:roomly/domain/entities/review_entity.dart';

abstract class ReviewState extends Equatable {
  const ReviewState();
  @override
  List<Object?> get props => [];
}

class ReviewInitial extends ReviewState {
  const ReviewInitial();
}

class ReviewLoading extends ReviewState {
  const ReviewLoading();
}

class ReviewLoaded extends ReviewState {
  final List<ReviewEntity> reviews;
  final double averageRating;
  final int totalCount;

  const ReviewLoaded({required this.reviews, this.averageRating = 0, this.totalCount = 0});

  @override
  List<Object?> get props => [reviews, averageRating, totalCount];
}

class ReviewSubmitting extends ReviewState {
  const ReviewSubmitting();
}

class ReviewCreated extends ReviewState {
  final ReviewEntity review;
  const ReviewCreated(this.review);
  @override
  List<Object?> get props => [review];
}

class ReviewError extends ReviewState {
  final String message;
  const ReviewError(this.message);
  @override
  List<Object?> get props => [message];
}
