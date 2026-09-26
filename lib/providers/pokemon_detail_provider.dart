import 'package:flutter/foundation.dart';

import '../models/pokemon.dart';
import '../services/poke_api_exception.dart';
import '../services/poke_api_service.dart';

class PokemonDetailProvider extends ChangeNotifier {
  PokemonDetailProvider({PokeApiService? api}) : _api = api ?? PokeApiService();

  final PokeApiService _api;

  Pokemon? pokemon;
  bool isLoading = false;
  String? error;

  Future<void> load(String nameOrId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      pokemon = await _api.fetchPokemon(nameOrId);
      error = null;
    } on PokeApiException catch (e) {
      error = e.message;
    } catch (_) {
      error = 'Could not load Pokémon details.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
