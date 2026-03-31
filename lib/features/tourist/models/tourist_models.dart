// tourist_models.dart  (updated)

class TouristProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String profilePic;
  final String profileBio;
  final String phoneNumber;
  final String dateOfBirth;
  final String gender;
  final String country;
  final String userRole;
  final bool isComplete;
  final String travelStyle;
  final String passportNumber;
  final String emergencyContactName;
  final String emergencyContactRelation;
  final String emergencyContactNumber;

  const TouristProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.profilePic,
    required this.profileBio,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.gender,
    required this.country,
    required this.userRole,
    required this.isComplete,
    required this.travelStyle,
    required this.passportNumber,
    required this.emergencyContactName,
    required this.emergencyContactRelation,
    required this.emergencyContactNumber,
  });

  factory TouristProfile.fromJson(Map<String, dynamic> json) {
    return TouristProfile(
      id: json['id'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      profilePic: json['profile_pic'] as String? ?? '',
      profileBio: json['profile_bio'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      dateOfBirth: json['date_of_birth'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      country: json['country'] as String? ?? '',
      userRole: json['user_role'] as String? ?? 'tourist',
      isComplete: json['is_complete'] as bool? ?? false,
      travelStyle: json['travel_style'] as String? ?? '',
      passportNumber: json['passport_number'] as String? ?? '',
      emergencyContactName: json['emergency_contact_name'] as String? ?? '',
      emergencyContactRelation:
      json['emergency_contact_relation'] as String? ?? '',
      emergencyContactNumber:
      json['emergency_contact_number'] as String? ?? '',
    );
  }

  // BUG FIX 1: No copyWith existed. Provider needed to rebuild the entire
  // object manually just to change one field (bio, profilePic, etc.).
  // copyWith() fixes that cleanly.
  TouristProfile copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? fullName,
    String? profilePic,
    String? profileBio,
    String? phoneNumber,
    String? dateOfBirth,
    String? gender,
    String? country,
    String? userRole,
    bool? isComplete,
    String? travelStyle,
    String? passportNumber,
    String? emergencyContactName,
    String? emergencyContactRelation,
    String? emergencyContactNumber,
  }) {
    return TouristProfile(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? this.fullName,
      profilePic: profilePic ?? this.profilePic,
      profileBio: profileBio ?? this.profileBio,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      country: country ?? this.country,
      userRole: userRole ?? this.userRole,
      isComplete: isComplete ?? this.isComplete,
      travelStyle: travelStyle ?? this.travelStyle,
      passportNumber: passportNumber ?? this.passportNumber,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactRelation:
      emergencyContactRelation ?? this.emergencyContactRelation,
      emergencyContactNumber:
      emergencyContactNumber ?? this.emergencyContactNumber,
    );
  }
}

class Interest {
  final String id;
  final String name;
  final String category;

  const Interest({required this.id, required this.name, required this.category});

  // BUG FIX 2: Two API endpoints return different JSON shapes:
  //   GET /interests/user/  -> { "interest": { id, name, category } }
  //   GET /interests/       -> { id, name, category, is_active }
  // Original code used (json['interest'] ?? json) without a type check, which
  // can throw a CastError at runtime if 'interest' exists but is not a Map.
  factory Interest.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
    (json['interest'] is Map<String, dynamic>)
        ? json['interest'] as Map<String, dynamic>
        : json;
    return Interest(
      id: data['id'] as String? ?? '',
      name: data['name'] as String? ?? '',
      category: data['category'] as String? ?? '',
    );
  }

  // BUG FIX 3: No == / hashCode override. Without it, Set.contains() and
  // List.remove() compare by identity, so availableInterests filtering breaks.
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Interest && other.id == id);

  @override
  int get hashCode => id.hashCode;
}