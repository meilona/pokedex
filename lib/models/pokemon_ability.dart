class PokemonAbility {
  PokemonAbility({
    required this.name,
    required this.url,
    required this.isHidden,
    required this.slot,
  });

  factory PokemonAbility.fromJson(Map<String, dynamic> json) {
    return PokemonAbility(
      name: json['ability']?['name'] ?? '',
      url: json['ability']?['url'] ?? '',
      isHidden: json['is_hidden'] ?? false,
      slot: (json['slot'] as num?)?.toInt() ?? 0,
    );
  }
  final String name;
  final String url;
  final bool isHidden;
  final int slot;
}
