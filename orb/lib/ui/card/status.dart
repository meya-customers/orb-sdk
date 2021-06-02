import 'package:flutter/material.dart';

import 'package:orb/event.dart';
import 'package:orb/ui/design.dart';

class OrbStatus extends StatelessWidget {
  final OrbEvent event;
  final bool isActiveEvent;

  OrbStatus({
    @required this.event,
    @required this.isActiveEvent,
  });

  @override
  Widget build(BuildContext context) {
    final status = this.event.data['status'];
    final ephemeral = this.event.data['ephemeral'];

    if (!isActiveEvent && ephemeral == true) {
      return SizedBox.shrink();
    } else {
      return Align(
        alignment: Alignment.center,
        child: Container(
          margin: EdgeInsets.only(
            top: OrbTheme.of(context).lengths.large,
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
}
