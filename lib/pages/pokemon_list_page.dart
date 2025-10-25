import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pokedex_web/models/pokemon_basic.dart';
import '../controllers/pokemon_list_controller.dart';
import 'pokemon_detail_page.dart';
import '../utils/pokemon_type_color.dart';

class PokemonListPage extends StatelessWidget {
  PokemonListPage({super.key});
  final controller = Get.put(PokemonListController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pokédex')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 3.5,
                ),
                itemCount: controller.pokemons.length,
                itemBuilder: (_, i) {
                  final p = controller.pokemons[i];
                  return InkWell(
                    onTap: () => 
                    Get.to(() => PokemonDetailPage(), arguments: p.name),
                    child: Obx(() {
                      final types = controller.detailsCache[p.id];
                      if (types == null) {
                        controller.fetchTypesIfNeeded(p.id, p.name);
                        return const Text('Loading...');
                      }
                      return Container(
                      decoration: BoxDecoration(
                        color: PokemonTypeColor.getColor(types.first),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(p.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: types
                                    .map((t) => Chip(label: Text(t.toUpperCase())))
                                    .toList(),
                              ),
                              Image.network(p.imageUrl, height: 80),
                            ],),
                          ],
                        ),
                      );
                    }),
                    
                    // Card(
                    //   elevation: 1,
                    //   child: Padding(
                    //     padding: const EdgeInsets.symmetric(horizontal: 16),
                    //     child: Column(
                    //       mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //       children: [
                    //         Row(
                    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //           children: [
                    //             Text(
                    //               p.displayName,
                    //               style: const TextStyle(fontWeight: FontWeight.w600),
                    //             ),
                    //             const Icon(Icons.chevron_right),
                    //           ],
                    //         ),
                    //         Row(
                    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //           children: [
                    //             Obx(() {
                    //               final types = controller.detailsCache[p.id];
                    //               if (types == null) {
                    //                 controller.fetchTypesIfNeeded(p.id, p.name);
                    //                 return const Text('Loading...');
                    //               }
                    //               return Wrap(
                    //                 spacing: 8,
                    //                 runSpacing: 8,
                    //                 children: types
                    //                     .map((t) => Chip(label: Text(t.toUpperCase())))
                    //                     .toList(),
                    //               );
                    //             }),
                    //             Image.network(
                    //               p.imageUrl,
                    //               width: 70,
                    //               height: 70,
                    //               fit: BoxFit.contain,
                    //               errorBuilder: (_, __, ___) => const Icon(Icons.catching_pokemon),
                    //             ),
                    //           ],
                    //         )
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FilledButton.tonal(
                    onPressed: controller.offset.value == 0 ? null : controller.prevPage,
                    child: const Text('Prev'),
                  ),
                  Text('Page ${(controller.offset.value ~/ controller.limit) + 1}'),
                  FilledButton(onPressed: controller.nextPage, child: const Text('Next')),
                ],
              ),
            )
          ],
        );
      }),
    );
  }
}