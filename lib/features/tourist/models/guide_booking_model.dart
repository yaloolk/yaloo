// lib/features/tourist/models/guide_booking_model.dart

class GuideBookingModel {
  final String id;
  final String touristProfileId;
  final String touristName;
  final String touristPhoto;
  final String touristPhone;
  final String guideProfileId;
  final String guideName;
  final String guidePhoto;
  final String guidePhone;
  final String cityName;
  final String bookingDate;
  final String startTime;
  final String endTime;
  final double totalHours;
  final double ratePerHour;
  final double totalAmount;
  final double tipAmount;
  final String bookingStatus;
  final String paymentStatus;
  final int guestCount;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final String? pickupAddress;
  final String? specialNote;
  final String? guideResponseNote;
  final String? respondedAt;
  final String createdAt;

  GuideBookingModel({
    required this.id,
    required this.touristProfileId,
    required this.touristName,
    required this.touristPhoto,
    required this.touristPhone,
    required this.guideProfileId,
    required this.guideName,
    required this.guidePhoto,
    required this.guidePhone,
    required this.cityName,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.totalHours,
    required this.ratePerHour,
    required this.totalAmount,
    required this.tipAmount,
    required this.bookingStatus,
    required this.paymentStatus,
    required this.guestCount,
    this.pickupLatitude,
    this.pickupLongitude,
    this.pickupAddress,
    this.specialNote,
    this.guideResponseNote,
    this.respondedAt,
    required this.createdAt,
  });

  factory GuideBookingModel.fromJson(Map<String, dynamic> json) {
    return GuideBookingModel(
      id: json['id'] ?? '',
      touristProfileId: json['tourist_profile_id'] ?? '',
      touristName: json['tourist_name'] ?? '',
      touristPhoto: json['tourist_photo'] ?? '',
      touristPhone: json['tourist_phone'] ?? '',
      guideProfileId: json['guide_profile_id'] ?? '',
      guideName: json['guide_name'] ?? '',
      guidePhoto: json['guide_photo'] ?? '',
      guidePhone: json['guide_phone'] ?? '',
      cityName: json['city_name'] ?? '',
      bookingDate: json['booking_date'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      totalHours: (json['total_hours'] ?? 0).toDouble(),
      ratePerHour: (json['rate_per_hour'] ?? 0).toDouble(),
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      tipAmount: (json['tip_amount'] ?? 0).toDouble(),
      bookingStatus: json['booking_status'] ?? 'pending',
      paymentStatus: json['payment_status'] ?? 'unpaid',
      guestCount: json['guest_count'] ?? 1,
      pickupLatitude: json['pickup_latitude']?.toDouble(),
      pickupLongitude: json['pickup_longitude']?.toDouble(),
      pickupAddress: json['pickup_address'],
      specialNote: json['special_note'],
      guideResponseNote: json['guide_response_note'],
      respondedAt: json['responded_at'],
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'tourist_profile_id': touristProfileId,
    'guide_profile_id': guideProfileId,
    'booking_date': bookingDate,
    'start_time': startTime,
    'end_time': endTime,
    'total_hours': totalHours,
    'total_amount': totalAmount,
    'booking_status': bookingStatus,
    'payment_status': paymentStatus,
    'guest_count': guestCount,
  };

  /// Human-readable status label
  String get statusLabel {
    switch (bookingStatus) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'rejected':
        return 'Rejected';
      case 'cancelled':
        return 'Cancelled';
      case 'completed':
        return 'Completed';
      default:
        return bookingStatus;
    }
  }
}