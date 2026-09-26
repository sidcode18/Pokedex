import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pokemon.dart';
import 'poke_api_exception.dart';

class PokeApiService {
  PokeApiService({http.Client? client}) : _client = client ?? http.Client();

  static const defaultListUrl =
      'https://pokeapi.co/api/v2/pokemon?limit=20&offset=0';

  final http.Client _client;

  Future<PokemonPage> fetchPokemonPage({String? url}) async {
    final pageJson = await _getJson(url ?? defaultListUrl);
    final results = pageJson['results'];
    final refs = <Pokemon>[];
    if (results is List) {
      for (final item in results) {
        if (item is Map<String, dynamic>) {
          final pokemon = Pokemon.fromListResult(item);
          if (pokemon.id > 0) {
            refs.add(pokemon);
          }
        }
      }
    }

    final detailed = await Future.wait(
      refs.map((pokemon) async {
        try {
          return await fetchPokemon(pokemon.id.toString());
        } catch (_) {
          return pokemon;
        }
      }),
    );

    final next = pageJson['next'];
    return PokemonPage(
      pokemon: detailed,
      nextUrl: next is String && next.isNotEmpty ? next : null,
    );
  }

  Future<Pokemon> fetchPokemon(String nameOrId) async {
    final json = await _getJson(
      'https://pokeapi.co/api/v2/pokemon/${Uri.encodeComponent(nameOrId)}',
    );
    return Pokemon.fromDetailJson(json);
  }

  Future<Map<String, dynamic>> _getJson(String url) async {
    http.Response response;
    try {
      response = await _client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw const PokeApiException('The request timed out. Please try again.');
    } on http.ClientException {
      throw const PokeApiException(
        'No internet connection. Check your network and try again.',
      );
    } catch (_) {
      throw const PokeApiException('Something went wrong. Please try again.');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw PokeApiException(
        'PokéAPI returned ${response.statusCode}. Please try again.',
        statusCode: response.statusCode,
      );
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const PokeApiException(
          'Received an unexpected response from PokéAPI.',
        );
      }
      return decoded;
    } on PokeApiException {
      rethrow;
    } on FormatException {
      throw const PokeApiException('Received an invalid response from PokéAPI.');
    }
}
