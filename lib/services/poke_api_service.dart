import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon_detail.dart';
import '../models/pokemon_list_response.dart'; // already used for list

class PokeApiService {
  static const baseUrl = 'https://pokeapi.co/api/v2';

  // LIST (already shown before)
  static Future<PokemonListResponse> getPokemonList({
    required int limit,
    required int offset,
  }) async {
    final res = await http.get(
      Uri.parse('$baseUrl/pokemon?limit=$limit&offset=$offset'),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to load pokemon list (${res.statusCode})');
    }
    return PokemonListResponse.fromJson(jsonDecode(res.body));
  }

  // DETAIL (typed)
  static Future<PokemonDetail> getPokemonDetail(String nameOrId) async {
    final res = await http.get(Uri.parse('$baseUrl/pokemon/$nameOrId'));
    if (res.statusCode != 200) {
      throw Exception('Failed to load pokemon detail (${res.statusCode})');
    }
    return PokemonDetail.fromJson(jsonDecode(res.body));
  }

  // Evolution names (optional helper you already used)
  static Future<List<String>> getEvolutionNamesFromDetail(
    PokemonDetail detail,
  ) async {
    if (detail.speciesUrl.isEmpty) return [];
    final speciesRes = await http.get(Uri.parse(detail.speciesUrl));
    if (speciesRes.statusCode != 200) return [];
    final species = jsonDecode(speciesRes.body) as Map<String, dynamic>;
    final evoUrl = (species['evolution_chain']?['url'] as String?) ?? '';
    if (evoUrl.isEmpty) return [];
    final evoRes = await http.get(Uri.parse(evoUrl));
    if (evoRes.statusCode != 200) return [];
    final evo = jsonDecode(evoRes.body) as Map<String, dynamic>;

    final List<String> names = [];
    void walk(Map<String, dynamic> node) {
      names.add(node['species']['name'] as String);
      for (final child in (node['evolves_to'] as List)) {
        walk(child as Map<String, dynamic>);
      }
    }

    walk(evo['chain'] as Map<String, dynamic>);
    return names;
  }
}
