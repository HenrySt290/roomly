import 'package:equatable/equatable.dart';

enum PropertyType {
  apartment('apartment'),
  house('house'),
  pg('pg'),
  hostel('hostel'),
  villa('villa'),
  studio('studio'),
  other('other');

  final String value;
  const PropertyType(this.value);

  static PropertyType fromString(String value) {
    return PropertyType.values.firstWhere(
      (e) => e.value == value.toLowerCase(),
      orElse: () => PropertyType.other,
    );
  }
}

enum RoomType {
  single('single'),
  double('double'),
  shared('shared'),
  dormitory('dormitory'),
  r1rk('1rk'),
  bhk1('1bhk'),
  bhk2('2bhk'),
  bhk3('3bhk'),
  bhk4('4bhk');

  final String value;
  const RoomType(this.value);

  static RoomType fromString(String value) {
    return RoomType.values.firstWhere(
      (e) => e.value == value.toLowerCase(),
      orElse: () => RoomType.single,
    );
  }
}

enum PropertyStatus {
  draft('draft'),
  pendingPayment('pending_payment'),
  pendingApproval('pending_approval'),
  published('published'),
  occupied('occupied'),
  expired('expired'),
  rejected('rejected'),
  hidden('hidden');

  final String value;
  const PropertyStatus(this.value);

  static PropertyStatus fromString(String value) {
    return PropertyStatus.values.firstWhere(
      (e) => e.value == value.toLowerCase(),
      orElse: () => PropertyStatus.draft,
    );
  }
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
