import 'package:flutter/material.dart';

import 'package:orb/connection.dart';
import 'package:orb/event_stream.dart';
import 'package:orb/ui/composer.dart';
import 'package:orb/ui/design.dart';
import 'package:orb/ui/header.dart';
import 'package:orb/ui/history.dart';

class OrbChat extends StatelessWidget {
  final OrbEventStream eventStream;
  final OrbConnection connection;

  OrbChat({Key? key, required this.eventStream, required this.connection})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        body: Container(
          color: OrbTheme.of(context).palette.blank,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            children: [
              OrbHeader(
                connection: connection,
              ),
              Flexible(
                child: OrbHistory(
                  eventStream: eventStream,
                  connection: connection,
                ),
              ),
              OrbComposer(eventStream: eventStream, connection: connection)
            ],
          ),
        ),
      ),
    );
  }
}
