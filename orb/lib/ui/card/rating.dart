import 'package:flutter/material.dart' hide Title;

import 'package:orb/connection.dart';
import 'package:orb/design.dart';
import 'package:orb/event.dart';
import 'package:orb/event_stream.dart';
import 'package:orb/ui/card/ask_tiles.dart';
import 'package:orb/ui/icon.dart';
import 'package:orb/ui/presence/user_avatar.dart';

class OrbRating extends StatefulWidget {
  final OrbEvent event;
  final OrbEventStream eventStream;
  final OrbConnection connection;
  final OrbUserAvatar? userAvatar;

  const OrbRating({
    required this.event,
    required this.eventStream,
    required this.connection,
    required this.userAvatar,
    Key? key,
  }) : super(key: key);

  static bool isVisible(OrbEvent event) {
    return (event.data['options'] as List<dynamic>).isNotEmpty;
  }

  @override
  _OrbRatingState createState() => _OrbRatingState();
}

class _OrbRatingState extends State<OrbRating> {
  late bool disabled;
  late int backfillIndex;
  String? selectedButtonId;

  @override
  void initState() {
    super.initState();
    disabled = !widget.eventStream.isActiveEvent(widget.event);
    backfillIndex = -1;
  }

  bool isButtonSelected(String? buttonId) => selectedButtonId != null
      ? selectedButtonId == buttonId
      : widget.eventStream.buttonClicks[buttonId] ?? false;

  @override
  Widget build(BuildContext context) {
    final List options = widget.event.data['options'] ?? [];
    final bool backfill = widget.event.data['backfill'];

    return Row(
      children: [
        OrbUserAvatar.avatarOrPlaceholder(
          context,
          avatar: widget.userAvatar,
        ),
        Flexible(
          child: RowTile(
            children: [
              Title(text: widget.event.data['title']),
              Container(
                margin: EdgeInsets.only(
                  top: OrbTheme.of(context).lengths.mediumSmall,
                  bottom: OrbTheme.of(context).lengths.mediumSmall,
                ),
                child: Wrap(
                  children:
                      buildIconButtons(context, options, backfill: backfill),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> buildIconButtons(
    BuildContext context,
    List<dynamic> options, {
    required bool backfill,
  }) {
    int disabledBackfillIndex = -1;

    for (int index = 0; index < options.length; index++) {
      final Map<dynamic, dynamic> option = options[index];
      if (disabled && isButtonSelected(option['button_id'])) {
        disabledBackfillIndex = index;
      }
    }

    return options.asMap().entries.map((entry) {
      final index = entry.key;
      final Map<dynamic, dynamic> option = entry.value;
      final buttonId = option['button_id'];
      return IconButton(
        iconSpec: OrbIconSpec.fromMap(option['icon'])!,
        disabled: disabled,
        backfill: (index < disabledBackfillIndex || index <= backfillIndex) &&
            backfill,
        selected: isButtonSelected(buttonId),
        onTap: () {
          widget.connection.publishEvent(
            OrbEvent.createButtonClickEvent(
              buttonId,
              text: option['text'] ?? option['description'],
              context: option['context'],
            ),
          );
          setState(() {
            disabled = true;
            backfillIndex = index;
            selectedButtonId = buttonId;
          });
        },
      );
    }).toList();
  }
}

class IconButton extends StatelessWidget {
  final OrbIconSpec iconSpec;
  final bool disabled;
  final bool backfill;
  final bool selected;
  final void Function() onTap;

  const IconButton({
    required this.iconSpec,
    required this.disabled,
    required this.backfill,
    required this.selected,
    required this.onTap,
    Key? key,
  }) : super(key: key);

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
    final icon = OrbIcon(
      OrbIconSpec(
        url: iconSpec.url,
        color: !disabled
            ? iconSpec.color
            : disabled && backfill
                ? iconSpec.color
                : null,
      ),
      size: OrbTheme.of(context).size.icon.medium,
      color: disabled
          ? selected || backfill
              ? OrbTheme.of(context).palette.normal
              : OrbTheme.of(context).palette.disabled
          : backfill
              ? OrbTheme.of(context).palette.brand
              : null,
    );
    return disabled ? icon : InkWell(child: icon, onTap: onTap);
  }
}
