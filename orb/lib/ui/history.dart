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
import 'package:orb/ui/card/text_input.dart';
import 'package:orb/ui/card/typing_indicator.dart';
import 'package:orb/ui/card/widget_mode.dart';
import 'package:orb/ui/design.dart';
import 'package:orb/ui/presence/user_avatar.dart';
import 'package:orb/ui/presence/user_name.dart';
import 'card/choice_input.dart';

class OrbHistory extends StatefulWidget {
  final OrbEventStream eventStream;
  final OrbConnection connection;
  final ScrollController listScrollController = ScrollController();

  OrbHistory({
    Key? key,
    required this.eventStream,
    required this.connection,
  }) : super(key: key);

  @override
  _OrbHistoryState createState() => _OrbHistoryState();
}

class _OrbHistoryState extends State<OrbHistory> {
  Timer? expireTypingEventTimer;
  String? hideTypingEventId;
  Map<String, bool> processedTypingEvents = {};

  @override
  Widget build(BuildContext context) {
    // TODO Keep children alive during scrolling and event stream updates
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
    final isVisible = widget.eventStream.isVisibleEvent(event);
    if (!isVisible) {
      return SizedBox.shrink();
    } else {
      return Column(children: [
        if (event.isFirstInGroup) buildUserName(event),
        ...[...buildWidgetMode(event, widget.eventStream, widget.connection)]
            .reversed
      ]);
    }
  }

  Widget buildStaticWidget() {
    processTypingEvents();
    return Column(
      children: [
        if (widget.eventStream.quickRepliesEvent != null)
          OrbQuickReplies(
            key: Key(
              'quick_replies_${widget.eventStream.quickRepliesEvent!.id}',
            ),
            connection: widget.connection,
            event: widget.eventStream.quickRepliesEvent!,
          ),
        if (widget.eventStream.typingOnEvent != null &&
            widget.eventStream.typingOnEvent!.id != hideTypingEventId)
          OrbTypingIndicator(
            event: widget.eventStream.typingOnEvent!,
            userAvatar: OrbUserAvatar.fromEvent(
              eventStream: widget.eventStream,
              event: widget.eventStream.typingOnEvent!,
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
      processedTypingEvents[event.id ?? "-"] = true;
    }
  }

  Duration getTypingOnInterval() => Duration(seconds: 10);

  Duration getTypingOffInterval() => Duration(milliseconds: 100);

  Widget buildUserName(OrbEvent event) {
    final userId = event.data['user_id'];
    return OrbUserName(
      eventStream: widget.eventStream,
      userId: userId,
      isSelfEvent: widget.eventStream.isSelfEvent(event),
    );
  }

  void scroll() {
    widget.listScrollController.animateTo(
      0.0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}

Iterable<Widget> buildWidgetMode(
  OrbEvent event,
  OrbEventStream eventStream,
  OrbConnection connection,
) sync* {
  if (!eventStream.isVisibleEvent(event)) {
    return;
  }

  var onlyText = false;
  final text = eventStream.getEventText(event) ?? '';
  var userAvatar = (event.showAvatar
      ? OrbUserAvatar.fromEvent(
          eventStream: eventStream,
          event: event,
        )
      : null);

  switch (event.type) {
    case 'meya.button.event.ask':
      yield OrbAskButtons(
          event: event,
          connection: connection,
          userAvatar: userAvatar,
          mode: OrbWidgetMode.standalone,
          controller: null,
          disabled: null);
      break;
    case 'meya.form.event.ask':
      yield OrbAskForm(
        event: event,
        connection: connection,
        userAvatar: userAvatar,
      );
      break;
    case 'meya.tile.event.ask':
      yield OrbAskTiles(
        event: event,
        connection: connection,
        userAvatar: userAvatar,
      );
      break;
    case "meya.tile.event.choice":
      yield OrbChoiceInput(
        event: event,
        connection: connection,
        userAvatar: userAvatar,
        mode: OrbWidgetMode.standalone,
        controller: null,
        disabled: null,
      );
      break;
    case 'meya.file.event':
      yield OrbFile(
        event: event,
        isSelfEvent: eventStream.isSelfEvent(event),
        userAvatar: userAvatar,
        mode: OrbWidgetMode.standalone,
      );
      break;
    case 'meya.image.event':
      yield OrbImage(
        event: event,
        isSelfEvent: eventStream.isSelfEvent(event),
        userAvatar: userAvatar,
        mode: OrbWidgetMode.standalone,
      );
      break;
    case 'meya.tile.event.rating':
      yield OrbRating(
        event: event,
        connection: connection,
        userAvatar: userAvatar,
      );
      break;
    case 'meya.text.event.info':
      yield OrbTextInfo(event: event, markdown: event.data["markdown"]);
      break;
    case 'meya.text.event.input':
      yield OrbTextInput(
        event: event,
        connection: connection,
        userAvatar: userAvatar,
        mode: OrbWidgetMode.standalone,
        controller: null,
        disabled: null,
      );
      break;
    case 'meya.text.event.status':
      yield OrbStatus(
        event: event,
        isActiveEvent: eventStream.isActiveEvent(event),
      );
      break;
    default:
      onlyText = true;
  }

  if (text != '') {
    yield OrbText(
      event: event,
      text: text,
      isSelfEvent: eventStream.isSelfEvent(event),
      userAvatar: onlyText ? userAvatar : null,
    );
  }
}
