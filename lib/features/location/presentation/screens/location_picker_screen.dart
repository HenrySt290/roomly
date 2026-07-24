import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:roomly/core/theme/app_colors.dart';
import 'package:roomly/features/location/providers/location_notifier.dart';

/// Interactive map screen for owners to pick property location
class LocationPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;
  final String? initialAddress;

  const LocationPickerScreen({
    super.key,
    this.initialLocation,
    this.initialAddress,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late MapController _mapController;
  LatLng? _selectedLocation;
  bool _isGettingAddress = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedLocation = widget.initialLocation ?? const LatLng(28.6139, 77.2090); // Default to Delhi
    
    // Move map to initial location after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialLocation != null) {
        _mapController.move(widget.initialLocation!, 15.0);
      }
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _onMapTap(LatLng location) async {
    setState(() {
      _selectedLocation = location;
    });

    // Update notifier
    if (mounted) {
      context.read<LocationNotifier>().setSelectedLocation(location);
      
      // Get address for the tapped location
      setState(() => _isGettingAddress = true);
      await context.read<LocationNotifier>().updateAddressForLocation();
      setState(() => _isGettingAddress = false);
    }
  }

  void _confirmSelection() {
    if (_selectedLocation == null) return;

    final address = context.read<LocationNotifier>().state.address ?? widget.initialAddress ?? 'Selected Location';
    
    Navigator.pop(context, {
      'latitude': _selectedLocation!.latitude,
      'longitude': _selectedLocation!.longitude,
      'address': address,
    });
  }

  void _useCurrentLocation() async {
    final notifier = context.read<LocationNotifier>();
    await notifier.getCurrentLocation();
    
    if (notifier.state.currentLocation != null && mounted) {
      final loc = notifier.state.currentLocation!;
      setState(() {
        _selectedLocation = loc.toLatLng();
      });
      _mapController.move(_selectedLocation!, 15.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _useCurrentLocation,
            tooltip: 'Use Current Location',
          ),
        ],
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: AppColors.primary.withOpacity(0.1),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Drag the map or tap to select the exact property location',
                    style: TextStyle(fontSize: 13, color: AppColors.textDark),
                  ),
                ),
              ],
            ),
          ),
          
          // Map
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selectedLocation ?? const LatLng(28.6139, 77.2090),
                initialZoom: 13.0,
                onTap: (_, location) => _onMapTap(location),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.roomly.app',
                ),
                MarkerLayer(
                  markers: [
                    if (_selectedLocation != null)
                      Marker(
                        point: _selectedLocation!,
                        width: 80,
                        height: 80,
                        child: const Icon(
                          Icons.location_on,
                          size: 40,
                          color: AppColors.error,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          
          // Selected location info
          if (_selectedLocation != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.pin_drop, size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      const Text(
                        'Selected Location:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                    style: const TextStyle(fontSize: 13, color: AppColors.textLight),
                  ),
                  if (_isGettingAddress)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else if (context.read<LocationNotifier>().state.address != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        context.read<LocationNotifier>().state.address!,
                        style: const TextStyle(fontSize: 13, color: AppColors.textDark),
                      ),
                    ),
                ],
              ),
            ),
          
          // Confirm button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _selectedLocation != null ? _confirmSelection : null,
                icon: const Icon(Icons.check_circle),
                label: const Text('Confirm Location'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
