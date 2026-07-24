import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../providers/location_notifier.dart';
import 'package:provider/provider.dart';

/// Full-screen map view for browsing properties
class PropertyMapView extends StatelessWidget {
  final List<Map<String, dynamic>> properties;
  final Function(String propertyId)? onPropertySelected;

  const PropertyMapView({
    super.key,
    required this.properties,
    this.onPropertySelected,
  });

  @override
  Widget build(BuildContext context) {
    // Convert properties to markers
    final markers = properties.map((property) {
      final lat = property['latitude'] as double?;
      final lng = property['longitude'] as double?;
      
      if (lat == null || lng == null) return null;

      return Marker(
        width: 40.0,
        height: 40.0,
        point: LatLng(lat, lng),
        child: GestureDetector(
          onTap: () {
            if (onPropertySelected != null) {
              onPropertySelected!(property['id'] as String);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  '₹${property['rent']}',
                  style: AppTextStyles.bodyBold.copyWith(
                    color: AppColors.primary,
                    fontSize: 12,
                  ),
                ),
              ),
              const Icon(
                Icons.location_on,
                color: AppColors.primary,
                size: 32,
              ),
            ],
          ),
        ),
      );
    }).whereType<Marker>().toList();

    // Calculate center point
    LatLng center;
    if (properties.isNotEmpty && 
        properties.first['latitude'] != null && 
        properties.first['longitude'] != null) {
      center = LatLng(
        properties.first['latitude'] as double,
        properties.first['longitude'] as double,
      );
    } else {
      center = const LatLng(28.6139, 77.2090); // Default to Delhi
    }

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: 12,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.roomly.app',
        ),
        MarkerLayer(markers: markers),
      ],
    );
  }
}

/// Button to toggle between list and map view
class MapTogglebutton extends StatelessWidget {
  final bool isMapView;
  final VoidCallback onPressed;

  const MapTogglebutton({
    super.key,
    required this.isMapView,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: AppColors.primary,
      child: Icon(
        isMapView ? Icons.list : Icons.map,
        color: Colors.white,
      ),
    );
  }
}

/// Widget to show distance from user's location
class DistanceBadge extends StatelessWidget {
  final double distanceMeters;

  const DistanceBadge({
    super.key,
    required this.distanceMeters,
  });

  String get _formattedDistance {
    if (distanceMeters < 1000) {
      return '${distanceMeters.toStringAsFixed(0)}m';
    } else {
      return '${(distanceMeters / 1000).toStringAsFixed(1)}km';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.primary, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.near_me,
            size: 12,
            color: AppColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            _formattedDistance,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
