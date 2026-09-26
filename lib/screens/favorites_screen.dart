import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/favorites_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/status_views.dart';
import 'pokemon_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final items = favorites.favorites;

    return ColoredBox(
      color: AppTheme.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'Favorites',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? const EmptyView(
                      icon: Icons.favorite_border,
                      title: 'You have not favorited any Pokémon :(',
                      subtitle: 'Tap the heart icon on a Pokémon card and it will show up here.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final pokemon = items[index];
                        return Dismissible(
                          key: ValueKey('favorite-${pokemon.id}'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            decoration: BoxDecoration(
                              color: AppTheme.danger,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          onDismissed: (_) {
                            context.read<FavoritesProvider>().removeFavorite(
                              pokemon.id,
                            );
                          },
                          child: PokemonCard(
                            pokemon: pokemon,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PokemonDetailScreen(
                                    nameOrId: pokemon.id.toString(),
                                    preview: pokemon,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
