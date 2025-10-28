import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pokedex_web/widgets/pokemon_card.dart';
import '../controllers/pokemon_list_controller.dart';

class PokemonListPage extends GetView<PokemonListController> {
  const PokemonListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(PokemonListController());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pokédex',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final pokemons = c.pokemons;
        if (pokemons.isEmpty) {
          return const Center(child: Text('No Pokémon found'));
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            // Responsive column & aspect ratio values
            int columns = 2;
            double aspect = 1.25;
            double padding = 8;

            if (width >= 400 && width < 700) {
              columns = 2;
              aspect = 1.3;
              padding = 10;
            } else if (width >= 700 && width < 1000) {
              columns = 3;
              aspect = 1.4;
              padding = 12;
            } else if (width >= 1000) {
              columns = 4;
              aspect = 1.5;
              padding = 14;
            }

            return GridView.builder(
              padding: EdgeInsets.all(padding),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                childAspectRatio: aspect,
                crossAxisSpacing: padding,
                mainAxisSpacing: padding,
              ),
              itemCount: pokemons.length,
              itemBuilder: (_, i) => PokemonCard(pokemons[i]),
            );
          },
        );
      }),
      bottomNavigationBar: Obx(() {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: c.hasPrevPage.value ? c.prevPage : null,
                child: const Text('Prev'),
              ),
              Text(
                'Page ${c.pageIndex.value + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: c.hasNextPage.value ? c.nextPage : null,
                child: const Text('Next'),
              ),
            ],
          ),
        );
      }),
    );
  }
}
