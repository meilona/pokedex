import 'package:flutter/material.dart';

class PokemonTypeColor {
  static Color getColor(String type) {
    switch (type.toLowerCase()) {
      case 'normal': return Colors.grey.shade400;
      case 'fire': return Colors.red.shade400;
      case 'water': return Colors.blue.shade400;
      case 'electric': return Colors.amber.shade400;
      case 'grass': return Colors.green.shade400;
      case 'ice': return Colors.cyan.shade300;
      case 'fighting': return Colors.orange.shade700;
      case 'poison': return Colors.purple.shade400;
      case 'ground': return Colors.brown.shade400;
      case 'flying': return Colors.indigo.shade300;
      case 'psychic': return Colors.pink.shade300;
      case 'bug': return Colors.lightGreen.shade400;
      case 'rock': return Colors.brown.shade600;
      case 'ghost': return Colors.deepPurple.shade400;
      case 'dragon': return Colors.indigo.shade700;
      case 'dark': return Colors.grey.shade800;
      case 'steel': return Colors.blueGrey.shade400;
      case 'fairy': return Colors.pink.shade200;
      default: return Colors.grey.shade300;
    }
  }
}