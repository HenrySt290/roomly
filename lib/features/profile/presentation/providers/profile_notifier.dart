import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/export.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../../../core/errors/failures.dart';

enum ProfileState { initial, loading, success, error }

class ProfileNotifier extends ChangeNotifier {
  final ProfileRepository repository;

  ProfileNotifier({required this.repository});

  ProfileState _state = ProfileState.initial;
  UserEntity? _currentUser;
  OwnerProfileEntity? _ownerProfile;
  TenantProfileEntity? _tenantProfile;
  List<KycDocumentEntity> _kycDocuments = [];
  String? _errorMessage;

  // Getters
  ProfileState get state => _state;
  UserEntity? get currentUser => _currentUser;
  OwnerProfileEntity? get ownerProfile => _ownerProfile;
  TenantProfileEntity? get tenantProfile => _tenantProfile;
  List<KycDocumentEntity> get kycDocuments => _kycDocuments;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == ProfileState.loading;
  bool get isAuthenticated => _currentUser != null;

  // Load current user profile
  Future<void> loadCurrentUser() async {
    _state = ProfileState.loading;
    notifyListeners();

    final result = await repository.getCurrentUser();

    result.fold(
      (failure) {
        _state = ProfileState.error;
        _errorMessage = _mapFailureToMessage(failure);
        notifyListeners();
      },
      (user) {
        _currentUser = user;
        _state = ProfileState.success;
        notifyListeners();
      },
    );
  }

  // Update user profile
  Future<bool> updateProfile({
    required String name,
    String? phone,
  }) async {
    _state = ProfileState.loading;
    notifyListeners();

    final result = await repository.updateCurrentUser(name: name, phone: phone);

    return result.fold(
      (failure) {
        _state = ProfileState.error;
        _errorMessage = _mapFailureToMessage(failure);
        notifyListeners();
        return false;
      },
      (user) {
        _currentUser = user;
        _state = ProfileState.success;
        notifyListeners();
        return true;
      },
    );
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _state = ProfileState.loading;
    notifyListeners();

    final result = await repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    return result.fold(
      (failure) {
        _state = ProfileState.error;
        _errorMessage = _mapFailureToMessage(failure);
        notifyListeners();
        return false;
      },
      (success) {
        _state = ProfileState.success;
        notifyListeners();
        return true;
      },
    );
  }

  // Load owner profile
  Future<void> loadOwnerProfile(String userId) async {
    _state = ProfileState.loading;
    notifyListeners();

    final result = await repository.getOwnerProfile(userId);

    result.fold(
      (failure) {
        _state = ProfileState.error;
        _errorMessage = _mapFailureToMessage(failure);
        notifyListeners();
      },
      (profile) {
        _ownerProfile = profile;
        _state = ProfileState.success;
        notifyListeners();
      },
    );
  }

  // Update owner profile (KYC)
  Future<bool> updateOwnerProfile({
    String? aadharNumber,
    String? panNumber,
  }) async {
    _state = ProfileState.loading;
    notifyListeners();

    final result = await repository.updateOwnerProfile(
      aadharNumber: aadharNumber,
      panNumber: panNumber,
    );

    return result.fold(
      (failure) {
        _state = ProfileState.error;
        _errorMessage = _mapFailureToMessage(failure);
        notifyListeners();
        return false;
      },
      (profile) {
        _ownerProfile = profile;
        _state = ProfileState.success;
        notifyListeners();
        return true;
      },
    );
  }

  // Load tenant profile
  Future<void> loadTenantProfile(String userId) async {
    _state = ProfileState.loading;
    notifyListeners();

    final result = await repository.getTenantProfile(userId);

    result.fold(
      (failure) {
        _state = ProfileState.error;
        _errorMessage = _mapFailureToMessage(failure);
        notifyListeners();
      },
      (profile) {
        _tenantProfile = profile;
        _state = ProfileState.success;
        notifyListeners();
      },
    );
  }

  // Upload KYC document
  Future<bool> uploadKycDocument({
    required String documentType,
    required String documentUrl,
    String? frontImageUrl,
    String? backImageUrl,
    String? selfImageUrl,
  }) async {
    _state = ProfileState.loading;
    notifyListeners();

    final result = await repository.uploadKycDocument(
      documentType: documentType,
      documentUrl: documentUrl,
      frontImageUrl: frontImageUrl,
      backImageUrl: backImageUrl,
      selfImageUrl: selfImageUrl,
    );

    return result.fold(
      (failure) {
        _state = ProfileState.error;
        _errorMessage = _mapFailureToMessage(failure);
        notifyListeners();
        return false;
      },
      (document) {
        _kycDocuments.add(document);
        _state = ProfileState.success;
        notifyListeners();
        return true;
      },
    );
  }

  // Load KYC documents
  Future<void> loadKycDocuments(String userId) async {
    _state = ProfileState.loading;
    notifyListeners();

    final result = await repository.getKycDocuments(userId);

    result.fold(
      (failure) {
        _state = ProfileState.error;
        _errorMessage = _mapFailureToMessage(failure);
        notifyListeners();
      },
      (documents) {
        _kycDocuments = documents;
        _state = ProfileState.success;
        notifyListeners();
      },
    );
  }

  // Delete KYC document
  Future<bool> deleteKycDocument(String documentId) async {
    final result = await repository.deleteKycDocument(documentId);

    return result.fold(
      (failure) {
        _errorMessage = _mapFailureToMessage(failure);
        notifyListeners();
        return false;
      },
      (success) {
        _kycDocuments.removeWhere((doc) => doc.id == documentId);
        notifyListeners();
        return true;
      },
    );
  }

  // Get owner dashboard stats
  Future<Map<String, dynamic>?> getOwnerDashboardStats(String userId) async {
    final result = await repository.getOwnerDashboardStats(userId);

    return result.fold(
      (failure) {
        _errorMessage = _mapFailureToMessage(failure);
        notifyListeners();
        return null;
      },
      (stats) => stats,
    );
  }

  // Get tenant dashboard stats
  Future<Map<String, dynamic>?> getTenantDashboardStats(String userId) async {
    final result = await repository.getTenantDashboardStats(userId);

    return result.fold(
      (failure) {
        _errorMessage = _mapFailureToMessage(failure);
        notifyListeners();
        return null;
      },
      (stats) => stats,
    );
  }

  // Helper method to map failure to message
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error. Please try again later.';
      case NetworkFailure:
        return 'Network error. Check your connection.';
      case ValidationFailure:
        return (failure as ValidationFailure).message;
      default:
        return 'Unexpected error occurred.';
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    if (_state == ProfileState.error) {
      _state = ProfileState.initial;
    }
    notifyListeners();
  }

  // Reset state
  void reset() {
    _state = ProfileState.initial;
    _currentUser = null;
    _ownerProfile = null;
    _tenantProfile = null;
    _kycDocuments = [];
    _errorMessage = null;
    notifyListeners();
  }
}
