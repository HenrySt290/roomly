import 'package:equatable/equatable.dart';

enum PropertyType {
  apartment,
  house,
  pg,
  hostel,
  villa,
  studio,
  other,
}

enum RoomType {
  single,
  double,
  shared,
  dormitory,
}

enum PropertyStatus {
  draft,
  pendingPayment,
  pendingApproval,
  published,
  occupied,
  expired,
  rejected,
  hidden,
}

class PropertyEntity extends Equatable {
  final int id;
  final String title;
  final String slug;
  final String description;
  final double rent;
  final double securityDeposit;
  final PropertyType propertyType;
  final RoomType roomType;
  final String area;
  final String city;
  final String address;
  final double latitude;
  final double longitude;
  final int ownerId;
  final String? ownerName;
  final List<String> images;
  final List<String> amenities;
  final List<String> rules;
  final DateTime availableFrom;
  final PropertyStatus status;
  final bool isFurnished;
  final bool hasAttachedBathroom;
  final bool hasParking;
  final bool hasWifi;
  final bool isPetFriendly;
  final String? genderPreference; // 'male', 'female', 'any'
  final int viewCount;
  final int favouriteCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? publishedAt;
  final DateTime? occupiedAt;

  const PropertyEntity({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.rent,
    required this.securityDeposit,
    required this.propertyType,
    required this.roomType,
    required this.area,
    required this.city,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.ownerId,
    this.ownerName,
    required this.images,
    required this.amenities,
    required this.rules,
    required this.availableFrom,
    required this.status,
    required this.isFurnished,
    required this.hasAttachedBathroom,
    required this.hasParking,
    required this.hasWifi,
    required this.isPetFriendly,
    this.genderPreference,
    required this.viewCount,
    required this.favouriteCount,
    required this.createdAt,
    this.updatedAt,
    this.publishedAt,
    this.occupiedAt,
  });

  factory PropertyEntity.fromJson(Map<String, dynamic> json) {
    return PropertyEntity(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      rent: (json['rent'] ?? 0).toDouble(),
      securityDeposit: (json['security_deposit'] ?? 0).toDouble(),
      propertyType: PropertyType.values.firstWhere(
        (e) => e.name == json['property_type'],
        orElse: () => PropertyType.other,
      ),
      roomType: RoomType.values.firstWhere(
        (e) => e.name == json['room_type'],
        orElse: () => RoomType.single,
      ),
      area: json['area'] ?? '',
      city: json['city'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      ownerId: json['owner_id'] ?? 0,
      ownerName: json['owner_name'],
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      amenities: json['amenities'] != null ? List<String>.from(json['amenities']) : [],
      rules: json['rules'] != null ? List<String>.from(json['rules']) : [],
      availableFrom: DateTime.parse(json['available_from']),
      status: PropertyStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PropertyStatus.draft,
      ),
      isFurnished: json['is_furnished'] ?? false,
      hasAttachedBathroom: json['has_attached_bathroom'] ?? false,
      hasParking: json['has_parking'] ?? false,
      hasWifi: json['has_wifi'] ?? false,
      isPetFriendly: json['is_pet_friendly'] ?? false,
      genderPreference: json['gender_preference'],
      viewCount: json['view_count'] ?? 0,
      favouriteCount: json['favourite_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      publishedAt: json['published_at'] != null ? DateTime.parse(json['published_at']) : null,
      occupiedAt: json['occupied_at'] != null ? DateTime.parse(json['occupied_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'description': description,
      'rent': rent,
      'security_deposit': securityDeposit,
      'property_type': propertyType.name,
      'room_type': roomType.name,
      'area': area,
      'city': city,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'owner_id': ownerId,
      'owner_name': ownerName,
      'images': images,
      'amenities': amenities,
      'rules': rules,
      'available_from': availableFrom.toIso8601String(),
      'status': status.name,
      'is_furnished': isFurnished,
      'has_attached_bathroom': hasAttachedBathroom,
      'has_parking': hasParking,
      'has_wifi': hasWifi,
      'is_pet_friendly': isPetFriendly,
      'gender_preference': genderPreference,
      'view_count': viewCount,
      'favourite_count': favouriteCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'published_at': publishedAt?.toIso8601String(),
      'occupied_at': occupiedAt?.toIso8601String(),
    };
  }

  bool get isPublished => status == PropertyStatus.published;
  bool get isOccupied => status == PropertyStatus.occupied;
  bool get isAvailable => status == PropertyStatus.published;

  @override
  List<Object?> get props => [
        id,
        title,
        slug,
        description,
        rent,
        securityDeposit,
        propertyType,
        roomType,
        area,
        city,
        address,
        latitude,
        longitude,
        ownerId,
        ownerName,
        images,
        amenities,
        rules,
        availableFrom,
        status,
        isFurnished,
        hasAttachedBathroom,
        hasParking,
        hasWifi,
        isPetFriendly,
        genderPreference,
        viewCount,
        favouriteCount,
        createdAt,
        updatedAt,
        publishedAt,
        occupiedAt,
      ];

  PropertyEntity copyWith({
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
    List<String>? images,
    List<String>? amenities,
    List<String>? rules,
    DateTime? availableFrom,
    PropertyStatus? status,
    bool? isFurnished,
    bool? hasAttachedBathroom,
    bool? hasParking,
    bool? hasWifi,
    bool? isPetFriendly,
    String? genderPreference,
    int? viewCount,
    int? favouriteCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? publishedAt,
    DateTime? occupiedAt,
  }) {
    return PropertyEntity(
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
      images: images ?? this.images,
      amenities: amenities ?? this.amenities,
      rules: rules ?? this.rules,
      availableFrom: availableFrom ?? this.availableFrom,
      status: status ?? this.status,
      isFurnished: isFurnished ?? this.isFurnished,
      hasAttachedBathroom: hasAttachedBathroom ?? this.hasAttachedBathroom,
      hasParking: hasParking ?? this.hasParking,
      hasWifi: hasWifi ?? this.hasWifi,
      isPetFriendly: isPetFriendly ?? this.isPetFriendly,
      genderPreference: genderPreference ?? this.genderPreference,
      viewCount: viewCount ?? this.viewCount,
      favouriteCount: favouriteCount ?? this.favouriteCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      publishedAt: publishedAt ?? this.publishedAt,
      occupiedAt: occupiedAt ?? this.occupiedAt,
    );
  }
}
