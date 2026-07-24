import 'package:flutter/material.dart';
import 'package:roomly/core/theme/app_colors.dart';
import 'package:roomly/core/theme/app_text_styles.dart';
import 'package:roomly/domain/entities/review_entity.dart';
import 'package:roomly/features/reviews/presentation/widgets/rating_stars.dart';
import 'package:intl/intl.dart';

class ReviewCard extends StatelessWidget {
  final ReviewEntity review;
  final bool showPropertyInfo;
  final VoidCallback? onDelete;

  const ReviewCard({super.key, required this.review, this.showPropertyInfo = false, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withOpacity(0.15),
                backgroundImage: review.tenantAvatar != null ? NetworkImage(review.tenantAvatar!) : null,
                child: review.tenantAvatar == null
                    ? Text(review.tenantName != null && review.tenantName!.isNotEmpty
                        ? review.tenantName![0].toUpperCase()
                        : 'T')
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.tenantName ?? 'Tenant', style: AppTextStyles.labelLarge),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        RatingStars(rating: review.rating.toDouble(), size: 16),
                        const SizedBox(width: 8),
                        Text(DateFormat('dd MMM yyyy').format(review.createdAt),
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                  onPressed: onDelete,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(review.comment, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
