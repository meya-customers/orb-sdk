import 'package:flutter/material.dart';

import 'package:orb/ui/design.dart';

class Label extends StatelessWidget {
  final String label;
  final bool required;
  final bool disabled;
  final bool focus;
  final bool invalid;

  Label({
    required this.label,
    required this.required,
    required this.disabled,
    required this.focus,
    required this.invalid,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: OrbTheme.of(context).lengths.none,
        left: OrbTheme.of(context).lengths.small,
        right: OrbTheme.of(context).lengths.small,
        bottom: OrbTheme.of(context).lengths.mediumSmall,
      ),
      child: Text(
        '${label.toUpperCase()}${required ? ' *' : ''}',
        style: labelStyle(context),
      ),
    );
  }

  TextStyle labelStyle(BuildContext context) {
    Color color;
    if (disabled) {
      color = OrbTheme.of(context).palette.disabled;
    } else if (!invalid && !focus) {
      color = OrbTheme.of(context).palette.normal;
    } else if (invalid && !focus) {
      color = OrbTheme.of(context).palette.error;
    } else {
      color = OrbTheme.of(context).palette.normal;
    }
    return OrbTheme.of(context)
        .text
        .style
        .normal
        .merge(OrbTheme.of(context).text.style.bold)
        .merge(OrbTheme.of(context).text.size.tiny)
        .copyWith(color: color);
  }
}
