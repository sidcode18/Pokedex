import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pokedex/models/pokemon.dart';
import 'package:pokedex/providers/favorites_provider.dart';
import 'package:pokedex/providers/pokemon_detail_provider.dart';
import 'package:pokedex/providers/pokemon_list_provider.dart';
import 'package:pokedex/services/favorites_storage.dart';
import 'package:pokedex/services/poke_api_service.dart';
import 'package:pokedex/widgets/favorite_button.dart';
import 'package:provider/provider.dart';

class _MemoryStorage extends FavoritesStorage {
  Set<int> ids = {};
  Map<int, Pokemon> cache = {};

  @override
  Future<Set<int>> loadIds() async => Set<int>.from(ids);

  @override
  Future<Map<int, Pokemon>> loadCache() async => Map<int, Pokemon>.from(cache);

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
  group('FavoritesProvider & Persistence', () {
    test(
      'FavoritesProvider is single source of truth for add/remove/toggle',
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

    test('Favorites survive simulated app restart via storage', () async {
      final storage = _MemoryStorage();
      final session1 = FavoritesProvider(storage: storage);
      await session1.load();

      const charmander = Pokemon(
        id: 4,
        name: 'charmander',
        imageUrl: 'https://example.com/4.png',
        types: ['fire'],
      );

      await session1.addFavorite(charmander);
      expect(session1.isFavorite(4), isTrue);

      // Simulate closing and restarting app with fresh provider
      final session2 = FavoritesProvider(storage: storage);
      await session2.load();

      expect(session2.isFavorite(4), isTrue);
      expect(session2.favorites.length, 1);
      expect(session2.favorites.first.name, 'charmander');
    });

    test(
      'Missing cache data produces valid fallback Pokémon without crash',
      () async {
        final storage = _MemoryStorage();
        storage.ids = {
          25,
        }; // Pikachu ID present in IDs but missing from cache map
        storage.cache = {};

        final provider = FavoritesProvider(storage: storage);
        await provider.load();

        expect(provider.isFavorite(25), isTrue);
        expect(provider.favorites.length, 1);
        expect(provider.favorites.first.id, 25);
        expect(provider.favorites.first.imageUrl, contains('25.png'));
      },
    );
  });

  group('PokemonListProvider & Pagination & Search', () {
    late PokeApiService fakeApi;

    setUp(() {
      final mockClient = MockClient((request) async {
        final url = request.url.toString();
        if (url.contains('offset=0')) {
          return http.Response(
            jsonEncode({
              'count': 4,
              'next': 'https://pokeapi.co/api/v2/pokemon?limit=2&offset=2',
              'results': [
                {
                  'name': 'bulbasaur',
                  'url': 'https://pokeapi.co/api/v2/pokemon/1/',
                },
                {
                  'name': 'ivysaur',
                  'url': 'https://pokeapi.co/api/v2/pokemon/2/',
                },
              ],
            }),
            200,
          );
        } else if (url.contains('offset=2')) {
          return http.Response(
            jsonEncode({
              'count': 4,
              'next': null,
              'results': [
                {
                  'name': 'venusaur',
                  'url': 'https://pokeapi.co/api/v2/pokemon/3/',
                },
                {
                  'name': 'charmander',
                  'url': 'https://pokeapi.co/api/v2/pokemon/4/',
                },
              ],
            }),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      fakeApi = PokeApiService(client: mockClient);
    });

    test(
      'Initial loading loads first page only without detail requests',
      () async {
        final listProvider = PokemonListProvider(api: fakeApi);
        await listProvider.loadInitial();

        expect(listProvider.allLoaded.length, 2);
        expect(listProvider.allLoaded[0].name, 'bulbasaur');
        expect(listProvider.allLoaded[1].name, 'ivysaur');
        expect(listProvider.hasMore, isTrue);
      },
    );

    test(
      'loadMore fetches next page and avoids duplicate pagination requests',
      () async {
        final listProvider = PokemonListProvider(api: fakeApi);
        await listProvider.loadInitial();

        // Trigger pagination
        await listProvider.loadMore();
        expect(listProvider.allLoaded.length, 4);
        expect(listProvider.hasMore, isFalse);

        // Attempting to load more when hasMore is false does not request
        await listProvider.loadMore();
        expect(listProvider.allLoaded.length, 4);
      },
    );

    test('Search filters strictly among currently loaded Pokémon', () async {
      final listProvider = PokemonListProvider(api: fakeApi);
      await listProvider.loadInitial(); // Loads bulbasaur and ivysaur only

      listProvider.setQuery('bulb');
      expect(listProvider.visiblePokemon.length, 1);
      expect(listProvider.visiblePokemon.first.name, 'bulbasaur');

      // Charmander is not loaded yet in page 1, so search yields empty
      listProvider.setQuery('char');
      expect(listProvider.visiblePokemon, isEmpty);

      // Now load page 2 (includes charmander)
      await listProvider.loadMore();
      expect(listProvider.visiblePokemon.length, 1);
      expect(listProvider.visiblePokemon.first.name, 'charmander');
    });

    test('Sorting by name and number works correctly', () async {
      final listProvider = PokemonListProvider(api: fakeApi);
      await listProvider.loadInitial();
      await listProvider.loadMore();

      listProvider.setSort(PokemonSort.nameAz);
      expect(listProvider.visiblePokemon.map((p) => p.name).toList(), [
        'bulbasaur',
        'charmander',
        'ivysaur',
        'venusaur',
      ]);

      listProvider.setSort(PokemonSort.largestNumber);
      expect(listProvider.visiblePokemon.map((p) => p.id).toList(), [
        4,
        3,
        2,
        1,
      ]);
    });
  });

  group('PokemonDetailProvider', () {
    test(
      'Loads complete details including stats, abilities, height, weight',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode({
              'id': 25,
              'name': 'pikachu',
              'height': 4,
              'weight': 60,
              'sprites': {
                'other': {
                  'official-artwork': {
                    'front_default': 'https://example.com/25.png',
                  },
                },
              },
              'types': [
                {
                  'type': {'name': 'electric'},
                },
              ],
              'abilities': [
                {
                  'ability': {'name': 'static'},
                },
              ],
              'stats': [
                {
                  'base_stat': 35,
                  'stat': {'name': 'hp'},
                },
                {
                  'base_stat': 55,
                  'stat': {'name': 'attack'},
                },
              ],
            }),
            200,
          );
        });

        final api = PokeApiService(client: mockClient);
        final detailProvider = PokemonDetailProvider(api: api);

        await detailProvider.load('25');
        expect(detailProvider.isLoading, isFalse);
        expect(detailProvider.error, isNull);
        expect(detailProvider.pokemon, isNotNull);
        expect(detailProvider.pokemon!.displayName, 'Pikachu');
        expect(detailProvider.pokemon!.heightMeters, 0.4);
        expect(detailProvider.pokemon!.weightKilograms, 6.0);
        expect(detailProvider.pokemon!.abilities, ['static']);
        expect(detailProvider.pokemon!.stats.length, 2);
      },
    );

    test('Handles API error gracefully', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      final api = PokeApiService(client: mockClient);
      final detailProvider = PokemonDetailProvider(api: api);

      await detailProvider.load('unknown');
      expect(detailProvider.isLoading, isFalse);
      expect(detailProvider.pokemon, isNull);
      expect(detailProvider.error, isNotNull);
    });
  });

  group('Widget UI Synchronization', () {
    testWidgets('FavoriteButton toggles state immediately in UI', (
      tester,
    ) async {
      final storage = _MemoryStorage();
      final favorites = FavoritesProvider(storage: storage);
      await favorites.load();

      const squirtle = Pokemon(
        id: 7,
        name: 'squirtle',
        imageUrl: 'https://example.com/7.png',
      );

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: favorites,
          child: const MaterialApp(
            home: Scaffold(body: FavoriteButton(pokemon: squirtle)),
          ),
        ),
      );

      // Initially unfavorited
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);

      // Tap favorite button
      await tester.tap(find.byType(IconButton));
      await tester.pump();

      // Heart updates immediately
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
      expect(favorites.isFavorite(7), isTrue);
    });
  });
}
