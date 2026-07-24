import 'package:flutter/material.dart';
import 'package:roomly/core/theme/app_colors.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final int starCount;
  final double size;
  final bool interactive;
  final ValueChanged<int>? onRatingChanged;
  final Color filledColor;
  final Color emptyColor;

  const RatingStars({
    super.key,
    required this.rating,
    this.starCount = 5,
    this.size = 24,
    this.interactive = false,
    this.onRatingChanged,
    this.filledColor = AppColors.primary,
    this.emptyColor = AppColors.border,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(starCount, (index) {
        final filled = index < rating;
        final half = !filled && (index + 1 - rating) <= 0.5 && (index + 1 - rating) > 0;
        return GestureDetector(
          onTap: interactive && onRatingChanged != null ? () => onRatingChanged!(index + 1) : null,
          child: Icon(
            filled ? Icons.star : (half ? Icons.star_half : Icons.star_border),
            size: size,
            color: filled || half ? filledColor : emptyColor,
          ),
        );
      }),
    );
  }
}

class InteractiveRating extends StatefulWidget {
  final int initialRating;
  final ValueChanged<int> onChanged;
  final double size;

  const InteractiveRating({super.key, this.initialRating = 0, required this.onChanged, this.size = 36});

  @override
  State<InteractiveRating> createState() => _InteractiveRatingState();
}

class _InteractiveRatingState extends State<InteractiveRating> {
  late int _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return RatingStars(
      rating: _rating.toDouble(),
      size: widget.size,
      interactive: true,
      onRatingChanged: (r) {
        setState(() => _rating = r);
        widget.onChanged(r);
      },
    );
  }
}
