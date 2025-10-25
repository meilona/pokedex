class PokemonBasic {
  final String name;
  final String url;

  const PokemonBasic({
    required this.name,
    required this.url,
  });

  factory PokemonBasic.fromJson(Map<String, dynamic> json) {
    return PokemonBasic(
      name: json['name'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'url': url,
      };

  /// Extract Pokémon ID from its URL (e.g. .../pokemon/1/)
  int get id {
    final uri = Uri.parse(url);
    final parts = uri.pathSegments;
    return int.tryParse(parts.isNotEmpty ? parts.lastWhere((p) => p.isNotEmpty) : '0') ?? 0;
  }

  String get formattedId => '#${id.toString().padLeft(3, "0")}';

  /// Get image URL (optional convenience)
  String get imageUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
}

extension PokemonBasicExtension on PokemonBasic {
  /// Capitalized name (e.g. "bulbasaur" → "Bulbasaur")
  String get displayName =>
      name.isNotEmpty ? name[0].toUpperCase() + name.substring(1) : name;
}