import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/favorites_provider.dart';
import 'providers/pokemon_list_provider.dart';
import 'screens/home_shell.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final favorites = FavoritesProvider();
  await favorites.load();

  runApp(PokedexApp(favorites: favorites));
}

class PokedexApp extends StatelessWidget {
  const PokedexApp({super.key, required this.favorites});

  final FavoritesProvider favorites;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: favorites),
        ChangeNotifierProvider(create: (_) => PokemonListProvider()),
      ],
      child: MaterialApp(
        title: 'Pokédex',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const HomeShell(),
      ),
    );
  }
}
