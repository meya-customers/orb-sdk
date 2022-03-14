import 'package:flutter/material.dart';

import 'package:orb/connection.dart';
import 'package:orb/event.dart';
import 'package:orb/ui/card/util/url.dart';
import 'package:orb/ui/design.dart';
import 'package:orb/ui/icon.dart';
import 'package:orb/ui/presence/user_avatar.dart';

class OrbAskTiles extends StatelessWidget {
  final OrbEvent event;
  final OrbConnection connection;
  final OrbUserAvatar? userAvatar;

  OrbAskTiles({
    required this.event,
    required this.connection,
    required this.userAvatar,
  });

  static bool isVisible(OrbEvent event) {
    return event.data["tiles"].length > 0;
  }

  String get buttonStyle => event.data['button_style'] ?? 'action';

  @override
  Widget build(BuildContext context) {
    final layout = event.data['layout'];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        OrbUserAvatar.avatarOrPlaceholder(context, avatar: userAvatar),
        Expanded(
          child: layout == 'column' ? buildColumn(context) : buildRow(context),
        ),
      ],
    );
  }

  Widget buildColumn(BuildContext context) {
    final tiles = event.data['tiles'];
    return Column(
      children: [
        for (final tile in tiles)
          Container(
            child: Text(tile['title'] ?? 'Tile'),
          )
      ],
    );
  }

  Widget buildRow(BuildContext context) {
    return TilesRow(
      event: event,
      connection: connection,
      buttonStyle: buttonStyle,
    );
  }
}

class TilesRow extends StatefulWidget {
  final OrbEvent event;
  final OrbConnection connection;
  final String buttonStyle;

  TilesRow({
    required this.event,
    required this.connection,
    required this.buttonStyle,
  });

  _TilesRowState createState() => _TilesRowState();
}

class _TilesRowState extends State<TilesRow> {
  late bool disabled;
  String? selectedButtonId;

  @override
  void initState() {
    super.initState();
    disabled = !widget.connection.getEventStream().isActiveEvent(widget.event);
  }

  bool isButtonSelected(String? buttonId) => selectedButtonId != null
      ? selectedButtonId == buttonId
      : widget.connection.getEventStream().buttonClicks[buttonId] ?? false;

  @override
  Widget build(BuildContext context) {
    final tiles = widget.event.data['tiles'];
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: OrbTheme.of(context).lengths.small,
        left: OrbTheme.of(context).lengths.small,
        bottom: OrbTheme.of(context).lengths.small,
      ),
      scrollDirection: Axis.horizontal,
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [for (final tile in tiles) buildRowTile(context, tile)]),
    );
  }

  Widget buildRowTile(BuildContext context, Map<dynamic, dynamic> tile) {
    final noButtons = (tile['buttons'] == null || tile['buttons'].isEmpty);
    final isTileButton = tile['button_id'] != null;
    final tileButtonId = tile['button_id'];
    final isTileButtonSelected = isButtonSelected(tileButtonId);
    final isTileLink = tile['url'] == true;
    final contents = buildTileContents(context, tile);

    if (noButtons && isTileButton) {
      return RowTileButton(
        onTap: () => onButtonTap(tileButtonId),
        disabled: disabled,
        selected: isTileButtonSelected,
        children: contents,
      );
    } else if (noButtons && isTileLink) {
      // TODO: Implement RowTileLinkButton
      return RowTile(children: contents);
    } else {
      return RowTile(children: contents);
    }
  }

  List<Widget> buildTileContents(
    BuildContext context,
    Map<dynamic, dynamic> tile,
  ) {
    return [
      if (tile['icon'] != null)
        RowIcon(
          icon: OrbIcon.fromSpec(
            tile['icon'],
            defaultColor: OrbTheme.of(context).palette.normal,
          ),
        ),
      if (tile['image'] != null) RowImage(image: tile['image']),
      if (tile['title'] != null) Title(text: tile['title']),
      if (tile['description'] != null) Description(text: tile['description']),
      if (tile['buttons'] != null) buildButtons(context, tile['buttons'])
    ];
  }

  Widget buildButtons(BuildContext context, List<dynamic> buttons) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: OrbTheme.of(context).borderRadius.small,
        bottomRight: OrbTheme.of(context).borderRadius.small,
      ),
      child: Container(
        margin: widget.buttonStyle == 'radio'
            ? EdgeInsets.only(top: OrbTheme.of(context).lengths.medium)
            : EdgeInsets.only(bottom: OrbTheme.of(context).lengths.medium),
        child: Column(children: [
          for (final button in buttons) buildButton(context, button)
        ]),
      ),
    );
  }

  Widget buildButton(BuildContext context, Map<dynamic, dynamic> button) {
    final buttonId = button['button_id'];
    final selected = isButtonSelected(buttonId);
    if (button['url'] != null) {
      switch (widget.buttonStyle) {
        // TODO: Support 'text' and 'radio' buttons
        default:
          return RowActionLinkButton(url: button['url'], text: button['text']);
      }
    } else {
      switch (widget.buttonStyle) {
        // TODO: Support 'text' buttons
        case 'radio':
          return RadioButton(
            icon: OrbIcon.fromSpec(
              button['icon'],
              defaultColor: disabled
                  ? selected
                      ? OrbTheme.of(context).palette.normal
                      : OrbTheme.of(context).palette.disabledDark
                  : OrbTheme.of(context).palette.blank,
            ),
            text: button['text'],
            onTap: () => widget.connection.publishEvent(
                OrbEvent.createButtonClickEvent(button['button_id'])),
            disabled: disabled,
            selected: selected,
          );
        default:
          return RowActionButton(
            icon: OrbIcon.fromSpec(
              button['icon'],
              defaultColor: disabled
                  ? selected
                      ? OrbTheme.of(context).palette.normal
                      : OrbTheme.of(context).palette.disabledDark
                  : OrbTheme.of(context).palette.blank,
            ),
            text: button['text'],
            onTap: () => onButtonTap(button['button_id']),
            disabled: disabled,
            selected: selected,
          );
      }
    }
  }

  void onButtonTap(String buttonId) {
    widget.connection.publishEvent(OrbEvent.createButtonClickEvent(buttonId));
    setState(() {
      disabled = true;
      selectedButtonId = buttonId;
    });
  }
}

class RowTile extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  RowTile({
    required this.children,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return buildContainer(
      context,
      child: Column(
        children: children,
      ),
    );
  }

  Widget buildContainer(
    BuildContext context, {
    required Widget child,
    Border? border,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 340),
      child: Container(
        margin: EdgeInsets.only(
          top: OrbTheme.of(context).lengths.medium,
          right: OrbTheme.of(context).lengths.medium,
        ),
        padding: padding,
        decoration: BoxDecoration(
          boxShadow: [OrbTheme.of(context).outerShadow.small],
          color: OrbTheme.of(context).palette.blank,
          border: border,
          borderRadius:
              BorderRadius.all(OrbTheme.of(context).borderRadius.small),
        ),
        child: child,
      ),
    );
  }
}

class RowTileButton extends RowTile {
  final Function onTap;
  final bool? disabled;
  final bool selected;
  final List<Widget> children;

  RowTileButton({
    required this.onTap,
    required this.disabled,
    required this.selected,
    required this.children,
  }) : super(children: children);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap as void Function()?,
      child: buildContainer(
        context,
        child: Column(
          children: [
            ...children,
            Container(
              margin:
                  EdgeInsets.only(bottom: OrbTheme.of(context).lengths.medium),
              child: RadioIcon(
                disabled: disabled,
                selected: selected,
              ),
            )
          ],
        ),
        border: selected
            ? OrbTheme.of(context)
                .innerBorder
                .thin(OrbTheme.of(context).palette.normal)
            : null,
      ),
    );
  }
}

class RowActionButton extends StatelessWidget {
  final OrbIcon? icon;
  final String? text;
  final void Function()? onTap;
  final bool? disabled;
  final bool selected;

  RowActionButton({
    this.icon,
    required this.text,
    this.onTap,
    required this.disabled,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    if (disabled!) {
      return buildButton(context);
    } else {
      return InkWell(
        onTap: () => processOnTap(context),
        child: buildButton(context),
      );
    }
  }

  Widget buildButton(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        top: OrbTheme.of(context).lengths.medium,
        left: OrbTheme.of(context).lengths.medium,
        right: OrbTheme.of(context).lengths.medium,
      ),
      padding: EdgeInsets.only(
        top: OrbTheme.of(context).lengths.mediumSmall,
        right: OrbTheme.of(context).lengths.medium,
        bottom: OrbTheme.of(context).lengths.mediumSmall,
        left: OrbTheme.of(context).lengths.medium,
      ),
      decoration: BoxDecoration(
          boxShadow: [OrbTheme.of(context).outerShadow.tiny],
          color: disabled!
              ? OrbTheme.of(context).palette.disabled
              : OrbTheme.of(context).palette.brand,
          border: OrbTheme.of(context).innerBorder.thin(
                disabled!
                    ? selected
                        ? OrbTheme.of(context).palette.normal
                        : OrbTheme.of(context).palette.disabled
                    : OrbTheme.of(context).palette.brand,
              ),
          borderRadius:
              BorderRadius.all(OrbTheme.of(context).borderRadius.small)),
      child: buildContent(context),
    );
  }

  Widget buildContent(BuildContext context) {
    final text = buildText(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null)
          buildButtonIcon(context, text: text as Text, icon: icon, left: true),
        buildText(context),
      ],
    );
  }

  Widget buildText(BuildContext context) {
    return Text(
      text!,
      textAlign: TextAlign.center,
      style: (OrbTheme.of(context).text.font.normal)
          .merge(OrbTheme.of(context).text.style.bold)
          .merge(OrbTheme.of(context).text.size.small)
          .copyWith(
              color: disabled!
                  ? selected
                      ? OrbTheme.of(context).palette.normal
                      : OrbTheme.of(context).palette.disabledDark
                  : OrbTheme.of(context).palette.blank),
    );
  }

  Widget buildButtonIcon(
    BuildContext context, {
    required Text text,
    required OrbIcon? icon,
    bool? left,
    bool? right,
  }) {
    EdgeInsets? margin;
    if (left == true) {
      margin = EdgeInsets.only(
        right: OrbTheme.of(context).lengths.tiny,
      );
    } else if (right == true) {
      margin = EdgeInsets.only(
        left: OrbTheme.of(context).lengths.tiny,
      );
    }
    return Container(
      margin: margin,
      height: text.style!.fontSize! * 1.2,
      child: icon,
    );
  }

  Future<void> processOnTap(BuildContext context) async {
    if (onTap != null) {
      onTap!();
    }
  }
}

class RowActionLinkButton extends RowActionButton {
  final String url;

  RowActionLinkButton({required this.url, OrbIcon? icon, required String? text})
      : super(icon: icon, text: text, disabled: false, selected: false);

  @override
  Widget buildContent(BuildContext context) {
    final Text text = buildText(context) as Text;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null)
          buildButtonIcon(context, text: text, icon: icon, left: true),
        text,
        buildButtonIcon(
          context,
          text: text,
          icon: OrbIcon(
            OrbIcons.link,
            color: OrbTheme.of(context).palette.blank,
          ),
          right: true,
        ),
      ],
    );
  }

  @override
  Future<void> processOnTap(BuildContext context) async {
    await OrbUrl(url).tryLaunch(context);
  }
}

class RadioButton extends RowActionButton {
  RadioButton({
    OrbIcon? icon,
    required String? text,
    void Function()? onTap,
    required bool? disabled,
    required bool selected,
  }) : super(
            icon: icon,
            text: text,
            onTap: onTap,
            disabled: disabled,
            selected: selected);

  @override
  Widget buildButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: OrbTheme.of(context).lengths.medium,
        right: OrbTheme.of(context).lengths.medium,
        bottom: OrbTheme.of(context).lengths.medium,
        left: OrbTheme.of(context).lengths.medium,
      ),
      decoration: BoxDecoration(
        color: OrbTheme.of(context).palette.blank,
        border: OrbTheme.of(context).innerBorder.top(
              OrbTheme.of(context).palette.neutral,
            ),
      ),
      child: buildContent(context),
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    final text = buildText(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(right: OrbTheme.of(context).lengths.small),
          child: RadioIcon(
            disabled: disabled,
            selected: selected,
          ),
        ),
        buildText(context),
        if (icon != null)
          buildButtonIcon(context, text: text as Text, icon: icon, right: true),
      ],
    );
  }

  @override
  Widget buildText(BuildContext context) {
    return Text(
      text!,
      textAlign: TextAlign.center,
      style: (OrbTheme.of(context).text.font.normal)
          .merge(OrbTheme.of(context).text.style.bold)
          .merge(OrbTheme.of(context).text.size.small)
          .copyWith(
              color: disabled!
                  ? selected
                      ? OrbTheme.of(context).palette.brand
                      : OrbTheme.of(context).palette.disabledDark
                  : OrbTheme.of(context).palette.brand),
    );
  }
}

class RadioIcon extends StatelessWidget {
  final bool? disabled;
  final bool selected;

  RadioIcon({required this.disabled, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: OrbTheme.of(context).lengths.medium,
          height: OrbTheme.of(context).lengths.medium,
          decoration: new BoxDecoration(
            color: disabled!
                ? OrbTheme.of(context).palette.disabled
                : OrbTheme.of(context).palette.brandShadow,
            shape: BoxShape.circle,
          ),
        ),
        if (selected)
          Container(
            width: OrbTheme.of(context).lengths.medium * 0.6,
            height: OrbTheme.of(context).lengths.medium * 0.6,
            decoration: new BoxDecoration(
              color: OrbTheme.of(context).palette.brand,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }
}

class RowIcon extends StatelessWidget {
  final OrbIcon? icon;

  RowIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: OrbTheme.of(context).lengths.hugeLarge,
      height: OrbTheme.of(context).lengths.hugeLarge,
      margin: EdgeInsets.only(
        top: OrbTheme.of(context).lengths.medium,
        left: OrbTheme.of(context).lengths.large,
        right: OrbTheme.of(context).lengths.large,
      ),
      child: icon,
    );
  }
}

class RowImage extends StatelessWidget {
  final Map<dynamic, dynamic>? image;

  RowImage({required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: OrbTheme.of(context).lengths.small),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: OrbTheme.of(context).borderRadius.small,
          topRight: OrbTheme.of(context).borderRadius.small,
        ),
        child: Image.network(
          image!['url'],
          loadingBuilder: (context, child, progress) {
            return progress == null
                ? child
                : LinearProgressIndicator(
                    value: progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!,
                  );
          },
        ),
      ),
    );
  }
}

class Title extends StatelessWidget {
  final String? text;

  Title({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: OrbTheme.of(context).lengths.medium,
        left: OrbTheme.of(context).lengths.mediumSmall,
        right: OrbTheme.of(context).lengths.mediumSmall,
      ),
      child: Text(text!,
          style: OrbTheme.of(context)
              .text
              .style
              .bold
              .merge(OrbTheme.of(context).text.size.medium)),
    );
  }
}

class Description extends StatelessWidget {
  final String? text;

  Description({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: OrbTheme.of(context).lengths.medium,
        left: OrbTheme.of(context).lengths.mediumSmall,
        right: OrbTheme.of(context).lengths.mediumSmall,
      ),
      child: Text(text!,
          style: OrbTheme.of(context)
              .text
              .style
              .normal
              .merge(OrbTheme.of(context).text.size.medium)),
    );
  }
}
