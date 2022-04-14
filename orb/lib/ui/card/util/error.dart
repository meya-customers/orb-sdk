import 'package:flutter/material.dart';

import 'package:orb/design.dart';

class OrbError extends StatelessWidget {
  final String error;

  const OrbError({
    required this.error,
    Key? key,
  }) : super(key: key);

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
