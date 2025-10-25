import 'package:get/get.dart';
import '../services/poke_api_service.dart';
import '../models/pokemon_basic.dart';
import '../models/pokemon_list_response.dart';

class PokemonListController extends GetxController {
  final limit = 20;
  var offset = 0.obs;
  var response = Rxn<PokemonListResponse>();
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPokemons();
  }

  Future<void> fetchPokemons() async {
    isLoading(true);
    try {
      final data = await PokeApiService.getPokemonList(limit, offset.value);
      response.value = data;
    } finally {
      isLoading(false);
    }
  }

  final detailsCache = <int, List<String>>{}.obs; // id -> types

  Future<void> fetchTypesIfNeeded(int id, String name) async {
    if (detailsCache.containsKey(id)) return;
    final detail = await PokeApiService.getPokemonDetail(name);
    detailsCache[id] = detail.types;
  }

  List<PokemonBasic> get pokemons => response.value?.results ?? [];

  void nextPage() {
    offset.value += limit;
    fetchPokemons();
  }

  void prevPage() {
    if (offset.value > 0) {
      offset.value -= limit;
      fetchPokemons();
    }
  }
}