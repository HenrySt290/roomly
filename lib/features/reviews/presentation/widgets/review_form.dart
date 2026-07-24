import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roomly/core/theme/app_colors.dart';
import 'package:roomly/core/theme/app_text_styles.dart';
import 'package:roomly/features/reviews/presentation/widgets/rating_stars.dart';
import 'package:roomly/features/reviews/providers/review_notifier.dart';

class ReviewForm extends StatefulWidget {
  final int propertyId;
  final VoidCallback? onSubmitted;

  const ReviewForm({super.key, required this.propertyId, this.onSubmitted});

  @override
  State<ReviewForm> createState() => _ReviewFormState();

  static Future<void> show(BuildContext context, int propertyId) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ReviewForm(propertyId: propertyId),
      ),
    );
  }
}

class _ReviewFormState extends State<ReviewForm> {
  int _rating = 0;
  final _commentCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a rating')));
      return;
    }
    final notifier = context.read<ReviewNotifier>();
    final success = await notifier.submitReview(
      propertyId: widget.propertyId,
      rating: _rating,
      comment: _commentCtrl.text.trim(),
    );
    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully!'), backgroundColor: AppColors.success),
      );
      widget.onSubmitted?.call();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(notifier.error ?? 'Failed to submit review'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text('Write a Review', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text('Share your experience with this property',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Text('How would you rate?', style: AppTextStyles.labelLarge),
                  const SizedBox(height: 12),
                  InteractiveRating(
                    initialRating: _rating,
                    onChanged: (r) => setState(() => _rating = r),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _rating == 0
                        ? 'Tap to rate'
                        : _rating == 1
                            ? 'Poor'
                            : _rating == 2
                                ? 'Fair'
                                : _rating == 3
                                    ? 'Good'
                                    : _rating == 4
                                        ? 'Great'
                                        : 'Excellent',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _commentCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Your review',
                hintText: 'Tell others about your experience...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppColors.surface,
              ),
              validator: (v) {
                if (v == null || v.trim().length < 10) return 'Minimum 10 characters required';
                return null;
              },
            ),
            const SizedBox(height: 20),
            Consumer<ReviewNotifier>(builder: (context, notifier, _) {
              final isLoading = notifier.isLoading;
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Submit Review', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              );
            }),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
