// lib/features/tourist/models/guide_search_result.dart

class GuideSearchResult {
  final String guideProfileId;
  final String userProfileId;
  final String fullName;
  final String profilePic;
  final String profileBio;
  final String cityId;
  final String cityName;
  final int? experienceYears;
  final String education;
  final double ratePerHour;
  final double avgRating;
  final int totalCompletedBookings;
  final bool isSltdaVerified;
  final List<GuideLanguage> languages;
  final List<GuideSpecialty> specialties;
  final List<AvailableSlot> availableSlots;
  final List<ReviewPreview> reviewsPreview;

  GuideSearchResult({
    required this.guideProfileId,
    required this.userProfileId,
    required this.fullName,
    required this.profilePic,
    required this.profileBio,
    required this.cityId,
    required this.cityName,
    this.experienceYears,
    required this.education,
    required this.ratePerHour,
    required this.avgRating,
    required this.totalCompletedBookings,
    required this.isSltdaVerified,
    required this.languages,
    required this.specialties,
    required this.availableSlots,
    required this.reviewsPreview,
  });

  factory GuideSearchResult.fromJson(Map<String, dynamic> json) {
    return GuideSearchResult(
      guideProfileId: json['guide_profile_id'] ?? '',
      userProfileId: json['user_profile_id'] ?? '',
      fullName: json['full_name'] ?? '',
      profilePic: json['profile_pic'] ?? '',
      profileBio: json['profile_bio'] ?? '',
      cityId: json['city_id'] ?? '',
      cityName: json['city_name'] ?? '',
      experienceYears: json['experience_years'],
      education: json['education'] ?? '',
      ratePerHour: (json['rate_per_hour'] ?? 0).toDouble(),
      avgRating: (json['avg_rating'] ?? 0).toDouble(),
      totalCompletedBookings: json['total_completed_bookings'] ?? 0,
      isSltdaVerified: json['is_SLTDA_verified'] ?? false,
      languages: (json['languages'] as List? ?? [])
          .map((l) => GuideLanguage.fromJson(l))
          .toList(),
      specialties: (json['specialties'] as List? ?? [])
          .map((s) => GuideSpecialty.fromJson(s))
          .toList(),
      availableSlots: (json['available_slots'] as List? ?? [])
          .map((s) => AvailableSlot.fromJson(s))
          .toList(),
      reviewsPreview: (json['reviews_preview'] as List? ?? [])
          .map((r) => ReviewPreview.fromJson(r))
          .toList(),
    );
  }
}

class GuideLanguage {
  final String id;
  final String name;
  final String code;
  final String proficiency;
  final bool isNative;

  GuideLanguage({
    required this.id,
    required this.name,
    required this.code,
    required this.proficiency,
    this.isNative = false,
  });

  factory GuideLanguage.fromJson(Map<String, dynamic> json) => GuideLanguage(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    code: json['code'] ?? '',
    proficiency: json['proficiency'] ?? '',
    isNative: json['is_native'] ?? false,
  );
}

class GuideSpecialty {
  final String id;
  final String name;
  final String category;

  GuideSpecialty({required this.id, required this.name, required this.category});

  factory GuideSpecialty.fromJson(Map<String, dynamic> json) => GuideSpecialty(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    category: json['category'] ?? '',
  );
}

class AvailableSlot {
  final String startTime;
  final String endTime;

  AvailableSlot({required this.startTime, required this.endTime});

  factory AvailableSlot.fromJson(Map<String, dynamic> json) => AvailableSlot(
    startTime: json['start_time'] ?? '',
    endTime: json['end_time'] ?? '',
  );
}

class ReviewPreview {
  final double rating;
  final String review;
  final String touristName;
  final String createdAt;

  ReviewPreview({
    required this.rating,
    required this.review,
    required this.touristName,
    required this.createdAt,
  });

  factory ReviewPreview.fromJson(Map<String, dynamic> json) => ReviewPreview(
    rating: (json['rating'] ?? 0).toDouble(),
    review: json['review'] ?? '',
    touristName: json['tourist_name'] ?? '',
    createdAt: json['created_at'] ?? '',
  );
}