import 'package:flutter/material.dart';

enum PotionColor {
  red,
  blue,
  green,
  yellow,
  purple,
  orange,
  cyan,
  pink,
  white,
  black,
}

extension PotionColorExtension on PotionColor {
  Color get color {
    switch (this) {
      case PotionColor.red:
        return Colors.red;
      case PotionColor.blue:
        return Colors.blue;
      case PotionColor.green:
        return Colors.green;
      case PotionColor.yellow:
        return Colors.yellow;
      case PotionColor.purple:
        return Colors.purple;
      case PotionColor.orange:
        return Colors.orange;
      case PotionColor.cyan:
        return Colors.cyan;
      case PotionColor.pink:
        return Colors.pink;
      case PotionColor.white:
        return Colors.white;
      case PotionColor.black:
        return Colors.black;
    }
  }

  String get name {
    switch (this) {
      case PotionColor.red:
        return 'Vermelho';
      case PotionColor.blue:
        return 'Azul';
      case PotionColor.green:
        return 'Verde';
      case PotionColor.yellow:
        return 'Amarelo';
      case PotionColor.purple:
        return 'Roxo';
      case PotionColor.orange:
        return 'Laranja';
      case PotionColor.cyan:
        return 'Ciano';
      case PotionColor.pink:
        return 'Rosa';
      case PotionColor.white:
        return 'Branco';
      case PotionColor.black:
        return 'Preto';
    }
  }
}

