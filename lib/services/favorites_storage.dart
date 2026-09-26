import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/pokemon.dart';

class FavoritesStorage {
  static const _idsKey = 'favorite_ids';
  static const _cacheKey = 'favorite_pokemon_cache';

  Future<Set<int>> loadIds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_idsKey) ?? const [];
    return raw.map(int.tryParse).whereType<int>().toSet();
  }

  Future<Map<int, Pokemon>> loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null || raw.isEmpty) return {};

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return {};
      final cache = <int, Pokemon>{};
      for (final entry in decoded.entries) {
        final id = int.tryParse(entry.key);
        final value = entry.value;
        if (id == null || value is! Map<String, dynamic>) continue;
        final pokemon = Pokemon.fromCacheJson(value);
        if (pokemon.id > 0) {
          cache[id] = pokemon;
        }
      }
      return cache;
    } catch (_) {
      return {};
    }
  }

  Future<void> save({
    required Set<int> ids,
    required Map<int, Pokemon> cache,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _idsKey,
      ids.map((id) => id.toString()).toList()..sort(),
    );
    final encoded = <String, dynamic>{};
    for (final id in ids) {
      final pokemon = cache[id];
      if (pokemon != null) {
        encoded['$id'] = pokemon.toCacheJson();
      }
    }
    await prefs.setString(_cacheKey, jsonEncode(encoded));
  }
}
