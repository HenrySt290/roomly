import '../entities/property_entity.dart';

/// Data model for Property
/// Implements serialization/deserialization for API communication
class PropertyModel extends PropertyEntity {
  const PropertyModel({
    required super.id,
    required super.title,
    required super.slug,
    required super.description,
    required super.rent,
    required super.deposit,
    required super.propertyType,
    required super.roomType,
    required super.area,
    required super.city,
    required super.address,
    required super.latitude,
    required super.longitude,
    required super.ownerId,
    required super.status,
    required super.amenities,
    required super.rules,
    required super.isAvailable,
    required super.availableFrom,
    required super.createdAt,
    required super.updatedAt,
    this.images = const [],
    this.viewCount = 0,
    this.favouriteCount = 0,
    this.rating,
    this.reviewCount = 0,
  });

  final List<String> images;
  final int viewCount;
  final int favouriteCount;
  final double? rating;
  final int reviewCount;

  /// Factory constructor from JSON (API Response)
  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    final amenitiesData = json['amenities'] as List<dynamic>? ?? [];
    final rulesData = json['rules'] as List<dynamic>? ?? [];
    final imagesData = json['images'] as List<dynamic>? ?? [];

    return PropertyModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      rent: (json['rent'] ?? 0).toDouble(),
      deposit: (json['deposit'] ?? 0).toDouble(),
      propertyType: PropertyType.fromString(json['property_type'] ?? 'room'),
      roomType: RoomType.fromString(json['room_type'] ?? 'single'),
      area: json['area'] ?? '',
      city: json['city'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      ownerId: json['owner_id'] ?? 0,
      status: PropertyStatus.fromString(json['status'] ?? 'draft'),
      amenities: amenitiesData.map((e) => e.toString()).toList(),
      rules: rulesData.map((e) => e.toString()).toList(),
      isAvailable: json['is_available'] ?? true,
      availableFrom: json['available_from'] != null
          ? DateTime.parse(json['available_from'])
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      images: imagesData.map((e) => e.toString()).toList(),
      viewCount: json['view_count'] ?? 0,
      favouriteCount: json['favourite_count'] ?? 0,
      rating: json['rating']?.toDouble(),
      reviewCount: json['review_count'] ?? 0,
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'description': description,
      'rent': rent,
      'deposit': deposit,
      'property_type': propertyType.value,
      'room_type': roomType.value,
      'area': area,
      'city': city,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'owner_id': ownerId,
      'status': status.value,
      'amenities': amenities,
      'rules': rules,
      'is_available': isAvailable,
      'available_from': availableFrom.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'images': images,
      'view_count': viewCount,
      'favourite_count': favouriteCount,
      'rating': rating,
      'review_count': reviewCount,
    };
  }

  /// Create teaser version (for non-pass holders)
  PropertyModel toTeaser() {
    return PropertyModel(
      id: id,
      title: title,
      slug: slug,
      description: description.length > 100
          ? '${description.substring(0, 100)}...'
          : description,
      rent: rent,
      deposit: deposit,
      propertyType: propertyType,
      roomType: roomType,
      area: area,
      city: city,
      address: '', // Hidden
      latitude: 0.0, // Hidden
      longitude: 0.0, // Hidden
      ownerId: ownerId,
      status: status,
      amenities: amenities.take(3).toList(), // Show only first 3
      rules: const [], // Hidden
      isAvailable: isAvailable,
      availableFrom: availableFrom,
      createdAt: createdAt,
      updatedAt: updatedAt,
      images: images.take(1).toList(), // Show only thumbnail
      viewCount: viewCount,
      favouriteCount: favouriteCount,
      rating: rating,
      reviewCount: reviewCount,
    );
  }

  /// Copy with method for immutable updates
  PropertyModel copyWith({
    int? id,
    String? title,
    String? slug,
    String? description,
    double? rent,
    double? deposit,
    PropertyType? propertyType,
    RoomType? roomType,
    String? area,
    String? city,
    String? address,
    double? latitude,
    double? longitude,
    int? ownerId,
    PropertyStatus? status,
    List<String>? amenities,
    List<String>? rules,
    bool? isAvailable,
    DateTime? availableFrom,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? images,
    int? viewCount,
    int? favouriteCount,
    double? rating,
    int? reviewCount,
  }) {
    return PropertyModel(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      rent: rent ?? this.rent,
      deposit: deposit ?? this.deposit,
      propertyType: propertyType ?? this.propertyType,
      roomType: roomType ?? this.roomType,
      area: area ?? this.area,
      city: city ?? this.city,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      ownerId: ownerId ?? this.ownerId,
      status: status ?? this.status,
      amenities: amenities ?? this.amenities,
      rules: rules ?? this.rules,
      isAvailable: isAvailable ?? this.isAvailable,
      availableFrom: availableFrom ?? this.availableFrom,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      images: images ?? this.images,
      viewCount: viewCount ?? this.viewCount,
      favouriteCount: favouriteCount ?? this.favouriteCount,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }

  @override
  String toString() {
    return 'PropertyModel(id: $id, title: $title, rent: ₹$rent, city: $city)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PropertyModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
