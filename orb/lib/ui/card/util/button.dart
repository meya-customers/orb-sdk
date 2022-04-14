import 'package:flutter/material.dart';

import 'package:separated_row/separated_row.dart';

import 'package:orb/design.dart';
import 'package:orb/ui/card/widget_mode.dart';
import 'package:orb/ui/icon.dart';

class OrbButton extends StatelessWidget {
  final String? text;
  final OrbIconSpec? iconSpec;
  final void Function() onTap;
  final bool disabled;
  final bool selected;
  final bool isAction;
  final bool isLink;
  final bool isMenu;
  final OrbWidgetMode mode;

  const OrbButton({
    required this.text,
    required this.iconSpec,
    required this.onTap,
    required this.disabled,
    required this.selected,
    required this.isAction,
    required this.isLink,
    required this.isMenu,
    required this.mode,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (disabled) {
      return buildMaterial(
        context,
        ({required decorationBorderColor, required textColor}) => buildButton(
          context,
          decorationBorderColor: decorationBorderColor,
          textColor: textColor,
        ),
      );
    } else {
      return buildMaterial(
        context,
        ({required decorationBorderColor, required textColor}) => Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              FocusScope.of(context).unfocus();
              onTap();
            },
            borderRadius:
                BorderRadius.all(OrbTheme.of(context).borderRadius.small),
            splashColor: Colors.transparent,
            highlightColor: OrbTheme.of(context).palette.brandShadow,
            child: buildButton(
              context,
              decorationBorderColor: decorationBorderColor,
              textColor: textColor,
            ),
          ),
        ),
      );
    }
  }

  Widget buildMaterial(
    BuildContext context,
    Widget Function({
      required Color decorationBorderColor,
      required Color textColor,
    })
        child,
  ) {
    final Color decorationColor;
    final Color decorationBorderColor;
    final Color textColor;
    if (mode == OrbWidgetMode.standalone) {
      if (selected) {
        decorationColor = OrbTheme.of(context).palette.disabled;
        decorationBorderColor = OrbTheme.of(context).palette.normal;
        textColor = OrbTheme.of(context).palette.normal;
      } else if (disabled) {
        decorationColor = OrbTheme.of(context).palette.disabled;
        decorationBorderColor = OrbTheme.of(context).palette.disabled;
        textColor = OrbTheme.of(context).palette.disabledDark;
      } else {
        decorationColor = OrbTheme.of(context).palette.brand;
        decorationBorderColor = OrbTheme.of(context).palette.brand;
        textColor = OrbTheme.of(context).palette.blank;
      }
    } else {
      if (selected) {
        decorationColor = OrbTheme.of(context).palette.brand;
        decorationBorderColor = OrbTheme.of(context).palette.brand;
        textColor = OrbTheme.of(context).palette.blank;
      } else if (disabled) {
        decorationColor = OrbTheme.of(context).palette.disabled;
        decorationBorderColor = OrbTheme.of(context).palette.disabled;
        textColor = OrbTheme.of(context).palette.disabledDark;
      } else if (isAction || isLink || isMenu) {
        decorationColor = OrbTheme.of(context).palette.brandNeutral;
        decorationBorderColor = OrbTheme.of(context).palette.brand;
        textColor = OrbTheme.of(context).palette.brand;
      } else {
        decorationColor = OrbTheme.of(context).palette.brandNeutral;
        decorationBorderColor = OrbTheme.of(context).palette.brandNeutral;
        textColor = OrbTheme.of(context).palette.brand;
      }
    }
    return Material(
      color: decorationColor,
      borderRadius: BorderRadius.all(OrbTheme.of(context).borderRadius.small),
      child: child(
        decorationBorderColor: decorationBorderColor,
        textColor: textColor,
      ),
    );
  }

  Widget buildButton(
    BuildContext context, {
    required Color decorationBorderColor,
    required Color textColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: OrbTheme.of(context).lengths.medium,
        horizontal: OrbTheme.of(context).lengths.large,
      ),
      decoration: BoxDecoration(
        boxShadow: [OrbTheme.of(context).outerShadow.tiny],
        border: OrbTheme.of(context).innerBorder.thin(
              decorationBorderColor,
            ),
        borderRadius: BorderRadius.all(OrbTheme.of(context).borderRadius.small),
      ),
      child: SeparatedRow(
        mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }
}
