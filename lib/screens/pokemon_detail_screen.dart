import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pokemon.dart';
import '../providers/favorites_provider.dart';
import '../providers/pokemon_detail_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/favorite_button.dart';
import '../widgets/stat_bar.dart';
import '../widgets/status_views.dart';
import '../widgets/type_chip.dart';

class PokemonDetailScreen extends StatelessWidget {
  const PokemonDetailScreen({super.key, required this.nameOrId, this.preview});

  final String nameOrId;
  final Pokemon? preview;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PokemonDetailProvider()..load(nameOrId),
      child: _PokemonDetailView(nameOrId: nameOrId, preview: preview),
    );
  }
}

class _PokemonDetailView extends StatefulWidget {
  const _PokemonDetailView({required this.nameOrId, this.preview});

  final String nameOrId;
  final Pokemon? preview;

  @override
  State<_PokemonDetailView> createState() => _PokemonDetailViewState();
}

class _PokemonDetailViewState extends State<_PokemonDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncCache());
  }

  void _syncCache() {
    final pokemon =
        context.read<PokemonDetailProvider>().pokemon ?? widget.preview;
    if (pokemon != null) {
      context.read<FavoritesProvider>().rememberPokemon(pokemon);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = context.watch<PokemonDetailProvider>();
    final pokemon = detail.pokemon ?? widget.preview;
    final typeColor = TypeColors.of(pokemon?.primaryType ?? 'normal');
    if (detail.pokemon != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncCache());
    }

    return Scaffold(
      backgroundColor: typeColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Spacer(),
                  if (pokemon != null)
                    FavoriteButton(pokemon: pokemon, size: 26),
                ],
              ),
            ),
            if (detail.isLoading && pokemon == null)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              )
            else if (detail.error != null && pokemon == null)
              Expanded(
                child: ColoredBox(
                  color: Colors.white,
                  child: ErrorView(
                    message: detail.error!,
                    onRetry: () => context.read<PokemonDetailProvider>().load(
                      widget.nameOrId,
                    ),
                  ),
                ),
              )
            else if (pokemon != null)
              Expanded(
                child: _DetailBody(
                  pokemon: pokemon,
                  color: typeColor,
                  isLoading: detail.isLoading,
                  error: detail.error,
                  onRetry: () => context.read<PokemonDetailProvider>().load(
                    widget.nameOrId,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.pokemon,
    required this.color,
    required this.isLoading,
    required this.error,
    required this.onRetry,
  });

  final Pokemon pokemon;
  final Color color;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pokemon.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (pokemon.types.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        children: pokemon.types
                            .map((type) => TypeChip(type: type, compact: false))
                            .toList(),
                      ),
                  ],
                ),
              ),
              Text(
                pokemon.paddedId,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: Center(
            child: Image.network(
              pokemon.imageUrl,
              height: 180,
              errorBuilder: (_, _, _) => const Icon(
                Icons.catching_pokemon,
                size: 96,
                color: Colors.white70,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: isLoading && pokemon.stats.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : error != null && pokemon.stats.isEmpty
                ? ErrorView(message: error!, onRetry: onRetry)
                : DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        TabBar(
                          labelColor: color,
                          unselectedLabelColor: AppTheme.textSecondary,
                          indicatorColor: color,
                          tabs: const [
                            Tab(text: 'About'),
                            Tab(text: 'Base Stats'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _AboutTab(pokemon: pokemon),
                              _StatsTab(pokemon: pokemon, color: color),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({required this.pokemon});

  final Pokemon pokemon;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      children: [
        _infoRow(
          'Height',
          pokemon.heightMeters == null
              ? '—'
              : '${pokemon.heightMeters!.toStringAsFixed(1)} m',
        ),
        _infoRow(
          'Weight',
          pokemon.weightKilograms == null
              ? '—'
              : '${pokemon.weightKilograms!.toStringAsFixed(1)} kg',
        ),
        _infoRow(
          'Abilities',
          pokemon.abilities.isEmpty
              ? '—'
              : pokemon.abilities.map(_pretty).join(', '),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsTab extends StatelessWidget {
  const _StatsTab({required this.pokemon, required this.color});

  final Pokemon pokemon;
  final Color color;

  static const labels = {
    'hp': 'HP',
    'attack': 'ATK',
    'defense': 'DEF',
    'special-attack': 'SATK',
    'special-defense': 'SDEF',
    'speed': 'SPD',
  };

  @override
  Widget build(BuildContext context) {
    if (pokemon.stats.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text('Stats are unavailable for this Pokémon.'),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      children: [
        for (final stat in pokemon.stats)
          StatBar(
            label: labels[stat.name] ?? stat.name.toUpperCase(),
            value: stat.value,
            color: color,
          ),
      ],
    );
  }
}

String _pretty(String value) => value.isEmpty
    ? value
    : value[0].toUpperCase() + value.substring(1).replaceAll('-', ' ');
