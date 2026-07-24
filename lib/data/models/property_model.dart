import '../entities/property_entity.dart';

/// Data model for Property
/// Implements serialization/deserialization for API communication
class PropertyModel extends PropertyEntity {
  final double? rating;
  final int reviewCount;

  const PropertyModel({
    required super.id,
    required super.title,
    required super.slug,
    required super.description,
    required super.rent,
    required super.securityDeposit,
    required super.propertyType,
    required super.roomType,
    required super.area,
    required super.city,
    required super.address,
    required super.latitude,
    required super.longitude,
    required super.ownerId,
    super.ownerName,
    required super.images,
    required super.amenities,
    required super.rules,
    required super.availableFrom,
    required super.status,
    required super.isFurnished,
    required super.hasAttachedBathroom,
    required super.hasParking,
    required super.hasWifi,
    required super.isPetFriendly,
    super.genderPreference,
    required super.viewCount,
    required super.favouriteCount,
    required super.createdAt,
    super.updatedAt,
    super.publishedAt,
    super.occupiedAt,
    this.rating,
    this.reviewCount = 0,
  });

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
      securityDeposit: (json['security_deposit'] ?? json['deposit'] ?? 0).toDouble(),
      propertyType: PropertyType.fromString(json['property_type'] ?? 'other'),
      roomType: RoomType.fromString(json['room_type'] ?? 'single'),
      area: json['area'] ?? '',
      city: json['city'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      ownerId: json['owner_id'] ?? 0,
      ownerName: json['owner_name'],
      status: PropertyStatus.fromString(json['status'] ?? 'draft'),
      amenities: amenitiesData.map((e) => e.toString()).toList(),
      rules: rulesData.map((e) => e.toString()).toList(),
      availableFrom: json['available_from'] != null
          ? DateTime.parse(json['available_from'])
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'])
          : null,
      occupiedAt: json['occupied_at'] != null
          ? DateTime.parse(json['occupied_at'])
          : null,
      images: imagesData.map((e) => e.toString()).toList(),
      viewCount: json['view_count'] ?? 0,
      favouriteCount: json['favourite_count'] ?? 0,
      isFurnished: json['is_furnished'] ?? false,
      hasAttachedBathroom: json['has_attached_bathroom'] ?? false,
      hasParking: json['has_parking'] ?? false,
      hasWifi: json['has_wifi'] ?? false,
      isPetFriendly: json['is_pet_friendly'] ?? false,
      genderPreference: json['gender_preference'] ?? 'any',
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
      'security_deposit': securityDeposit,
      'property_type': propertyType.value,
      'room_type': roomType.value,
      'area': area,
      'city': city,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'owner_id': ownerId,
      'owner_name': ownerName,
      'status': status.value,
      'amenities': amenities,
      'rules': rules,
      'available_from': availableFrom.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'published_at': publishedAt?.toIso8601String(),
      'occupied_at': occupiedAt?.toIso8601String(),
      'images': images,
      'view_count': viewCount,
      'favourite_count': favouriteCount,
      'is_furnished': isFurnished,
      'has_attached_bathroom': hasAttachedBathroom,
      'has_parking': hasParking,
      'has_wifi': hasWifi,
      'is_pet_friendly': isPetFriendly,
      'gender_preference': genderPreference,
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
      securityDeposit: securityDeposit,
      propertyType: propertyType,
      roomType: roomType,
      area: area,
      city: city,
      address: '', // Hidden
      latitude: 0.0, // Hidden
      longitude: 0.0, // Hidden
      ownerId: ownerId,
      ownerName: null, // Hidden
      status: status,
      amenities: amenities.take(3).toList(), // Show only first 3
      rules: const [], // Hidden
      availableFrom: availableFrom,
      createdAt: createdAt,
      updatedAt: updatedAt,
      publishedAt: publishedAt,
      occupiedAt: occupiedAt,
      images: images.take(1).toList(), // Show only thumbnail
      viewCount: viewCount,
      favouriteCount: favouriteCount,
      isFurnished: isFurnished,
      hasAttachedBathroom: hasAttachedBathroom,
      hasParking: hasParking,
      hasWifi: hasWifi,
      isPetFriendly: isPetFriendly,
      genderPreference: genderPreference,
      rating: rating,
      reviewCount: reviewCount,
    );
  }

  /// Copy with method for immutable updates
  PropertyModel copyWithModel({
    int? id,
    String? title,
    String? slug,
    String? description,
    double? rent,
    double? securityDeposit,
    PropertyType? propertyType,
    RoomType? roomType,
    String? area,
    String? city,
    String? address,
    double? latitude,
    double? longitude,
    int? ownerId,
    String? ownerName,
    PropertyStatus? status,
    List<String>? amenities,
    List<String>? rules,
    bool? isFurnished,
    bool? hasAttachedBathroom,
    bool? hasParking,
    bool? hasWifi,
    bool? isPetFriendly,
    String? genderPreference,
    DateTime? availableFrom,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? publishedAt,
    DateTime? occupiedAt,
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
      securityDeposit: securityDeposit ?? this.securityDeposit,
      propertyType: propertyType ?? this.propertyType,
      roomType: roomType ?? this.roomType,
      area: area ?? this.area,
      city: city ?? this.city,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      status: status ?? this.status,
      amenities: amenities ?? this.amenities,
      rules: rules ?? this.rules,
      isFurnished: isFurnished ?? this.isFurnished,
      hasAttachedBathroom: hasAttachedBathroom ?? this.hasAttachedBathroom,
      hasParking: hasParking ?? this.hasParking,
      hasWifi: hasWifi ?? this.hasWifi,
      isPetFriendly: isPetFriendly ?? this.isPetFriendly,
      genderPreference: genderPreference ?? this.genderPreference,
      availableFrom: availableFrom ?? this.availableFrom,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      publishedAt: publishedAt ?? this.publishedAt,
      occupiedAt: occupiedAt ?? this.occupiedAt,
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
