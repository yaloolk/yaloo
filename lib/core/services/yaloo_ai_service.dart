// lib/features/tourist/services/yaloo_ai_service.dart
//
// Thin wrapper around POST https://yaloolk-yaloo-ai.hf.space/recommend
// Returns ranked guide_profile_ids and stay_ids so list screens can
// re-order results and surface the "AI Pick" badge.

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

String get _aiBaseUrl => dotenv.env['_aiBaseUrl'] ?? 'https://yaloolk-yaloo-ai.hf.space';

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

class AiRecommendResult {
  final List<AiGuideResult> guides;
  final List<AiStayResult>  stays;
  const AiRecommendResult({required this.guides, required this.stays});

  /// Returns an ordered list of guide_profile_ids (best first).
  List<String> get rankedGuideIds => guides.map((g) => g.guideProfileId).toList();

  /// Returns an ordered list of stay_ids (best first).
  List<String> get rankedStayIds => stays.map((s) => s.stayId).toList();
}

// ── Service ───────────────────────────────────────────────────────────────────

class YalooAiService {
  YalooAiService._();
  static final instance = YalooAiService._();

  /// Fetch AI recommendations.
  ///
  /// [touristId]          – tourist_profile.id (UUID).
  /// [city]               – city name string (case-insensitive on server).
  /// [availableGuideIds]  – IDs from Django availability check; null = browse mode.
  /// [availableStayIds]   – same for stays.
  /// [topK]               – how many results per category (default 10).
  Future<AiRecommendResult?> recommend({
    required String touristId,
    String?         city,
    String?         guideGender,
    List<String>?   availableGuideIds,
    List<String>?   availableStayIds,
    int             topK = 10,
  }) async {
    try {
      final body = <String, dynamic>{
        'tourist_id': touristId,
        'top_k':      topK,
      };
      if (city != null && city.isNotEmpty)    body['city']         = city;
      if (guideGender != null)                body['guide_gender'] = guideGender;
      if (availableGuideIds != null)          body['available_guide_ids'] = availableGuideIds;
      if (availableStayIds  != null)          body['available_stay_ids']  = availableStayIds;

      final resp = await http
          .post(
        Uri.parse('$_aiBaseUrl/recommend'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      )
          .timeout(const Duration(seconds: 45));

      if (resp.statusCode != 200) return null;

      final data = jsonDecode(resp.body) as Map<String, dynamic>;

      final guides = (data['guides'] as List? ?? []).map((g) => AiGuideResult(
        guideProfileId: g['guide_profile_id'] as String,
        finalScore:     (g['final_score'] as num).toDouble(),
        vecSim:         (g['vec_sim']     as num).toDouble(),
      )).toList();

      final stays = (data['stays'] as List? ?? []).map((s) => AiStayResult(
        stayId:     s['stay_id']     as String,
        finalScore: (s['final_score'] as num).toDouble(),
        vecSim:     (s['vec_sim']     as num).toDouble(),
      )).toList();

      return AiRecommendResult(guides: guides, stays: stays);
    } catch (e) {
      // Add this print statement to see the exact error!
      if (kDebugMode) {
        print('🔴 AI SERVICE ERROR: $e');
      }
      // Fail silently — caller falls back to original sort order.
      return null;
    }

  }
}