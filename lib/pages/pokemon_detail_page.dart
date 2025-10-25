// lib/pages/pokemon_detail_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pokedex_web/models/pokemon_detail.dart';
import '../controllers/pokemon_detail_controller.dart';
import '../utils/pokemon_type_color.dart';

class PokemonDetailPage extends GetView<PokemonDetailController> {
  const PokemonDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    // No Binding: read the argument and register controller here.
    final String idOrName = (Get.arguments is String && (Get.arguments as String).isNotEmpty)
        ? Get.arguments as String
        : (Get.parameters['id'] ?? Get.parameters['name'] ?? 'bulbasaur');

    // Tag by id/name so multiple detail pages can coexist.
    final c = Get.put(PokemonDetailController(idOrName), tag: idOrName, permanent: false);

    return Obx(() {
      if (c.isLoading.value && c.model.value == null) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      final d = c.model.value;
      if (d == null) {
        return Scaffold(
          appBar: AppBar(),
          body: Center(
            child: FilledButton(
              onPressed: c.fetchDetail,
              child: const Text('Retry'),
            ),
          ),
        );
      }

      final primaryType = d.types.isNotEmpty ? d.types.first : 'normal';
      final base = PokemonTypeColor.getColor(primaryType);
      final bg1 = base;
      final bg2 = base.withOpacity(0.65);

      return DefaultTabController(
        length: 4,
        child: Scaffold(
          floatingActionButton: c.isLoading.value
              ? null
              : FloatingActionButton.extended(
                  onPressed: c.fetchDetail,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                  backgroundColor: base,
                ),
          body: SafeArea(
            child: NestedScrollView(
              headerSliverBuilder: (_, __) => [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 260,
                  backgroundColor: bg1,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: Get.back,
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 16, bottom: 12),
                    title: Text(d.displayName),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [bg1, bg2],
                            ),
                          ),
                        ),
                        Positioned(
                          right: 12,
                          top: 18,
                          child: Text(
                            '#${d.id.toString().padLeft(3, "0")}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        // Positioned(
                        //   left: 12,
                        //   top: 18,
                        //   child: Wrap(
                        //     spacing: 6,
                        //     children: d.types
                        //         .map((t) => Chip(
                        //               visualDensity: VisualDensity.compact,
                        //               backgroundColor: Colors.white.withOpacity(0.18),
                        //               label: Text(
                        //                 t.toUpperCase(),
                        //                 style: const TextStyle(color: Colors.white),
                        //               ),
                        //               shape: StadiumBorder(
                        //                 side: BorderSide(color: Colors.white.withOpacity(0.25)),
                        //               ),
                        //             ))
                        //         .toList(),
                        //   ),
                        // ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Hero(
                            tag: 'pokemon-art-${d.id}',
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: AspectRatio(
                                aspectRatio: 1.6,
                                child: d.imageUrl == null
                                    ? const Icon(Icons.catching_pokemon,
                                        size: 160, color: Colors.white)
                                    : Image.network(
                                        d.imageUrl!,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.catching_pokemon,
                                                size: 160, color: Colors.white),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(52),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x22000000),
                            blurRadius: 12,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: TabBar(
                        isScrollable: true,
                        labelColor: base.darken(0.12),
                        unselectedLabelColor: Colors.black54,
                        indicatorColor: base,
                        tabs: const [
                          Tab(text: 'About'),
                          Tab(text: 'Base Stats'),
                          Tab(text: 'Evolution'),
                          Tab(text: 'Moves'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              body: Container(
                color: Colors.white,
                child: TabBarView(
                  children: [
                    // ABOUT
                    ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _kv('Species', d.speciesName),
                        _kv('Height', '${d.height} dm'),
                        _kv('Weight', '${d.weight} hg'),
                        _kv('Base Experience', '${d.baseExperience}'),
                        const SizedBox(height: 16),
                        const Text('Abilities',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: d.abilities
                              .map((a) => Chip(
                                    label: Text(a.isHidden ? '${a.name} (Hidden)' : a.name),
                                    backgroundColor: base.withOpacity(0.08),
                                    side: BorderSide(color: base.withOpacity(0.22)),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),

                    // BASE STATS
                    ListView(
                      padding: const EdgeInsets.all(16),
                      children: d.stats.entries
                          .map((e) => _StatRow(label: e.key, value: e.value, color: base))
                          .toList(),
                    ),
                    // EVOLUTION
                    Obx(() {
                      final evo = c.evolutions;
                      if (evo.isEmpty) {
                        return const Center(child: Text('No evolution data.'));
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (_, i) => ListTile(
                          leading: Icon(Icons.trending_up, color: base),
                          title: Text(evo[i].capitalizeFirst ?? evo[i]),
                        ),
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemCount: evo.length,
                      );
                    }),

                    // MOVES
                    ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: d.moves.length.clamp(0, 60),
                      itemBuilder: (_, i) => ListTile(
                        dense: true,
                        leading: Icon(Icons.bolt, color: base),
                        title: Text(d.moves[i]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

// Simple key/value line
Widget _kv(String k, String v) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(child: Text(k, style: const TextStyle(color: Colors.black87))),
        const SizedBox(width: 12),
        Text(v, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

class _StatRow extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0, 200).toDouble();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${label.toUpperCase()} ($value)'),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: clamped / 200.0,
              minHeight: 10,
              color: color,
              backgroundColor: color.withOpacity(0.15),
            ),
          ),
        ],
      ),
    );
  }
}

// small darken util for tab colors
extension _ColorX on Color {
  Color darken([double amount = .1]) {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }
}