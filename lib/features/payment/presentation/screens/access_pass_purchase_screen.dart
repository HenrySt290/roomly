import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:provider/provider.dart';
import 'package:roomly/core/theme/app_colors.dart';
import 'package:roomly/core/theme/app_text_styles.dart';
import 'package:roomly/features/payment/providers/payment_notifier.dart';
import 'package:roomly/features/payment/presentation/widgets/payment_button.dart';

/// Access Pass Purchase Screen
/// Allows tenants to purchase 24-hour access pass for ₹5
class AccessPassPurchaseScreen extends StatefulWidget {
  const AccessPassPurchaseScreen({super.key});

  @override
  State<AccessPassPurchaseScreen> createState() => _AccessPassPurchaseScreenState();
}

class _AccessPassPurchaseScreenState extends State<AccessPassPurchaseScreen> {
  late Razorpay _razorpay;
  String? _currentOrderId;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _setupRazorpayListeners();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _setupRazorpayListeners() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final notifier = context.read<PaymentNotifier>();
    
    // Verify payment with backend
    await notifier.verifyPayment(
      orderId: response.orderId!,
      paymentId: response.paymentId!,
      signature: response.signature!,
    );

    // Handle access pass activation
    notifier.handleAccessPassSuccess(
      orderId: response.orderId!,
      paymentId: response.paymentId!,
      signature: response.signature!,
    );

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success, size: 32),
              SizedBox(width: 12),
              Text('Payment Successful!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Access Pass has been activated!',
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              _buildInfoRow('Amount Paid', '₹5.00'),
              _buildInfoRow('Transaction ID', response.paymentId ?? ''),
              _buildInfoRow('Valid Until', _getExpiryTime()),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to property list
              },
              child: const Text('Browse Properties'),
            ),
          ],
        ),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    final errorMessage = _getErrorMessage(response.code);
    
    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.error, color: AppColors.error, size: 28),
              SizedBox(width: 12),
              Text('Payment Failed'),
            ],
          ),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External wallet selected: ${response.walletName}');
  }

  String _getErrorMessage(int? code) {
    switch (code) {
      case 0:
        return 'Network error. Please check your connection and try again.';
      case 1:
        return 'Authentication failed. Please verify your payment details.';
      case 2:
        return 'Network error. The server could not be reached.';
      default:
        return 'Payment failed. Please try again or use a different payment method.';
    }
  }

  String _getExpiryTime() {
    final expiry = DateTime.now().add(const Duration(hours: 24));
    return '${expiry.day}/${expiry.month}/${expiry.year} ${expiry.hour}:${expiry.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint)),
          Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _initiatePayment() {
    final notifier = context.read<PaymentNotifier>();
    
    // Create order from backend first
    notifier.purchaseAccessPass();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Access Pass'),
        centerTitle: true,
      ),
      body: Consumer<PaymentNotifier>(
        builder: (context, notifier, _) {
          // Listen for order creation success
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (notifier.state is PaymentSuccess && 
                notifier.currentOrderId != null &&
                _currentOrderId != notifier.currentOrderId) {
              
              _currentOrderId = notifier.currentOrderId;
              final state = notifier.state as PaymentSuccess;
              
              // Open Razorpay checkout
              final options = {
                'key': 'YOUR_RAZORPAY_KEY_ID', // Replace with actual key from env
                'amount': 500, // ₹5 in paise
                'name': 'Roomly',
                'description': '24-Hour Access Pass',
                'order_id': notifier.currentOrderId,
                'prefill': {
                  'email': 'tenant@example.com', // Get from auth state
                  'contact': '9999999999', // Get from auth state
                },
                'theme': {
                  'color': AppColors.primary.value.toRadixString(16),
                },
              };

              _razorpay.open(options);
            }
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                
                // Header Card
                _buildHeaderCard(),
                const SizedBox(height: 24),
                
                // Benefits List
                _buildBenefitsSection(),
                const SizedBox(height: 24),
                
                // Pricing Details
                _buildPricingSection(),
                const SizedBox(height: 24),
                
                // Terms
                _buildTermsSection(),
                const SizedBox(height: 32),
                
                // Purchase Button
                if (notifier.isProcessing)
                  const Center(child: CircularProgressIndicator())
                else
                  PaymentButton(
                    text: 'Pay ₹5 & Activate',
                    amount: 5.00,
                    onPressed: _initiatePayment,
                  ),
                
                if (notifier.state is PaymentFailure) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            (notifier.state as PaymentFailure).message,
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.vip_card,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Premium Access Pass',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Unlock unlimited property details for 24 hours',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What You Get', style: AppTextStyles.h5),
        const SizedBox(height: 12),
        _buildBenefitItem(Icons.lock_open, 'View Owner Contact Details'),
        _buildBenefitItem(Icons.location_on, 'See Exact Property Location'),
        _buildBenefitItem(Icons.photo_library, 'Access Full Photo Gallery'),
        _buildBenefitItem(Icons.description, 'Read Complete Property Description'),
        _buildBenefitItem(Icons.chat, 'Direct WhatsApp Communication'),
        _buildBenefitItem(Icons.visibility, 'Unlimited Property Views'),
      ],
    );
  }

  Widget _buildBenefitItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AppColors.success),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Access Pass Price', style: AppTextStyles.bodyMedium),
              const Text(
                '₹5.00',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Validity', style: AppTextStyles.bodySmall),
              Text('24 Hours', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Properties Viewable', style: AppTextStyles.bodySmall),
              Text('Unlimited', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTermsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Important Terms', style: AppTextStyles.h6),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.warningLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTermItem('• Pass activates immediately after payment'),
              _buildTermItem('• Valid for exactly 24 hours from purchase'),
              _buildTermItem('• Non-refundable once activated'),
              _buildTermItem('• Can view unlimited properties during validity'),
              _buildTermItem('• Does not include booking or rental agreement'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTermItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(height: 1.4),
      ),
    );
  }
}
