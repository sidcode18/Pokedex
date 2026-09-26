import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/pokemon_list_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/status_views.dart';
import 'pokemon_detail_screen.dart';

class PokemonListScreen extends StatefulWidget {
  const PokemonListScreen({super.key});

  @override
  State<PokemonListScreen> createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PokemonListProvider>().loadInitial();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      context.read<PokemonListProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = context.watch<PokemonListProvider>();

    return ColoredBox(
      color: AppTheme.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'Pokédex',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: _SearchField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {});
                  list.setQuery(val);
                },
                onClear: () {
                  _searchController.clear();
                  list.setQuery('');
                  setState(() {});
                },
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _FilterChipButton(
                      label: list.typeFilter == null
                          ? 'All types'
                          : _capitalize(list.typeFilter!),
                      onTap: () => _showTypeSheet(list),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _FilterChipButton(
                      label: _sortLabel(list.sort),
                      onTap: () => _showSortSheet(list),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildBody(list)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(PokemonListProvider list) {
    if (list.isInitialLoading && !list.hasLoadedItems) {
      return const Center(child: CircularProgressIndicator());
    }
    if (list.error != null && !list.hasLoadedItems) {
      return ErrorView(message: list.error!, onRetry: list.retry);
    }

    final items = list.visiblePokemon;
    if (items.isEmpty) {
      return EmptyView(
        title: 'No Pokémon found',
        subtitle: list.query.isEmpty && list.typeFilter == null
            ? 'Try loading more Pokémon.'
            : 'Nothing in the loaded list matches this search or type filter.',
      );
    }

    return RefreshIndicator(
      onRefresh: list.retry,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: items.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == items.length) {
            return _Footer(list: list);
          }
          final pokemon = items[index];
          return PokemonCard(
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
          );
        },
      ),
    );
  }

  Future<void> _showTypeSheet(PokemonListProvider list) async {
    final selected = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _TypeSheet(current: list.typeFilter),
    );
    if (!mounted) return;
    if (selected == _clearSentinel) {
      list.setTypeFilter(null);
    } else if (selected != null) {
      list.setTypeFilter(selected);
    }
  }

  Future<void> _showSortSheet(PokemonListProvider list) async {
    final selected = await showModalBottomSheet<PokemonSort>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _SortSheet(current: list.sort),
    );
    if (selected != null) {
      list.setSort(selected);
    }
  }
}

const _clearSentinel = '__all__';

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search Pokémon...',
        hintStyle: const TextStyle(color: AppTheme.textSecondary),
        prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(
                  Icons.clear,
                  size: 20,
                  color: AppTheme.textSecondary,
                ),
                onPressed: onClear,
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const Icon(Icons.expand_more, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.list});

  final PokemonListProvider list;

  @override
  Widget build(BuildContext context) {
    if (list.loadMoreError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Text(
              list.loadMoreError!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            TextButton(onPressed: list.loadMore, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (list.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (!list.hasMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'You have seen every Pokémon in this list.',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      );
    }
    return const SizedBox(height: 12);
  }
}

class _TypeSheet extends StatelessWidget {
  const _TypeSheet({required this.current});

  final String? current;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.7,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            children: [
              const Text(
                'Select a type',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              _sheetButton(
                context,
                label: 'All types',
                color: AppTheme.textPrimary,
                selected: current == null,
                onTap: () => Navigator.pop(context, _clearSentinel),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: TypeColors.allTypes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final type = TypeColors.allTypes[index];
                    return _sheetButton(
                      context,
                      label: _capitalize(type),
                      color: TypeColors.of(type),
                      selected: current == type,
                      onTap: () => Navigator.pop(context, type),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SortSheet extends StatelessWidget {
  const _SortSheet({required this.current});

  final PokemonSort current;

  @override
  Widget build(BuildContext context) {
    const options = PokemonSort.values;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select the order',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            for (final option in options) ...[
              _sheetButton(
                context,
                label: _sortLabel(option),
                color: AppTheme.textPrimary,
                selected: current == option,
                onTap: () => Navigator.pop(context, option),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

Widget _sheetButton(
  BuildContext _, {
  required String label,
  required Color color,
  required bool selected,
  required VoidCallback onTap,
}) {
  return SizedBox(
    width: double.infinity,
    height: 48,
    child: FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      child: Text(
        selected ? '$label  ✓' : label,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
  );
}

String _sortLabel(PokemonSort sort) {
  switch (sort) {
    case PokemonSort.smallestNumber:
      return 'Smallest number';
    case PokemonSort.largestNumber:
      return 'Largest number';
    case PokemonSort.nameAz:
      return 'A-Z';
    case PokemonSort.nameZa:
      return 'Z-A';
  }
}

String _capitalize(String value) =>
    value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);
