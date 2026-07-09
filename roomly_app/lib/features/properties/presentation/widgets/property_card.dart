import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/property_entity.dart';

class PropertyCard extends StatelessWidget {
  final PropertyEntity property;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final bool isFavorite;
  final bool showAccessBadge;

  const PropertyCard({
    Key? key,
    required this.property,
    this.onTap,
    this.onFavoriteToggle,
    this.isFavorite = false,
    this.showAccessBadge = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 4 / 3,
                    child: property.images.isNotEmpty
                        ? Image.network(
                            property.images.first,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.border,
                              child: Icon(Icons.home, size: 48, color: AppColors.textLight),
                            ),
                          )
                        : Container(
                            color: AppColors.border,
                            child: Icon(Icons.home, size: 48, color: AppColors.textLight),
                          ),
                  ),
                  
                  // Favorite Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onFavoriteToggle,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: isFavorite ? AppColors.error : AppColors.textDark,
                        ),
                      ),
                    ),
                  ),

                  // Access Pass Badge
                  if (showAccessBadge)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_open, size: 12, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              'Unlock Details',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Rent
                  Text(
                    property.title,
                    style: AppTextStyles.headingSmall.copyWith(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Location
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: AppColors.textLight),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${property.area}, ${property.city}',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Rent
                  Row(
                    children: [
                      Text(
                        '\u20B9${property.rent.toStringAsFixed(0)}',
                        style: AppTextStyles.headingSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '/month',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
                      ),
                      if (property.deposit > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            '+\u20B9${property.deposit.toStringAsFixed(0)} dep',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textLight,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Features
                  Row(
                    children: [
                      _buildFeatureChip(Icons.bed, property.roomType),
                      const SizedBox(width: 8),
                      if (property.furnished) ...[
                        _buildFeatureChip(Icons.chair, 'Furnished'),
                        const SizedBox(width: 8),
                      ],
                      if (property.attachedBathroom) ...[
                        _buildFeatureChip(Icons.bathtub, 'Attached Bath'),
                        const SizedBox(width: 8),
                      ],
                      if (property.parking) ...[
                        _buildFeatureChip(Icons.local_parking, 'Parking'),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primary),
          const SizedBox(width: 3),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              fontSize: 10,
            ),
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
