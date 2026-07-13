import '../entities/access_pass_entity.dart';

/// Data model for Access Pass
/// Implements serialization/deserialization for API communication
class AccessPassModel extends AccessPassEntity {
  const AccessPassModel({
    required super.id,
    required super.userId,
    required super.isActive,
    required super.expiresAt,
    required super.purchasedAt,
    this.transactionId,
    this.paymentStatus = 'pending',
  });

  final int? transactionId;
  final String paymentStatus;

  /// Factory constructor from JSON (API Response)
  factory AccessPassModel.fromJson(Map<String, dynamic> json) {
    return AccessPassModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      isActive: json['is_active'] ?? false,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : DateTime.now().add(const Duration(hours: 24)),
      purchasedAt: json['purchased_at'] != null
          ? DateTime.parse(json['purchased_at'])
          : DateTime.now(),
      transactionId: json['transaction_id'],
      paymentStatus: json['payment_status'] ?? 'pending',
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'is_active': isActive,
      'expires_at': expiresAt.toIso8601String(),
      'purchased_at': purchasedAt.toIso8601String(),
      'transaction_id': transactionId,
      'payment_status': paymentStatus,
    };
  }

  /// Check if pass is currently valid
  bool get isValid => isActive && DateTime.now().isBefore(expiresAt);

  /// Get remaining time in hours
  double get remainingHours {
    if (!isValid) return 0;
    final difference = expiresAt.difference(DateTime.now());
    return difference.inHours + (difference.inMinutes % 60) / 60;
  }

  /// Get remaining time as formatted string
  String get remainingTimeString {
    if (!isValid) return 'Expired';
    final hours = remainingHours;
    if (hours >= 24) {
      final days = (hours / 24).floor();
      return '$days day${days > 1 ? 's' : ''} remaining';
    } else if (hours >= 1) {
      final hrs = hours.floor();
      final mins = ((hours - hrs) * 60).floor();
      return '$hrs hr${hrs > 1 ? 's' : ''} $mins min${mins > 1 ? 's' : ''}';
    } else {
      final mins = (hours * 60).floor();
      return '$mins min${mins > 1 ? 's' : ''}';
    }
  }

  /// Copy with method for immutable updates
  AccessPassModel copyWith({
    int? id,
    int? userId,
    bool? isActive,
    DateTime? expiresAt,
    DateTime? purchasedAt,
    int? transactionId,
    String? paymentStatus,
  }) {
    return AccessPassModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      isActive: isActive ?? this.isActive,
      expiresAt: expiresAt ?? this.expiresAt,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      transactionId: transactionId ?? this.transactionId,
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }

  /// Create expired pass
  factory AccessPassModel.expired(int userId) {
    final now = DateTime.now();
    return AccessPassModel(
      id: 0,
      userId: userId,
      isActive: false,
      expiresAt: now.subtract(const Duration(hours: 1)),
      purchasedAt: now.subtract(const Duration(days: 1)),
    );
  }

  @override
  String toString() {
    return 'AccessPassModel(id: $id, userId: $userId, isActive: $isActive, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AccessPassModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
