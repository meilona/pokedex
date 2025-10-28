import 'package:get/get.dart';
import 'package:pokedex_web/services/poke_api_service.dart';
import '../models/pokemon_basic.dart';

class PokemonListController extends GetxController {
  final pokemons = <PokemonBasic>[].obs;
  final isLoading = false.obs;

  final offset = 0.obs;
  final limit = 20;
  final hasNextPage = false.obs;
  final hasPrevPage = false.obs;
  final pageIndex = 0.obs;

  final _detailsCache = <String, Map<String, dynamic>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPokemons();
  }

  Future<void> fetchPokemons() async {
    try {
      isLoading.value = true;

      final response = await PokeApiService.getPokemonList(
        limit: limit,
        offset: offset.value,
      );
      // Directly use properties from the model
      pokemons.assignAll(response.results);
      hasNextPage.value = response.next != null;
      hasPrevPage.value = response.previous != null;

      // Fetch abilities + types asynchronously
      for (final p in response.results) {
        _fetchDetailsForPokemon(p);
      }
    } catch (e) {
      print('❌ Error fetching Pokémon list: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchDetailsForPokemon(PokemonBasic p) async {
    // Don’t fetch again if cached
    if (_detailsCache.containsKey(p.name)) {
      final cached = _detailsCache[p.name]!;
      p.primaryType = cached['type'];
      p.abilities = cached['abilities'];
      p.types = cached['types'];
      pokemons.refresh();
      return;
    }

    try {
      final detail = await PokeApiService.getPokemonDetail(p.name);

      p.primaryType = detail.types.isNotEmpty ? detail.types.first : 'normal';
      p.abilities = detail.abilities;
      p.types = detail.types;

      _detailsCache[p.name] = {
        'type': p.primaryType,
        'abilities': p.abilities,
        'types': p.types,
      };

      pokemons.refresh();
    } catch (e) {
      print('⚠️ Error fetching details for ${p.name}: $e');
    }
  }

  void nextPage() {
    if (hasNextPage.value) {
      offset.value += limit;
      pageIndex.value += 1;
      fetchPokemons();
    }
  }

  void prevPage() {
    if (offset.value >= limit) {
      offset.value -= limit;
      pageIndex.value -= 1;
      fetchPokemons();
    }
  }
}
