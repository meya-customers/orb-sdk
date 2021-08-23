import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:orb/connection.dart';
import 'package:orb/event.dart';
import 'package:orb/ui/card/text.dart';
import 'package:orb/ui/design.dart';
import 'package:orb/ui/presence/user_avatar.dart';

class OrbAskButtons extends StatelessWidget {
  final OrbEvent event;
  final OrbConnection connection;
  final OrbUserAvatar userAvatar;

  OrbAskButtons({
    @required this.event,
    @required this.connection,
    @required this.userAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final text = event.data['text'];
    final disabled = !connection.getEventStream().isActiveEvent(event);
    final buttons = event.data['buttons'] as List<dynamic>;
    if (buttons.length == 0) {
      return SizedBox.shrink();
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          OrbUserAvatar.avatarOrPlaceholder(
            context,
            avatar: userAvatar,
          ),
          text != null
              ? Flexible(
                  child: (Column(
                    children: [
                      OrbTextOther.container(event: event, text: text),
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
    return [
      for (final button in buttons)
        Button(
          text: button["text"],
          onTap: () {
            if (button["button_id"] != null) {
              connection.publishEvent(OrbEvent.createButtonClickEvent(
                button["button_id"],
                text: button["text"],
                context: button["context"],
              ));
            } else {
              connection.publishEvent(OrbEvent.createSayEvent(
                button["text"],
                context: button["context"],
              ));
            }
          },
          disabled: disabled,
        )
    ];
  }
}

class Button extends StatelessWidget {
  final String text;
  final Function onTap;
  final bool disabled;

  Button({
    @required this.text,
    @required this.onTap,
    @required this.disabled,
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
          border: OrbTheme.of(context).innerBorder.thick(
                disabled
                    ? OrbTheme.of(context).palette.disabled
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
                      ? OrbTheme.of(context).palette.disabledDark
                      : OrbTheme.of(context).palette.blank),
        ),
      ),
    );
  }
}
