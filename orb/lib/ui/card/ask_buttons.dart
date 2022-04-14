import 'package:flutter/material.dart';

import 'package:collection/collection.dart';

import 'package:orb/connection.dart';
import 'package:orb/design.dart';
import 'package:orb/event.dart';
import 'package:orb/event_stream.dart';
import 'package:orb/ui/card/util/button.dart';
import 'package:orb/ui/card/util/error.dart';
import 'package:orb/ui/card/util/label.dart';
import 'package:orb/ui/card/util/url.dart';
import 'package:orb/ui/card/widget_mode.dart';
import 'package:orb/ui/icon.dart';
import 'package:orb/ui/menu.dart';
import 'package:orb/ui/presence/user_avatar.dart';

class OrbAskButtons extends StatefulWidget {
  final OrbEvent event;
  final OrbEventStream eventStream;
  final OrbConnection connection;
  final OrbUserAvatar? userAvatar;
  final OrbWidgetMode mode;
  final ValueNotifier<dynamic>? controller;
  final bool? disabled;

  const OrbAskButtons({
    required this.event,
    required this.eventStream,
    required this.connection,
    required this.userAvatar,
    required this.mode,
    required this.controller,
    required this.disabled,
    Key? key,
  }) : super(key: key);

  static bool isVisible(OrbEvent event) {
    return (event.data['buttons'] as List<dynamic>).isNotEmpty;
  }

  static ValueNotifier<dynamic> createController(
    dynamic inputData,
    OrbEvent event,
  ) {
    final List<dynamic> buttons = event.data['buttons'];
    if (event.data['multi'] != true) {
      return ValueNotifier(
        inputData as String? ??
            (buttons.cast<Map<dynamic, dynamic>>().firstWhereOrNull(
                  (button) => button['default'] == true,
                ))?['text'] ??
            '',
      );
    } else {
      return ValueNotifier(
        (inputData as List<dynamic>? ??
                buttons
                    .cast<Map<dynamic, dynamic>>()
                    .where(
                      (button) => button['default'] == true,
                    )
                    .map((button) => button['text']!))
            .cast<String>()
            .toList(),
      );
    }
  }

  @override
  _OrbAskButtonsState createState() => _OrbAskButtonsState();
}

class _OrbAskButtonsState extends State<OrbAskButtons> {
  late bool disabledOverride;
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    disabledOverride = false;
  }

  bool get disabled {
    return disabledOverride ||
        (widget.disabled ?? !widget.eventStream.isActiveEvent(widget.event));
  }

  bool get invalid {
    return !disabled && widget.event.data['error'] != null;
  }

  @override
  Widget build(BuildContext context) {
    final buttons = widget.event.data['buttons'];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (widget.mode == OrbWidgetMode.standalone)
          OrbUserAvatar.avatarOrPlaceholder(
            context,
            avatar: widget.userAvatar,
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.event.data['label'] != null)
                OrbLabel(
                  label: widget.event.data['label'],
                  required: widget.event.data['required'],
                  disabled: disabled,
                  focus: false,
                  invalid: invalid,
                ),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: OrbTheme.of(context).lengths.medium,
                runSpacing: OrbTheme.of(context).lengths.medium,
                children: buildButtons(context, buttons),
              ),
              if (invalid) OrbError(error: widget.event.data['error'])
            ],
          ),
        )
      ],
    );
  }

  List<Widget> buildButtons(
    BuildContext context,
    List<dynamic> buttons,
  ) {
    return buttons.cast<Map<dynamic, dynamic>>().mapIndexed((index, button) {
      final buttonId = button['button_id'];
      final String? text = button['text'];
      final icon = button['icon'];
      final buttonContext = button['context'];
      final String? url = button['url'];
      final menu = button['menu'];
      final buttonDisabled = button['disabled'] == true;
      final bool selected;
      if (selectedIndex != null) {
        selected = selectedIndex == index;
      } else if (widget.mode == OrbWidgetMode.standalone) {
        selected = widget.eventStream.buttonClicks[buttonId] ?? false;
      } else {
        selected = widget.event.data['multi'] != true
            ? text == widget.controller!.value
            : (widget.controller!.value as List<String>).contains(text);
      }
      return IntrinsicWidth(
        child: OrbButton(
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
                disabledOverride = true;
                selectedIndex = index;
              });
            } else if (widget.mode == OrbWidgetMode.standalone) {
              widget.connection.publishEvent(
                OrbEvent.createSayEvent(
                  text,
                  context: buttonContext,
                ),
              );
              setState(() {
                disabledOverride = true;
              });
            } else {
              setState(() {
                if (widget.event.data['multi'] != true) {
                  widget.controller!.value = selected ? '' : text;
                } else if (selected) {
                  widget.controller!.value =
                      List.of(widget.controller!.value as List<String>)
                        ..remove(text!);
                } else {
                  widget.controller!.value = [
                    ...widget.controller!.value as List<String>,
                    text!
                  ];
                }
              });
            }
          },
          disabled: url != null ? false : (buttonDisabled || disabled),
          selected: selected,
          isAction: buttonId != null,
          isLink: url != null,
          isMenu: menu != null,
          mode: widget.mode,
        ),
      );
    }).toList();
  }
}
