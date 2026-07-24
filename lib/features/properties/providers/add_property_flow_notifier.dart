import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dartz/dartz.dart';
import 'package:roomly/domain/entities/property_entity.dart';
import 'package:roomly/domain/repositories/property_repository.dart';
import 'package:roomly/domain/repositories/payment_repository.dart';
import 'package:roomly/core/errors/failures.dart';
import 'package:roomly/features/properties/providers/add_property_flow_state.dart';

/// Multi-step landlord listing flow notifier
/// Implements cohesive state management for 6-step wizard
class AddPropertyFlowNotifier extends ChangeNotifier {
  final PropertyRepository _propertyRepository;
  final PaymentRepository _paymentRepository;

  AddPropertyFlowState _state = AddPropertyFlowState();

  AddPropertyFlowNotifier({
    required PropertyRepository propertyRepository,
    required PaymentRepository paymentRepository,
  })  : _propertyRepository = propertyRepository,
        _paymentRepository = paymentRepository;

  AddPropertyFlowState get state => _state;

  // Navigation
  void nextStep() {
    if (!_state.canProceedFromCurrent) return;
    if (_state.isLastStep) return;

    final nextIndex = _state.currentIndex + 1;
    final nextStep = AddPropertyFlowStep.values[nextIndex];
    _state = _state.copyWith(
      currentIndex: nextIndex,
      currentStep: nextStep,
      clearError: true,
    );
    notifyListeners();
  }

  void previousStep() {
    if (_state.isFirstStep) return;
    final prevIndex = _state.currentIndex - 1;
    final prevStep = AddPropertyFlowStep.values[prevIndex];
    _state = _state.copyWith(
      currentIndex: prevIndex,
      currentStep: prevStep,
      clearError: true,
    );
    notifyListeners();
  }

  void goToStep(int index) {
    if (index < 0 || index >= AddPropertyFlowStep.values.length) return;
    // Allow backward navigation freely, forward only if previous steps valid
    if (index > _state.currentIndex && !_state.canProceedFromCurrent) return;

    _state = _state.copyWith(
      currentIndex: index,
      currentStep: AddPropertyFlowStep.values[index],
      clearError: true,
    );
    notifyListeners();
  }

  // Step 1 Basic
  void updateBasic({
    String? title,
    String? description,
    PropertyType? propertyType,
    RoomType? roomType,
    String? genderPreference,
  }) {
    _state = _state.copyWith(
      title: title,
      description: description,
      propertyType: propertyType,
      roomType: roomType,
      genderPreference: genderPreference,
      clearError: true,
    );
    notifyListeners();
  }

  // Step 2 Pricing
  void updatePricing({
    String? rent,
    String? deposit,
    DateTime? availableFrom,
  }) {
    _state = _state.copyWith(
      rent: rent,
      deposit: deposit,
      availableFrom: availableFrom,
      clearError: true,
    );
    notifyListeners();
  }

  // Step 3 Location
  void updateLocation({
    String? address,
    String? city,
    String? area,
    double? latitude,
    double? longitude,
  }) {
    _state = _state.copyWith(
      address: address,
      city: city,
      area: area,
      latitude: latitude,
      longitude: longitude,
      clearError: true,
    );
    notifyListeners();
  }

  void setMapLocation({
    required double latitude,
    required double longitude,
    String? address,
  }) {
    _state = _state.copyWith(
      latitude: latitude,
      longitude: longitude,
      address: address,
      clearError: true,
    );
    notifyListeners();
  }

  // Step 4 Amenities
  void updateAmenities({
    bool? isFurnished,
    bool? hasAttachedBathroom,
    bool? hasParking,
    bool? hasWifi,
    bool? isPetFriendly,
    List<String>? selectedAmenities,
    List<String>? rules,
  }) {
    _state = _state.copyWith(
      isFurnished: isFurnished,
      hasAttachedBathroom: hasAttachedBathroom,
      hasParking: hasParking,
      hasWifi: hasWifi,
      isPetFriendly: isPetFriendly,
      selectedAmenities: selectedAmenities,
      rules: rules,
      clearError: true,
    );
    notifyListeners();
  }

  void toggleAmenity(String amenity) {
    final current = List<String>.from(_state.selectedAmenities);
    if (current.contains(amenity)) {
      current.remove(amenity);
    } else {
      current.add(amenity);
    }
    _state = _state.copyWith(selectedAmenities: current, clearError: true);
    notifyListeners();
  }

  // Step 5 Photos
  void setImages(List<XFile> images) {
    _state = _state.copyWith(images: images, clearError: true);
    notifyListeners();
  }

  void addImages(List<XFile> newImages) {
    final combined = [..._state.images, ...newImages];
    // Limit to 10
    final limited = combined.take(10).toList();
    _state = _state.copyWith(images: limited, clearError: true);
    notifyListeners();
  }

  void removeImage(int index) {
    if (index < 0 || index >= _state.images.length) return;
    final updated = List<XFile>.from(_state.images)..removeAt(index);
    _state = _state.copyWith(images: updated, clearError: true);
    notifyListeners();
  }

  // Final submission - Clean architecture: orchestrates Property + Payment
  Future<Either<Failure, PropertyEntity>> submit() async {
    if (!_state.canProceedFromCurrent &&
        _state.currentStep != AddPropertyFlowStep.preview) {
      return Left(ValidationFailure('Please complete all required steps'));
    }

    _state = _state.copyWith(isSubmitting: true, clearError: true);
    notifyListeners();

    // Build amenities from booleans + selected list
    final amenities = <String>[
      ..._state.selectedAmenities,
      if (_state.isFurnished) 'furnished',
      if (_state.hasAttachedBathroom) 'attached_bathroom',
      if (_state.hasParking) 'parking',
      if (_state.hasWifi) 'wifi',
      if (_state.isPetFriendly) 'pet_friendly',
    ];

    // For demo, use placeholder image URLs if no real upload
    final imageUrls = _state.images.isNotEmpty
        ? _state.images.map((e) => e.path).toList()
        : ['https://images.unsplash.com/photo-1522708323590-d24dbb6b0267'];

    final rentVal = double.tryParse(_state.rent) ?? 0;
    final depositVal = double.tryParse(_state.deposit) ?? 0;

    // 1. Create property draft
    final createResult = await _propertyRepository.createProperty(
      title: _state.title.trim(),
      description: _state.description.trim(),
      rent: rentVal,
      deposit: depositVal,
      propertyType: _state.propertyType,
      roomType: _state.roomType,
      area: _state.area.trim(),
      city: _state.city.trim(),
      address: _state.address.trim(),
      latitude: _state.latitude ?? 28.6139,
      longitude: _state.longitude ?? 77.2090,
      amenities: amenities,
      rules: _state.rules,
      availableFrom: _state.availableFrom,
      imageUrls: imageUrls,
    );

    return createResult.fold(
      (failure) {
        _state = _state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
        );
        notifyListeners();
        return Left(failure);
      },
      (property) async {
        _state = _state.copyWith(
          createdProperty: property,
          isPaymentProcessing: true,
        );
        notifyListeners();

        // 2. Create listing payment order (₹9)
        final orderResult = await _paymentRepository.createListingOrder(
          propertyId: property.id,
        );

        return orderResult.fold(
          (failure) {
            // Property created but payment order failed - still allow retry
            _state = _state.copyWith(
              isSubmitting: false,
              isPaymentProcessing: false,
              paymentOrder: null,
              errorMessage:
                  'Property created but payment order failed: ${failure.message}',
            );
            notifyListeners();
            // Return property as success – UI can handle payment retry
            return Right(property);
          },
          (orderData) {
            _state = _state.copyWith(
              isSubmitting: false,
              isPaymentProcessing: false,
              paymentOrder: orderData,
            );
            notifyListeners();
            return Right(property);
          },
        );
      },
    );
  }

  // After Razorpay success callback
  Future<Either<Failure, bool>> verifyListingPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    _state = _state.copyWith(isPaymentProcessing: true, clearError: true);
    notifyListeners();

    final result = await _paymentRepository.verifyPayment(
      orderId: orderId,
      paymentId: paymentId,
      signature: signature,
    );

    return result.fold(
      (failure) {
        _state = _state.copyWith(
          isPaymentProcessing: false,
          errorMessage: failure.message,
        );
        notifyListeners();
        return Left(failure);
      },
      (verified) {
        _state = _state.copyWith(isPaymentProcessing: false);
        notifyListeners();
        return Right(verified);
      },
    );
  }

  void clearError() {
    _state = _state.copyWith(clearError: true);
    notifyListeners();
  }

  void reset() {
    _state = AddPropertyFlowState();
    notifyListeners();
  }
}
