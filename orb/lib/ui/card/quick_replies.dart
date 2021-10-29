import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:orb/connection.dart';
import 'package:orb/event.dart';
import 'package:orb/ui/design.dart';

class OrbQuickReplies extends StatelessWidget {
  final OrbConnection connection;

  OrbQuickReplies({
    required this.connection,
  });

  @override
  Widget build(BuildContext context) {
    final eventStream = connection.getEventStream();
    final event = eventStream.quickRepliesEvent!;
    final quickReplies = event.data["quick_replies"] as List<dynamic>?;
    if (!eventStream.isActiveEvent(event) || quickReplies!.isEmpty) {
      return SizedBox.shrink();
    } else {
      return _OrbQuickReplies(event: event, connection: connection);
    }
  }
}

class _OrbQuickReplies extends StatefulWidget {
  final OrbEvent event;
  final OrbConnection? connection;

  _OrbQuickReplies({
    required this.event,
    required this.connection,
  });

  _OrbQuickRepliesState createState() => _OrbQuickRepliesState();
}

class _OrbQuickRepliesState extends State<_OrbQuickReplies> {
  bool disabled = false;
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    final quickReplies = widget.event.data["quick_replies"] as List<dynamic>;
    return Container(
      alignment: Alignment.centerRight,
      child: Wrap(
        alignment: WrapAlignment.end,
        children: buildQuickReplies(context, quickReplies),
      ),
    );
  }

  bool isQuickReplySelected(int index) =>
      selectedIndex != null ? selectedIndex == index : false;

  List<Widget> buildQuickReplies(
    BuildContext context,
    List<dynamic> quickReplies,
  ) {
    return quickReplies.asMap().entries.map((entry) {
      final index = entry.key;
      final quickReply = entry.value;
      final buttonId = quickReply["button_id"];
      final text = quickReply["text"];
      final context = quickReply["context"];
      return QuickReply(
        text: quickReply["text"],
        onTap: () {
          if (buttonId != null) {
            widget.connection!.publishEvent(OrbEvent.createButtonClickEvent(
              buttonId,
              text: text,
              context: context,
            ));
          } else {
            widget.connection!.publishEvent(OrbEvent.createSayEvent(
              text,
              context: context,
            ));
          }
          setState(() {
            this.disabled = true;
            this.selectedIndex = index;
          });
        },
        disabled: disabled,
        selected: isQuickReplySelected(index),
      );
    }).toList();
  }
}

class QuickReply extends StatelessWidget {
  final String? text;
  final Function onTap;
  final bool disabled;
  final bool selected;

  QuickReply({
    required this.text,
    required this.onTap,
    required this.disabled,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    if (disabled) {
      return buildQuickReply(context);
    } else {
      return InkWell(
        onTap: onTap as void Function()?,
        child: buildQuickReply(context),
      );
    }
  }

  Widget buildQuickReply(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: OrbTheme.of(context).lengths.large,
        left: OrbTheme.of(context).lengths.small,
        right: OrbTheme.of(context).lengths.small,
      ),
      padding: EdgeInsets.all(OrbTheme.of(context).lengths.medium),
      decoration: BoxDecoration(
        boxShadow: [OrbTheme.of(context).outerShadow.tiny],
        color: selected
            ? OrbTheme.of(context).palette.disabled
            : OrbTheme.of(context).palette.blank,
        border: OrbTheme.of(context).innerBorder.thick(
              disabled
                  ? OrbTheme.of(context).palette.disabledDark
                  : OrbTheme.of(context).palette.brand!,
            ),
        borderRadius:
            BorderRadius.all(OrbTheme.of(context).borderRadius.medium) -
                BorderRadius.only(
                  bottomRight: OrbTheme.of(context).borderRadius.medium,
                ),
      ),
      child: FittedBox(
        child: Text(
          text!,
          style: (OrbTheme.of(context).text.font.normal)
              .merge(OrbTheme.of(context).text.style.bold)
              .merge(OrbTheme.of(context).text.size.medium)
              .copyWith(
                  color: disabled
                      ? OrbTheme.of(context).palette.disabledDark
                      : OrbTheme.of(context).palette.brand),
        ),
      ),
    );
  }
}
