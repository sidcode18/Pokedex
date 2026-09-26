import 'package:flutter/foundation.dart';

import '../models/pokemon.dart';
import '../services/favorites_storage.dart';

class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider({FavoritesStorage? storage})
    : _storage = storage ?? FavoritesStorage();

  final FavoritesStorage _storage;
  final Set<int> _ids = {};
  final Map<int, Pokemon> _cache = {};
  bool _loaded = false;

  bool get isLoaded => _loaded;

  Set<int> get favoriteIds => Set.unmodifiable(_ids);

  List<Pokemon> get favorites {
    final items = _ids.map((id) {
      final cached = _cache[id];
      if (cached != null) return cached;
      return Pokemon(
        id: id,
        name: 'pokemon #$id',
        imageUrl: Pokemon.artworkUrlFor(id),
      );
    }).toList();
    items.sort((a, b) => a.id.compareTo(b.id));
    return items;
  }

  Future<void> load() async {
    final ids = await _storage.loadIds();
    final cache = await _storage.loadCache();
    _ids
      ..clear()
      ..addAll(ids);
    _cache
      ..clear()
      ..addAll(cache);
    _loaded = true;
    notifyListeners();
  }

  bool isFavorite(int id) => _ids.contains(id);

  Future<void> toggleFavorite(Pokemon pokemon) async {
    if (pokemon.id <= 0) return;
    if (_ids.contains(pokemon.id)) {
      await removeFavorite(pokemon.id);
    } else {
      await addFavorite(pokemon);
    }
  }

  Future<void> addFavorite(Pokemon pokemon) async {
    if (pokemon.id <= 0) return;
    _ids.add(pokemon.id);
    _cache[pokemon.id] = pokemon;
    notifyListeners();
    await _persist();
  }

  Future<void> removeFavorite(int id) async {
    _ids.remove(id);
    _cache.remove(id);
    notifyListeners();
    await _persist();
  }

  /// Keeps cached card data fresh when list/detail fetches complete.
  void rememberPokemon(Pokemon pokemon) {
    if (!_ids.contains(pokemon.id)) return;
    _cache[pokemon.id] = pokemon;
    _persist();
  }

  Future<void> _persist() {
    return _storage.save(ids: _ids, cache: _cache);
  }
}
