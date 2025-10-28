import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pokedex_web/pages/pokemon_detail_page.dart';
import '../models/pokemon_basic.dart';
import '../utils/pokemon_type_color.dart';
import 'package:flutter/foundation.dart';

class PokemonCard extends StatelessWidget {
  const PokemonCard(this.p, {super.key});
  final PokemonBasic p;

  @override
  Widget build(BuildContext context) {
    final color = PokemonTypeColor.getColor(p.primaryType ?? 'normal');

    return InkWell(
      onTap: () => Get.to<PokemonDetailPage>(() => const PokemonDetailPage(), arguments: p.name),
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Pokéball watermark
          Positioned.fill(
            top: 50,
            left: 120,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.3,
                child: Image.asset(
                  'assets/images/pokeball.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Foreground content
          Container(
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Id
                  Text(
                    p.formattedId,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: Colors.black12,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Pokémon name
                  Text(
                    p.displayName,
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            p.types?.map((t) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha:0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  t.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList() ??
                            [],
                      ),
                      SizedBox(
                        height: 100,
                        child: FittedBox(
                          child: Image.network(
                            p.imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.catching_pokemon,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<PokemonBasic>('p', p));
  }
}
