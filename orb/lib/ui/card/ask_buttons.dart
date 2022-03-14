import 'package:flutter/material.dart';

import 'package:collection/collection.dart';

import 'package:orb/connection.dart';
import 'package:orb/event.dart';
import 'package:orb/ui/card/util/button.dart';
import 'package:orb/ui/card/util/error.dart';
import 'package:orb/ui/card/util/label.dart';
import 'package:orb/ui/card/util/url.dart';
import 'package:orb/ui/card/widget_mode.dart';
import 'package:orb/ui/design.dart';
import 'package:orb/ui/presence/user_avatar.dart';

class OrbAskButtons extends StatefulWidget {
  final OrbEvent event;
  final OrbConnection connection;
  final OrbUserAvatar? userAvatar;
  final OrbWidgetMode mode;
  final ValueNotifier<dynamic>? controller;
  final bool? disabled;

  OrbAskButtons({
    required this.event,
    required this.connection,
    required this.userAvatar,
    required this.mode,
    required this.controller,
    required this.disabled,
  });

  static bool isVisible(OrbEvent event) {
    return event.data["buttons"].length > 0;
  }

  static ValueNotifier<dynamic> createController(
      dynamic inputData, OrbEvent event) {
    final List<dynamic> buttons = event.data["buttons"];
    if (!event.data["multi"]) {
      return ValueNotifier(inputData ??
          buttons.firstWhereOrNull(
              (button) => button["default"] == true)?["text"] ??
          "");
    } else {
      return ValueNotifier(inputData ??
          buttons
              .where((button) => button["default"] == true)
              .map((button) => button["text"]));
    }
  }

  _OrbAskButtonsState createState() => _OrbAskButtonsState();
}

class _OrbAskButtonsState extends State<OrbAskButtons> {
  late bool disabledOverride;
  String? selectedButtonId;

  @override
  void initState() {
    super.initState();
    disabledOverride = false;
  }

  bool get disabled {
    return disabledOverride ||
        (widget.disabled ??
            !widget.connection.getEventStream().isActiveEvent(widget.event));
  }

  bool get invalid {
    return !disabled && widget.event.data["error"] != null;
  }

  @override
  Widget build(BuildContext context) {
    final buttons = widget.event.data['buttons'] as List<dynamic>;
    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      if (widget.mode == OrbWidgetMode.standalone)
        OrbUserAvatar.avatarOrPlaceholder(
          context,
          avatar: widget.userAvatar,
        ),
      Expanded(
        child: Container(
          margin: EdgeInsets.only(top: OrbTheme.of(context).lengths.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.event.data['label'] != null)
                Label(
                  label: widget.event.data['label'],
                  required: widget.event.data['required'],
                  disabled: disabled,
                  focus: false,
                  invalid: invalid,
                ),
              Container(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: OrbTheme.of(context).lengths.medium,
                  runSpacing: OrbTheme.of(context).lengths.medium,
                  children: buildButtons(context, buttons),
                ),
              ),
              if (invalid) Error(error: widget.event.data["error"])
            ],
          ),
        ),
      )
    ]);
  }

  List<Widget> buildButtons(
    BuildContext context,
    List<dynamic> buttons,
  ) {
    return buttons.map((button) {
      final buttonId = button['button_id'];
      final text = button['text'];
      final icon = button['icon'];
      final buttonContext = button['context'];
      final String? url = button["url"];
      final bool selected;
      if (selectedButtonId != null) {
        selected = selectedButtonId == buttonId;
      } else if (widget.mode == OrbWidgetMode.standalone) {
        selected =
            widget.connection.getEventStream().buttonClicks[buttonId] ?? false;
      } else {
        selected = !widget.event.data["multi"]
            ? text == widget.controller!.value
            : widget.controller!.value.contains(text);
      }
      return FittedBox(
          fit: BoxFit.scaleDown,
          child: Button(
            text: text,
            icon: icon,
            onTap: () async {
              if (url != null) {
                await OrbUrl(url).tryLaunch(context);
                return;
              } else if (buttonId != null) {
                widget.connection.publishEvent(OrbEvent.createButtonClickEvent(
                  buttonId,
                  text: text,
                  context: buttonContext,
                ));
                setState(() {
                  this.disabledOverride = true;
                  this.selectedButtonId = buttonId;
                });
              } else if (widget.mode == OrbWidgetMode.standalone) {
                widget.connection.publishEvent(OrbEvent.createSayEvent(
                  text,
                  context: buttonContext,
                ));
                setState(() {
                  this.disabledOverride = true;
                });
              } else {
                setState(() {
                  if (!widget.event.data["multi"]) {
                    widget.controller!.value = selected ? '' : text;
                  } else if (selected) {
                    widget.controller!.value = List.of(widget.controller!.value)
                      ..remove(text);
                  } else {
                    widget.controller!.value = [
                      ...widget.controller!.value,
                      text
                    ];
                  }
                });
              }
            },
            disabled: disabled,
            selected: selected,
            isAction: buttonId != null,
            isLink: url != null,
            mode: widget.mode,
          ));
    }).toList();
  }
}
