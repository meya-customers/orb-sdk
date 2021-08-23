import 'package:flutter/material.dart' hide Title;

import 'package:orb/connection.dart';
import 'package:orb/event.dart';
import 'package:orb/ui/card/ask_tiles.dart';
import 'package:orb/ui/design.dart';
import 'package:orb/ui/icon.dart';
import 'package:orb/ui/presence/user_avatar.dart';

class OrbRating extends StatefulWidget {
  final OrbEvent event;
  final OrbConnection connection;
  final OrbUserAvatar userAvatar;
  bool disabled;

  OrbRating({
    @required this.event,
    @required this.connection,
    @required this.userAvatar,
  }) {
    this.disabled = !connection.getEventStream().isActiveEvent(event);
  }

  @override
  _OrbRatingState createState() => _OrbRatingState();
}

class _OrbRatingState extends State<OrbRating> {
  int backfillIndex;

  @override
  void initState() {
    super.initState();
    backfillIndex = -1;
  }

  void setBackfillIndex(int index) => setState(() => backfillIndex = index);

  @override
  Widget build(BuildContext context) {
    final List options = widget.event.data['options'];
    final bool backfill = widget.event.data['backfill'];
    List<IconButton> iconButtons = [];
    int disabledBackfillIndex = -1;

    for (int index = 0; index < options.length; index++) {
      final option = options[index];
      if (widget.disabled && buttonSelected(option['button_id']))
        disabledBackfillIndex = index;
    }

    for (int index = 0; index < options.length; index++) {
      final option = options[index];
      final buttonId = option['button_id'];
      final selected = buttonSelected(buttonId);
      final iconButton = IconButton(
        connection: widget.connection,
        option: option,
        disabled: widget.disabled,
        backfill: (index < disabledBackfillIndex || index <= backfillIndex) &&
            backfill,
        selected: selected,
        index: index,
        setBackfillIndex: setBackfillIndex,
      );
      iconButtons.add(iconButton);
    }

    return Row(
      children: [
        OrbUserAvatar.avatarOrPlaceholder(
          context,
          avatar: widget.userAvatar,
        ),
        Flexible(
          child: RowTile(
            padding: EdgeInsets.only(
              bottom: OrbTheme.of(context).lengths.medium,
            ),
            children: [
              Title(text: widget.event.data['title']),
              Container(
                margin: EdgeInsets.only(
                  top: OrbTheme.of(context).lengths.mediumSmall,
                  bottom: OrbTheme.of(context).lengths.mediumSmall,
                ),
                child: Wrap(
                  children: iconButtons,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  bool buttonSelected(String buttonId) =>
      widget.connection.getEventStream().buttonClicks[buttonId] ?? false;
}

class IconButton extends StatelessWidget {
  final OrbConnection connection;
  final Map<dynamic, dynamic> option;
  final bool disabled;
  final bool backfill;
  final bool selected;
  final int index;
  final Function(int) setBackfillIndex;

  IconButton({
    @required this.connection,
    @required this.option,
    @required this.disabled,
    @required this.backfill,
    @required this.selected,
    @required this.index,
    @required this.setBackfillIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: OrbTheme.of(context).lengths.mediumSmall,
        bottom: OrbTheme.of(context).lengths.small,
        left: OrbTheme.of(context).lengths.medium,
        right: OrbTheme.of(context).lengths.medium,
      ),
      width: OrbTheme.of(context).lengths.huge,
      height: OrbTheme.of(context).lengths.huge,
      child: buildIcon(context),
    );
  }

  Widget buildIcon(BuildContext context) {
    final customColor = option['icon']['color'];
    final icon = OrbIcon(
      OrbIconSpec(
        url: option['icon']['url'],
        color: !disabled
            ? customColor
            : disabled && backfill
                ? customColor
                : null,
      ),
      color: disabled
          ? selected || backfill
              ? OrbTheme.of(context).palette.normal
              : OrbTheme.of(context).palette.disabled
          : backfill
              ? OrbTheme.of(context).palette.brand
              : null,
    );
    return disabled
        ? icon
        : InkWell(
            child: icon,
            onTap: () {
              setBackfillIndex(index);
              connection.publishEvent(
                OrbEvent.createButtonClickEvent(
                  option['button_id'],
                  text: option['text'] ?? option['description'],
                  context: option['context'],
                ),
              );
            },
          );
  }
}
