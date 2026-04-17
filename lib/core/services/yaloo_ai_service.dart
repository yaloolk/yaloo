// lib/features/tourist/services/yaloo_ai_service.dart
//
// Thin wrapper around:
//   POST https://yaloolk-yaloo-ai.hf.space/recommend/guides
//   POST https://yaloolk-yaloo-ai.hf.space/recommend/stays
// Returns ranked guide_profile_ids / stay_ids so list screens can
// re-order results and surface the "AI Pick" badge.

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

String get _aiBaseUrl =>
    dotenv.env['_aiBaseUrl'] ?? 'https://yaloolk-yaloo-ai.hf.space';

// ── Lightweight result models (only what the Flutter layer needs) ─────────────

class AiGuideResult {
  final String guideProfileId;
  final double finalScore;
  final double vecSim;
  const AiGuideResult({
    required this.guideProfileId,
    required this.finalScore,
    required this.vecSim,
  });
}

class AiStayResult {
  final String stayId;
  final double finalScore;
  final double vecSim;
  const AiStayResult({
    required this.stayId,
    required this.finalScore,
    required this.vecSim,
  });
}

class AiGuideRecommendResult {
  final List<AiGuideResult> guides;
  const AiGuideRecommendResult({required this.guides});

  /// Returns an ordered list of guide_profile_ids (best first).
  List<String> get rankedGuideIds =>
      guides.map((g) => g.guideProfileId).toList();
}

class AiStayRecommendResult {
  final List<AiStayResult> stays;
  const AiStayRecommendResult({required this.stays});

  /// Returns an ordered list of stay_ids (best first).
  List<String> get rankedStayIds => stays.map((s) => s.stayId).toList();
}

// ── Service ───────────────────────────────────────────────────────────────────

class YalooAiService {
  YalooAiService._();
  static final instance = YalooAiService._();

  // ── Guide recommendations ──────────────────────────────────────────────────
  /// Fetch AI guide recommendations via POST /recommend/guides
  ///
  /// [touristId]         – tourist_profile.id (UUID).
  /// [city]              – city name string (case-insensitive on server).
  /// [guideGender]       – optional gender filter.
  /// [availableGuideIds] – IDs from Django availability check; null = browse mode.
  /// [topK]              – how many results (default 10).
  Future<AiGuideRecommendResult?> recommendGuides({
    required String touristId,
    String?         city,
    String?         guideGender,
    List<String>?   availableGuideIds,
    int             topK = 10,
  }) async {
    try {
      final body = <String, dynamic>{
        'tourist_id': touristId,
        'top_k':      topK,
      };
      if (city != null && city.isNotEmpty) body['city']         = city;
      if (guideGender != null)             body['guide_gender'] = guideGender;
      if (availableGuideIds != null)       body['available_guide_ids'] = availableGuideIds;

      final resp = await http
          .post(
        Uri.parse('$_aiBaseUrl/recommend/guides'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      )
          .timeout(const Duration(seconds: 45));

      if (resp.statusCode != 200) return null;

      final data = jsonDecode(resp.body) as Map<String, dynamic>;

      final guides = (data['guides'] as List? ?? [])
          .map((g) => AiGuideResult(
        guideProfileId: g['guide_profile_id'] as String,
        finalScore:     (g['final_score'] as num).toDouble(),
        vecSim:         (g['vec_sim']     as num).toDouble(),
      ))
          .toList();

      return AiGuideRecommendResult(guides: guides);
    } catch (e) {
      if (kDebugMode) print('🔴 AI GUIDES ERROR: $e');
      // Fail silently — caller falls back to original sort order.
      return null;
    }
  }

  // ── Stay recommendations ───────────────────────────────────────────────────
  /// Fetch AI stay recommendations via POST /recommend/stays
  ///
  /// [touristId]        – tourist_profile.id (UUID).
  /// [city]             – city name string (case-insensitive on server).
  /// [availableStayIds] – IDs from Django availability check; null = browse mode.
  /// [topK]             – how many results (default 10).
  Future<AiStayRecommendResult?> recommendStays({
    required String touristId,
    String?         city,
    List<String>?   availableStayIds,
    int             topK = 10,
  }) async {
    try {
      final body = <String, dynamic>{
        'tourist_id': touristId,
        'top_k':      topK,
      };
      if (city != null && city.isNotEmpty) body['city']              = city;
      if (availableStayIds != null)        body['available_stay_ids'] = availableStayIds;

      final resp = await http
          .post(
        Uri.parse('$_aiBaseUrl/recommend/stays'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      )
          .timeout(const Duration(seconds: 45));

      if (resp.statusCode != 200) return null;

      final data = jsonDecode(resp.body) as Map<String, dynamic>;

      final stays = (data['stays'] as List? ?? [])
          .map((s) => AiStayResult(
        stayId:     s['stay_id']     as String,
        finalScore: (s['final_score'] as num).toDouble(),
        vecSim:     (s['vec_sim']     as num).toDouble(),
      ))
          .toList();

      return AiStayRecommendResult(stays: stays);
    } catch (e) {
      if (kDebugMode) print('🔴 AI STAYS ERROR: $e');
      // Fail silently — caller falls back to original sort order.
      return null;
    }
  }
}