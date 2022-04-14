import 'package:flutter/material.dart';

import 'package:separated_column/separated_column.dart';
import 'package:separated_row/separated_row.dart';

import 'package:orb/connection.dart';
import 'package:orb/design.dart';
import 'package:orb/event.dart';
import 'package:orb/event_stream.dart';
import 'package:orb/ui/card/util/url.dart';
import 'package:orb/ui/icon.dart';
import 'package:orb/ui/menu.dart';
import 'package:orb/ui/presence/user_avatar.dart';

class OrbAskTiles extends StatelessWidget {
  final OrbEvent event;
  final OrbEventStream eventStream;
  final OrbConnection connection;
  final OrbUserAvatar? userAvatar;

  const OrbAskTiles({
    required this.event,
    required this.eventStream,
    required this.connection,
    required this.userAvatar,
    Key? key,
  }) : super(key: key);

  static bool isVisible(OrbEvent event) {
    return (event.data['tiles'] as List<dynamic>).isNotEmpty;
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
        for (final Map<dynamic, dynamic> tile in tiles)
          Text(tile['title'] ?? 'Tile'),
      ],
    );
  }

  Widget buildRow(BuildContext context) {
    return TilesRow(
      event: event,
      eventStream: eventStream,
      connection: connection,
      buttonStyle: buttonStyle,
    );
  }
}

class TilesRow extends StatefulWidget {
  final OrbEvent event;
  final OrbEventStream eventStream;
  final OrbConnection connection;
  final String buttonStyle;

  const TilesRow({
    required this.event,
    required this.eventStream,
    required this.connection,
    required this.buttonStyle,
    Key? key,
  }) : super(key: key);

  @override
  _TilesRowState createState() => _TilesRowState();
}

class _TilesRowState extends State<TilesRow> {
  late bool disabled;
  String? selectedButtonId;

  @override
  void initState() {
    super.initState();
    disabled = !widget.eventStream.isActiveEvent(widget.event);
  }

  bool isButtonSelected(String? buttonId) => selectedButtonId != null
      ? selectedButtonId == buttonId
      : widget.eventStream.buttonClicks[buttonId] ?? false;

  @override
  Widget build(BuildContext context) {
    final tiles = widget.event.data['tiles'];
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: OrbTheme.of(context).lengths.small,
      ),
      scrollDirection: Axis.horizontal,
      child: SeparatedRow(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [for (final tile in tiles) buildRowTile(context, tile)],
        separatorBuilder: (_context, _index) =>
            SizedBox(width: OrbTheme.of(context).lengths.huge),
      ),
    );
  }

  Widget buildRowTile(BuildContext context, Map<dynamic, dynamic> tile) {
    final noButtons =
        tile['buttons'] == null || (tile['buttons'] as List<dynamic>).isEmpty;
    final buttonId = tile['button_id'];
    final text = tile['title'] ?? tile['description'];
    final buttonContext = tile['context'];
    final String? url = tile['url'];
    final menu = tile['menu'];
    final tileDisabled = tile['disabled'] == true;
    final isTileButtonSelected = isButtonSelected(buttonId);
    final contents = buildTileContents(context, tile);

    if (noButtons && (buttonId != null || url != null || menu != null)) {
      return RowTileButton(
        buttonStyle: widget.buttonStyle,
        onTap: () => onButtonTap(
          context,
          text: text,
          url: url,
          menu: menu,
          buttonId: buttonId,
          buttonContext: buttonContext,
        ),
        disabled: url != null ? false : (tileDisabled || disabled),
        selected: isTileButtonSelected,
        isLink: url != null,
        isMenu: menu != null,
        children: contents,
      );
    } else {
      return RowTile(children: contents);
    }
  }

  List<Widget> buildTileContents(
    BuildContext context,
    Map<dynamic, dynamic> tile,
  ) {
    final initialContents = buildInitialTileContents(context, tile);
    return [
      ...initialContents,
      if (tile['buttons'] != null)
        buildButtons(context, initialContents, tile['buttons'])
    ];
  }

  List<Widget> buildInitialTileContents(
    BuildContext context,
    Map<dynamic, dynamic> tile,
  ) {
    final iconSpec = OrbIconSpec.fromMap(tile['icon']);
    return [
      if (iconSpec != null)
        RowIcon(
          icon: OrbIcon(
            iconSpec,
            size: OrbTheme.of(context).size.icon.huge,
            color: OrbTheme.of(context).palette.normal,
          ),
        ),
      if (tile['image'] != null) RowImage(image: tile['image']),
      if (tile['title'] != null) Title(text: tile['title']),
      if (tile['description'] != null) Description(text: tile['description']),
    ];
  }

  Widget buildButtons(
    BuildContext context,
    List<Widget> initialContents,
    List<dynamic> buttons,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: initialContents.isEmpty
            ? OrbTheme.of(context).borderRadius.small
            : OrbTheme.of(context).borderRadius.none,
        topRight: initialContents.isEmpty
            ? OrbTheme.of(context).borderRadius.small
            : OrbTheme.of(context).borderRadius.none,
        bottomLeft: OrbTheme.of(context).borderRadius.small,
        bottomRight: OrbTheme.of(context).borderRadius.small,
      ),
      child: Container(
        margin: widget.buttonStyle == 'radio'
            ? EdgeInsets.only(
                top: initialContents.isNotEmpty
                    ? OrbTheme.of(context).lengths.medium
                    : 0,
              )
            : EdgeInsets.only(bottom: OrbTheme.of(context).lengths.medium),
        decoration: BoxDecoration(
          border: widget.buttonStyle == 'radio' && initialContents.isNotEmpty
              ? OrbTheme.of(context).innerBorder.top(
                    OrbTheme.of(context).palette.brandNeutral,
                  )
              : null,
        ),
        child: SeparatedColumn(
          children: [
            for (final button in buttons) buildButton(context, button)
          ],
          separatorBuilder: (_context, _index) => Container(
            decoration: BoxDecoration(
              border: widget.buttonStyle == 'radio'
                  ? OrbTheme.of(context).innerBorder.top(
                        OrbTheme.of(context).palette.brandNeutral,
                      )
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildButton(BuildContext context, Map<dynamic, dynamic> button) {
    final buttonId = button['button_id'];
    final text = button['text'];
    final icon = button['icon'];
    final buttonContext = button['context'];
    final String? url = button['url'];
    final menu = button['menu'];
    final buttonDisabled = button['disabled'] == true;
    final selected = isButtonSelected(buttonId);
    void onTap() => onButtonTap(
          context,
          text: text,
          url: url,
          menu: menu,
          buttonId: buttonId,
          buttonContext: buttonContext,
        );
    switch (widget.buttonStyle) {
      // TODO: Support 'text' style buttons
      case 'radio':
        return RadioButton(
          iconSpec: OrbIconSpec.fromMap(icon),
          text: text,
          onTap: onTap,
          disabled: url != null ? false : (buttonDisabled || disabled),
          selected: selected,
          isLink: url != null,
          isMenu: menu != null,
        );
      default:
        return RowActionButton(
          iconSpec: OrbIconSpec.fromMap(icon),
          text: text,
          onTap: onTap,
          disabled: url != null ? false : (buttonDisabled || disabled),
          selected: selected,
          isLink: url != null,
          isMenu: menu != null,
        );
    }
  }

  void onButtonTap(
    BuildContext context, {
    required String? text,
    required String? url,
    required List<dynamic>? menu,
    required String? buttonId,
    required Map<dynamic, dynamic>? buttonContext,
  }) async {
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
        disabled = true;
        selectedButtonId = buttonId;
      });
    } else {
      widget.connection.publishEvent(
        OrbEvent.createSayEvent(
          text,
          context: buttonContext,
        ),
      );
      setState(() {
        disabled = true;
      });
    }
  }
}

class RowTile extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  const RowTile({
    required this.children,
    this.padding,
    Key? key,
  }) : super(key: key);

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
    return IntrinsicWidth(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        margin: EdgeInsets.symmetric(
          vertical: OrbTheme.of(context).lengths.medium,
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
  final String buttonStyle;
  final void Function() onTap;
  final bool disabled;
  final bool selected;
  final bool isLink;
  final bool isMenu;

  const RowTileButton({
    required this.buttonStyle,
    required this.onTap,
    required this.disabled,
    required this.selected,
    required this.isLink,
    required this.isMenu,
    required List<Widget> children,
    Key? key,
  }) : super(key: key, children: children);

  @override
  Widget build(BuildContext context) {
    if (disabled) {
      return buildTile(context);
    } else {
      return InkWell(
        onTap: onTap,
        child: buildTile(context),
      );
    }
  }

  Widget buildTile(BuildContext context) {
    return buildContainer(
      context,
      child: Column(
        children: [
          ...children,
          if (!isLink && !isMenu && buttonStyle == 'radio')
            Container(
              margin:
                  EdgeInsets.only(bottom: OrbTheme.of(context).lengths.medium),
              child: RadioIcon(
                disabled: disabled,
                selected: selected,
              ),
            ),
        ],
      ),
      border: selected
          ? OrbTheme.of(context)
              .innerBorder
              .thin(OrbTheme.of(context).palette.normal)
          : null,
    );
  }
}

class RowActionButton extends StatelessWidget {
  final OrbIconSpec? iconSpec;
  final String? text;
  final void Function() onTap;
  final bool disabled;
  final bool selected;
  final bool isLink;
  final bool isMenu;

  const RowActionButton({
    required this.iconSpec,
    required this.text,
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
        borderRadius: BorderRadius.all(OrbTheme.of(context).borderRadius.small),
      ),
      child: buildContent(context),
    );
  }

  Widget buildContent(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (iconSpec != null)
          buildButtonIcon(
            context,
            icon: OrbIcon(
              iconSpec!,
              size: OrbTheme.of(context).size.icon.medium,
              color: disabled
                  ? selected
                      ? OrbTheme.of(context).palette.normal
                      : OrbTheme.of(context).palette.disabledDark
                  : OrbTheme.of(context).palette.blank,
            ),
            left: true,
          ),
        if (text != null) buildText(context),
        if (isLink)
          buildButtonIcon(
            context,
            icon: OrbIcon(
              OrbIcons.link,
              size: OrbTheme.of(context).size.icon.small,
              color: OrbTheme.of(context).palette.blank,
            ),
            right: true,
          ),
        if (isMenu)
          buildButtonIcon(
            context,
            icon: OrbIcon(
              OrbIcons.right,
              size: OrbTheme.of(context).size.icon.small,
              color: disabled
                  ? OrbTheme.of(context).palette.disabledDark
                  : OrbTheme.of(context).palette.blank,
            ),
            right: true,
          ),
      ],
    );
  }

  Widget buildText(BuildContext context) {
    return Flexible(
      child: Text(
        text!,
        textAlign: TextAlign.center,
        style: (OrbTheme.of(context).text.font.normal)
            .merge(OrbTheme.of(context).text.style.bold)
            .merge(OrbTheme.of(context).text.size.small)
            .copyWith(
              color: disabled
                  ? selected
                      ? OrbTheme.of(context).palette.normal
                      : OrbTheme.of(context).palette.disabledDark
                  : OrbTheme.of(context).palette.blank,
            ),
      ),
    );
  }

  Widget buildButtonIcon(
    BuildContext context, {
    required OrbIcon icon,
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
      height: OrbTheme.of(context).text.size.small.fontSize! * 1.2,
      child: icon,
    );
  }
}

class RadioButton extends RowActionButton {
  const RadioButton({
    required OrbIconSpec? iconSpec,
    required String? text,
    required void Function() onTap,
    required bool disabled,
    required bool selected,
    required bool isLink,
    required bool isMenu,
    Key? key,
  }) : super(
          iconSpec: iconSpec,
          text: text,
          onTap: onTap,
          disabled: disabled,
          selected: selected,
          isLink: isLink,
          isMenu: isMenu,
          key: key,
        );

  @override
  Widget buildButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: OrbTheme.of(context).lengths.medium,
        right: OrbTheme.of(context).lengths.medium,
        bottom: OrbTheme.of(context).lengths.medium,
        left: OrbTheme.of(context).lengths.medium,
      ),
      decoration: BoxDecoration(
        color: OrbTheme.of(context).palette.blank,
      ),
      child: buildContent(context),
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(right: OrbTheme.of(context).lengths.small),
          child: isLink
              ? OrbIcon(
                  OrbIcons.link,
                  size: OrbTheme.of(context).size.icon.small,
                  color: disabled
                      ? OrbTheme.of(context).palette.disabled
                      : OrbTheme.of(context).palette.brand,
                )
              : isMenu
                  ? OrbIcon(
                      OrbIcons.right,
                      size: OrbTheme.of(context).size.icon.small,
                      color: disabled
                          ? OrbTheme.of(context).palette.disabled
                          : OrbTheme.of(context).palette.brand,
                    )
                  : RadioIcon(
                      disabled: disabled,
                      selected: selected,
                    ),
        ),
        if (text != null) buildText(context),
        if (iconSpec != null)
          buildButtonIcon(
            context,
            icon: OrbIcon(
              iconSpec!,
              size: OrbTheme.of(context).size.icon.medium,
              defaultColor: disabled
                  ? selected
                      ? OrbTheme.of(context).palette.normal
                      : OrbTheme.of(context).palette.disabledDark
                  : OrbTheme.of(context).palette.blank,
            ),
            right: true,
          ),
      ],
    );
  }

  @override
  Widget buildText(BuildContext context) {
    return Flexible(
      child: Text(
        text!,
        textAlign: TextAlign.center,
        style: (OrbTheme.of(context).text.font.normal)
            .merge(OrbTheme.of(context).text.style.bold)
            .merge(OrbTheme.of(context).text.size.small)
            .copyWith(
              color: disabled
                  ? selected
                      ? OrbTheme.of(context).palette.brand
                      : OrbTheme.of(context).palette.disabledDark
                  : OrbTheme.of(context).palette.brand,
            ),
      ),
    );
  }
}

class RadioIcon extends StatelessWidget {
  final bool disabled;
  final bool selected;

  const RadioIcon({required this.disabled, required this.selected, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: OrbTheme.of(context).lengths.medium,
          height: OrbTheme.of(context).lengths.medium,
          decoration: BoxDecoration(
            color: disabled
                ? OrbTheme.of(context).palette.disabled
                : OrbTheme.of(context).palette.brandShadow,
            shape: BoxShape.circle,
          ),
        ),
        if (selected)
          Container(
            width: OrbTheme.of(context).lengths.medium * 0.6,
            height: OrbTheme.of(context).lengths.medium * 0.6,
            decoration: BoxDecoration(
              color: OrbTheme.of(context).palette.brand,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }
}

class RowIcon extends StatelessWidget {
  final OrbIcon icon;

  const RowIcon({required this.icon, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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

  const RowImage({required this.image, Key? key}) : super(key: key);

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

  const Title({required this.text, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: OrbTheme.of(context).lengths.medium,
        left: OrbTheme.of(context).lengths.mediumSmall,
        right: OrbTheme.of(context).lengths.mediumSmall,
      ),
      child: Text(
        text!,
        style: OrbTheme.of(context)
            .text
            .style
            .bold
            .merge(OrbTheme.of(context).text.size.medium),
      ),
    );
  }
}

class Description extends StatelessWidget {
  final String? text;

  const Description({required this.text, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: OrbTheme.of(context).lengths.medium,
        left: OrbTheme.of(context).lengths.mediumSmall,
        right: OrbTheme.of(context).lengths.mediumSmall,
      ),
      child: Text(
        text!,
        style: OrbTheme.of(context)
            .text
            .style
            .normal
            .merge(OrbTheme.of(context).text.size.medium),
      ),
    );
  }
}
