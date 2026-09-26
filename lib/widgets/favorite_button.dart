import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pokemon.dart';
import '../providers/favorites_provider.dart';
import '../theme/app_theme.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    super.key,
    required this.pokemon,
    this.color,
    this.size = 22,
  });

  final Pokemon pokemon;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isFavorite = context.select<FavoritesProvider, bool>(
      (favorites) => favorites.isFavorite(pokemon.id),
    );

    return IconButton(
      visualDensity: VisualDensity.compact,
      onPressed: () {
        context.read<FavoritesProvider>().toggleFavorite(pokemon);
      },
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? AppTheme.heart : (color ?? Colors.white),
        size: size,
      ),
      tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
    );
  }
}
