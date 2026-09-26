class PokemonStat {
  const PokemonStat({required this.name, required this.value});

  final String name;
  final int value;

  factory PokemonStat.fromJson(Map<String, dynamic> json) {
    final stat = json['stat'];
    final name = stat is Map<String, dynamic>
        ? (stat['name'] as String? ?? 'unknown')
        : 'unknown';
    final value = json['base_stat'];
    return PokemonStat(
      name: name,
      value: value is int ? value : int.tryParse('$value') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'value': value};

  factory PokemonStat.fromCache(Map<String, dynamic> json) {
    return PokemonStat(
      name: json['name'] as String? ?? 'unknown',
      value: json['value'] as int? ?? 0,
    );
  }
}

class Pokemon {
  const Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.types = const [],
    this.heightDecimetres,
    this.weightHectograms,
    this.abilities = const [],
    this.stats = const [],
  });

  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;
  final int? heightDecimetres;
  final int? weightHectograms;
  final List<String> abilities;
  final List<PokemonStat> stats;

  String get displayName {
    if (name.isEmpty) return 'Unknown';
    return name[0].toUpperCase() + name.substring(1);
  }

  String get paddedId => '#${id.toString().padLeft(3, '0')}';

  String get primaryType => types.isNotEmpty ? types.first : 'normal';

  double? get heightMeters =>
      heightDecimetres == null ? null : heightDecimetres! / 10;

  double? get weightKilograms =>
      weightHectograms == null ? null : weightHectograms! / 10;

  static String artworkUrlFor(int id) {
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
  }

  static int? idFromUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    final parts = uri.pathSegments.where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return null;
    return int.tryParse(parts.last);
  }

  factory Pokemon.fromListResult(Map<String, dynamic> json) {
    final name = (json['name'] as String? ?? 'unknown').toLowerCase();
    final id = idFromUrl(json['url'] as String?) ?? 0;
    return Pokemon(id: id, name: name, imageUrl: artworkUrlFor(id));
  }

  factory Pokemon.fromDetailJson(Map<String, dynamic> json) {
    final id = json['id'] is int
        ? json['id'] as int
        : int.tryParse('${json['id']}') ??
              idFromUrl(json['species']?['url'] as String?) ??
              0;

    final sprites = json['sprites'];
    String? image;
    if (sprites is Map<String, dynamic>) {
      final other = sprites['other'];
      if (other is Map<String, dynamic>) {
        final official = other['official-artwork'];
        if (official is Map<String, dynamic>) {
          image = official['front_default'] as String?;
        }
        image ??= (other['home'] is Map<String, dynamic>)
            ? (other['home'] as Map<String, dynamic>)['front_default']
                  as String?
            : null;
      }
      image ??= sprites['front_default'] as String?;
    }

    final types = <String>[];
    final typesJson = json['types'];
    if (typesJson is List) {
      for (final entry in typesJson) {
        if (entry is Map<String, dynamic>) {
          final type = entry['type'];
          if (type is Map<String, dynamic>) {
            final typeName = type['name'] as String?;
            if (typeName != null && typeName.isNotEmpty) {
              types.add(typeName);
            }
          }
        }
      }
    }

    final abilities = <String>[];
    final abilitiesJson = json['abilities'];
    if (abilitiesJson is List) {
      for (final entry in abilitiesJson) {
        if (entry is Map<String, dynamic>) {
          final ability = entry['ability'];
          if (ability is Map<String, dynamic>) {
            final abilityName = ability['name'] as String?;
            if (abilityName != null && abilityName.isNotEmpty) {
              abilities.add(abilityName);
            }
          }
        }
      }
    }

    final stats = <PokemonStat>[];
    final statsJson = json['stats'];
    if (statsJson is List) {
      for (final entry in statsJson) {
        if (entry is Map<String, dynamic>) {
          stats.add(PokemonStat.fromJson(entry));
        }
      }
    }

    return Pokemon(
      id: id,
      name: (json['name'] as String? ?? 'unknown').toLowerCase(),
      imageUrl: (image == null || image.isEmpty) ? artworkUrlFor(id) : image,
      types: types,
      heightDecimetres: json['height'] is int
          ? json['height'] as int
          : int.tryParse('${json['height']}'),
      weightHectograms: json['weight'] is int
          ? json['weight'] as int
          : int.tryParse('${json['weight']}'),
      abilities: abilities,
      stats: stats,
    );
  }

  Map<String, dynamic> toCacheJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'types': types,
      'heightDecimetres': heightDecimetres,
      'weightHectograms': weightHectograms,
      'abilities': abilities,
      'stats': stats.map((stat) => stat.toJson()).toList(),
    };
  }

  factory Pokemon.fromCacheJson(Map<String, dynamic> json) {
    final typesJson = json['types'];
    final abilitiesJson = json['abilities'];
    final statsJson = json['stats'];
    return Pokemon(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'unknown',
      imageUrl:
          json['imageUrl'] as String? ?? artworkUrlFor(json['id'] as int? ?? 0),
      types: typesJson is List
          ? typesJson.whereType<String>().toList()
          : const [],
      heightDecimetres: json['heightDecimetres'] as int?,
      weightHectograms: json['weightHectograms'] as int?,
      abilities: abilitiesJson is List
          ? abilitiesJson.whereType<String>().toList()
          : const [],
      stats: statsJson is List
          ? statsJson
                .whereType<Map<String, dynamic>>()
                .map(PokemonStat.fromCache)
                .toList()
          : const [],
    );
  }

  Pokemon copyWith({
    int? id,
    String? name,
    String? imageUrl,
    List<String>? types,
    int? heightDecimetres,
    int? weightHectograms,
    List<String>? abilities,
    List<PokemonStat>? stats,
  }) {
    return Pokemon(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      types: types ?? this.types,
      heightDecimetres: heightDecimetres ?? this.heightDecimetres,
      weightHectograms: weightHectograms ?? this.weightHectograms,
      abilities: abilities ?? this.abilities,
      stats: stats ?? this.stats,
    );
  }
}

class PokemonPage {
  const PokemonPage({required this.pokemon, required this.nextUrl});

  final List<Pokemon> pokemon;
  final String? nextUrl;
}
