import 'package:get/get.dart';
import '../models/pokemon_detail.dart';
import '../services/poke_api_service.dart';

class PokemonDetailController extends GetxController {
  PokemonDetailController(this.nameOrId);
  final String nameOrId;

  final model = Rxn<PokemonDetail>();
  final evolutions = <String>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    isLoading(true);
    try {
      final d = await PokeApiService.getPokemonDetail(nameOrId);
      model.value = d;
      evolutions.assignAll(await PokeApiService.getEvolutionNamesFromDetail(d));
    } finally {
      isLoading(false);
    }
  }
}
