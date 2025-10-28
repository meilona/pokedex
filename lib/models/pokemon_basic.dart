import 'package:pokedex_web/models/pokemon_ability.dart';

class PokemonBasic {
  PokemonBasic({
    required this.name,
    required this.url,
    this.primaryType,
    this.types,
    this.abilities,
  });

  factory PokemonBasic.fromJson(Map<String, dynamic> json) {
    return PokemonBasic(name: json['name'], url: json['url']);
  }
  final String name;
  final String url;
  String? primaryType;
  List<String>? types;
  List<PokemonAbility>? abilities;

  int get id {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    final idStr = segments.isNotEmpty
        ? segments.lastWhere((s) => s.isNotEmpty)
        : '0';
    return int.tryParse(idStr) ?? 0;
  }

  String get imageUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

  String get displayName =>
      name.isNotEmpty ? '${name[0].toUpperCase()}${name.substring(1)}' : name;

  String get formattedId => '#${id.toString().padLeft(3, "0")}';
}
