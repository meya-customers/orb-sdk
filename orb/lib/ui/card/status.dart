import 'package:flutter/material.dart';

import 'package:orb/design.dart';
import 'package:orb/event.dart';

class OrbStatus extends StatelessWidget {
  final OrbEvent event;
  final bool isActiveEvent;

  const OrbStatus({
    required this.event,
    required this.isActiveEvent,
    Key? key,
  }) : super(key: key);

  static bool isVisible(
    OrbEvent event,
    bool Function(OrbEvent event) isActiveEvent,
  ) {
    return isActiveEvent(event) || event.data['ephemeral'] != true;
  }

  @override
  Widget build(BuildContext context) {
    final status = event.data['status'];
    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: EdgeInsets.all(
          OrbTheme.of(context).lengths.large,
        ),
        child: Text(
          status,
          style: (OrbTheme.of(context).text.font.normal)
              .merge(OrbTheme.of(context).text.style.normal)
              .merge(OrbTheme.of(context).text.size.medium)
              .copyWith(
                color: OrbTheme.of(context).palette.disabledDark,
              ),
        ),
      ),
    );
  }
}
