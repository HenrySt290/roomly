import 'package:flutter/foundation.dart';
import '../../../data/repositories/payment_repository_impl.dart';
import '../../../domain/entities/access_pass_entity.dart';
import '../../../core/errors/failures.dart';

/// Payment states for the payment flow
abstract class PaymentState {
  const PaymentState();
  
  List<Object?> get props => [];
}

/// Initial state
class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

/// Loading state during payment processing
class PaymentLoading extends PaymentState {
  const PaymentLoading();
}

/// Success state after payment completion
class PaymentSuccess extends PaymentState {
  final String transactionId;
  final String orderId;
  final String paymentId;
  final double amount;
  final String paymentType; // 'listing' or 'access_pass'
  final DateTime timestamp;

  const PaymentSuccess({
    required this.transactionId,
    required this.orderId,
    required this.paymentId,
    required this.amount,
    required this.paymentType,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [transactionId, orderId, paymentId, amount, paymentType];
}

/// Failure state with error information
class PaymentFailure extends PaymentState {
  final String message;
  final Failure? failure;

  const PaymentFailure({
    required this.message,
    this.failure,
  });

  @override
  List<Object?> get props => [message, failure];
}

/// Verification pending state (waiting for backend confirmation)
class PaymentVerificationPending extends PaymentState {
  final String orderId;
  final String paymentId;

  const PaymentVerificationPending({
    required this.orderId,
    required this.paymentId,
  });

  @override
  List<Object?> get props => [orderId, paymentId];
}

/// Access Pass activated state
class AccessPassActivated extends PaymentState {
  final AccessPassEntity accessPass;

  const AccessPassActivated({required this.accessPass});

  @override
  List<Object?> get props => [accessPass];
}

/// Listing Published state
class ListingPublished extends PaymentState {
  final int propertyId;
  final String transactionId;

  const ListingPublished({
    required this.propertyId,
    required this.transactionId,
  });

  @override
  List<Object?> get props => [propertyId, transactionId];
}

/// Payment Notifier - Manages payment state and business logic
class PaymentNotifier extends ChangeNotifier {
  final PaymentRepositoryImpl _paymentRepository;
  
  PaymentState _state = const PaymentInitial();
  bool _isProcessing = false;
  String? _currentOrderId;
  String? _currentPaymentId;

  PaymentNotifier({required PaymentRepositoryImpl paymentRepository})
      : _paymentRepository = paymentRepository;

  PaymentState get state => _state;
  bool get isProcessing => _isProcessing;
  String? get currentOrderId => _currentOrderId;
  String? get currentPaymentId => _currentPaymentId;

  /// Initialize Razorpay checkout for Access Pass purchase
  Future<void> purchaseAccessPass() async {
    _isProcessing = true;
    _state = const PaymentLoading();
    notifyListeners();

    try {
      // Create order from backend
      final orderResult = await _paymentRepository.createAccessPassOrder();
      
      orderResult.fold(
        (failure) {
          _state = PaymentFailure(
            message: 'Failed to create payment order. Please try again.',
            failure: failure,
          );
          _isProcessing = false;
          notifyListeners();
        },
        (orderData) async {
          _currentOrderId = orderData['id'] as String?;
          
          // Order created successfully - Razorpay checkout will be triggered
          // from the UI layer using the order data
          _state = PaymentSuccess(
            transactionId: orderData['receipt'] as String? ?? '',
            orderId: orderData['id'] as String,
            paymentId: '', // Will be set after payment
            amount: (orderData['amount'] as num) / 100, // Convert paise to rupees
            paymentType: 'access_pass',
            timestamp: DateTime.now(),
          );
          _isProcessing = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _state = PaymentFailure(
        message: 'An unexpected error occurred: $e',
      );
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Initialize Razorpay checkout for Property Listing fee
  Future<void> payListingFee({required int propertyId}) async {
    _isProcessing = true;
    _state = const PaymentLoading();
    notifyListeners();

    try {
      final orderResult = await _paymentRepository.createListingOrder(propertyId: propertyId);
      
      orderResult.fold(
        (failure) {
          _state = PaymentFailure(
            message: 'Failed to create listing payment order. Please try again.',
            failure: failure,
          );
          _isProcessing = false;
          notifyListeners();
        },
        (orderData) async {
          _currentOrderId = orderData['id'] as String?;
          
          _state = PaymentSuccess(
            transactionId: orderData['receipt'] as String? ?? '',
            orderId: orderData['id'] as String,
            paymentId: '',
            amount: (orderData['amount'] as num) / 100,
            paymentType: 'listing',
            timestamp: DateTime.now(),
          );
          _isProcessing = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _state = PaymentFailure(
        message: 'An unexpected error occurred: $e',
      );
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Verify payment after Razorpay success callback
  Future<void> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    _state = PaymentVerificationPending(orderId: orderId, paymentId: paymentId);
    notifyListeners();

    try {
      final verificationResult = await _paymentRepository.verifyPayment(
        orderId: orderId,
        paymentId: paymentId,
        signature: signature,
      );

      verificationResult.fold(
        (failure) {
          _state = PaymentFailure(
            message: 'Payment verification failed. Please contact support.',
            failure: failure,
          );
          notifyListeners();
        },
        (isVerified) async {
          if (isVerified) {
            // Fetch transaction details
            final transactionResult = await _paymentRepository.getTransaction(paymentId);
            
            transactionResult.fold(
              (failure) {
                // Still consider it success if verified, just log the error
                debugPrint('Failed to fetch transaction details: $failure');
              },
              (transactionData) {
                // State update handled by specific handlers based on payment type
              },
            );
          } else {
            _state = const PaymentFailure(
              message: 'Payment could not be verified. Please contact support.',
            );
          }
          notifyListeners();
        },
      );
    } catch (e) {
      _state = PaymentFailure(
        message: 'Verification error: $e',
      );
      notifyListeners();
    }
  }

  /// Handle successful Access Pass payment
  void handleAccessPassSuccess({
    required String orderId,
    required String paymentId,
    required String signature,
  }) {
    // This would typically fetch the activated access pass from backend
    // For now, we'll create a local entity
    final accessPass = AccessPassEntity(
      id: paymentId,
      userId: 0, // Would come from auth state
      isActive: true,
      purchasedAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
    );
    
    _state = AccessPassActivated(accessPass: accessPass);
    notifyListeners();
  }

  /// Handle successful Listing Fee payment
  void handleListingSuccess({
    required int propertyId,
    required String orderId,
    required String paymentId,
    required String signature,
  }) {
    _state = ListingPublished(
      propertyId: propertyId,
      transactionId: paymentId,
    );
    notifyListeners();
  }

  /// Get transaction history
  Future<void> loadTransactionHistory({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    _isProcessing = true;
    notifyListeners();

    try {
      // Implementation would go here
      // For now, just reset processing flag
      _isProcessing = false;
      notifyListeners();
    } catch (e) {
      _state = PaymentFailure(message: 'Failed to load transactions: $e');
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Reset state to initial
  void reset() {
    _state = const PaymentInitial();
    _isProcessing = false;
    _currentOrderId = null;
    _currentPaymentId = null;
    notifyListeners();
  }
}
