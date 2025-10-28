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
      // Pick an image height that adapts to the available width.
final imgH = (MediaQuery.sizeOf(context).width * 0.18)
    .clamp(80.0, 120.0); // min/max guard

      return DefaultTabController(
        length: 4,
        child: Scaffold(
          body: SafeArea(
            child: NestedScrollView(
              headerSliverBuilder: (_, __) => [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 380,
                  backgroundColor: bg1,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: Get.back,
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [bg1, bg2],
                        ),
                      ),
                      child: LayoutBuilder(
                        builder: (context, cns) {
                          final w = cns.maxWidth;
                          final ballSize = (w * 0.65).clamp(160.0, 320.0);

                          return Padding(
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // Top row: Name (handled by title) + ID on the right
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        d.displayName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 30,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '#${d.id.toString().padLeft(3, "0")}',
                                      textAlign: TextAlign.end,
                                      style: const TextStyle(
                                        color: Colors.black12,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                // Types row (chips)
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: d.types
                                      .map((t) => Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.15),
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
                                          ))
                                      .toList(),
                                ),

                                // Artwork area (center-aligned, responsive, no Positioned)
                                Align(
                                  alignment: AlignmentGeometry.bottomRight,
                                  child: Opacity(
                                    opacity: 0.10,
                                    child: SizedBox(
                                      width: ballSize,
                                      height: ballSize,
                                      child: Image.asset(
                                        'assets/images/pokeball.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  bottom: PreferredSize(
  // preferred size now depends on the image height
  preferredSize: Size.fromHeight(
    kTextTabBarHeight + (imgH * 0.25),
  ),
  child: _FloatingImageTabs(
    imageUrl: d.imageUrl ?? '',
    heroTag: 'pokemon-art-${d.id}',
    base: base,
    imageHeight: imgH,
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
                        _kv('Height', '${d.height/10} cm'),
                        _kv('Weight', '${d.weight/10} kg'),
                        _kv('Abilities', d.abilities.map((a)=>a.name.capitalizeFirst).join(", ")),
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
                      final evo = c.evolutions; // e.g. ["bulbasaur","ivysaur","venusaur"]
                      if (evo.isEmpty) {
                        return const Center(child: Text('No evolution data.'));
                      }
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: _EvolutionChain(
                          chain: evo,
                          currentName: d.name, // use the model's name to find current step
                          color: base,
                        ),
                      );
                    }),

                    // MOVES
                    // replace ListView with GridView
 GridView.builder(
  padding: const EdgeInsets.all(16),
  itemCount: d.moves.length,
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 8,
    mainAxisSpacing: 8,
    childAspectRatio: 3.5,
  ),
  itemBuilder: (_, i) {
    final move = d.moves[i];
    final displayName = move.replaceAll('-', ' ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: base.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.bolt, color: base, size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              displayName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  },
)
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
        Expanded(flex:1,child: Text(k, style: const TextStyle(color: Colors.black87))),
        // const SizedBox(width: 12),
        Expanded(flex:3,child: Text(v, style: const TextStyle(fontWeight: FontWeight.w600))),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex:1,child: Text('${label.capitalizeFirst}')),
          Expanded(flex:1,child:Text('$value', style: TextStyle(fontWeight: FontWeight.bold),)),
          Expanded(
            flex: 3,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: clamped / 200.0,
                  minHeight: 10,
                  color: value<60 ? Colors.red.shade400 : Colors.green.shade400,
                  backgroundColor: Colors.grey.shade100,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _FloatingImageTabs extends StatelessWidget implements PreferredSizeWidget {
  final String imageUrl;
  final String heroTag;
  final Color base;
  final double imageHeight;

  const _FloatingImageTabs({
    super.key,
    required this.imageUrl,
    required this.heroTag,
    required this.base,
    required this.imageHeight,
  });

  // How much the image floats above the rounded sheet
  double get _lift => imageHeight * 0.55;

  // preferredSize can be dynamic because it's derived from a ctor param
  @override
  Size get preferredSize =>
      Size.fromHeight(kTextTabBarHeight + (imageHeight * 0.25));

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none, // allow image to overflow upward
        children: [
          // Pokémon image floating above the bar
          Transform.translate(
            offset: Offset(0, -_lift),
            child: Hero(
              tag: heroTag,
              child: Image.network(
                imageUrl,
                height: imageHeight,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // TabBar with top padding based on image size
          Padding(
            // space so tabs don’t collide with the floating image
            padding: EdgeInsets.only(top: (imageHeight * 0.45).clamp(36, 64)),
            child: TabBar(
              isScrollable: true,
              labelColor: base,
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
        ],
      ),
    );
  }
}

class _EvolutionChain extends StatelessWidget {
  final List<String> chain;     // ordered list: 1 -> 2 -> 3
  final String currentName;     // d.name
  final Color color;

  const _EvolutionChain({
    required this.chain,
    required this.currentName,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final currentIdx = chain.indexWhere(
      (e) => e.toLowerCase() == currentName.toLowerCase(),
    );

    // Build nodes + arrows
    List<Widget> buildNodes(bool horizontal) {
      final widgets = <Widget>[];
      for (var i = 0; i < chain.length; i++) {
        final isCurrent = i == currentIdx;
        widgets.add(_EvoNode(
          index: i + 1,
          name: chain[i],
          isCurrent: isCurrent,
          color: color,
          onTap: () => Get.to(PokemonDetailPage, arguments: chain[i]),
        ));
        if (i < chain.length - 1) {
          widgets.add(_EvoArrow(
            color: color,
            horizontal: horizontal,
          ));
        }
      }
      return widgets;
    }

    return LayoutBuilder(
      builder: (context, cns) {
        final horizontal = cns.maxWidth >= 520; // row on wide, column on narrow

        if (horizontal) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: buildNodes(true)
                  .map((w) => Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: w))
                  .toList(),
            ),
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: buildNodes(false)
                .map((w) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: w))
                .toList(),
          );
        }
      },
    );
  }
}

class _EvoNode extends StatelessWidget {
  final int index;            // 1, 2, 3...
  final String name;          // "bulbasaur"
  final bool isCurrent;       // highlight the current one
  final Color color;
  final VoidCallback onTap;

  const _EvoNode({
    required this.index,
    required this.name,
    required this.isCurrent,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final display = name.isNotEmpty
        ? '${name[0].toUpperCase()}${name.substring(1)}'
        : name;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isCurrent ? color.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isCurrent ? color : Colors.grey.shade300),
          boxShadow: [
            if (isCurrent)
              BoxShadow(
                color: color.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StepBadge(index: index, color: color, active: isCurrent),
            const SizedBox(width: 10),
            Text(
              display,
              style: TextStyle(
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepBadge extends StatelessWidget {
  final int index;
  final Color color;
  final bool active;

  const _StepBadge({required this.index, required this.color, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? color : Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$index',
        style: TextStyle(
          color: active ? Colors.white : Colors.black54,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _EvoArrow extends StatelessWidget {
  final Color color;
  final bool horizontal; // true => right arrow, false => down arrow
  const _EvoArrow({required this.color, required this.horizontal});

  @override
  Widget build(BuildContext context) {
    return Icon(
      horizontal ? Icons.arrow_forward_rounded : Icons.arrow_downward_rounded,
      color: color.withOpacity(0.8),
      size: 22,
    );
  }
}
