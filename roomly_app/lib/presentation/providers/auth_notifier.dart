import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../providers/auth_provider.dart';
import 'package:flutter/foundation.dart';

/// Notifier for authentication state management
/// Implements Riverpod-style state management pattern
class AuthNotifier extends ChangeNotifier {
  final AuthRepository authRepository;

  AuthState _state = const AuthInitial();
  UserModel? _currentUser;

  AuthNotifier({required this.authRepository});

  /// Get current state
  AuthState get state => _state;

  /// Get current user
  UserModel? get currentUser => _currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _state is AuthAuthenticated;

  /// Check if user is loading
  bool get isLoading => _state is AuthLoading;

  /// Get error message
  String? get errorMessage {
    if (_state is AuthError) {
      return (_state as AuthError).message;
    }
    return null;
  }

  /// Initialize and check if user is already logged in
  Future<void> initialize() async {
    _state = const AuthLoading();
    notifyListeners();

    final result = await authRepository.getCurrentUser();

    result.fold(
      (failure) {
        _state = const AuthUnauthenticated();
        notifyListeners();
      },
      (user) {
        _currentUser = user;
        _state = AuthAuthenticated(
          userId: user.id,
          email: user.email,
          name: user.name,
          role: user.role.value,
          isEmailVerified: user.isEmailVerified,
          isPhoneVerified: user.isPhoneVerified,
        );
        notifyListeners();
      },
    );
  }

  /// Login user
  Future<void> login({required String email, required String password}) async {
    _state = const AuthLoading();
    notifyListeners();

    final result = await authRepository.login(email: email, password: password);

    result.fold(
      (failure) {
        _state = AuthError(failure.message);
        notifyListeners();
      },
      (data) async {
        // Fetch full user details after login
        final userResult = await authRepository.getCurrentUser();
        userResult.fold(
          (failure) {
            _state = AuthError(failure.message);
            notifyListeners();
          },
          (user) {
            _currentUser = user;
            _state = AuthAuthenticated(
              userId: user.id,
              email: user.email,
              name: user.name,
              role: user.role.value,
              isEmailVerified: user.isEmailVerified,
              isPhoneVerified: user.isPhoneVerified,
            );
            notifyListeners();
          },
        );
      },
    );
  }

  /// Register new user
  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    _state = const AuthLoading();
    notifyListeners();

    final result = await authRepository.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
      role: role,
    );

    result.fold(
      (failure) {
        _state = AuthError(failure.message);
        notifyListeners();
      },
      (user) async {
        _currentUser = user;
        _state = AuthAuthenticated(
          userId: user.id,
          email: user.email,
          name: user.name,
          role: user.role.value,
          isEmailVerified: user.isEmailVerified,
          isPhoneVerified: user.isPhoneVerified,
        );
        notifyListeners();
      },
    );
  }

  /// Logout user
  Future<void> logout() async {
    _state = const AuthLoading();
    notifyListeners();

    final result = await authRepository.logout();

    result.fold(
      (failure) {
        _state = AuthError(failure.message);
        notifyListeners();
      },
      (_) {
        _currentUser = null;
        _state = const AuthUnauthenticated();
        notifyListeners();
      },
    );
  }

  /// Forgot password
  Future<void> forgotPassword({required String email}) async {
    _state = const AuthLoading();
    notifyListeners();

    final result = await authRepository.forgotPassword(email: email);

    result.fold(
      (failure) {
        _state = AuthError(failure.message);
        notifyListeners();
      },
      (_) {
        _state = const AuthInitial();
        notifyListeners();
      },
    );
  }

  /// Reset password
  Future<void> resetPassword({
    required String token,
    required String password,
    required String confirmPassword,
  }) async {
    _state = const AuthLoading();
    notifyListeners();

    final result = await authRepository.resetPassword(
      token: token,
      password: password,
      confirmPassword: confirmPassword,
    );

    result.fold(
      (failure) {
        _state = AuthError(failure.message);
        notifyListeners();
      },
      (_) {
        _state = const AuthInitial();
        notifyListeners();
      },
    );
  }

  /// Verify email
  Future<void> verifyEmail({required String token}) async {
    _state = const AuthLoading();
    notifyListeners();

    final result = await authRepository.verifyEmail(token: token);

    result.fold(
      (failure) {
        _state = AuthError(failure.message);
        notifyListeners();
      },
      (_) {
        // Refresh user data after verification
        initialize();
      },
    );
  }

  /// Resend verification email
  Future<void> resendVerificationEmail() async {
    _state = const AuthLoading();
    notifyListeners();

    final result = await authRepository.resendVerificationEmail();

    result.fold(
      (failure) {
        _state = AuthError(failure.message);
        notifyListeners();
      },
      (_) {
        _state = const AuthInitial();
        notifyListeners();
      },
    );
  }

  /// Clear error state
  void clearError() {
    if (_state is AuthError) {
      _state = const AuthInitial();
      notifyListeners();
    }
  }
}
