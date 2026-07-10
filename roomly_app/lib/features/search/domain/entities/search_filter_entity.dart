import 'package:equatable/equatable.dart';

/// Search filter entity for property search
class SearchFilterEntity extends Equatable {
  final String? city;
  final String? area;
  final double? minRent;
  final double? maxRent;
  final String? propertyType;
  final String? roomType;
  final String? genderPreference;
  final bool? furnished;
  final bool? attachedBathroom;
  final bool? parking;
  final bool? wifi;
  final bool? petFriendly;
  final DateTime? availableFrom;
  final String? sortBy;

  const SearchFilterEntity({
    this.city,
    this.area,
    this.minRent,
    this.maxRent,
    this.propertyType,
    this.roomType,
    this.genderPreference,
    this.furnished,
    this.attachedBathroom,
    this.parking,
    this.wifi,
    this.petFriendly,
    this.availableFrom,
    this.sortBy,
  });

  factory SearchFilterEntity.empty() => const SearchFilterEntity();

  SearchFilterEntity copyWith({
    String? city,
    String? area,
    double? minRent,
    double? maxRent,
    String? propertyType,
    String? roomType,
    String? genderPreference,
    bool? furnished,
    bool? attachedBathroom,
    bool? parking,
    bool? wifi,
    bool? petFriendly,
    DateTime? availableFrom,
    String? sortBy,
  }) {
    return SearchFilterEntity(
      city: city ?? this.city,
      area: area ?? this.area,
      minRent: minRent ?? this.minRent,
      maxRent: maxRent ?? this.maxRent,
      propertyType: propertyType ?? this.propertyType,
      roomType: roomType ?? this.roomType,
      genderPreference: genderPreference ?? this.genderPreference,
      furnished: furnished ?? this.furnished,
      attachedBathroom: attachedBathroom ?? this.attachedBathroom,
      parking: parking ?? this.parking,
      wifi: wifi ?? this.wifi,
      petFriendly: petFriendly ?? this.petFriendly,
      availableFrom: availableFrom ?? this.availableFrom,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  Map<String, dynamic> toQueryMap() {
    return {
      if (city != null && city!.isNotEmpty) 'city': city,
      if (area != null && area!.isNotEmpty) 'area': area,
      if (minRent != null) 'min_rent': minRent,
      if (maxRent != null) 'max_rent': maxRent,
      if (propertyType != null && propertyType!.isNotEmpty) 'property_type': propertyType,
      if (roomType != null && roomType!.isNotEmpty) 'room_type': roomType,
      if (genderPreference != null && genderPreference!.isNotEmpty) 'gender_preference': genderPreference,
      if (furnished == true) 'furnished': '1',
      if (attachedBathroom == true) 'attached_bathroom': '1',
      if (parking == true) 'parking': '1',
      if (wifi == true) 'wifi': '1',
      if (petFriendly == true) 'pet_friendly': '1',
      if (availableFrom != null) 'available_from': availableFrom!.toIso8601String().split('T').first,
      if (sortBy != null && sortBy!.isNotEmpty) 'sort_by': sortBy,
    };
  }

  bool get hasActiveFilters {
    return city != null ||
        area != null ||
        minRent != null ||
        maxRent != null ||
        propertyType != null ||
        roomType != null ||
        genderPreference != null ||
        furnished == true ||
        attachedBathroom == true ||
        parking == true ||
        wifi == true ||
        petFriendly == true ||
        availableFrom != null;
  }

  int get activeFiltersCount {
    int count = 0;
    if (city != null && city!.isNotEmpty) count++;
    if (area != null && area!.isNotEmpty) count++;
    if (minRent != null) count++;
    if (maxRent != null) count++;
    if (propertyType != null && propertyType!.isNotEmpty) count++;
    if (roomType != null && roomType!.isNotEmpty) count++;
    if (genderPreference != null && genderPreference!.isNotEmpty) count++;
    if (furnished == true) count++;
    if (attachedBathroom == true) count++;
    if (parking == true) count++;
    if (wifi == true) count++;
    if (petFriendly == true) count++;
    if (availableFrom != null) count++;
    return count;
  }

  @override
  List<Object?> get props => [
        city,
        area,
        minRent,
        maxRent,
        propertyType,
        roomType,
        genderPreference,
        furnished,
        attachedBathroom,
        parking,
        wifi,
        petFriendly,
        availableFrom,
        sortBy,
      ];
}
