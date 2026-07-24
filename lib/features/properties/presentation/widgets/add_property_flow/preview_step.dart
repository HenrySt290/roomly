import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roomly/core/theme/app_colors.dart';
import 'package:roomly/core/theme/app_text_styles.dart';
import 'package:roomly/features/properties/providers/add_property_flow_notifier.dart';
import 'package:roomly/features/properties/providers/add_property_flow_state.dart';

class PreviewStep extends StatelessWidget {
  const PreviewStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AddPropertyFlowNotifier>(builder: (context, notifier, _) {
      final s = notifier.state;
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Review & Pay', style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Check details before submitting for approval',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          _section('Basic', [
            _row('Title', s.title),
            _row('Description', s.description, maxLines: 3),
            _row('Type', '${s.propertyType.value} • ${s.roomType.value}'),
            _row('Gender', s.genderPreference),
          ]),
          _section('Pricing', [
            _row('Rent', '₹${s.rent}'),
            _row('Deposit', '₹${s.deposit}'),
            _row('Available', '${s.availableFrom.day}/${s.availableFrom.month}/${s.availableFrom.year}'),
          ]),
          _section('Location', [
            _row('Address', s.address),
            _row('City', '${s.city} • ${s.area}'),
            _row('Coordinates', s.latitude != null ? '${s.latitude!.toStringAsFixed(5)}, ${s.longitude!.toStringAsFixed(5)}' : 'Not set'),
          ]),
          _section('Amenities', [
            _row('Furnished', s.isFurnished ? 'Yes' : 'No'),
            _row('Attached Bath', s.hasAttachedBathroom ? 'Yes' : 'No'),
            _row('Parking', s.hasParking ? 'Yes' : 'No'),
            _row('WiFi', s.hasWifi ? 'Yes' : 'No'),
            _row('Pet Friendly', s.isPetFriendly ? 'Yes' : 'No'),
            if (s.selectedAmenities.isNotEmpty) _row('Extras', s.selectedAmenities.join(', ')),
            if (s.rules.isNotEmpty) _row('Rules', s.rules.join(', ')),
          ]),
          _section('Photos', [
            _row('Count', '${s.images.length} images'),
            _row('Thumbnail', s.images.isNotEmpty ? s.images.first.name : 'None'),
          ]),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Listing Fee', style: AppTextStyles.h4),
                    Text('₹9', style: AppTextStyles.h3.copyWith(color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'One-time fee per listing. Listing remains active until occupied. Pay again to relist.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (s.errorMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, size: 18, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(child: Text(s.errorMessage!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.error))),
                ],
              ),
            ),
          const SizedBox(height: 16),
          if (s.createdProperty != null && s.paymentOrder != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success),
                      const SizedBox(width: 8),
                      Text('Property Created!', style: AppTextStyles.labelLarge.copyWith(color: AppColors.success)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('ID: ${s.createdProperty!.id} • Order: ${s.paymentOrder!['id'] ?? 'created'}',
                      style: AppTextStyles.bodySmall),
                  const SizedBox(height: 8),
                  Text('Next: Complete Razorpay payment to publish.',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          const SizedBox(height: 80),
        ],
      );
    });
  }

  Widget _section(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w600)),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String label, String value, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value.isEmpty ? '-' : value,
                style: AppTextStyles.bodyMedium, maxLines: maxLines, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
