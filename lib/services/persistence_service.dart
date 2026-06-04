import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/persistent_stats.dart';

class PersistenceService {
  static const _statsKey = 'strain_persistent_stats';

  Future<PersistentStats> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_statsKey);
    if (raw == null) return PersistentStats();
    try {
      return PersistentStats.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return PersistentStats();
    }
  }

  Future<void> saveStats(PersistentStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statsKey, jsonEncode(stats.toJson()));
  }
}
