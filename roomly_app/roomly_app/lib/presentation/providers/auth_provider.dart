import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';

/// Base authentication state
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial authentication state
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Authentication loading state
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User authenticated state
class AuthAuthenticated extends AuthState {
  final int userId;
  final String email;
  final String name;
  final String role;
  final bool isEmailVerified;
  final bool isPhoneVerified;

  const AuthAuthenticated({
    required this.userId,
    required this.email,
    required this.name,
    required this.role,
    required this.isEmailVerified,
    required this.isPhoneVerified,
  });

  @override
  List<Object?> get props => [userId, email, name, role, isEmailVerified, isPhoneVerified];
}

/// User unauthenticated state
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Authentication error state
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check if user is already logged in
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// User login event
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// User registration event
class AuthRegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String role;

  const AuthRegisterRequested({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.role,
  });

  @override
  List<Object?> get props => [name, email, phone, password, role];
}

/// User logout event
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Forgot password event
class AuthForgotPasswordRequested extends AuthEvent {
  final String email;

  const AuthForgotPasswordRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Reset password event
class AuthResetPasswordRequested extends AuthEvent {
  final String token;
  final String password;
  final String confirmPassword;

  const AuthResetPasswordRequested({
    required this.token,
    required this.password,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [token, password, confirmPassword];
}

/// Email verification event
class AuthVerifyEmailRequested extends AuthEvent {
  final String token;

  const AuthVerifyEmailRequested({required this.token});

  @override
  List<Object?> get props => [token];
}

/// Resend verification email event
class AuthResendVerificationRequested extends AuthEvent {
  const AuthResendVerificationRequested();
}
