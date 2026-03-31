// lib/features/guide/models/guide_model.dart

class GuideLanguage {
  /// UserLanguage bridge-table PK — used for DELETE / PATCH requests.
  final String id;
  /// Language master-table PK — kept for reference / display only.
  final String languageId;
  final String name;
  final String code;
  final String proficiency;
  final bool   isNative;

  const GuideLanguage({
    required this.id,
    required this.languageId,
    required this.name,
    required this.code,
    required this.proficiency,
    required this.isNative,
  });

  factory GuideLanguage.fromJson(Map<String, dynamic> j) => GuideLanguage(
    id:          j['id']?.toString()          ?? '',          // UserLanguage.id
    languageId:  j['language_id']?.toString() ?? '',          // Language.id
    name:        j['name']?.toString()        ?? '',
    code:        j['code']?.toString()        ?? '',
    proficiency: j['proficiency']?.toString() ?? 'native',
    isNative:    j['is_native']               ?? false,
  );
}

class GuideInterest {
  final String id;
  final String name;
  final String category;

  const GuideInterest({
    required this.id,
    required this.name,
    required this.category,
  });

  factory GuideInterest.fromJson(Map<String, dynamic> j) => GuideInterest(
    id:       j['id']?.toString()       ?? '',
    name:     j['name']?.toString()     ?? '',
    category: j['category']?.toString() ?? '',
  );
}

class GuideCity {
  final String id;
  final String name;
  final String country;

  const GuideCity({
    required this.id,
    required this.name,
    required this.country,
  });

  factory GuideCity.fromJson(Map<String, dynamic> j) => GuideCity(
    id:      j['id']?.toString()      ?? '',
    name:    j['name']?.toString()    ?? '',
    country: j['country']?.toString() ?? '',
  );
}

class GuideAvailabilitySlot {
  final String id;
  final String date;
  final String startTime;
  final String endTime;
  final bool   isBooked;

  const GuideAvailabilitySlot({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.isBooked,
  });

  factory GuideAvailabilitySlot.fromJson(Map<String, dynamic> j) =>
      GuideAvailabilitySlot(
        id:        j['id']?.toString()         ?? '',
        date:      j['date']?.toString()       ?? '',
        startTime: j['start_time']?.toString() ?? '',
        endTime:   j['end_time']?.toString()   ?? '',
        isBooked:  j['is_booked']              ?? false,
      );

  String get timeLabel {
    String fmt(String t) {
      try {
        final p = t.split(':');
        int h = int.parse(p[0]);
        final m = p[1].padLeft(2, '0');
        final ap = h >= 12 ? 'PM' : 'AM';
        if (h == 0) h = 12; else if (h > 12) h -= 12;
        return '$h:$m $ap';
      } catch (_) { return t; }
    }
    return '${fmt(startTime)} – ${fmt(endTime)}';
  }
}

class GuideReview {
  final String id;
  final double rating;
  final String review;
  final String touristName;
  final String touristPhoto;
  final String createdAt;

  const GuideReview({
    required this.id,
    required this.rating,
    required this.review,
    required this.touristName,
    required this.touristPhoto,
    required this.createdAt,
  });

  factory GuideReview.fromJson(Map<String, dynamic> j) => GuideReview(
    id:          j['id']?.toString()           ?? '',
    rating:      (j['rating'] ?? 0).toDouble(),
    review:      j['review']?.toString()       ?? '',
    touristName: j['tourist_name']?.toString() ?? 'Tourist',
    touristPhoto:j['tourist_photo']?.toString() ?? '',
    createdAt:   j['created_at']?.toString()   ?? '',
  );
}

class GuideStats {
  final int    totalBookings;
  final double totalEarnings;
  final double totalTips;
  final double avgRating;
  final int    reviewCount;
  final double responseRate;

  const GuideStats({
    required this.totalBookings,
    required this.totalEarnings,
    required this.totalTips,
    required this.avgRating,
    required this.reviewCount,
    required this.responseRate,
  });

  factory GuideStats.fromJson(Map<String, dynamic> j) => GuideStats(
    totalBookings:  j['total_bookings']  ?? 0,
    totalEarnings:  (j['total_earnings'] ?? 0).toDouble(),
    totalTips:      (j['total_tips']     ?? 0).toDouble(),
    avgRating:      (j['avg_rating']     ?? 0).toDouble(),
    reviewCount:    j['review_count']    ?? 0,
    responseRate:   (j['response_rate']  ?? 0).toDouble(),
  );
}

// ── Main model ────────────────────────────────────────────────────────────────

class GuideModel {
  // Guide profile IDs
  final String guideProfileId;
  final String userProfileId;
  final String authUserId;

  // Basic info
  final String fullName;
  final String profilePic;
  final String profileBio;
  final String phoneNumber;
  final String gender;
  final String country;
  final String memberSince;

  // Guide-specific
  final GuideCity?  city;
  final int?        experienceYears;
  final String      education;
  final double      ratePerHour;
  final double      avgRating;
  final double      bookingResponseRate;
  final int         totalCompleted;
  final double      totalEarned;
  final bool        isAvailable;
  final bool        isSLTDAVerified;
  final String      verificationStatus;
  final bool        isComplete;

  // Related
  final List<GuideLanguage>         languages;
  final List<GuideInterest>         interests;
  final List<Map<String, dynamic>>  gallery;
  final List<GuideAvailabilitySlot> availability;
  final List<GuideReview>           reviews;
  final GuideStats                  stats;

  const GuideModel({
    required this.guideProfileId,
    required this.userProfileId,
    required this.authUserId,
    required this.fullName,
    required this.profilePic,
    required this.profileBio,
    required this.phoneNumber,
    required this.gender,
    required this.country,
    required this.memberSince,
    this.city,
    this.experienceYears,
    required this.education,
    required this.ratePerHour,
    required this.avgRating,
    required this.bookingResponseRate,
    required this.totalCompleted,
    required this.totalEarned,
    required this.isAvailable,
    required this.isSLTDAVerified,
    required this.verificationStatus,
    required this.isComplete,
    required this.languages,
    required this.interests,
    required this.gallery,
    required this.availability,
    required this.reviews,
    required this.stats,
  });

  factory GuideModel.fromJson(Map<String, dynamic> j) {
    // Parse availability list → GuideAvailabilitySlot
    final rawAvail = j['availability'];
    List<GuideAvailabilitySlot> avail = [];
    if (rawAvail is List) {
      avail = rawAvail
          .map((e) => GuideAvailabilitySlot.fromJson(
          e is Map<String, dynamic> ? e : {}))
          .toList();
    }

    return GuideModel(
      guideProfileId:      j['id']?.toString()                   ?? '',
      userProfileId:       j['user_profile_id']?.toString()      ?? '',
      authUserId:          j['auth_user_id']?.toString()         ?? '',
      fullName:            j['full_name']?.toString()            ?? '',
      profilePic:          j['profile_pic']?.toString()          ?? '',
      profileBio:          j['profile_bio']?.toString()          ?? '',
      phoneNumber:         j['phone_number']?.toString()         ?? '',
      gender:              j['gender']?.toString()               ?? '',
      country:             j['country']?.toString()              ?? '',
      memberSince:         j['member_since']?.toString()         ?? '',
      city:                j['city'] != null
          ? GuideCity.fromJson(j['city'] as Map<String, dynamic>)
          : null,
      experienceYears:     j['experience_years'] as int?,
      education:           j['education']?.toString()            ?? '',
      ratePerHour:         (j['rate_per_hour']          ?? 0).toDouble(),
      avgRating:           (j['avg_rating']             ?? 0).toDouble(),
      bookingResponseRate: (j['booking_response_rate']  ?? 0).toDouble(),
      totalCompleted:      j['total_completed_bookings']         ?? 0,
      totalEarned:         (j['total_earned']           ?? 0).toDouble(),
      isAvailable:         j['is_available']                     ?? true,
      isSLTDAVerified:     j['is_SLTDA_verified']                ?? false,
      verificationStatus:  j['verification_status']?.toString()  ?? 'pending',
      isComplete:          j['is_complete']                      ?? false,
      languages:  (j['languages'] as List? ?? [])
          .map((e) => GuideLanguage.fromJson(e as Map<String, dynamic>))
          .toList(),
      interests:  (j['interests'] as List? ?? [])
          .map((e) => GuideInterest.fromJson(e as Map<String, dynamic>))
          .toList(),
      gallery:    List<Map<String, dynamic>>.from(
          (j['gallery'] as List? ?? [])
              .map((e) => Map<String, dynamic>.from(e as Map))),
      availability: avail,
      reviews:    (j['reviews'] as List? ?? [])
          .map((e) => GuideReview.fromJson(e as Map<String, dynamic>))
          .toList(),
      stats:      j['stats'] != null
          ? GuideStats.fromJson(j['stats'] as Map<String, dynamic>)
          : const GuideStats(
        totalBookings:  0,
        totalEarnings:  0,
        totalTips:      0,
        avgRating:      0,
        reviewCount:    0,
        responseRate:   0,
      ),
    );
  }

  // Copy with for immutable updates
  GuideModel copyWith({
    bool? isAvailable,
    double? avgRating,
    List<GuideLanguage>? languages,
  }) => GuideModel(
    guideProfileId:      guideProfileId,
    userProfileId:       userProfileId,
    authUserId:          authUserId,
    fullName:            fullName,
    profilePic:          profilePic,
    profileBio:          profileBio,
    phoneNumber:         phoneNumber,
    gender:              gender,
    country:             country,
    memberSince:         memberSince,
    city:                city,
    experienceYears:     experienceYears,
    education:           education,
    ratePerHour:         ratePerHour,
    avgRating:           avgRating ?? this.avgRating,
    bookingResponseRate: bookingResponseRate,
    totalCompleted:      totalCompleted,
    totalEarned:         totalEarned,
    isAvailable:         isAvailable ?? this.isAvailable,
    isSLTDAVerified:     isSLTDAVerified,
    verificationStatus:  verificationStatus,
    isComplete:          isComplete,
    languages:           languages  ?? this.languages,
    interests:           interests,
    gallery:             gallery,
    availability:        availability,
    reviews:             reviews,
    stats:               stats,
  );
}