import 'dart:async';

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
import 'package:orb/ui/card/rating.dart';
import 'package:orb/ui/card/status.dart';
import 'package:orb/ui/card/text.dart';
import 'package:orb/ui/card/typing_indicator.dart';
import 'package:orb/ui/design.dart';
import 'package:orb/ui/presence/user_avatar.dart';
import 'package:orb/ui/presence/user_name.dart';

class OrbHistory extends StatefulWidget {
  final OrbEventStream eventStream;
  final OrbConnection connection;
  final ScrollController listScrollController = ScrollController();

  OrbHistory({
    Key key,
    @required this.eventStream,
    @required this.connection,
  }) : super(key: key);

  @override
  _OrbHistoryState createState() => _OrbHistoryState();
}

class _OrbHistoryState extends State<OrbHistory> {
  Timer expireTypingEventTimer;
  String hideTypingEventId;
  Map<String, bool> processedTypingEvents = {};

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        vertical: OrbTheme.of(context).lengths.medium,
        horizontal: OrbTheme.of(context).lengths.mediumSmall,
      ),
      itemBuilder: (context, index) => buildItem(index),
      itemCount: widget.eventStream.events.length + 1,
      reverse: true,
      controller: widget.listScrollController,
    );
  }

  Widget buildItem(int index) {
    if (index == 0) {
      return buildStaticWidget();
    }
    final event = widget.eventStream.events[index - 1];
    return buildEvent(
      event: event,
      userAvatar: (event.showAvatar
          ? OrbUserAvatar.fromEvent(
              eventStream: widget.eventStream,
              event: event,
            )
          : null),
    );
  }

  Widget buildStaticWidget() {
    processTypingEvents();
    return Column(
      children: [
        if (widget.eventStream.quickRepliesEvent != null)
          OrbQuickReplies(
            event: widget.eventStream.quickRepliesEvent,
            connection: widget.connection,
          ),
        if (widget.eventStream.typingOnEvent != null &&
            widget.eventStream.typingOnEvent.id != hideTypingEventId)
          OrbTypingIndicator(
            event: widget.eventStream.typingOnEvent,
            userAvatar: OrbUserAvatar.fromEvent(
              eventStream: widget.eventStream,
              event: widget.eventStream.typingOnEvent,
            ),
          ),
      ],
    );
  }

  void processTypingEvents() {
    final typingOnEventId = widget.eventStream.typingOnEvent?.id;

    for (final event in widget.eventStream.events) {
      if (processedTypingEvents.containsKey(event.id)) return;

      final isSelf = widget.eventStream.isSelfEvent(event);
      if (event.type == "meya.presence.event.typing.on" && !isSelf) {
        expireTypingEventTimer?.cancel();
        expireTypingEventTimer = Timer(
          getTypingOnInterval(),
          () => setState(() {
            hideTypingEventId = typingOnEventId;
          }),
        );
      }

      if (event.type == "meya.presence.event.typing.off" && !isSelf) {
        expireTypingEventTimer?.cancel();
        expireTypingEventTimer = Timer(
          getTypingOffInterval(),
          () => setState(() {
            hideTypingEventId = typingOnEventId;
          }),
        );
      }
      processedTypingEvents[event.id] = true;
    }
  }

  Duration getTypingOnInterval() => Duration(seconds: 10);

  Duration getTypingOffInterval() => Duration(milliseconds: 100);

  Widget buildEvent({
    @required OrbEvent event,
    OrbUserAvatar userAvatar,
  }) {
    // TODO: Consolidate this with EventMap class
    switch (event.type) {
      case 'meya.button.event.ask':
        return buildAskButtons(event, userAvatar);
      case 'meya.form.event.ask':
        return buildAskForm(event, userAvatar);
      case 'meya.tile.event.ask':
        return buildAskTiles(event, userAvatar);
      case 'meya.file.event':
        return buildFile(event, userAvatar);
      case 'meya.image.event':
        return buildImage(event, userAvatar);
      case 'meya.tile.event.rating':
        return buildRating(event, userAvatar);
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
      connection: widget.connection,
      userAvatar: userAvatar,
    );
  }

  Widget buildAskTiles(
    OrbEvent event,
    OrbUserAvatar userAvatar,
  ) {
    return OrbAskTiles(
      event: event,
      connection: widget.connection,
      userAvatar: userAvatar,
    );
  }

  Widget buildAskButtons(
    OrbEvent event,
    OrbUserAvatar userAvatar,
  ) {
    return OrbAskButtons(
      event: event,
      connection: widget.connection,
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
        isSelfEvent: widget.eventStream.isSelfEvent(event),
        userAvatar: userAvatar,
      );
    }
  }

  Widget buildRating(
    OrbEvent event,
    OrbUserAvatar userAvatar,
  ) {
    return OrbRating(
      event: event,
      connection: widget.connection,
      userAvatar: userAvatar,
    );
  }

  Widget buildStatus(OrbEvent event) {
    return OrbStatus(
      event: event,
      isActiveEvent: widget.eventStream.isActiveEvent(event),
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
        isSelfEvent: widget.eventStream.isSelfEvent(event),
        userAvatar: userAvatar,
      );
    }
  }

  Widget buildUserName(OrbEvent event) {
    final userId = event.data['user_id'];
    return OrbUserName(
      eventStream: widget.eventStream,
      userId: userId,
      isSelfEvent: widget.eventStream.isSelfEvent(event),
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
        isSelfEvent: widget.eventStream.isSelfEvent(event),
        userAvatar: userAvatar,
      );
    }
  }

  void scroll() {
    widget.listScrollController.animateTo(
      0.0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}
