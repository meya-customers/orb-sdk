import 'package:flutter/material.dart';

import 'package:orb/connection.dart';
import 'package:orb/design.dart';
import 'package:orb/event_stream.dart';
import 'package:orb/ui/composer.dart';
import 'package:orb/ui/header.dart';
import 'package:orb/ui/history.dart';
import 'package:orb/ui/menu.dart';
import 'package:orb/ui/page.dart';

class OrbChat extends StatelessWidget {
  final OrbEventStream eventStream;
  final OrbConnection connection;

  const OrbChat({
    required this.eventStream,
    required this.connection,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final menuStack = OrbMenuState.of(context).getMenuStack(eventStream);
    return SafeArea(
      top: false,
      child: Scaffold(
        body: Container(
          color: OrbTheme.of(context).palette.blank,
          child: OrbHeader(
            eventStream: eventStream,
            connection: connection,
            childrenBuilder: (context, {required headerIsTransparent}) => [
              Flexible(
                child: menuStack.isNotEmpty
                    ? OrbMenu(
                        menuStack: menuStack,
                        connection: connection,
                        headerIsTransparent: headerIsTransparent,
                      )
                    : eventStream.pageEvent != null
                        ? OrbPage(
                            key: Key(eventStream.pageEvent!.data['page_id']),
                            eventStream: eventStream,
                            connection: connection,
                            event: eventStream.pageEvent!,
                            headerIsTransparent: headerIsTransparent,
                          )
                        : OrbHistory(
                            eventStream: eventStream,
                            connection: connection,
                            headerIsTransparent: headerIsTransparent,
                          ),
              ),
              if (menuStack.isEmpty)
                OrbComposer(eventStream: eventStream, connection: connection)
            ],
          ),
        ),
      ),
    );
  }
}
