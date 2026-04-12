// lib/features/tourist/models/city_model.dart

class CityModel {
  final String id;
  final String name;
  final String country;
  final String? description;
  final String? imageUrl; // from image_url column in Supabase
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CityModel({
    required this.id,
    required this.name,
    required this.country,
    this.description,
    this.imageUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      country: json['country'] as String? ?? 'Sri Lanka',
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?, // read from DB
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'country': country,
    'description': description,
    'image_url': imageUrl,
    'is_active': isActive,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}