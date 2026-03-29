// lib/features/tourist/models/stay_booking_model.dart

class StayBookingModel {
  final String id;
  final String touristProfileId;
  final String touristFullName;
  final String touristPhone;
  final String touristEmail;
  final String touristCountry;
  final String touristGender;
  final String touristPassport;
  final String touristPhoto;

  final String stayId;
  final String stayName;
  final String stayCoverPhoto;

  final String hostProfileId;
  final String hostName;
  final String hostPhoto;
  final String hostPhone;
  final String cityName;

  final String checkinDate;
  final String checkoutDate;
  final int    totalNights;
  final String bookingType;
  final int    roomCount;
  final int    guestCount;
  final String mealPreference;
  final String? checkinTime;
  final String? checkoutTime;

  final double pricePerNight;
  final double totalAmount;
  final double tipAmount;

  final String  bookingStatus;
  final String  paymentStatus;
  final String? specialNote;
  final String? hostResponseNote;
  final String? respondedAt;
  final String  createdAt;

  const StayBookingModel({
    required this.id,
    required this.touristProfileId,
    required this.touristFullName,
    required this.touristPhone,
    required this.touristEmail,
    required this.touristCountry,
    required this.touristGender,
    required this.touristPassport,
    required this.touristPhoto,
    required this.stayId,
    required this.stayName,
    required this.stayCoverPhoto,
    required this.hostProfileId,
    required this.hostName,
    required this.hostPhoto,
    required this.hostPhone,
    required this.cityName,
    required this.checkinDate,
    required this.checkoutDate,
    required this.totalNights,
    required this.bookingType,
    required this.roomCount,
    required this.guestCount,
    required this.mealPreference,
    this.checkinTime,
    this.checkoutTime,
    required this.pricePerNight,
    required this.totalAmount,
    required this.tipAmount,
    required this.bookingStatus,
    required this.paymentStatus,
    this.specialNote,
    this.hostResponseNote,
    this.respondedAt,
    required this.createdAt,
  });

  factory StayBookingModel.fromJson(Map<String, dynamic> j) {
    return StayBookingModel(
      id:               j['id']                 as String? ?? '',
      touristProfileId: j['tourist_profile_id'] as String? ?? '',
      touristFullName:  j['tourist_full_name']  as String? ?? '',
      touristPhone:     j['tourist_phone']      as String? ?? '',
      touristEmail:     j['tourist_email']      as String? ?? '',
      touristCountry:   j['tourist_country']    as String? ?? '',
      touristGender:    j['tourist_gender']     as String? ?? '',
      touristPassport:  j['tourist_passport']   as String? ?? '',
      touristPhoto:     j['tourist_photo']      as String? ?? '',
      stayId:           j['stay_id']            as String? ?? '',
      stayName:         j['stay_name']          as String? ?? '',
      stayCoverPhoto:   j['stay_cover_photo']   as String? ?? '',
      hostProfileId:    j['host_profile_id']    as String? ?? '',
      hostName:         j['host_name']          as String? ?? '',
      hostPhoto:        j['host_photo']         as String? ?? '',
      hostPhone:        j['host_phone']         as String? ?? '',
      cityName:         j['city_name']          as String? ?? '',
      checkinDate:      j['checkin_date']       as String? ?? '',
      checkoutDate:     j['checkout_date']      as String? ?? '',
      totalNights:      (j['total_nights']      as num?)?.toInt() ?? 1,
      bookingType:      j['booking_type']       as String? ?? 'per_night',
      roomCount:        (j['room_count']        as num?)?.toInt() ?? 1,
      guestCount:       (j['guest_count']       as num?)?.toInt() ?? 1,
      mealPreference:   j['meal_preference']    as String? ?? 'none',
      checkinTime:      j['checkin_time']       as String?,
      checkoutTime:     j['checkout_time']      as String?,
      pricePerNight:    (j['price_per_night']   as num?)?.toDouble() ?? 0,
      totalAmount:      (j['total_amount']      as num?)?.toDouble() ?? 0,
      tipAmount:        (j['tip_amount']        as num?)?.toDouble() ?? 0,
      bookingStatus:    j['booking_status']     as String? ?? 'pending',
      paymentStatus:    j['payment_status']     as String? ?? 'unpaid',
      specialNote:      j['special_note']       as String?,
      hostResponseNote: j['host_response_note'] as String?,
      respondedAt:      j['responded_at']       as String?,
      createdAt:        j['created_at']         as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id':                  id,
    'tourist_profile_id':  touristProfileId,
    'tourist_full_name':   touristFullName,
    'tourist_phone':       touristPhone,
    'tourist_email':       touristEmail,
    'tourist_country':     touristCountry,
    'tourist_gender':      touristGender,
    'tourist_passport':    touristPassport,
    'tourist_photo':       touristPhoto,
    'stay_id':             stayId,
    'stay_name':           stayName,
    'stay_cover_photo':    stayCoverPhoto,
    'host_profile_id':     hostProfileId,
    'host_name':           hostName,
    'host_photo':          hostPhoto,
    'host_phone':          hostPhone,
    'city_name':           cityName,
    'checkin_date':        checkinDate,
    'checkout_date':       checkoutDate,
    'total_nights':        totalNights,
    'booking_type':        bookingType,
    'room_count':          roomCount,
    'guest_count':         guestCount,
    'meal_preference':     mealPreference,
    'checkin_time':        checkinTime,
    'checkout_time':       checkoutTime,
    'price_per_night':     pricePerNight,
    'total_amount':        totalAmount,
    'tip_amount':          tipAmount,
    'booking_status':      bookingStatus,
    'payment_status':      paymentStatus,
    'special_note':        specialNote,
    'host_response_note':  hostResponseNote,
    'responded_at':        respondedAt,
    'created_at':          createdAt,
  };

  String get statusLabel {
    switch (bookingStatus) {
      case 'confirmed':  return 'Confirmed';
      case 'completed':  return 'Completed';
      case 'rejected':   return 'Rejected';
      case 'cancelled':  return 'Cancelled';
      default:           return 'Pending';
    }
  }
}

// ── Stay search result model ──────────────────────────────────────────────────

class StaySearchResult {
  final String stayId;
  final String hostProfileId;
  final String name;
  final String type;
  final String description;
  final String cityName;
  final String coverPhoto;
  final int    roomCount;
  final int    maxGuests;
  final double pricePerNight;
  final double priceEntirePlace;
  final bool   entirePlaceIsAvailable;
  final double pricePerHalfday;
  final bool   halfdayAvailable;
  final int    bathroomCount;
  final double avgRating;
  final String hostName;
  final String hostPhoto;
  final double? latitude;
  final double? longitude;

  const StaySearchResult({
    required this.stayId,
    required this.hostProfileId,
    required this.name,
    required this.type,
    required this.description,
    required this.cityName,
    required this.coverPhoto,
    required this.roomCount,
    required this.maxGuests,
    required this.pricePerNight,
    required this.priceEntirePlace,
    required this.entirePlaceIsAvailable,
    required this.pricePerHalfday,
    required this.halfdayAvailable,
    required this.bathroomCount,
    required this.avgRating,
    required this.hostName,
    required this.hostPhoto,
    this.latitude,
    this.longitude,
  });

  factory StaySearchResult.fromJson(Map<String, dynamic> j) {
    return StaySearchResult(
      stayId:                  j['stay_id']              as String? ?? '',
      hostProfileId:           j['host_profile_id']      as String? ?? '',
      name:                    j['name']                 as String? ?? '',
      type:                    j['type']                 as String? ?? '',
      description:             j['description']          as String? ?? '',
      cityName:                j['city_name']            as String? ?? '',
      coverPhoto:              j['cover_photo']          as String? ?? '',
      roomCount:               (j['room_count']          as num?)?.toInt() ?? 0,
      maxGuests:               (j['max_guests']          as num?)?.toInt() ?? 0,
      pricePerNight:           (j['price_per_night']     as num?)?.toDouble() ?? 0,
      priceEntirePlace:        (j['price_entire_place']  as num?)?.toDouble() ?? 0,
      entirePlaceIsAvailable:  j['entire_place_is_available'] as bool? ?? false,
      pricePerHalfday:         (j['price_per_halfday']   as num?)?.toDouble() ?? 0,
      halfdayAvailable:        j['halfday_available']    as bool? ?? false,
      bathroomCount:           (j['bathroom_count']      as num?)?.toInt() ?? 0,
      avgRating:               (j['avg_rating']          as num?)?.toDouble() ?? 0,
      hostName:                j['host_name']            as String? ?? '',
      hostPhoto:               j['host_photo']           as String? ?? '',
      latitude:                (j['latitude']            as num?)?.toDouble(),
      longitude:               (j['longitude']           as num?)?.toDouble(),
    );
  }

  // Proper placement of the toJson method for the Search Result!
  Map<String, dynamic> toJson() => {
    'stay_id':                  stayId,
    'host_profile_id':          hostProfileId,
    'name':                     name,
    'type':                     type,
    'description':              description,
    'city_name':                cityName,
    'cover_photo':              coverPhoto,
    'room_count':               roomCount,
    'max_guests':               maxGuests,
    'price_per_night':          pricePerNight,
    'price_entire_place':       priceEntirePlace,
    'entire_place_is_available': entirePlaceIsAvailable,
    'price_per_halfday':        pricePerHalfday,
    'halfday_available':        halfdayAvailable,
    'bathroom_count':           bathroomCount,
    'avg_rating':               avgRating,
    'host_name':                hostName,
    'host_photo':               hostPhoto,
    'latitude':                 latitude,
    'longitude':                longitude,
  };
}