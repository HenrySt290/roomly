import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../domain/entities/listing_entity.dart';
import 'listing_card.dart';

/// Responsive grid that adjusts columns based on screen size
class AdaptiveListingGrid extends StatelessWidget {
  final List<ListingEntity> listings;
  final Function(ListingEntity) onTap;
  final Function(ListingEntity)? onFavorite;

  const AdaptiveListingGrid({
    Key? key,
    required this.listings,
    required this.onTap,
    this.onFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = ResponsiveUtils.getGridCrossAxisCount(context);
    final isMobile = ResponsiveUtils.isMobile(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: isMobile ? 0.75 : 0.8,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemCount: listings.length,
      itemBuilder: (context, index) {
        final listing = listings[index];
        return ListingCard(
          listing: listing,
          onTap: () => onTap(listing),
          onFavorite: onFavorite != null ? () => onFavorite!(listing) : null,
        );
      },
    );
  }
}
