import 'package:flutter/material.dart';

import 'package:orb/connection.dart';
import 'package:orb/event.dart';
import 'package:orb/event_stream.dart';
import 'package:orb/ui/card/ask_buttons.dart';
import 'package:orb/ui/card/ask_form.dart';
import 'package:orb/ui/card/ask_tiles.dart';
import 'package:orb/ui/card/file.dart';
import 'package:orb/ui/card/image.dart';
import 'package:orb/ui/card/quick_replies.dart';
import 'package:orb/ui/card/status.dart';
import 'package:orb/ui/card/text.dart';
import 'package:orb/ui/design.dart';
import 'package:orb/ui/presence/user_avatar.dart';
import 'package:orb/ui/presence/user_name.dart';

class OrbHistory extends StatelessWidget {
  final OrbEventStream eventStream;
  final OrbConnection connection;
  final ScrollController listScrollController = ScrollController();

  OrbHistory({Key key, @required this.eventStream, @required this.connection})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        vertical: OrbTheme.of(context).lengths.medium,
        horizontal: OrbTheme.of(context).lengths.mediumSmall,
      ),
      itemBuilder: (context, index) => buildItem(index),
      itemCount: eventStream.events.length + 1,
      reverse: true,
      controller: listScrollController,
    );
  }

  Widget buildItem(int index) {
    if (index == 0) {
      return buildQuickReplies();
    }
    final event = eventStream.events[index - 1];
    final userId = event.data['user_id'];
    return buildEvent(
      event: event,
      userAvatar: (event.showAvatar
          ? OrbUserAvatar(
              eventStream: eventStream,
              userId: userId,
            )
          : null),
    );
  }

  Widget buildQuickReplies() {
    if (eventStream.quickRepliesEvent == null) {
      return SizedBox.shrink();
    } else {
      return OrbQuickReplies(
        event: eventStream.quickRepliesEvent,
        connection: connection,
      );
    }
  }

  Widget buildEvent({
    @required OrbEvent event,
    OrbUserAvatar userAvatar,
  }) {
    switch (event.type) {
      case 'meya.button.event.ask':
        return buildAskButtons(event, userAvatar);
      case 'meya.form.event.ask':
        return buildAskForm(event, userAvatar);
      case 'meya.tile.event.ask':
        return buildAskTiles(event, userAvatar);
      case 'meya.image.event':
        return buildImage(event, userAvatar);
      case 'meya.file.event':
        return buildFile(event, userAvatar);
      case 'meya.text.event.status':
        return buildStatus(event);
      case 'virtual.orb.event.user_name':
        return buildUserName(event);
      default:
        return buildText(event, userAvatar);
    }
  }

  Widget buildAskForm(
    OrbEvent event,
    OrbUserAvatar userAvatar,
  ) {
    return OrbAskForm(
      event: event,
      connection: connection,
      userAvatar: userAvatar,
    );
  }

  Widget buildAskTiles(
    OrbEvent event,
    OrbUserAvatar userAvatar,
  ) {
    return OrbAskTiles(
      event: event,
      connection: connection,
      userAvatar: userAvatar,
    );
  }

  Widget buildAskButtons(
    OrbEvent event,
    OrbUserAvatar userAvatar,
  ) {
    return OrbAskButtons(
      event: event,
      connection: connection,
      userAvatar: userAvatar,
    );
  }

  Widget buildImage(
    OrbEvent event,
    OrbUserAvatar userAvatar,
  ) {
    final url = event.data['url'];
    if (url == null || url == '') {
      return SizedBox.shrink();
    } else {
      return OrbImage(
        event: event,
        url: url,
        isSelfEvent: eventStream.isSelfEvent(event),
        userAvatar: userAvatar,
      );
    }
  }

  Widget buildStatus(OrbEvent event) {
    return OrbStatus(
      event: event,
      isActiveEvent: eventStream.isActiveEvent(event),
    );
  }

  Widget buildFile(
    OrbEvent event,
    OrbUserAvatar userAvatar,
  ) {
    final filename = event.data['filename'];
    final url = event.data['url'];
    if (url == null || url == '') {
      return SizedBox.shrink();
    } else {
      return OrbFile(
        event: event,
        filename: filename,
        url: url,
        isSelfEvent: eventStream.isSelfEvent(event),
        userAvatar: userAvatar,
      );
    }
  }

  Widget buildUserName(OrbEvent event) {
    final userId = event.data['user_id'];
    return OrbUserName(
      eventStream: eventStream,
      userId: userId,
      isSelfEvent: eventStream.isSelfEvent(event),
    );
  }

  Widget buildText(
    OrbEvent event,
    OrbUserAvatar userAvatar,
  ) {
    final text = event.data['text'];
    if (text == null || text == '') {
      return SizedBox.shrink();
    } else {
      return OrbText(
        event: event,
        text: text,
        isSelfEvent: eventStream.isSelfEvent(event),
        userAvatar: userAvatar,
      );
    }
  }

  void scroll() {
    listScrollController.animateTo(
      0.0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}
