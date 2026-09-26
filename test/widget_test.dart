import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/models/pokemon.dart';
import 'package:pokedex/providers/favorites_provider.dart';
import 'package:pokedex/services/favorites_storage.dart';

class _MemoryStorage extends FavoritesStorage {
  Set<int> ids = {};
  Map<int, Pokemon> cache = {};

  @override
  Future<Set<int>> loadIds() async => ids;

  @override
  Future<Map<int, Pokemon>> loadCache() async => cache;

  @override
  Future<void> save({
    required Set<int> ids,
    required Map<int, Pokemon> cache,
  }) async {
    this.ids = Set<int>.from(ids);
    this.cache = Map<int, Pokemon>.from(cache);
  }
}

void main() {
  test(
    'FavoritesProvider is a single source of truth for favorite ids',
    () async {
      final storage = _MemoryStorage();
      final provider = FavoritesProvider(storage: storage);
      await provider.load();

      const bulbasaur = Pokemon(
        id: 1,
        name: 'bulbasaur',
        imageUrl: 'https://example.com/1.png',
        types: ['grass', 'poison'],
      );

      expect(provider.isFavorite(1), isFalse);
      await provider.toggleFavorite(bulbasaur);
      expect(provider.isFavorite(1), isTrue);
      expect(provider.favorites.single.id, 1);
      expect(storage.ids, {1});

      await provider.toggleFavorite(bulbasaur);
      expect(provider.isFavorite(1), isFalse);
      expect(provider.favorites, isEmpty);
      expect(storage.ids, isEmpty);
    },
  );
}
