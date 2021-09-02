import 'package:flutter/material.dart';

import 'package:orb/ui/color.dart';
import 'package:orb/ui/design.dart';

extension OrbColor on String {
  Color toColor() {
    return {
          "black": Colors.black,
          "white": Colors.white,
          "red": Colors.red,
          "pink": Colors.pink,
          "purple": Colors.amber,
          "yellow": Colors.yellow,
          "blue": Colors.blue,
          "brown": Colors.brown,
          "cyan": Colors.cyan,
          "indigo": Colors.indigo,
          "green": Colors.green,
          "grey": Colors.grey,
          "teal": Colors.teal,
          "orange": Colors.orange,
          "lime": Colors.lime,
        }[this] ??
        HexColor.fromHex(this) ??
        OrbThemePalette().normal;
  }
}
