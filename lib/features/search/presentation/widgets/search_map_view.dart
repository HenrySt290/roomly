import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:roomly/core/theme/app_colors.dart';
import 'package:roomly/core/theme/app_text_styles.dart';
import 'package:roomly/domain/entities/property_entity.dart';
import 'package:roomly/features/location/providers/location_notifier.dart';

class SearchMapView extends StatelessWidget {
  final List<PropertyEntity> properties;
  final Function(PropertyEntity)? onMarkerTap;

  const SearchMapView({super.key, required this.properties, this.onMarkerTap});

  @override
  Widget build(BuildContext context) {
    final locationNotifier = context.watch<LocationNotifier>();
    final userLocation = locationNotifier.currentLocation;

    // Markers for properties
    final markers = properties
        .where((p) => p.latitude != 0 && p.longitude != 0)
        .map((property) {
      return Marker(
        width: 80,
        height: 80,
        point: LatLng(property.latitude, property.longitude),
        child: GestureDetector(
          onTap: () => onMarkerTap?.call(property),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.primary, width: 1.2),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
                  ],
                ),
                child: Text(
                  '₹${property.rent.toStringAsFixed(0)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              const Icon(Icons.location_on, color: AppColors.primary, size: 28),
            ],
          ),
        ),
      );
    }).toList();

    // Add user location marker if available
    if (userLocation != null) {
      markers.add(
        Marker(
          width: 40,
          height: 40,
          point: userLocation,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.my_location, color: Colors.blue, size: 20),
          ),
        ),
      );
    }

    LatLng center;
    if (properties.isNotEmpty) {
      // Average lat/lng for center
      final avgLat = properties.map((p) => p.latitude).reduce((a, b) => a + b) / properties.length;
      final avgLng = properties.map((p) => p.longitude).reduce((a, b) => a + b) / properties.length;
      center = LatLng(avgLat, avgLng);
    } else if (userLocation != null) {
      center = userLocation;
    } else {
      center = const LatLng(28.6139, 77.2090);
    }

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: properties.isEmpty ? 11 : 12,
        maxZoom: 18,
        minZoom: 5,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.roomly.app',
        ),
        MarkerLayer(markers: markers),
        // Attribution
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution('© OpenStreetMap contributors'),
          ],
        ),
      ],
    );
  }
}

class SearchMapBottomSheet extends StatelessWidget {
  final PropertyEntity property;
  final VoidCallback? onViewDetails;

  const SearchMapBottomSheet({super.key, required this.property, this.onViewDetails});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: property.images.isNotEmpty
                ? Image.network(property.images.first, width: 80, height: 80, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(width: 80, height: 80, color: AppColors.border, child: const Icon(Icons.home)))
                : Container(width: 80, height: 80, color: AppColors.border, child: const Icon(Icons.home)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(property.title, style: AppTextStyles.labelLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('${property.area}, ${property.city}', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text('₹${property.rent.toStringAsFixed(0)}',
                        style: AppTextStyles.priceMedium.copyWith(fontSize: 16)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text(property.roomType.value, style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: onViewDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text('View', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
