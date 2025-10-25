import 'package:get/get.dart';
import '../pages/pokemon_detail_page.dart';

class AppPages {
  static const detail = '/detail';

  static final routes = <GetPage>[
    GetPage(
  name: '/detail',
  page: () => const PokemonDetailPage(), // no binding
)

  ];
}
