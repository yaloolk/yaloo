// lib/features/tourist/providers/city_provider.dart

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/city_model.dart';

class CityProvider extends ChangeNotifier {
  final _client = Supabase.instance.client;

  List<CityModel> _cities = [];
  bool _loading = false;
  String? _error;

  List<CityModel> get cities => _cities;
  bool get loading => _loading;
  String? get error => _error;

  /// Fetch active cities from the `city` table.
  Future<void> loadCities({bool forceRefresh = false}) async {
    if (_cities.isNotEmpty && !forceRefresh) return;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('🏙️ CityProvider: fetching cities...');

      final response = await _client
          .from('city')
          .select()
          .eq('is_active', true)
          .order('name', ascending: true);

      debugPrint('🏙️ CityProvider: raw response → $response');
      debugPrint('🏙️ CityProvider: count → ${(response as List).length}');

      _cities = response
          .map((e) => CityModel.fromJson(e as Map<String, dynamic>))
          .toList();

      debugPrint('🏙️ CityProvider: parsed ${_cities.length} cities');
    } catch (e, stack) {
      _error = e.toString();
      debugPrint('🏙️ CityProvider ERROR: $e');
      debugPrint('🏙️ Stack trace: $stack');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}