// lib/features/tourist/models/tourist_public_profile_model.dart

class TouristPublicProfileModel {
  final String id;
  final String fullName;
  final String profilePic;
  final String country;
  final String bio;
  final String travelStyle;
  final String memberSince;
  final int    toursCompleted;
  final double avgRating;
  final int    reviewCount;
  final bool   isVerified;
  final List<TouristLanguage> languages;
  final List<String>          interests;
  final List<TouristReview>   reviews;
  final Map<int, int>         ratingBreakdown; // {5: 3, 4: 1, ...}

  const TouristPublicProfileModel({
    required this.id,
    required this.fullName,
    required this.profilePic,
    required this.country,
    required this.bio,
    required this.travelStyle,
    required this.memberSince,
    required this.toursCompleted,
    required this.avgRating,
    required this.reviewCount,
    required this.isVerified,
    required this.languages,
    required this.interests,
    required this.reviews,
    required this.ratingBreakdown,
  });

  factory TouristPublicProfileModel.fromJson(Map<String, dynamic> json) {
    // ── Languages ──
    final rawLangs = json['languages'] as List<dynamic>? ?? [];
    final languages = rawLangs
        .map((l) => TouristLanguage.fromJson(l as Map<String, dynamic>))
        .toList();

    // ── Interests ──
    final rawInterests = json['interests'] as List<dynamic>? ?? [];
    final interests = rawInterests
        .map((i) => (i is Map) ? (i['name'] as String? ?? '') : i.toString())
        .where((s) => s.isNotEmpty)
        .toList();

    // ── Reviews ──
    final rawReviews = json['reviews'] as List<dynamic>? ?? [];
    final reviews = rawReviews
        .map((r) => TouristReview.fromJson(r as Map<String, dynamic>))
        .toList();

    // ── Rating breakdown ──
    final rawBreakdown =
        json['rating_breakdown'] as Map<String, dynamic>? ?? {};
    final breakdown = <int, int>{};
    rawBreakdown.forEach((k, v) {
      breakdown[int.tryParse(k) ?? 0] = (v as num?)?.toInt() ?? 0;
    });

    return TouristPublicProfileModel(
      id:             json['id'] as String? ?? '',
      fullName:       json['full_name'] as String?  ?? '',
      profilePic:     json['profile_pic'] as String? ?? '',
      country:        json['country'] as String?    ?? '',
      bio:            json['profile_bio'] as String? ?? '',
      travelStyle:    json['travel_style'] as String? ?? '',
      memberSince:    _fmtMemberSince(json['member_since'] as String? ?? ''),
      toursCompleted: (json['tours_completed'] as num?)?.toInt() ?? 0,
      avgRating:      (json['avg_rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount:    (json['review_count'] as num?)?.toInt() ?? 0,
      isVerified:     json['is_verified'] as bool? ?? false,
      languages:      languages,
      interests:      interests,
      reviews:        reviews,
      ratingBreakdown: breakdown,
    );
  }

  static String _fmtMemberSince(String raw) {
    if (raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return raw;
    }
  }
}

class TouristLanguage {
  final String name;
  final bool   isNative;

  const TouristLanguage({required this.name, required this.isNative});

  factory TouristLanguage.fromJson(Map<String, dynamic> json) =>
      TouristLanguage(
        name:     json['name'] as String? ?? '',
        isNative: json['is_native'] as bool? ?? false,
      );
}

class TouristReview {
  final String reviewerName;
  final String reviewerPhoto;
  final int    rating;
  final String comment;
  final String date;

  const TouristReview({
    required this.reviewerName,
    required this.reviewerPhoto,
    required this.rating,
    required this.comment,
    required this.date,
  });

  factory TouristReview.fromJson(Map<String, dynamic> json) {
    String fmtDate(String raw) {
      try {
        final dt = DateTime.parse(raw);
        const m = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
      } catch (_) {
        return raw;
      }
    }

    return TouristReview(
      reviewerName:  json['reviewer_name']  as String? ?? 'Guide',
      reviewerPhoto: json['reviewer_photo'] as String? ?? '',
      rating:        (json['rating'] as num?)?.toInt() ?? 5,
      comment:       json['comment'] as String? ?? '',
      date:          fmtDate(json['created_at'] as String? ?? ''),
    );
  }
}