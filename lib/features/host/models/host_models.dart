// lib/features/host/models/host_models.dart

class HostProfile {
  final String id;
  final String userProfileId;
  final String firstName;
  final String lastName;
  final String fullName;
  final String phoneNumber;
  final String dateOfBirth;
  final String gender;
  final String country;
  final String profilePic;
  final String profileBio;
  final String verificationStatus;
  final bool isVerified;
  final int noOfStaysOwned;
  final int totalCompletedBookings;
  final double avgRating;
  final double totalEarned;
  final String memberSince;
  final List<UserLanguage> languages;

  HostProfile({
    required this.id,
    required this.userProfileId,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.gender,
    required this.country,
    required this.profilePic,
    required this.profileBio,
    required this.verificationStatus,
    required this.isVerified,
    required this.noOfStaysOwned,
    required this.totalCompletedBookings,
    required this.avgRating,
    required this.totalEarned,
    required this.memberSince,
    required this.languages,
  });

  factory HostProfile.fromJson(Map<String, dynamic> json) {
    return HostProfile(
      id: json['id'] ?? '',
      userProfileId: json['user_profile_id'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      fullName: json['full_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      dateOfBirth: json['date_of_birth'] ?? '',
      gender: json['gender'] ?? '',
      country: json['country'] ?? '',
      profilePic: json['profile_pic'] ?? '',
      profileBio: json['profile_bio'] ?? '',
      verificationStatus: json['verification_status'] ?? 'pending',
      isVerified: json['is_verified'] ?? false,
      noOfStaysOwned: json['no_of_stays_owned'] ?? 0,
      totalCompletedBookings: json['total_completed_bookings'] ?? 0,
      avgRating: (json['avg_rating'] ?? 0).toDouble(),
      totalEarned: (json['total_earned'] ?? 0).toDouble(),
      memberSince: json['member_since'] ?? '',
      languages: (json['languages'] as List? ?? [])
          .map((l) => UserLanguage.fromJson(l))
          .toList(),
    );
  }
}

class UserLanguage {
  final String id;
  final String languageId;
  final String name;
  final String code;
  String proficiency;
  bool isNative;

  UserLanguage({
    required this.id,
    required this.languageId,
    required this.name,
    required this.code,
    required this.proficiency,
    required this.isNative,
  });

  factory UserLanguage.fromJson(Map<String, dynamic> json) {
    return UserLanguage(
      id: json['id'] ?? '',
      languageId: json['language_id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      proficiency: json['proficiency'] ?? 'native',
      isNative: json['is_native'] ?? false,
    );
  }
}

class Stay {
  final String id;
  final String name;
  final String type;
  final String? coverPhoto;
  final String cityName;
  final String verificationStatus;
  final bool isActive;
  final int roomCount;
  final int maxGuests;
  final double pricePerNight;
  final double avgRating;
  final int reviewCount;

  Stay({
    required this.id,
    required this.name,
    required this.type,
    this.coverPhoto,
    required this.cityName,
    required this.verificationStatus,
    required this.isActive,
    required this.roomCount,
    required this.maxGuests,
    required this.pricePerNight,
    required this.avgRating,
    required this.reviewCount,
  });

  factory Stay.fromJson(Map<String, dynamic> json) {
    return Stay(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unnamed Stay',
      type: json['type'] ?? '',
      coverPhoto: json['cover_photo'],
      cityName: json['city_name'] ?? '',
      verificationStatus: json['verification_status'] ?? 'pending',
      isActive: json['is_active'] ?? false,
      roomCount: json['room_count'] ?? 0,
      maxGuests: json['max_guests'] ?? 0,
      pricePerNight: (json['price_per_night'] ?? 0).toDouble(),
      avgRating: (json['avg_rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
    );
  }
}

class StayDetail {
  final String id;
  final String name;
  final String type;
  final String description;
  final String houseNo;
  final String street;
  final String town;
  final String? cityId;
  final String cityName;
  final int? postalCode;
  final double? latitude;
  final double? longitude;
  final int roomCount;
  final bool roomAvailable;
  final int maxGuests;
  final double pricePerNight;
  final double priceEntirePlace;
  final bool entirePlaceIsAvailable;
  final double pricePerExtraGuest;
  final int bathroomCount;
  final bool sharedBathrooms;
  final double pricePerHalfday;
  final bool halfdayAvailable;
  final String standardCheckinTime;
  final String standardCheckoutTime;
  final bool isActive;
  final String verificationStatus;
  final List<StayPhoto> photos;
  final List<String> facilityIds;
  final List<Facility> facilities;

  StayDetail({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.houseNo,
    required this.street,
    required this.town,
    this.cityId,
    required this.cityName,
    this.postalCode,
    this.latitude,
    this.longitude,
    required this.roomCount,
    required this.roomAvailable,
    required this.maxGuests,
    required this.pricePerNight,
    required this.priceEntirePlace,
    required this.entirePlaceIsAvailable,
    required this.pricePerExtraGuest,
    required this.bathroomCount,
    required this.sharedBathrooms,
    required this.pricePerHalfday,
    required this.halfdayAvailable,
    required this.standardCheckinTime,
    required this.standardCheckoutTime,
    required this.isActive,
    required this.verificationStatus,
    required this.photos,
    required this.facilityIds,
    required this.facilities,
  });

  factory StayDetail.fromJson(Map<String, dynamic> json) {
    return StayDetail(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      houseNo: json['house_no'] ?? '',
      street: json['street'] ?? '',
      town: json['town'] ?? '',
      cityId: json['city_id'],
      cityName: json['city_name'] ?? '',
      postalCode: json['postal_code'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      roomCount: json['room_count'] ?? 0,
      roomAvailable: json['room_available'] ?? true,
      maxGuests: json['max_guests'] ?? 0,
      pricePerNight: (json['price_per_night'] ?? 0).toDouble(),
      priceEntirePlace: (json['price_entire_place'] ?? 0).toDouble(),
      entirePlaceIsAvailable: json['entire_place_is_available'] ?? false,
      pricePerExtraGuest: (json['price_per_extra_guest'] ?? 0).toDouble(),
      bathroomCount: json['bathroom_count'] ?? 0,
      sharedBathrooms: json['shared_bathrooms'] ?? false,
      pricePerHalfday: (json['price_per_halfday'] ?? 0).toDouble(),
      halfdayAvailable: json['halfday_available'] ?? false,
      standardCheckinTime: json['standard_checkin_time'] ?? '14:00:00',
      standardCheckoutTime: json['standard_checkout_time'] ?? '11:00:00',
      isActive: json['is_active'] ?? false,
      verificationStatus: json['verification_status'] ?? 'pending',
      photos: (json['photos'] as List? ?? [])
          .map((p) => StayPhoto.fromJson(p))
          .toList(),
      facilityIds: List<String>.from(json['facility_ids'] ?? []),
      facilities: (json['facilities'] as List? ?? [])
          .map((f) => Facility.fromJson(f))
          .toList(),
    );
  }
}

class StayPhoto {
  final String id;
  final String url;
  final int order;

  StayPhoto({
    required this.id,
    required this.url,
    required this.order,
  });

  factory StayPhoto.fromJson(Map<String, dynamic> json) {
    return StayPhoto(
      id: json['id'] ?? '',
      url: json['photo_url'] ?? '',
      order: json['position'] ?? 0,
    );
  }
}

class Facility {
  final String id;
  final String name;
  final String? description;
  final double? addonPrice;
  final String? specialNote;

  Facility({
    required this.id,
    required this.name,
    this.description,
    this.addonPrice,
    this.specialNote,
  });

  factory Facility.fromJson(Map<String, dynamic> json) {
    return Facility(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      addonPrice: json['addon_price']?.toDouble(),
      specialNote: json['special_note'],
    );
  }
}

class Language {
  final String id;
  final String name;
  final String code;

  Language({
    required this.id,
    required this.name,
    required this.code,
  });

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
    );
  }
}

class City {
  final String id;
  final String name;

  City({
    required this.id,
    required this.name,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class HostDashboard {
  final String hostName;
  final String? profilePic;
  final String verificationStatus;
  final double avgRating;
  final int totalStays;
  final int activeStays;
  final int pendingStays;
  final double totalEarned;
  final int totalBookings;
  final List<Stay> stays;

  HostDashboard({
    required this.hostName,
    this.profilePic,
    required this.verificationStatus,
    required this.avgRating,
    required this.totalStays,
    required this.activeStays,
    required this.pendingStays,
    required this.totalEarned,
    required this.totalBookings,
    required this.stays,
  });

  factory HostDashboard.fromJson(Map<String, dynamic> json) {
    return HostDashboard(
      hostName: json['host_name'] ?? '',
      profilePic: json['profile_pic'],
      verificationStatus: json['verification_status'] ?? 'pending',
      avgRating: (json['avg_rating'] ?? 0).toDouble(),
      totalStays: json['total_stays'] ?? 0,
      activeStays: json['active_stays'] ?? 0,
      pendingStays: json['pending_stays'] ?? 0,
      totalEarned: (json['total_earned'] ?? 0).toDouble(),
      totalBookings: json['total_bookings'] ?? 0,
      stays: (json['stays'] as List? ?? [])
          .map((s) => Stay.fromJson(s))
          .toList(),
    );
  }
}