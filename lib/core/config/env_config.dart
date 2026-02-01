import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  // Supabase
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // Backend API
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';

  // Google Maps
  static String get googleMapsApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  // Stripe
  static String get stripePublishableKey => dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';

  // Validation
  static bool get isConfigured {
    return supabaseUrl.isNotEmpty &&
        supabaseAnonKey.isNotEmpty &&
        apiBaseUrl.isNotEmpty;
  }
}