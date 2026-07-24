import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:roomly/core/theme/app_colors.dart';
import 'package:roomly/features/location/providers/location_notifier.dart';
import 'package:provider/provider.dart';

/// Interactive map widget for property location picker
class PropertyLocationMap extends StatefulWidget {
  final LatLng? initialLocation;
  final Function(LatLng)? onLocationSelected;
  final bool showCurrentLocationButton;
  final double height;

  const PropertyLocationMap({
    super.key,
    this.initialLocation,
    this.onLocationSelected,
    this.showCurrentLocationButton = true,
    this.height = 400,
  });

  @override
  State<PropertyLocationMap> createState() => _PropertyLocationMapState();
}

class _PropertyLocationMapState extends State<PropertyLocationMap> {
  late MapController _mapController;
  late LatLng _centerLocation;
  Marker? _selectedMarker;

  @override
  void initState() {
    super.initState();
    _centerLocation = widget.initialLocation ?? const LatLng(28.6139, 77.2090); // Default to Delhi
    _mapController = MapController();
    _updateMarker(_centerLocation);
  }

  void _updateMarker(LatLng position) {
    setState(() {
      _selectedMarker = Marker(
        width: 40.0,
        height: 40.0,
        point: position,
        child: const Icon(
          Icons.location_on,
          color: AppColors.primary,
          size: 40,
        ),
      );
    });
  }

  void _onMapTap(LatLng position) {
    _updateMarker(position);
    _mapController.move(position, _mapController.zoom);
    
    if (widget.onLocationSelected != null) {
      widget.onLocationSelected!(position);
    }

    // Update address automatically
    final notifier = context.read<LocationNotifier>();
    notifier.setSelectedLocation(position);
    notifier.updateAddressForLocation();
  }

  void _moveToCurrentLocation() async {
    final notifier = context.read<LocationNotifier>();
    await notifier.getCurrentLocation();
    
    if (notifier.state.selectedLocation != null) {
      setState(() {
        _centerLocation = notifier.state.selectedLocation!;
      });
      _updateMarker(_centerLocation);
      _mapController.move(_centerLocation, 15);
      
      if (widget.onLocationSelected != null) {
        widget.onLocationSelected!(_centerLocation);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _centerLocation,
              initialZoom: 13,
              onTap: (_, latLng) => _onMapTap(latLng),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.roomly.app',
              ),
              MarkerLayer(markers: _selectedMarker != null ? [_selectedMarker!] : []),
            ],
          ),
        ),
        if (widget.showCurrentLocationButton)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _moveToCurrentLocation,
                  icon: const Icon(Icons.my_location),
                  label: const Text('Use Current Location'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Consumer<LocationNotifier>(
                  builder: (context, notifier, _) {
                    if (notifier.state.isLoading) {
                      return const CircularProgressIndicator();
                    }
                    if (notifier.state.address != null) {
                      return Expanded(
                        child: Text(
                          notifier.state.address!,
                          style: const TextStyle(fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
