import 'package:flutter/foundation.dart';

import '../models/pokemon.dart';
import '../services/poke_api_exception.dart';
import '../services/poke_api_service.dart';

enum PokemonSort { smallestNumber, largestNumber, nameAz, nameZa }

class PokemonListProvider extends ChangeNotifier {
  PokemonListProvider({PokeApiService? api}) : _api = api ?? PokeApiService();

  final PokeApiService _api;

  final List<Pokemon> _loaded = [];
  String? _nextUrl;
  String _query = '';
  String? _typeFilter;
  PokemonSort _sort = PokemonSort.smallestNumber;

  bool _initialLoading = false;
  bool _loadingMore = false;
  String? _error;
  String? _loadMoreError;

  List<Pokemon> get allLoaded => List.unmodifiable(_loaded);
  String get query => _query;
  String? get typeFilter => _typeFilter;
  PokemonSort get sort => _sort;
  bool get isInitialLoading => _initialLoading;
  bool get isLoadingMore => _loadingMore;
  String? get error => _error;
  String? get loadMoreError => _loadMoreError;
  bool get hasMore => _nextUrl != null;
  bool get hasLoadedItems => _loaded.isNotEmpty;

  List<Pokemon> get visiblePokemon {
    var items = _loaded.where((pokemon) {
      final matchesQuery =
          _query.isEmpty || pokemon.name.contains(_query.toLowerCase());
      final matchesType =
          _typeFilter == null || pokemon.types.contains(_typeFilter);
      return matchesQuery && matchesType;
    }).toList();

    items.sort((a, b) {
      switch (_sort) {
        case PokemonSort.smallestNumber:
          return a.id.compareTo(b.id);
        case PokemonSort.largestNumber:
          return b.id.compareTo(a.id);
        case PokemonSort.nameAz:
          return a.name.compareTo(b.name);
        case PokemonSort.nameZa:
          return b.name.compareTo(a.name);
      }
    });
    return items;
  }

  Future<void> loadInitial() async {
    if (_initialLoading) return;
    _initialLoading = true;
    _error = null;
    _loadMoreError = null;
    notifyListeners();

    try {
      final page = await _api.fetchPokemonPage();
      _loaded
        ..clear()
        ..addAll(_mergeUnique(const [], page.pokemon));
      _nextUrl = page.nextUrl;
      _error = null;
    } on PokeApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
    } finally {
      _initialLoading = false;
      notifyListeners();
    }
  }

  Future<void> retry() => loadInitial();

  Future<void> loadMore() async {
    if (_loadingMore || _initialLoading || _nextUrl == null) return;
    _loadingMore = true;
    _loadMoreError = null;
    notifyListeners();

    try {
      final page = await _api.fetchPokemonPage(url: _nextUrl);
      _loaded.addAll(_mergeUnique(_loaded, page.pokemon));
      _nextUrl = page.nextUrl;
      _loadMoreError = null;
    } on PokeApiException catch (e) {
      _loadMoreError = e.message;
    } catch (_) {
      _loadMoreError = 'Could not load more Pokémon.';
    } finally {
      _loadingMore = false;
      notifyListeners();
    }
  }

  void setQuery(String value) {
    final next = value.trim().toLowerCase();
    if (next == _query) return;
    _query = next;
    notifyListeners();
  }

  void setTypeFilter(String? type) {
    if (type == _typeFilter) return;
    _typeFilter = type;
    notifyListeners();
  }

  void setSort(PokemonSort sort) {
    if (sort == _sort) return;
    _sort = sort;
    notifyListeners();
  }

  List<Pokemon> _mergeUnique(List<Pokemon> existing, List<Pokemon> incoming) {
    final seen = existing.map((pokemon) => pokemon.id).toSet();
    final unique = <Pokemon>[];
    for (final pokemon in incoming) {
      if (seen.add(pokemon.id)) {
        unique.add(pokemon);
      }
    }
    return unique;
  }
}
