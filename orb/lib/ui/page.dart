import 'package:flutter/material.dart';

import 'package:collection/collection.dart';

import 'package:orb/connection.dart';
import 'package:orb/event.dart';
import 'package:orb/event_stream.dart';
import 'package:orb/ui/card/ask_buttons.dart';
import 'package:orb/ui/card/choice_input.dart';
import 'package:orb/ui/card/file.dart';
import 'package:orb/ui/card/image.dart';
import 'package:orb/ui/card/quick_replies.dart';
import 'package:orb/ui/card/text.dart';
import 'package:orb/ui/card/text_input.dart';
import 'package:orb/ui/card/util/button.dart';
import 'package:orb/ui/card/widget_mode.dart';
import 'package:orb/ui/design.dart';
import 'package:orb/ui/input_data_controller.dart';

class OrbPage extends StatefulWidget {
  final OrbEventStream eventStream;
  final OrbConnection connection;
  final OrbEvent event;

  OrbPage({
    Key? key,
    required this.eventStream,
    required this.connection,
  })  : event = eventStream.pageEvent!,
        super(key: key);

  static bool isVisible(OrbEvent event) {
    return event.data["widgets"].length > 0;
  }

  _OrbPageState createState() => _OrbPageState();

  List<OrbEvent> getWidgetEvents() {
    return event.data["widgets"]
        .whereType<Map<dynamic, dynamic>?>()
        .map<OrbEvent>((eventMap) => OrbEvent.fromEventMap(eventMap))
        .toList();
  }
}

class _OrbPageState extends State<OrbPage> {
  late InputDataController controller;
  late bool ok;
  late bool disabled;
  late Map<String?, bool> processedEvents;

  @override
  void initState() {
    super.initState();
    ok = widget.event.data["ok"] == true;
    disabled = ok;
    controller = new InputDataController(
        children: widget
            .getWidgetEvents()
            .mapIndexed(
              (index, event) => createChildController(
                  widget.event.data["input_data"]?[index],
                  event,
                  widget.eventStream),
            )
            .toList());
    processedEvents = {};
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    process();

    final String pageId = widget.event.data["page_id"];
    final String? submitButtonText = widget.event.data["submit_button_text"];
    final String? submitButtonId = widget.event.data["submit_button_id"];
    final List<OrbEvent> widgetEvents = widget.getWidgetEvents();
    return Align(
        alignment: Alignment.bottomCenter,
        child: ListView.separated(
          padding: MediaQuery.of(context).padding.add(
                EdgeInsets.symmetric(
                  vertical: OrbTheme.of(context).lengths.large,
                  horizontal: OrbTheme.of(context).lengths.mediumSmall,
                ),
              ),
          separatorBuilder: (context, index) =>
              buildSeparator(widgetEvents, submitButtonText, index),
          itemBuilder: (context, index) => buildItem(
              pageId, widgetEvents, submitButtonText, submitButtonId, index),
          itemCount: widgetEvents.length + 2,
          shrinkWrap: true,
        ));
  }

  Widget buildSeparator(
      List<OrbEvent> widgetEvents, String? submitButtonText, int index) {
    if (index < widgetEvents.length - 1) {
      return SizedBox(height: OrbTheme.of(context).lengths.small);
    } else if (index == widgetEvents.length - 1) {
      return submitButtonText != null
          ? Container(
              margin: EdgeInsets.symmetric(
                  vertical: OrbTheme.of(context).lengths.large),
              child: Divider(
                  color: OrbTheme.of(context).palette.disabled,
                  thickness: 1,
                  height: 1),
            )
          : SizedBox.shrink();
    } else {
      return SizedBox.shrink();
    }
  }

  Widget buildItem(String pageId, List<OrbEvent> widgetEvents,
      String? submitButtonText, String? submitButtonId, int index) {
    if (index < widgetEvents.length) {
      final event = widgetEvents[index];
      return Column(children: [
        ...buildNonWidgetMode(
            index,
            event,
            widget.eventStream,
            widget.connection,
            widget.event,
            disabled,
            controller,
            OrbWidgetMode.page)
      ]);
    } else if (index == widgetEvents.length) {
      return submitButtonText != null
          ? buildSubmitButton(pageId, submitButtonText, submitButtonId)
          : SizedBox.shrink();
    } else {
      return OrbQuickReplies(
        key: Key('quick_replies_${widget.event.id}'),
        connection: widget.connection,
        event: widget.event,
      );
    }
  }

  Widget buildSubmitButton(
      String pageId, String submitButtonText, String? submitButtonId) {
    return Row(children: [
      Expanded(
        child: Button(
            text: submitButtonText,
            icon: null,
            onTap: () => submit(pageId, submitButtonId, submitButtonText),
            disabled: disabled,
            selected: disabled,
            isAction: true,
            isLink: false,
            mode: OrbWidgetMode.standalone),
      )
    ]);
  }

  void process() {
    if (!widget.connection.getEventStream().isActiveEvent(widget.event)) {
      // Event not relevant
      return;
    } else if (processedEvents[widget.event.id] == true) {
      // Event already processed
      return;
    }
    ok = widget.event.data["ok"] == true;
    disabled = ok;
    processedEvents[widget.event.id] = true;
  }

  void submit(String pageId, String? buttonId, String? text) {
    if (buttonId == null) {
      return;
    }
    widget.connection.publishEvent(OrbEvent.createPageButtonClickEvent(
      pageId,
      buttonId,
      controller.value,
      text: text,
    ));
    setState(() {
      this.disabled = true;
    });
  }
}

ValueNotifier<dynamic>? createChildController(
  dynamic inputData,
  OrbEvent event,
  OrbEventStream eventStream,
) {
  if (!eventStream.isVisibleEvent(event)) {
    return null;
  }

  switch (event.type) {
    case 'meya.button.event.ask':
      return OrbAskButtons.createController(inputData, event);
    case 'meya.text.event.input':
      return OrbTextInput.createController(inputData, event);
    case 'meya.text.event.input':
      return OrbTextInput.createController(inputData, event);
    case "meya.tile.event.choice":
      return OrbChoiceInput.createController(inputData, event);
    default:
      return null;
  }
}

Iterable<Widget> buildNonWidgetMode(
  int index,
  OrbEvent event,
  OrbEventStream eventStream,
  OrbConnection connection,
  OrbEvent pageEvent,
  bool disabled,
  InputDataController controller,
  OrbWidgetMode mode,
) sync* {
  if (!eventStream.isVisibleEvent(event)) {
    return;
  }

  switch (event.type) {
    case 'meya.button.event.ask':
      yield OrbAskButtons(
        event: event,
        connection: connection,
        userAvatar: null,
        mode: mode,
        controller: controller.getChild(index),
        disabled: disabled,
      );
      break;
    case 'meya.file.event':
      yield event.data['url'] == null || event.data['url'] == ''
          ? SizedBox.shrink()
          : OrbFile(
              event: event,
              isSelfEvent: eventStream.isSelfEvent(event),
              userAvatar: null,
              mode: mode,
            );
      break;
    case 'meya.image.event':
      yield event.data['url'] == null || event.data['url'] == ''
          ? SizedBox.shrink()
          : OrbImage(
              event: event,
              isSelfEvent: eventStream.isSelfEvent(event),
              userAvatar: null,
              mode: mode,
            );
      break;
    case 'meya.text.event.info':
      yield OrbTextInfo(event: event, markdown: pageEvent.data["markdown"]);
      break;
    case 'meya.text.event.input':
      yield OrbTextInput(
        event: event,
        connection: connection,
        userAvatar: null,
        mode: mode,
        controller: controller.getChild(index),
        disabled: disabled,
      );
      break;
    case "meya.tile.event.choice":
      yield OrbChoiceInput(
        event: event,
        connection: connection,
        userAvatar: null,
        mode: mode,
        controller: controller.getChild(index),
        disabled: disabled,
      );
      break;
  }
}
