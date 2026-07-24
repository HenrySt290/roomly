import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roomly/core/theme/app_colors.dart';
import 'package:roomly/core/theme/app_text_styles.dart';
import 'package:roomly/features/properties/providers/add_property_flow_notifier.dart';

class AmenitiesStep extends StatelessWidget {
  const AmenitiesStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AddPropertyFlowNotifier>(builder: (context, notifier, _) {
      final state = notifier.state;
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Amenities & House Rules', style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Select what you offer – helps filtering',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          Text('Basic Facilities', style: AppTextStyles.h4),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _chip('Furnished', state.isFurnished, (v) => notifier.updateAmenities(isFurnished: v)),
              _chip('Attached Bathroom', state.hasAttachedBathroom,
                  (v) => notifier.updateAmenities(hasAttachedBathroom: v)),
              _chip('Parking', state.hasParking, (v) => notifier.updateAmenities(hasParking: v)),
              _chip('WiFi', state.hasWifi, (v) => notifier.updateAmenities(hasWifi: v)),
              _chip('Pet Friendly', state.isPetFriendly, (v) => notifier.updateAmenities(isPetFriendly: v)),
            ],
          ),
          const SizedBox(height: 24),
          Text('Extra Amenities', style: AppTextStyles.h4),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final amenity in [
                'Lift',
                'Security',
                'Water Supply',
                'Power Backup',
                'Gym',
                'Swimming Pool',
                'Garden',
                'Kitchen'
              ])
                _dynamicChip(amenity, state.selectedAmenities.contains(amenity), () => notifier.toggleAmenity(amenity)),
            ],
          ),
          const SizedBox(height: 24),
          Text('House Rules', style: AppTextStyles.h4),
          const SizedBox(height: 12),
          _rulesField(notifier),
          const SizedBox(height: 16),
          if (state.rules.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Added Rules:', style: AppTextStyles.labelLarge),
                const SizedBox(height: 8),
                ...state.rules.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.check, size: 16, color: AppColors.success),
                          const SizedBox(width: 8),
                          Expanded(child: Text(r, style: AppTextStyles.bodySmall)),
                          IconButton(
                            icon: const Icon(Icons.close, size: 16),
                            onPressed: () {
                              final updated = List<String>.from(state.rules)..remove(r);
                              notifier.updateAmenities(rules: updated);
                            },
                          ),
                        ],
                      ),
                    )),
              ],
            ),
        ],
      );
    });
  }

  Widget _chip(String label, bool selected, Function(bool) onChanged) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onChanged,
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: selected ? AppColors.primary : AppColors.textPrimary,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
      ),
    );
  }

  Widget _dynamicChip(String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary.withOpacity(0.15),
      labelStyle: TextStyle(color: selected ? AppColors.primary : AppColors.textSecondary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _rulesField(AddPropertyFlowNotifier notifier) {
    final controller = TextEditingController();
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'e.g., No smoking inside',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: AppColors.surface,
            ),
            onSubmitted: (v) {
              if (v.trim().isEmpty) return;
              final updated = [...notifier.state.rules, v.trim()];
              notifier.updateAmenities(rules: updated);
              controller.clear();
            },
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            final text = controller.text.trim();
            if (text.isEmpty) return;
            final updated = [...notifier.state.rules, text];
            notifier.updateAmenities(rules: updated);
            controller.clear();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ],
    );
  }
}
