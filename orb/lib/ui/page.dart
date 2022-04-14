import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:separated_column/separated_column.dart';

import 'package:orb/connection.dart';
import 'package:orb/design.dart';
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
import 'package:orb/ui/card/util/url.dart';
import 'package:orb/ui/card/widget_mode.dart';
import 'package:orb/ui/icon.dart';
import 'package:orb/ui/input_data_controller.dart';
import 'package:orb/ui/menu.dart';

class OrbPage extends StatefulWidget {
  final OrbEventStream eventStream;
  final OrbConnection connection;
  final OrbEvent event;
  final bool headerIsTransparent;

  const OrbPage({
    required this.eventStream,
    required this.connection,
    required this.event,
    required this.headerIsTransparent,
    Key? key,
  }) : super(key: key);

  static bool isVisible(OrbEvent event) {
    return (event.data['widgets'] as List<dynamic>).isNotEmpty;
  }

  @override
  _OrbPageState createState() => _OrbPageState();

  List<OrbEvent> getWidgetEvents() {
    return (event.data['widgets'] as List<dynamic>)
        .cast<Map<dynamic, dynamic>>()
        .map((eventMap) => OrbEvent.fromEventMap(eventMap))
        .toList();
  }
}

class _OrbPageState extends State<OrbPage> {
  late InputDataController controller;
  late bool ok;
  late bool disabled;
  late Map<String?, bool> processedEvents;
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    ok = widget.event.data['ok'] == true;
    disabled = ok;
    controller = InputDataController(
      children: widget
          .getWidgetEvents()
          .mapIndexed(
            (index, event) => createChildController(
              (widget.event.data['input_data'] as List<dynamic>?)?[index],
              event,
              widget.eventStream,
            ),
          )
          .toList(),
    );
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

    final String pageId = widget.event.data['page_id'];
    final String? submitButtonText = widget.event.data['submit_button_text'];
    final String? submitButtonId = widget.event.data['submit_button_id'];
    final List<dynamic> extraButtons = widget.event.data['extra_buttons'] ?? [];
    final List<OrbEvent> widgetEvents = widget.getWidgetEvents();
    return Align(
      alignment: Alignment.bottomCenter,
      child: ListView.separated(
        padding: EdgeInsets.only(
          top: (widget.headerIsTransparent
                  ? MediaQuery.of(context).padding.top
                  : 0) +
              OrbTheme.of(context).lengths.large,
          right: OrbTheme.of(context).lengths.mediumSmall,
          bottom: OrbTheme.of(context).lengths.large,
          left: OrbTheme.of(context).lengths.mediumSmall,
        ),
        separatorBuilder: (context, index) => buildSeparator(
          context,
          widgetEvents,
          submitButtonText,
          extraButtons,
          index,
        ),
        itemBuilder: (context, index) => buildItem(
          context,
          pageId,
          widgetEvents,
          submitButtonText,
          submitButtonId,
          extraButtons,
          index,
        ),
        itemCount: widgetEvents.length + 2,
        shrinkWrap: true,
      ),
    );
  }

  Widget buildSeparator(
    BuildContext context,
    List<OrbEvent> widgetEvents,
    String? submitButtonText,
    List<dynamic> extraButtons,
    int index,
  ) {
    if (index < widgetEvents.length - 1) {
      final event = widgetEvents[index];
      if (widget.eventStream.isVisibleEvent(event)) {
        return SizedBox(height: OrbTheme.of(context).lengths.huge);
      }
    } else if (index == widgetEvents.length - 1) {
      if (submitButtonText != null || extraButtons.isNotEmpty) {
        return Container(
          margin: EdgeInsets.symmetric(
            vertical: OrbTheme.of(context).lengths.large,
          ),
          child: Divider(
            color: OrbTheme.of(context).palette.brandNeutral,
            thickness: 1,
            height: 1,
          ),
        );
      }
    }
    return const SizedBox.shrink();
  }

  Widget buildItem(
    BuildContext context,
    String pageId,
    List<OrbEvent> widgetEvents,
    String? submitButtonText,
    String? submitButtonId,
    List<dynamic> extraButtons,
    int index,
  ) {
    if (index < widgetEvents.length) {
      final event = widgetEvents[index];
      return Column(
        children: [
          ...buildNonWidgetMode(
            index,
            event,
            widget.eventStream,
            widget.connection,
            widget.event,
            controller,
            OrbWidgetMode.page,
            disabled: disabled,
          )
        ],
      );
    } else if (index == widgetEvents.length) {
      if (submitButtonText != null || extraButtons.isNotEmpty) {
        return Container(
          padding: EdgeInsets.only(
            right: OrbTheme.of(context).lengths.mediumSmall,
            bottom: OrbTheme.of(context).lengths.tiny,
            left: OrbTheme.of(context).lengths.mediumSmall,
          ),
          child: SeparatedColumn(
            children: [
              if (submitButtonText != null)
                buildSubmitButton(
                  context,
                  pageId,
                  submitButtonText,
                  submitButtonId,
                ),
              ...extraButtons
                  .cast<Map<dynamic, dynamic>>()
                  .mapIndexed(buildButton),
            ],
            separatorBuilder: (_context, _index) =>
                SizedBox(height: OrbTheme.of(context).lengths.medium),
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    } else {
      return OrbQuickReplies(
        key: Key('quick_replies_${widget.event.id}'),
        event: widget.event,
        eventStream: widget.eventStream,
        connection: widget.connection,
      );
    }
  }

  Widget buildSubmitButton(
    BuildContext context,
    String pageId,
    String submitButtonText,
    String? submitButtonId,
  ) {
    return OrbButton(
      text: submitButtonText,
      iconSpec: null,
      onTap: () => submit(pageId, submitButtonId, submitButtonText),
      disabled: disabled,
      selected: disabled && selectedIndex == null,
      isAction: true,
      isLink: false,
      isMenu: false,
      mode: OrbWidgetMode.standalone,
    );
  }

  Widget buildButton(int index, Map<dynamic, dynamic> button) {
    final buttonId = button['button_id'];
    final String? text = button['text'];
    final icon = button['icon'];
    final buttonContext = button['context'];
    final String? url = button['url'];
    final menu = button['menu'];
    return OrbButton(
      text: text,
      iconSpec: OrbIconSpec.fromMap(icon),
      onTap: () async {
        if (url != null) {
          await OrbUrl(url).tryLaunch(context);
        } else if (menu != null) {
          OrbMenuState.of(context).openMenu(widget.eventStream, menu);
        } else if (buttonId != null) {
          widget.connection.publishEvent(
            OrbEvent.createButtonClickEvent(
              buttonId,
              text: text,
              context: buttonContext,
            ),
          );
          setState(() {
            disabled = true;
            selectedIndex = index;
          });
        } else {
          widget.connection.publishEvent(
            OrbEvent.createSayEvent(
              text,
              context: buttonContext,
            ),
          );
          setState(() {
            disabled = true;
            selectedIndex = index;
          });
        }
      },
      disabled: url != null ? false : disabled,
      selected: selectedIndex == index,
      isAction: buttonId != null,
      isLink: url != null,
      isMenu: menu != null,
      mode: OrbWidgetMode.standalone,
    );
  }

  void process() {
    if (!widget.eventStream.isActiveEvent(widget.event)) {
      // Event not relevant
      return;
    } else if (processedEvents[widget.event.id] == true) {
      // Event already processed
      return;
    }
    ok = widget.event.data['ok'] == true;
    disabled = ok;
    processedEvents[widget.event.id] = true;
  }

  void submit(String pageId, String? buttonId, String? text) {
    if (buttonId == null) {
      return;
    }
    widget.connection.publishEvent(
      OrbEvent.createPageButtonClickEvent(
        pageId,
        buttonId,
        controller.value,
        text: text,
      ),
    );
    setState(() {
      disabled = true;
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
    case 'meya.tile.event.choice':
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
  InputDataController controller,
  OrbWidgetMode mode, {
  required bool disabled,
}) sync* {
  if (!eventStream.isVisibleEvent(event)) {
    return;
  }

  switch (event.type) {
    case 'meya.button.event.ask':
      yield OrbAskButtons(
        event: event,
        eventStream: eventStream,
        connection: connection,
        userAvatar: null,
        mode: mode,
        controller: controller.getChild(index),
        disabled: disabled,
      );
      break;
    case 'meya.file.event':
      yield event.data['url'] == null || event.data['url'] == ''
          ? const SizedBox.shrink()
          : OrbFile(
              event: event,
              isSelfEvent: eventStream.isSelfEvent(event),
              userAvatar: null,
              mode: mode,
            );
      break;
    case 'meya.image.event':
      yield event.data['url'] == null || event.data['url'] == ''
          ? const SizedBox.shrink()
          : OrbImage(
              event: event,
              isSelfEvent: eventStream.isSelfEvent(event),
              userAvatar: null,
              mode: mode,
            );
      break;
    case 'meya.text.event.info':
      yield OrbTextInfo(event: event, markdown: pageEvent.data['markdown']);
      break;
    case 'meya.text.event.input':
      yield OrbTextInput(
        event: event,
        eventStream: eventStream,
        connection: connection,
        userAvatar: null,
        mode: mode,
        controller: controller.getChild(index),
        disabled: disabled,
      );
      break;
    case 'meya.tile.event.choice':
      yield OrbChoiceInput(
        event: event,
        eventStream: eventStream,
        connection: connection,
        userAvatar: null,
        mode: mode,
        controller: controller.getChild(index),
        disabled: disabled,
      );
      break;
  }
}
