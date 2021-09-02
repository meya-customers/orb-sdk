import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:orb/connection.dart';
import 'package:orb/event.dart';
import 'package:orb/ui/card/text.dart';
import 'package:orb/ui/design.dart';
import 'package:orb/ui/presence/user_avatar.dart';

class OrbAskButtons extends StatefulWidget {
  final OrbEvent event;
  final OrbConnection connection;
  final OrbUserAvatar userAvatar;

  OrbAskButtons({
    @required this.event,
    @required this.connection,
    @required this.userAvatar,
  });

  _OrbAskButtonsState createState() => _OrbAskButtonsState();
}

class _OrbAskButtonsState extends State<OrbAskButtons> {
  bool disabled;
  String selectedButtonId;

  @override
  void initState() {
    super.initState();
    disabled = !widget.connection.getEventStream().isActiveEvent(widget.event);
  }

  bool isButtonSelected(String buttonId) => selectedButtonId != null
      ? selectedButtonId == buttonId
      : widget.connection.getEventStream().buttonClicks[buttonId] ?? false;

  @override
  Widget build(BuildContext context) {
    final text = widget.event.data['text'];
    final buttons = widget.event.data['buttons'] as List<dynamic>;
    if (buttons.length == 0) {
      return SizedBox.shrink();
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          OrbUserAvatar.avatarOrPlaceholder(
            context,
            avatar: widget.userAvatar,
          ),
          text != null
              ? Flexible(
                  child: (Column(
                    children: [
                      OrbTextOther.container(event: widget.event, text: text),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        direction: Axis.horizontal,
                        children:
                            buildButtons(context, text, disabled, buttons),
                      ),
                    ],
                  )),
                )
              : Expanded(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: buildButtons(context, text, disabled, buttons),
                  ),
                )
        ],
      );
    }
  }

  List<Widget> buildButtons(
    BuildContext context,
    String text,
    bool disabled,
    List<dynamic> buttons,
  ) {
    return buttons.map((button) {
      final buttonId = button['button_id'];
      final text = button['text'];
      final context = button['context'];

      return Button(
        text: text,
        onTap: () {
          if (buttonId != null) {
            widget.connection.publishEvent(OrbEvent.createButtonClickEvent(
              buttonId,
              text: text,
              context: context,
            ));
          } else {
            widget.connection.publishEvent(OrbEvent.createSayEvent(
              text,
              context: context,
            ));
          }
          setState(() {
            this.disabled = true;
            this.selectedButtonId = buttonId;
          });
        },
        disabled: disabled,
        selected: isButtonSelected(buttonId),
      );
    }).toList();
  }
}

class Button extends StatelessWidget {
  final String text;
  final Function onTap;
  final bool disabled;
  final bool selected;

  Button({
    @required this.text,
    @required this.onTap,
    @required this.disabled,
    @required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    if (disabled) {
      return buildButton(context);
    } else {
      return InkWell(
        onTap: onTap,
        child: buildButton(context),
      );
    }
  }

  Widget buildButton(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: OrbTheme.of(context).lengths.large,
        left: OrbTheme.of(context).lengths.small,
        right: OrbTheme.of(context).lengths.small,
      ),
      padding: EdgeInsets.all(OrbTheme.of(context).lengths.medium),
      decoration: BoxDecoration(
          boxShadow: [OrbTheme.of(context).outerShadow.tiny],
          color: disabled
              ? OrbTheme.of(context).palette.disabled
              : OrbTheme.of(context).palette.brand,
          border: OrbTheme.of(context).innerBorder.thin(
                disabled
                    ? selected
                        ? OrbTheme.of(context).palette.normal
                        : OrbTheme.of(context).palette.disabled
                    : OrbTheme.of(context).palette.brand,
              ),
          borderRadius:
              BorderRadius.all(OrbTheme.of(context).borderRadius.small)),
      child: FittedBox(
        child: Text(
          text,
          style: (OrbTheme.of(context).text.font.normal)
              .merge(OrbTheme.of(context).text.style.bold)
              .merge(OrbTheme.of(context).text.size.medium)
              .copyWith(
                  color: disabled
                      ? selected
                          ? OrbTheme.of(context).palette.normal
                          : OrbTheme.of(context).palette.disabledDark
                      : OrbTheme.of(context).palette.blank),
        ),
      ),
    );
  }
}
