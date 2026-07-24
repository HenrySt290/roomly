import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roomly/core/theme/app_colors.dart';
import 'package:roomly/core/theme/app_text_styles.dart';
import 'package:roomly/domain/entities/property_entity.dart';
import 'package:roomly/features/properties/providers/add_property_flow_notifier.dart';
import 'package:roomly/presentation/widgets/common_widgets.dart';

class BasicDetailsStep extends StatefulWidget {
  const BasicDetailsStep({super.key});

  @override
  State<BasicDetailsStep> createState() => _BasicDetailsStepState();
}

class _BasicDetailsStepState extends State<BasicDetailsStep> {
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;

  @override
  void initState() {
    super.initState();
    final state = context.read<AddPropertyFlowNotifier>().state;
    _titleCtrl = TextEditingController(text: state.title);
    _descCtrl = TextEditingController(text: state.description);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AddPropertyFlowNotifier>(
      builder: (context, notifier, _) {
        final state = notifier.state;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Tell us about your property',
                style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(state.currentStep.description,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            CommonWidgets.buildTextField(
              controller: _titleCtrl,
              label: 'Property Title',
              hint: 'e.g., Sunny 2BHK near Metro',
              onChanged: (v) => notifier.updateBasic(title: v),
            ),
            const SizedBox(height: 16),
            CommonWidgets.buildTextField(
              controller: _descCtrl,
              label: 'Description',
              hint: 'Describe your property in detail (min 20 chars)...',
              maxLines: 5,
              onChanged: (v) => notifier.updateBasic(description: v),
            ),
            const SizedBox(height: 24),
            _buildDropdown<PropertyType>(
              label: 'Property Type',
              value: state.propertyType,
              items: PropertyType.values,
              itemLabel: (e) => e.value,
              onChanged: (v) => notifier.updateBasic(propertyType: v),
            ),
            const SizedBox(height: 16),
            _buildDropdown<RoomType>(
              label: 'Room Configuration',
              value: state.roomType,
              items: RoomType.values,
              itemLabel: (e) => e.value,
              onChanged: (v) => notifier.updateBasic(roomType: v),
            ),
            const SizedBox(height: 16),
            _buildDropdown<String>(
              label: 'Gender Preference',
              value: state.genderPreference,
              items: const ['any', 'male', 'female'],
              itemLabel: (e) => e == 'any' ? 'Any' : e.capitalize(),
              onChanged: (v) => notifier.updateBasic(genderPreference: v),
            ),
            const SizedBox(height: 24),
            if (!state.isBasicValid)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: AppColors.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Title min 5 chars & Description min 20 chars required',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) itemLabel,
    required void Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: AppColors.surface,
          ),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(itemLabel(e)))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

extension on String {
  String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
