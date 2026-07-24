import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roomly/core/theme/app_colors.dart';
import 'package:roomly/core/theme/app_text_styles.dart';
import 'package:roomly/features/reviews/providers/review_notifier.dart';
import 'package:roomly/features/reviews/providers/review_state.dart';
import 'package:roomly/features/reviews/presentation/widgets/review_card.dart';
import 'package:roomly/features/reviews/presentation/widgets/rating_stars.dart';
import 'package:roomly/features/reviews/presentation/widgets/review_form.dart';

class ReviewListScreen extends StatefulWidget {
  final int propertyId;
  final String propertyTitle;

  const ReviewListScreen({super.key, required this.propertyId, required this.propertyTitle});

  @override
  State<ReviewListScreen> createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends State<ReviewListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewNotifier>().loadReviews(widget.propertyId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Reviews'),
            Text(widget.propertyTitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
      body: Consumer<ReviewNotifier>(builder: (context, notifier, _) {
        final state = notifier.state;
        return Column(
          children: [
            // Summary header
            if (notifier.reviews.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.surface,
                child: Row(
                  children: [
                    Column(
                      children: [
                        Text(notifier.averageRating.toStringAsFixed(1),
                            style: AppTextStyles.h1.copyWith(color: AppColors.primary)),
                        RatingStars(rating: notifier.averageRating, size: 20),
                        const SizedBox(height: 4),
                        Text('${notifier.reviews.length} reviews',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        children: List.generate(5, (index) {
                          final star = 5 - index;
                          final count = notifier.reviews.where((r) => r.rating == star).length;
                          final pct = notifier.reviews.isEmpty ? 0.0 : count / notifier.reviews.length;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Text('$star', style: AppTextStyles.bodySmall),
                                const SizedBox(width: 4),
                                const Icon(Icons.star, size: 12, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: pct,
                                    backgroundColor: AppColors.border,
                                    color: AppColors.primary,
                                    minHeight: 6,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text('$count', style: AppTextStyles.bodySmall),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            const Divider(height: 1),
            Expanded(
              child: _buildList(state, notifier),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ReviewForm.show(context, widget.propertyId),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.rate_review, color: Colors.white),
        label: const Text('Write Review', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildList(ReviewState state, ReviewNotifier notifier) {
    if (state is ReviewLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is ReviewError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(state.message, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: () => notifier.loadReviews(widget.propertyId), child: const Text('Retry')),
          ],
        ),
      );
    }
    if (notifier.reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.reviews_outlined, size: 64, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text('No reviews yet', style: AppTextStyles.h4),
            const SizedBox(height: 4),
            Text('Be the first to review', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ReviewForm.show(context, widget.propertyId),
              icon: const Icon(Icons.edit),
              label: const Text('Write Review'),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => notifier.loadReviews(widget.propertyId),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifier.reviews.length,
        itemBuilder: (ctx, idx) => ReviewCard(review: notifier.reviews[idx]),
      ),
    );
  }
}
