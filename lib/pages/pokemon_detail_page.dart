import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pokedex_web/models/pokemon_detail.dart';
import 'package:pokedex_web/widgets/key_value.dart';
import '../controllers/pokemon_detail_controller.dart';
import '../utils/pokemon_type_color.dart';
import 'package:flutter/foundation.dart';

class PokemonDetailPage extends GetView<PokemonDetailController> {
  const PokemonDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    // No Binding: read the argument and register controller here.
    final String idOrName =
        (Get.arguments is String && (Get.arguments as String).isNotEmpty)
        ? Get.arguments as String
        : (Get.parameters['id'] ?? Get.parameters['name'] ?? 'bulbasaur');

    // Tag by id/name so multiple detail pages can coexist.
    final c = Get.put(PokemonDetailController(idOrName), tag: idOrName);

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
      final bg2 = base.withValues(alpha:0.65);
      final imgH = (MediaQuery.sizeOf(context).width * 0.18).clamp(80.0, 120.0);

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
                    onPressed: () => Get.back<void>(),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: _HeaderBackground(bg1: bg1, bg2: bg2, d: d),
                  ),
                  bottom: PreferredSize(
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
                        KeyValueWidget('Species', d.speciesName),
                        KeyValueWidget('Height', '${d.height / 10} cm'),
                        KeyValueWidget('Weight', '${d.weight / 10} kg'),
                        KeyValueWidget(
                          'Abilities',
                          d.abilities
                              .map((a) => a.name.capitalizeFirst)
                              .join(', '),
                        ),
                      ],
                    ),

                    // BASE STATS
                    ListView(
                      padding: const EdgeInsets.all(16),
                      children: d.stats.entries
                          .map(
                            (e) => _StatRow(
                              label: e.key,
                              value: e.value,
                              color: base,
                            ),
                          )
                          .toList(),
                    ),

                    // EVOLUTION
                    Obx(() {
                      final evo = c.evolutions;
                      if (evo.isEmpty) {
                        return const Center(child: Text('No evolution data.'));
                      }
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: _EvolutionChain(
                          chain: evo,
                          currentName: d.name,
                          color: base,
                        ),
                      );
                    }),

                    // MOVES
                    GridView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: d.moves.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 3.5,
                          ),
                      itemBuilder: (_, i) {
                        final move = d.moves[i];
                        final displayName = move.replaceAll('-', ' ');
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: base.withValues(alpha:0.08),
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
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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

/// ----------------------
/// Header (gradient + name + id + types + pokeball)
/// ----------------------
class _HeaderBackground extends StatelessWidget {
  const _HeaderBackground({
    required this.bg1,
    required this.bg2,
    required this.d,
  });

  final Color bg1;
  final Color bg2;
  final PokemonDetail d;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: Stack(
              children: [
                // Main column content
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeaderTitleRow(d: d),
                    const SizedBox(height: 6),
                    _TypeChips(types: d.types),
                  ],
                ),
                // Pokeball overlay
                Align(
                  alignment: Alignment.bottomRight,
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
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('bg1', bg1));
    properties.add(ColorProperty('bg2', bg2));
    properties.add(DiagnosticsProperty<PokemonDetail>('d', d));
  }
}

class _HeaderTitleRow extends StatelessWidget {
  const _HeaderTitleRow({required this.d});
  final PokemonDetail d;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 50),
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
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<PokemonDetail>('d', d));
  }
}

class _TypeChips extends StatelessWidget {
  const _TypeChips({required this.types});
  final List<String> types;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: types
          .map(
            (t) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
            ),
          )
          .toList(),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<String>('types', types));
  }
}

/// ----------------------
/// Base stats row
/// ----------------------
class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0, 200).toDouble();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text('${label.capitalizeFirst}')),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$value',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: clamped / 200.0,
                  minHeight: 10,
                  color: value < 60 ? Colors.redAccent : Colors.green,
                  backgroundColor: Colors.grey.shade100,
                ),
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
    properties.add(StringProperty('label', label));
    properties.add(IntProperty('value', value));
    properties.add(ColorProperty('color', color));
  }
}

/// ----------------------
/// Tabs with floating image
/// ----------------------
class _FloatingImageTabs extends StatelessWidget
    implements PreferredSizeWidget {
  const _FloatingImageTabs({
    required this.imageUrl,
    required this.heroTag,
    required this.base,
    required this.imageHeight,
  });
  final String imageUrl;
  final String heroTag;
  final Color base;
  final double imageHeight;

  double get _lift => imageHeight * 0.55;

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
        clipBehavior: Clip.none,
        children: [
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
          Padding(
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('imageUrl', imageUrl));
    properties.add(StringProperty('heroTag', heroTag));
    properties.add(ColorProperty('base', base));
    properties.add(DoubleProperty('imageHeight', imageHeight));
  }
}

/// ----------------------
/// Evolution chain
/// ----------------------
class _EvolutionChain extends StatelessWidget {
  const _EvolutionChain({
    required this.chain,
    required this.currentName,
    required this.color,
  });
  final List<String> chain; // ordered list: 1 -> 2 -> 3
  final String currentName; // d.name
  final Color color;

  @override
  Widget build(BuildContext context) {
    final currentIdx = chain.indexWhere(
      (e) => e.toLowerCase() == currentName.toLowerCase(),
    );

    List<Widget> buildNodes(bool horizontal) {
      final widgets = <Widget>[];
      for (var i = 0; i < chain.length; i++) {
        final isCurrent = i == currentIdx;
        widgets.add(
          _EvoNode(
            index: i + 1,
            name: chain[i],
            isCurrent: isCurrent,
            color: color,
            onTap: () => Get.to<PokemonDetailPage>(() => const PokemonDetailPage(), arguments: chain[i]),
          ),
        );
        if (i < chain.length - 1) {
          widgets.add(_EvoArrow(color: color, horizontal: horizontal));
        }
      }
      return widgets;
    }

    return LayoutBuilder(
      builder: (context, cns) {
        final horizontal = cns.maxWidth >= 520;
        final children = buildNodes(horizontal)
            .map(
              (w) => Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontal ? 6 : 0,
                  vertical: horizontal ? 0 : 6,
                ),
                child: w,
              ),
            )
            .toList();

        if (horizontal) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: children,
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        );
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<String>('chain', chain));
    properties.add(StringProperty('currentName', currentName));
    properties.add(ColorProperty('color', color));
  }
}

class _EvoNode extends StatelessWidget {
  const _EvoNode({
    required this.index,
    required this.name,
    required this.isCurrent,
    required this.color,
    required this.onTap,
  });
  final int index; // 1, 2, 3...
  final String name; // "bulbasaur"
  final bool isCurrent; // highlight the current one
  final Color color;
  final VoidCallback onTap;

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
          color: isCurrent ? color.withValues(alpha:0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isCurrent ? color : Colors.grey.shade300),
          boxShadow: [
            if (isCurrent)
              BoxShadow(
                color: color.withValues(alpha:0.12),
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('index', index));
    properties.add(StringProperty('name', name));
    properties.add(DiagnosticsProperty<bool>('isCurrent', isCurrent));
    properties.add(ColorProperty('color', color));
    properties.add(ObjectFlagProperty<VoidCallback>.has('onTap', onTap));
  }
}

class _StepBadge extends StatelessWidget {
  const _StepBadge({
    required this.index,
    required this.color,
    required this.active,
  });
  final int index;
  final Color color;
  final bool active;

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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('index', index));
    properties.add(ColorProperty('color', color));
    properties.add(DiagnosticsProperty<bool>('active', active));
  }
}

class _EvoArrow extends StatelessWidget {
  // true => right arrow, false => down arrow
  const _EvoArrow({required this.color, required this.horizontal});
  final Color color;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    return Icon(
      horizontal ? Icons.arrow_forward_rounded : Icons.arrow_downward_rounded,
      color: color.withValues(alpha:0.8),
      size: 22,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('color', color));
    properties.add(DiagnosticsProperty<bool>('horizontal', horizontal));
  }
}
