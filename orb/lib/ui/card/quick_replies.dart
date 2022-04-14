import 'package:flutter/material.dart';

import 'package:separated_row/separated_row.dart';

import 'package:orb/connection.dart';
import 'package:orb/design.dart';
import 'package:orb/event.dart';
import 'package:orb/event_stream.dart';
import 'package:orb/ui/card/util/url.dart';
import 'package:orb/ui/icon.dart';
import 'package:orb/ui/menu.dart';

class OrbQuickReplies extends StatefulWidget {
  final OrbEvent event;
  final OrbEventStream eventStream;
  final OrbConnection connection;

  const OrbQuickReplies({
    required this.event,
    required this.eventStream,
    required this.connection,
    Key? key,
  }) : super(key: key);

  @override
  _OrbQuickRepliesState createState() => _OrbQuickRepliesState();
}

class _OrbQuickRepliesState extends State<OrbQuickReplies> {
  bool disabledOverride = false;
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    final List<dynamic>? quickReplies = widget.event.data['quick_replies'];
    if (quickReplies!.isEmpty) {
      return const SizedBox.shrink();
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
      final Map<dynamic, dynamic> quickReply = entry.value;
      final buttonId = quickReply['button_id'];
      final text = quickReply['text'];
      final icon = quickReply['icon'];
      final quickReplyContext = quickReply['context'];
      final String? url = quickReply['url'];
      final menu = quickReply['menu'];
      final disabled = quickReply['disabled'];
      return Container(
        margin: EdgeInsets.only(
          top: OrbTheme.of(context).lengths.large,
          left: OrbTheme.of(context).lengths.small,
          right: OrbTheme.of(context).lengths.small,
        ),
        child: QuickReply(
          text: text,
          iconSpec: OrbIconSpec.fromMap(icon),
          onTap: () async {
            if (url != null) {
              await OrbUrl(url).tryLaunch(context);
              return;
            } else if (menu != null) {
              OrbMenuState.of(context).openMenu(widget.eventStream, menu);
              return;
            } else if (buttonId != null) {
              widget.connection.publishEvent(
                OrbEvent.createButtonClickEvent(
                  buttonId,
                  text: text,
                  context: quickReplyContext,
                ),
              );
            } else {
              widget.connection.publishEvent(
                OrbEvent.createSayEvent(
                  text,
                  context: quickReplyContext,
                ),
              );
            }
            setState(() {
              disabledOverride = true;
              selectedIndex = index;
            });
          },
          disabled: url != null
              ? false
              : (disabledOverride ||
                  !widget.eventStream.isActiveEvent(widget.event) ||
                  disabled == true),
          selected: isQuickReplySelected(index),
          isLink: url != null,
          isMenu: menu != null,
        ),
      );
    }).toList();
  }
}

class QuickReply extends StatelessWidget {
  final String? text;
  final OrbIconSpec? iconSpec;
  final void Function() onTap;
  final bool disabled;
  final bool selected;
  final bool isLink;
  final bool isMenu;

  const QuickReply({
    required this.text,
    required this.iconSpec,
    required this.onTap,
    required this.disabled,
    required this.selected,
    required this.isLink,
    required this.isMenu,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (disabled) {
      return buildQuickReply(context);
    } else {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.all(OrbTheme.of(context).borderRadius.medium) -
                  BorderRadius.only(
                    bottomRight: OrbTheme.of(context).borderRadius.medium,
                  ),
          splashColor: Colors.transparent,
          highlightColor: OrbTheme.of(context).palette.brandShadow,
          child: buildQuickReply(context),
        ),
      );
    }
  }

  Widget buildQuickReply(BuildContext context) {
    final textColor = disabled && !selected
        ? OrbTheme.of(context).palette.disabled
        : OrbTheme.of(context).palette.brand;
    return IntrinsicWidth(
      child: Container(
        padding: EdgeInsets.all(OrbTheme.of(context).lengths.medium),
        decoration: BoxDecoration(
          boxShadow: [OrbTheme.of(context).outerShadow.tiny],
          color: selected
              ? OrbTheme.of(context).palette.brandTranslucent
              : OrbTheme.of(context).palette.blankTranslucent,
          border: OrbTheme.of(context).innerBorder.thick(
                disabled && !selected
                    ? OrbTheme.of(context).palette.disabled
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
            if (iconSpec != null)
              OrbIcon(
                iconSpec!,
                size: OrbTheme.of(context).size.icon.medium,
                color: textColor,
              ),
            if (text != null)
              Flexible(
                child: Text(
                  text!,
                  style: (OrbTheme.of(context).text.font.normal)
                      .merge(OrbTheme.of(context).text.style.bold)
                      .merge(OrbTheme.of(context).text.size.medium)
                      .copyWith(color: textColor),
                ),
              ),
            if (isLink)
              OrbIcon(
                OrbIcons.link,
                size: OrbTheme.of(context).size.icon.small,
                color: textColor,
              ),
            if (isMenu)
              OrbIcon(
                OrbIcons.right,
                size: OrbTheme.of(context).size.icon.small,
                color: textColor,
              ),
          ],
          separatorBuilder: (_context, _index) =>
              SizedBox(width: OrbTheme.of(context).lengths.small),
        ),
      ),
    );
  }
}
