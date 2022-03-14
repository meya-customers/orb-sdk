import 'package:flutter/material.dart';

import 'package:separated_row/separated_row.dart';

import 'package:orb/connection.dart';
import 'package:orb/event.dart';
import 'package:orb/ui/card/util/url.dart';
import 'package:orb/ui/design.dart';
import 'package:orb/ui/icon.dart';

class OrbQuickReplies extends StatefulWidget {
  final OrbConnection connection;
  final OrbEvent event;

  OrbQuickReplies({
    required this.connection,
    required this.event,
    Key? key,
  }) : super(key: key);

  _OrbQuickRepliesState createState() => _OrbQuickRepliesState();
}

class _OrbQuickRepliesState extends State<OrbQuickReplies> {
  bool disabled = false;
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    final quickReplies = widget.event.data["quick_replies"] as List<dynamic>?;
    if (quickReplies!.isEmpty) {
      return SizedBox.shrink();
    } else {
      return Container(
        alignment: Alignment.centerRight,
        child: Wrap(
          alignment: WrapAlignment.end,
          children: buildQuickReplies(context, quickReplies),
        ),
      );
    }
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
      final icon = quickReply["icon"];
      final quickReplyContext = quickReply["context"];
      final String? url = quickReply["url"];
      return QuickReply(
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
              context: quickReplyContext,
            ));
          } else {
            widget.connection.publishEvent(OrbEvent.createSayEvent(
              text,
              context: quickReplyContext,
            ));
          }
          setState(() {
            this.disabled = true;
            this.selectedIndex = index;
          });
        },
        disabled: disabled,
        selected: isQuickReplySelected(index),
        isLink: url != null,
      );
    }).toList();
  }
}

class QuickReply extends StatelessWidget {
  final String? text;
  final Map<dynamic, dynamic>? icon;
  final void Function() onTap;
  final bool disabled;
  final bool selected;
  final bool isLink;

  QuickReply({
    required this.text,
    required this.icon,
    required this.onTap,
    required this.disabled,
    required this.selected,
    required this.isLink,
  });

  @override
  Widget build(BuildContext context) {
    if (disabled) {
      return buildQuickReply(context);
    } else {
      return InkWell(
        onTap: onTap,
        child: buildQuickReply(context),
      );
    }
  }

  Widget buildQuickReply(BuildContext context) {
    final textColor = disabled
        ? OrbTheme.of(context).palette.disabledDark
        : OrbTheme.of(context).palette.brand;
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
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
                    : OrbTheme.of(context).palette.brand,
              ),
          borderRadius:
              BorderRadius.all(OrbTheme.of(context).borderRadius.medium) -
                  BorderRadius.only(
                    bottomRight: OrbTheme.of(context).borderRadius.medium,
                  ),
        ),
        child: SeparatedRow(
            children: [
              if (icon != null)
                OrbIcon(
                    OrbIconSpec(
                      url: icon!['url'],
                      color: icon!['color'],
                    ),
                    color: textColor),
              if (text != null)
                Text(
                  text!,
                  style: (OrbTheme.of(context).text.font.normal)
                      .merge(OrbTheme.of(context).text.style.bold)
                      .merge(OrbTheme.of(context).text.size.medium)
                      .copyWith(color: textColor),
                ),
              if (isLink) OrbIcon(OrbIcons.link, color: textColor),
            ],
            separatorBuilder: (BuildContext _context, int _index) =>
                SizedBox(width: OrbTheme.of(context).lengths.small)),
      ),
    );
  }
}
