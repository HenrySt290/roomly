import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roomly/core/theme/app_colors.dart';
import 'package:roomly/core/theme/app_text_styles.dart';
import 'package:roomly/features/properties/providers/add_property_flow_notifier.dart';
import 'package:roomly/features/properties/providers/add_property_flow_state.dart';
import 'package:roomly/features/properties/presentation/widgets/add_property_flow/basic_details_step.dart';
import 'package:roomly/features/properties/presentation/widgets/add_property_flow/pricing_step.dart';
import 'package:roomly/features/properties/presentation/widgets/add_property_flow/location_step.dart';
import 'package:roomly/features/properties/presentation/widgets/add_property_flow/amenities_step.dart';
import 'package:roomly/features/properties/presentation/widgets/add_property_flow/photos_step.dart';
import 'package:roomly/features/properties/presentation/widgets/add_property_flow/preview_step.dart';

class AddPropertyFlowScreen extends StatefulWidget {
  const AddPropertyFlowScreen({super.key});

  @override
  State<AddPropertyFlowScreen> createState() => _AddPropertyFlowScreenState();
}

class _AddPropertyFlowScreenState extends State<AddPropertyFlowScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onStepChanged(int index, AddPropertyFlowNotifier notifier) {
    // Sync page controller when notifier changes via goToStep
    if (_pageController.hasClients && _pageController.page?.round() != index) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AddPropertyFlowNotifier>(builder: (context, notifier, _) {
      final state = notifier.state;
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Discard listing?'),
                  content: const Text('Your progress will be lost.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () {
                        notifier.reset();
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text('Discard'),
                    ),
                  ],
                ),
              );
            },
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Property', style: AppTextStyles.h4),
              Text('${state.currentIndex + 1} of ${AddPropertyFlowStep.values.length} • ${state.currentStep.title}',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(6),
            child: LinearProgressIndicator(
              value: state.progress,
              backgroundColor: AppColors.border,
              color: AppColors.primary,
              minHeight: 4,
            ),
          ),
        ),
        body: Column(
          children: [
            // Stepper indicator
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: AddPropertyFlowStep.values.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final step = entry.value;
                  final isActive = idx == state.currentIndex;
                  final isCompleted = idx < state.currentIndex;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (idx <= state.currentIndex || state.canProceedFromCurrent) {
                          notifier.goToStep(idx);
                          _pageController.jumpToPage(idx);
                        }
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCompleted
                                  ? AppColors.success
                                  : isActive
                                      ? AppColors.primary
                                      : AppColors.border,
                            ),
                            child: Center(
                              child: isCompleted
                                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                                  : Text('${idx + 1}',
                                      style: TextStyle(
                                        color: isActive ? Colors.white : AppColors.textSecondary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      )),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            step.title.split(' ').first,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: isActive ? AppColors.primary : AppColors.textHint,
                              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (idx) {
                  notifier.goToStep(idx);
                },
                children: const [
                  BasicDetailsStep(),
                  PricingStep(),
                  LocationStep(),
                  AmenitiesStep(),
                  PhotosStep(),
                  PreviewStep(),
                ],
              ),
            ),
            // Bottom navigation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  if (!state.isFirstStep)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: state.isSubmitting
                            ? null
                            : () {
                                notifier.previousStep();
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                  if (!state.isFirstStep) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: state.isSubmitting || state.isPaymentProcessing
                          ? null
                          : () async {
                              if (state.isPreviewStep) {
                                // Final submission
                                final result = await notifier.submit();
                                result.fold(
                                  (failure) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(failure.message), backgroundColor: AppColors.error),
                                    );
                                  },
                                  (property) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Property #${property.id} created! Order: ${notifier.state.paymentOrder?['id'] ?? 'pending'}'),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                    // In real app, trigger Razorpay here using paymentOrder
                                    // For now, show success dialog
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Row(
                                          children: [
                                            Icon(Icons.check_circle, color: AppColors.success),
                                            SizedBox(width: 8),
                                            Text('Submitted'),
                                          ],
                                        ),
                                        content: Text(
                                            'Your listing "${property.title}" is submitted for approval. Pay ₹9 to publish. In production, Razorpay would open now with order ${notifier.state.paymentOrder?['id']}.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              notifier.reset();
                                              Navigator.pop(context);
                                              Navigator.pop(context, true);
                                            },
                                            child: const Text('Done'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              } else {
                                if (!state.canProceedFromCurrent) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Complete ${state.currentStep.title} to continue'),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                  return;
                                }
                                notifier.nextStep();
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: state.isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(state.isPreviewStep ? 'Submit & Pay ₹9' : 'Continue'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
