import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roomly/core/theme/app_colors.dart';
import 'package:roomly/core/theme/app_text_styles.dart';
import 'package:roomly/features/properties/providers/add_property_flow_notifier.dart';
import 'package:roomly/presentation/widgets/common_widgets.dart';

class PricingStep extends StatefulWidget {
  const PricingStep({super.key});

  @override
  State<PricingStep> createState() => _PricingStepState();
}

class _PricingStepState extends State<PricingStep> {
  late TextEditingController _rentCtrl;
  late TextEditingController _depositCtrl;

  @override
  void initState() {
    super.initState();
    final s = context.read<AddPropertyFlowNotifier>().state;
    _rentCtrl = TextEditingController(text: s.rent);
    _depositCtrl = TextEditingController(text: s.deposit);
  }

  @override
  void dispose() {
    _rentCtrl.dispose();
    _depositCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AddPropertyFlowNotifier>(builder: (context, notifier, _) {
      final state = notifier.state;
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Set your pricing', style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Competitive pricing gets more enquiries',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: CommonWidgets.buildTextField(
                  controller: _rentCtrl,
                  label: 'Monthly Rent (₹)',
                  hint: '8000',
                  keyboardType: TextInputType.number,
                  onChanged: (v) => notifier.updatePricing(rent: v),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CommonWidgets.buildTextField(
                  controller: _depositCtrl,
                  label: 'Deposit (₹)',
                  hint: '16000',
                  keyboardType: TextInputType.number,
                  onChanged: (v) => notifier.updatePricing(deposit: v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Available From', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: state.availableFrom,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) notifier.updatePricing(availableFrom: picked);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 20, color: AppColors.textSecondary),
                  const SizedBox(width: 12),
                  Text(
                    '${state.availableFrom.day}/${state.availableFrom.month}/${state.availableFrom.year}',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildPricingInfo(),
          const SizedBox(height: 16),
          if (!state.isPricingValid)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Enter valid rent (>0) and deposit',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
            ),
        ],
      );
    });
  }

  Widget _buildPricingInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Pricing Tip', style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• Listing fee is ₹9 one-time per listing\n• Tenant pays ₹5 access pass to contact you\n• Higher deposit can reduce spam enquiries',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
