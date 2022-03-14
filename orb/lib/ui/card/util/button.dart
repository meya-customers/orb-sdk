import 'package:flutter/material.dart';

import 'package:separated_row/separated_row.dart';

import 'package:orb/ui/card/widget_mode.dart';
import 'package:orb/ui/design.dart';
import 'package:orb/ui/icon.dart';

class Button extends StatelessWidget {
  final String? text;
  final Map<dynamic, dynamic>? icon;
  final void Function() onTap;
  final bool disabled;
  final bool selected;
  final bool isAction;
  final bool isLink;
  final OrbWidgetMode mode;

  Button({
    required this.text,
    required this.icon,
    required this.onTap,
    required this.disabled,
    required this.selected,
    required this.isAction,
    required this.isLink,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    if (disabled) {
      return buildButton(context);
    } else {
      return InkWell(
        onTap: () {
          FocusScope.of(context).unfocus();
          onTap();
        },
        child: buildButton(context),
      );
    }
  }

  Widget buildButton(BuildContext context) {
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
      } else if (isAction || isLink) {
        decorationColor = OrbTheme.of(context).palette.brandNeutral;
        decorationBorderColor = OrbTheme.of(context).palette.brand;
        textColor = OrbTheme.of(context).palette.brand;
      } else {
        decorationColor = OrbTheme.of(context).palette.brandNeutral;
        decorationBorderColor = OrbTheme.of(context).palette.brandNeutral;
        textColor = OrbTheme.of(context).palette.brand;
      }
    }
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: OrbTheme.of(context).lengths.medium,
          horizontal: OrbTheme.of(context).lengths.large),
      decoration: BoxDecoration(
          boxShadow: [OrbTheme.of(context).outerShadow.tiny],
          color: decorationColor,
          border: OrbTheme.of(context).innerBorder.thin(
                decorationBorderColor,
              ),
          borderRadius:
              BorderRadius.all(OrbTheme.of(context).borderRadius.small)),
      child: SeparatedRow(
          mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }
}
