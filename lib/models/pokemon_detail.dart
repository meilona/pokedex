import 'package:pokedex_web/models/pokemon_ability.dart';

class PokemonDetail {
  PokemonDetail({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.baseExperience,
    required this.imageUrl,
    required this.types,
    required this.stats,
    required this.moves,
    required this.abilities,
    required this.speciesName,
    required this.speciesUrl,
  });

  factory PokemonDetail.fromJson(Map<String, dynamic> json) {
    // pick best image available
    final other = json['sprites']?['other'] as Map<String, dynamic>?;
    final official = other?['official-artwork']?['front_default'] as String?;
    final frontDefault = json['sprites']?['front_default'] as String?;

    final types = (json['types'] as List<dynamic>)
        .map((e) => (e['type']['name'] as String?) ?? '')
        .where((e) => e.isNotEmpty)
        .toList();

    final stats = <String, int>{};
    for (final s in (json['stats'] as List<dynamic>)) {
      final name = s['stat']['name'] as String;
      final value = (s['base_stat'] as num).toInt();
      stats[name] = value;
    }

    final moves = (json['moves'] as List<dynamic>)
        .map((m) => (m['move']['name'] as String?) ?? '')
        .where((e) => e.isNotEmpty)
        .toList();

    final abilities = (json['abilities'] as List<dynamic>)
        .map((a) => PokemonAbility.fromJson(a as Map<String, dynamic>))
        .toList();

    final species = json['species'] as Map<String, dynamic>? ?? {};

    return PokemonDetail(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      height: (json['height'] as num).toInt(),
      weight: (json['weight'] as num).toInt(),
      baseExperience: (json['base_experience'] as num?)?.toInt() ?? 0,
      imageUrl: official ?? frontDefault,
      types: types,
      stats: stats,
      moves: moves,
      abilities: abilities,
      speciesName: (species['name'] as String?) ?? '',
      speciesUrl: (species['url'] as String?) ?? '',
    );
  }
  final int id;
  final String name;
  final int height; // dm
  final int weight; // hg
  final int baseExperience;
  final String? imageUrl; // official artwork or front_default
  final List<String> types; // ["grass", "poison"]
  final Map<String, int> stats; // {"hp": 45, "attack": 49, ...}
  final List<String> moves; // move names (you can limit in UI)
  final List<PokemonAbility> abilities; // abilities with isHidden
  final String speciesName;
  final String speciesUrl;
}

extension PokemonDetailX on PokemonDetail {
  String get displayName =>
      name.isNotEmpty ? name[0].toUpperCase() + name.substring(1) : name;
}
