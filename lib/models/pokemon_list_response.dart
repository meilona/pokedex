import 'pokemon_basic.dart';

class PokemonListResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<PokemonBasic> results;

  const PokemonListResponse({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  factory PokemonListResponse.fromJson(Map<String, dynamic> json) {
    return PokemonListResponse(
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List)
          .map((e) => PokemonBasic.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  bool get hasNext => next != null;
  bool get hasPrevious => previous != null;

  int? get nextOffset {
    if (next == null) return null;
    final q = Uri.parse(next!).queryParameters;
    return int.tryParse(q['offset'] ?? '');
  }

  int? get previousOffset {
    if (previous == null) return null;
    final q = Uri.parse(previous!).queryParameters;
    return int.tryParse(q['offset'] ?? '');
  }
}
