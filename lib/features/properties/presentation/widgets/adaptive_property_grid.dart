import 'package:flutter/material.dart';
import 'package:roomly/core/utils/responsive_utils.dart';
import 'package:roomly/domain/entities/property_entity.dart';
import 'package:roomly/features/properties/presentation/widgets/property_card.dart';

/// Responsive grid that adjusts columns based on screen size
class AdaptivePropertyGrid extends StatelessWidget {
  final List<PropertyEntity> properties;
  final Function(PropertyEntity) onTap;
  final Function(PropertyEntity)? onFavoriteToggle;
  final Function(int) isFavourite;

  const AdaptivePropertyGrid({
    Key? key,
    required this.properties,
    required this.onTap,
    this.onFavoriteToggle,
    required this.isFavourite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = ResponsiveUtils.getGridCrossAxisCount(context);
    final isMobile = ResponsiveUtils.isMobile(context);

    if (isMobile) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: properties.length,
        itemBuilder: (context, index) {
          final property = properties[index];
          return PropertyCard(
            property: property,
            onTap: () => onTap(property),
            onFavoriteToggle: onFavoriteToggle != null ? () => onFavoriteToggle!(property) : null,
            isFavorite: isFavourite(property.id),
          );
        },
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      itemCount: properties.length,
      itemBuilder: (context, index) {
        final property = properties[index];
        return PropertyCard(
          property: property,
          onTap: () => onTap(property),
          onFavoriteToggle: onFavoriteToggle != null ? () => onFavoriteToggle!(property) : null,
          isFavorite: isFavourite(property.id),
        );
      },
    );
  }
}
