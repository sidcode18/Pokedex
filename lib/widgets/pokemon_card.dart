import 'package:flutter/material.dart';

import '../models/pokemon.dart';
import '../theme/app_theme.dart';
import 'favorite_button.dart';
import 'type_chip.dart';

class PokemonCard extends StatelessWidget {
  const PokemonCard({super.key, required this.pokemon, required this.onTap});

  final Pokemon pokemon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final surface = TypeColors.surface(pokemon.primaryType);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          height: 118,
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nº${pokemon.id.toString().padLeft(3, '0')}',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        pokemon.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: pokemon.types
                            .map((type) => TypeChip(type: type))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 128,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: TypeColors.of(pokemon.primaryType)
                              .withValues(alpha: 0.35),
                          borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                        child: Image.network(
                          pokemon.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.catching_pokemon,
                            size: 56,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: FavoriteButton(pokemon: pokemon),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
