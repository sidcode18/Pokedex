# Pokédex Flutter App

A responsive Flutter application powered by PokéAPI that lets users browse Pokémon with infinite scrolling, search and filter loaded Pokémon, view detailed stats/abilities, and manage locally persisted favorites with real-time state synchronization across all screens.

---

## Features

- **Pokémon List**:
  - Fetches paginated Pokémon using PokéAPI.
  - Fast page loading: fetches only list endpoints on the main feed without issuing 20+ detail network calls per page.
  - Infinite scrolling with pagination guards preventing duplicate network requests.
  - Search filtering strictly scoped to currently loaded Pokémon.
  - Type filter modal and multiple sort orders (Smallest number, Largest number, A-Z, Z-A).
  - Handles initial loading, load-more indicators, pull-to-refresh, empty search states, and error retries.

- **Pokémon Detail View**:
  - Full data fetched on-demand only when a Pokémon is opened.
  - Displays high-resolution official artwork, Pokémon ID, name, and type badges with corresponding elemental theme colors.
  - Tabbed interface separating Pokémon metrics (Height, Weight, Abilities) and animated Base Stats (HP, ATK, DEF, SATK, SDEF, SPD).
  - Integrated favorite toggle button synchronized directly with the shared favorites state.

- **Favorites**:
  - Single source of truth managed by `FavoritesProvider`.
  - Adding or removing favorites updates immediately across list cards, detail screen, and the Favorites tab.
  - Swipe-to-dismiss deletion on the Favorites screen.
  - Persisted locally to survive app restarts.
  - Graceful fallback and error recovery for corrupt or missing local storage data.

---

## How to Run

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.13+ / Dart 3.13+)

### Commands
```bash
# 1. Install dependencies
flutter pub get

# 2. Run code formatting check
dart format .

# 3. Run static analyzer
flutter analyze

# 4. Run test suite
flutter test

# 5. Launch app on connected device or simulator
flutter run
```

---

## Architecture & Project Structure

The project adheres to a clean, straightforward layered architecture:

```
lib/
├── models/         # Data representations and JSON parsing (Pokemon, PokemonStat, PokemonPage)
├── providers/      # Business logic & state management (PokemonListProvider, PokemonDetailProvider, FavoritesProvider)
├── services/       # Network calls (PokeApiService) & local storage (FavoritesStorage)
├── screens/        # Top-level screen views (HomeShell, PokemonListScreen, PokemonDetailScreen, FavoritesScreen)
├── widgets/        # Reusable UI components (PokemonCard, FavoriteButton, TypeChip, StatBar, StatusViews)
└── theme/          # Type color palettes and theme configurations (AppTheme, TypeColors)
```

---

## Design & Technology Decisions

### Why Provider?
- **Lightweight & Idiomatic**: `provider` is Flutter's standard approach for scoped dependency injection and reactive state management without the boilerplate of heavier alternatives like BLoC or Redux.
- **Single Source of Truth**: `FavoritesProvider` acts as the central state holder for favorites. Any modification instantly triggers selective rebuilds (`context.select` / `context.watch`) across the list, detail, and favorites views simultaneously without out-of-sync states.

### Why SharedPreferences?
- **No Overhead**: Used for lightweight key-value storage of favorited Pokémon IDs and cached summary data.
- **Offline Favorites**: Avoids complex external database setups (SQLite, Hive, Firebase) while providing instant startup restoration and resilience to app restarts.

---

## API Used

- **Base URL**: `https://pokeapi.co/api/v2/`
- **List Endpoint**: `GET /pokemon?limit=20&offset={offset}`
- **Detail Endpoint**: `GET /pokemon/{name_or_id}`
- **Official Artwork Sprite**: `https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/{id}.png`

---

## Assumptions & Limitations

- **Local Search Scope**: As specified in the requirements, the search bar filters among the currently loaded/paginated Pokémon in memory rather than querying the remote API for unseen entries.
- **Network Dependency for Detail**: Full stats and abilities are fetched dynamically when opening a Pokémon detail screen. If offline and not previously cached as a favorite, an error retry view is shown.

---

## What Could Be Improved With More Time

1. **Evolution Chains & Weaknesses**: Integrate PokéAPI's species and evolution-chain endpoints to display evolution stages and type weaknesses.
2. **Audio & Cries**: Add Pokémon cry audio playback using PokéAPI's audio assets.
3. **Advanced Offline Caching**: Implement full HTTP response caching (e.g. using `dio_cache_interceptor` or local SQLite) for seamless offline detail browsing.
4. **Hero Animations & Sound Effects**: Add shared element transitions between card artwork and detail header.
