import 'package:equatable/equatable.dart';
import 'package:roomly/domain/entities/property_entity.dart';
import 'package:image_picker/image_picker.dart';

enum AddPropertyFlowStep {
  basic,
  pricing,
  location,
  amenities,
  photos,
  preview;

  String get title {
    switch (this) {
      case AddPropertyFlowStep.basic:
        return 'Basic Details';
      case AddPropertyFlowStep.pricing:
        return 'Pricing';
      case AddPropertyFlowStep.location:
        return 'Location';
      case AddPropertyFlowStep.amenities:
        return 'Amenities';
      case AddPropertyFlowStep.photos:
        return 'Photos';
      case AddPropertyFlowStep.preview:
        return 'Preview & Pay';
    }
  }

  String get description {
    switch (this) {
      case AddPropertyFlowStep.basic:
        return 'Title, description, type';
      case AddPropertyFlowStep.pricing:
        return 'Rent, deposit, availability';
      case AddPropertyFlowStep.location:
        return 'Address & map';
      case AddPropertyFlowStep.amenities:
        return 'Facilities & rules';
      case AddPropertyFlowStep.photos:
        return 'Upload property photos';
      case AddPropertyFlowStep.preview:
        return 'Review & submit';
    }
  }

  static List<AddPropertyFlowStep> get all => values;
}

class AddPropertyFlowState extends Equatable {
  final AddPropertyFlowStep currentStep;
  final int currentIndex;

  // Step 1 Basic
  final String title;
  final String description;
  final PropertyType propertyType;
  final RoomType roomType;
  final String genderPreference;

  // Step 2 Pricing
  final String rent;
  final String deposit;
  final DateTime availableFrom;

  // Step 3 Location
  final String address;
  final String city;
  final String area;
  final double? latitude;
  final double? longitude;

  // Step 4 Amenities
  final bool isFurnished;
  final bool hasAttachedBathroom;
  final bool hasParking;
  final bool hasWifi;
  final bool isPetFriendly;
  final List<String> selectedAmenities;
  final List<String> rules;

  // Step 5 Photos
  final List<XFile> images;

  // Flow meta
  final bool isSubmitting;
  final String? errorMessage;
  final PropertyEntity? createdProperty;
  final Map<String, dynamic>? paymentOrder;
  final bool isPaymentProcessing;

  AddPropertyFlowState({
    this.currentStep = AddPropertyFlowStep.basic,
    this.currentIndex = 0,
    this.title = '',
    this.description = '',
    this.propertyType = PropertyType.apartment,
    this.roomType = RoomType.bhk1,
    this.genderPreference = 'any',
    this.rent = '',
    this.deposit = '',
    DateTime? availableFrom,
    this.address = '',
    this.city = '',
    this.area = '',
    this.latitude,
    this.longitude,
    this.isFurnished = false,
    this.hasAttachedBathroom = false,
    this.hasParking = false,
    this.hasWifi = false,
    this.isPetFriendly = false,
    this.selectedAmenities = const [],
    this.rules = const [],
    this.images = const [],
    this.isSubmitting = false,
    this.errorMessage,
    this.createdProperty,
    this.paymentOrder,
    this.isPaymentProcessing = false,
  }) : availableFrom = availableFrom ?? DateTime.now();

  bool get isFirstStep => currentIndex == 0;
  bool get isLastStep => currentIndex == AddPropertyFlowStep.values.length - 1;
  bool get isPreviewStep => currentStep == AddPropertyFlowStep.preview;

  double get progress => (currentIndex + 1) / AddPropertyFlowStep.values.length;

  // Validation per step
  bool get isBasicValid =>
      title.trim().length >= 5 &&
      description.trim().length >= 20 &&
      genderPreference.isNotEmpty;

  bool get isPricingValid {
    final rentVal = double.tryParse(rent);
    final depositVal = double.tryParse(deposit);
    return rentVal != null &&
        rentVal > 0 &&
        depositVal != null &&
        depositVal >= 0;
  }

  bool get isLocationValid =>
      address.trim().isNotEmpty &&
      city.trim().isNotEmpty &&
      area.trim().isNotEmpty &&
      latitude != null &&
      longitude != null;

  bool get isAmenitiesValid => true; // always valid, optional

  bool get isPhotosValid => images.isNotEmpty;

  bool get canProceedFromCurrent {
    switch (currentStep) {
      case AddPropertyFlowStep.basic:
        return isBasicValid;
      case AddPropertyFlowStep.pricing:
        return isPricingValid;
      case AddPropertyFlowStep.location:
        return isLocationValid;
      case AddPropertyFlowStep.amenities:
        return isAmenitiesValid;
      case AddPropertyFlowStep.photos:
        return isPhotosValid;
      case AddPropertyFlowStep.preview:
        return isBasicValid &&
            isPricingValid &&
            isLocationValid &&
            isPhotosValid;
    }
  }

  AddPropertyFlowState copyWith({
    AddPropertyFlowStep? currentStep,
    int? currentIndex,
    String? title,
    String? description,
    PropertyType? propertyType,
    RoomType? roomType,
    String? genderPreference,
    String? rent,
    String? deposit,
    DateTime? availableFrom,
    String? address,
    String? city,
    String? area,
    double? latitude,
    double? longitude,
    bool? isFurnished,
    bool? hasAttachedBathroom,
    bool? hasParking,
    bool? hasWifi,
    bool? isPetFriendly,
    List<String>? selectedAmenities,
    List<String>? rules,
    List<XFile>? images,
    bool? isSubmitting,
    String? errorMessage,
    PropertyEntity? createdProperty,
    Map<String, dynamic>? paymentOrder,
    bool? isPaymentProcessing,
    bool clearError = false,
    bool clearLatLng = false,
  }) {
    return AddPropertyFlowState(
      currentStep: currentStep ?? this.currentStep,
      currentIndex: currentIndex ?? this.currentIndex,
      title: title ?? this.title,
      description: description ?? this.description,
      propertyType: propertyType ?? this.propertyType,
      roomType: roomType ?? this.roomType,
      genderPreference: genderPreference ?? this.genderPreference,
      rent: rent ?? this.rent,
      deposit: deposit ?? this.deposit,
      availableFrom: availableFrom ?? this.availableFrom,
      address: address ?? this.address,
      city: city ?? this.city,
      area: area ?? this.area,
      latitude: clearLatLng ? null : (latitude ?? this.latitude),
      longitude: clearLatLng ? null : (longitude ?? this.longitude),
      isFurnished: isFurnished ?? this.isFurnished,
      hasAttachedBathroom: hasAttachedBathroom ?? this.hasAttachedBathroom,
      hasParking: hasParking ?? this.hasParking,
      hasWifi: hasWifi ?? this.hasWifi,
      isPetFriendly: isPetFriendly ?? this.isPetFriendly,
      selectedAmenities: selectedAmenities ?? this.selectedAmenities,
      rules: rules ?? this.rules,
      images: images ?? this.images,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      createdProperty: createdProperty ?? this.createdProperty,
      paymentOrder: paymentOrder ?? this.paymentOrder,
      isPaymentProcessing: isPaymentProcessing ?? this.isPaymentProcessing,
    );
  }

  @override
  List<Object?> get props => [
        currentStep,
        currentIndex,
        title,
        description,
        propertyType,
        roomType,
        genderPreference,
        rent,
        deposit,
        availableFrom,
        address,
        city,
        area,
        latitude,
        longitude,
        isFurnished,
        hasAttachedBathroom,
        hasParking,
        hasWifi,
        isPetFriendly,
        selectedAmenities,
        rules,
        images,
        isSubmitting,
        errorMessage,
        createdProperty,
        paymentOrder,
        isPaymentProcessing,
      ];
}
