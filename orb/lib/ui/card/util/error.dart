import 'package:flutter/material.dart';

import 'package:orb/ui/design.dart';

class Error extends StatelessWidget {
  final String error;

  Error({
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: OrbTheme.of(context).lengths.small,
        left: OrbTheme.of(context).lengths.small,
        right: OrbTheme.of(context).lengths.small,
      ),
      child: Text(
        error,
        style: OrbTheme.of(context)
            .text
            .style
            .normal
            .merge(OrbTheme.of(context).text.size.small)
            .copyWith(color: OrbTheme.of(context).palette.error),
      ),
    );
  }
}
