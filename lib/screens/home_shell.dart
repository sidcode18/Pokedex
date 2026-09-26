import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'favorites_screen.dart';
import 'pokemon_list_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _pages = [PokemonListScreen(), FavoritesScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        indicatorColor: AppTheme.accent.withValues(alpha: 0.12),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.catching_pokemon),
            selectedIcon: Icon(Icons.catching_pokemon, color: AppTheme.accent),
            label: 'Pokédex',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite, color: AppTheme.accent),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}
