import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roomly/core/theme/app_colors.dart';
import 'package:roomly/core/theme/app_text_styles.dart';
import 'package:roomly/features/properties/providers/add_property_flow_notifier.dart';
import 'package:roomly/presentation/widgets/common_widgets.dart';
import 'package:roomly/features/location/presentation/screens/location_picker_screen.dart';

class LocationStep extends StatefulWidget {
  const LocationStep({super.key});

  @override
  State<LocationStep> createState() => _LocationStepState();
}

class _LocationStepState extends State<LocationStep> {
  late TextEditingController _addressCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _areaCtrl;

  @override
  void initState() {
    super.initState();
    final s = context.read<AddPropertyFlowNotifier>().state;
    _addressCtrl = TextEditingController(text: s.address);
    _cityCtrl = TextEditingController(text: s.city);
    _areaCtrl = TextEditingController(text: s.area);
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _areaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AddPropertyFlowNotifier>(builder: (context, notifier, _) {
      final state = notifier.state;
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Where is your property?', style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Exact address is hidden until tenant buys ₹5 pass',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push<Map<String, dynamic>>(
                      context,
                      MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
                    );
                    if (result != null) {
                      notifier.setMapLocation(
                        latitude: result['latitude'] as double,
                        longitude: result['longitude'] as double,
                        address: result['address'] as String?,
                      );
                      if (result['address'] != null) {
                        _addressCtrl.text = result['address'];
                      }
                    }
                  },
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Pick on Map'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (state.latitude != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, size: 16, color: AppColors.success),
                      const SizedBox(width: 6),
                      Text('Lat: ${state.latitude!.toStringAsFixed(4)}',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.success)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          CommonWidgets.buildTextField(
            controller: _addressCtrl,
            label: 'Full Address',
            hint: 'House No, Street, Landmark',
            onChanged: (v) => notifier.updateLocation(address: v),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CommonWidgets.buildTextField(
                  controller: _cityCtrl,
                  label: 'City',
                  hint: 'Bangalore',
                  onChanged: (v) => notifier.updateLocation(city: v),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CommonWidgets.buildTextField(
                  controller: _areaCtrl,
                  label: 'Area/Locality',
                  hint: 'Indiranagar',
                  onChanged: (v) => notifier.updateLocation(area: v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
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
                    const Icon(Icons.privacy_tip_outlined, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text('Privacy Protected', style: AppTextStyles.labelLarge),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Teaser view shows only City & Area. Exact address & map unlocks only after tenant purchases access pass.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (!state.isLocationValid) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Complete address, city, area and pick location on map',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
            ),
          ],
        ],
      );
    });
  }
}
