import 'package:flutter/material.dart';

import 'package:separated_row/separated_row.dart';

import 'package:orb/config.dart';
import 'package:orb/connection.dart';
import 'package:orb/design.dart';
import 'package:orb/event.dart';
import 'package:orb/event_stream.dart';
import 'package:orb/ui/card/util/url.dart';
import 'package:orb/ui/icon.dart';
import 'package:orb/ui/menu.dart';

class OrbHeader extends StatefulWidget {
  final OrbEventStream eventStream;
  final OrbConnection connection;
  final List<Widget> Function(
    BuildContext context, {
    required bool headerIsTransparent,
  }) childrenBuilder;

  const OrbHeader({
    required this.eventStream,
    required this.connection,
    required this.childrenBuilder,
    Key? key,
  }) : super(key: key);

  @override
  _OrbHeaderState createState() => _OrbHeaderState();
}

class _OrbHeaderState extends State<OrbHeader> {
  OverlayEntry? overlayEntry;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if (overlayEntry != null) {
      overlayEntry!.remove();
      overlayEntry = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentEvent = widget.eventStream.events.firstWhere(
      (event) =>
          event.data['header'] != null &&
          !widget.eventStream.isSelfEvent(event),
      orElse: () => OrbEvent(id: '-', type: 'empty', data: {}),
    );
    final current = OrbHeaderEventSpec.fromMap(currentEvent.data['header']) ??
        const OrbHeaderEventSpec();
    final currentTitle = current.title ?? const OrbHeaderTitleEventSpec();
    final currentProgress =
        current.progress ?? const OrbHeaderProgressEventSpec();
    final buttons = current.buttons ?? OrbConfig.of(context).header.buttons;
    final titleIcon =
        currentTitle.icon ?? OrbConfig.of(context).header.title.icon;
    final titleText =
        currentTitle.text ?? OrbConfig.of(context).header.title.text;
    final progressValue =
        currentProgress.value ?? OrbConfig.of(context).header.progress.value;
    final progressShowPercent = currentProgress.showPercent ??
        OrbConfig.of(context).header.progress.showPercent;
    final milestones =
        current.milestones ?? OrbConfig.of(context).header.milestones;
    final extraButtons =
        current.extraButtons ?? OrbConfig.of(context).header.extraButtons;
    final transparent = buttons.isEmpty &&
        titleIcon == null &&
        (titleText ?? '') == '' &&
        progressValue == null &&
        milestones.isEmpty &&
        extraButtons.isEmpty;
    final Widget? header;

    if (transparent) {
      if (widget.connection.enableCloseButton && overlayEntry == null) {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          overlayEntry = OverlayEntry(
            builder: (context) => Positioned(
              top: MediaQuery.of(context).padding.top +
                  OrbTheme.of(context).lengths.small,
              right: MediaQuery.of(context).padding.right +
                  OrbTheme.of(context).lengths.small,
              child: buildCloseButton(context),
            ),
          );
          Overlay.of(context)!.insert(overlayEntry!);
        });
      }
      header = null;
    } else {
      if (overlayEntry != null) {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          overlayEntry!.remove();
          overlayEntry = null;
        });
      }
      header = Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top +
              OrbTheme.of(context).lengths.mediumSmall,
          right: OrbTheme.of(context).lengths.mediumSmall,
          bottom: OrbTheme.of(context).lengths.mediumSmall,
          left: OrbTheme.of(context).lengths.mediumSmall,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: OrbTheme.of(context).palette.brandNeutral,
              width: 1,
            ),
          ),
          color: Colors.white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildButtonGroup(context, [
              for (final button in buttons) buildButton(context, button),
            ]),
            _OrbHeaderTitle(iconSpec: titleIcon, text: titleText),
            _OrbHeaderProgress(
              value: progressValue,
              showPercent: progressShowPercent,
            ),
            _OrbHeaderMilestones(
              milestones: milestones.cast<Map<dynamic, dynamic>>().toList(),
            ),
            buildButtonGroup(context, [
              for (final button in extraButtons) buildButton(context, button),
              buildCloseButton(context),
            ]),
          ],
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.max,
      children: [
        if (header != null) header,
        ...widget.childrenBuilder(context, headerIsTransparent: transparent),
      ],
    );
  }

  Widget buildButtonGroup(BuildContext context, List<Widget> children) {
    return SeparatedRow(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
      separatorBuilder: (_context, _index) =>
          SizedBox(width: OrbTheme.of(context).lengths.small),
    );
  }

  Widget buildButton(
    BuildContext context,
    Map<dynamic, dynamic> button,
  ) {
    final buttonId = button['button_id'];
    final text = button['text'];
    final icon = button['icon'];
    final itemContext = button['context'];
    final String? url = button['url'];
    final menu = button['menu'];
    final disabled = button['disabled'] == true;
    return _OrbHeaderButton(
      text: text,
      iconSpec: OrbIconSpec.fromMap(icon),
      onTap: () async {
        if (url != null) {
          await OrbUrl(url).tryLaunch(context);
        } else if (menu != null) {
          OrbMenuState.of(context).openMenu(widget.eventStream, menu);
        } else if (buttonId != null) {
          widget.connection.publishEvent(
            OrbEvent.createButtonClickEvent(
              buttonId,
              text: text,
              context: itemContext,
            ),
          );
          OrbMenuState.of(context).closeMenu();
        } else {
          widget.connection.publishEvent(
            OrbEvent.createSayEvent(
              text,
              context: itemContext,
            ),
          );
          OrbMenuState.of(context).closeMenu();
        }
      },
      disabled: disabled,
    );
  }

  Widget buildCloseButton(BuildContext context) {
    return _OrbHeaderButton(
      text: null,
      iconSpec: OrbIcons.close,
      onTap: () => widget.connection.closeUi(),
      disabled: false,
    );
  }
}

class _OrbHeaderButton extends StatelessWidget {
  final String? text;
  final OrbIconSpec? iconSpec;
  final void Function() onTap;
  final bool disabled;

  const _OrbHeaderButton({
    required this.text,
    required this.iconSpec,
    required this.onTap,
    required this.disabled,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (disabled) {
      return buildButton(context);
    } else {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            FocusScope.of(context).unfocus();
            onTap();
          },
          borderRadius: BorderRadius.all(
            OrbTheme.of(context).borderRadius.small,
          ),
          splashColor: Colors.transparent,
          highlightColor: OrbTheme.of(context).palette.brandShadow,
          child: buildButton(context),
        ),
      );
    }
  }

  Widget buildButton(BuildContext context) {
    final Color textColor;
    if (disabled) {
      textColor = OrbTheme.of(context).palette.disabled;
    } else {
      textColor = OrbTheme.of(context).palette.normal;
    }
    return Container(
      padding: EdgeInsets.all(OrbTheme.of(context).lengths.tiny),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (iconSpec != null)
            OrbIcon(
              iconSpec!,
              size: OrbTheme.of(context).size.icon.medium,
              color: textColor,
            ),
          if (text != null)
            Text(
              text!.toUpperCase(),
              style: (OrbTheme.of(context).text.font.normal)
                  .merge(OrbTheme.of(context).text.style.bold)
                  .merge(OrbTheme.of(context).text.size.tiny)
                  .copyWith(color: textColor),
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}

class _OrbHeaderTitle extends StatelessWidget {
  final OrbIconSpec? iconSpec;
  final String? text;

  const _OrbHeaderTitle({
    required this.iconSpec,
    required this.text,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (iconSpec == null && (text ?? '') == '') {
      return const SizedBox.shrink();
    }
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: OrbTheme.of(context).lengths.tiny,
          horizontal: OrbTheme.of(context).lengths.medium,
        ),
        child: SeparatedRow(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (iconSpec != null)
              OrbIcon(
                iconSpec!,
                size: OrbTheme.of(context).size.icon.medium,
                color: OrbTheme.of(context).palette.normal,
              ),
            if (text != null)
              Flexible(
                child: Text(
                  text!,
                  style: (OrbTheme.of(context).text.font.normal)
                      .merge(OrbTheme.of(context).text.style.bold)
                      .merge(
                        TextStyle(
                          fontSize: OrbTheme.of(context)
                              .text
                              .size
                              .mediumLarge
                              .fontSize!,
                          height: 24 /
                              OrbTheme.of(context)
                                  .text
                                  .size
                                  .mediumLarge
                                  .fontSize!,
                        ),
                      )
                      .copyWith(color: OrbTheme.of(context).palette.normal),
                ),
              ),
          ],
          separatorBuilder: (_context, _index) =>
              SizedBox(width: OrbTheme.of(context).lengths.small),
        ),
      ),
    );
  }
}

class _OrbHeaderProgress extends StatelessWidget {
  final num? value;
  final bool? showPercent;

  const _OrbHeaderProgress({
    required this.value,
    required this.showPercent,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (value == null) {
      return const SizedBox.shrink();
    }
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: OrbTheme.of(context).lengths.tiny,
          horizontal: OrbTheme.of(context).lengths.medium,
        ),
        child: SeparatedRow(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: LayoutBuilder(
                builder: (context, constraints) => Stack(
                  children: [
                    Container(
                      width: constraints.maxWidth,
                      height: OrbTheme.of(context).lengths.mediumSmall,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(
                            OrbTheme.of(context).lengths.mediumSmall / 2,
                          ),
                        ),
                        color: OrbTheme.of(context).palette.disabled,
                      ),
                    ),
                    AnimatedContainer(
                      width: constraints.maxWidth * value! / 100,
                      height: OrbTheme.of(context).lengths.mediumSmall,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(
                            OrbTheme.of(context).lengths.mediumSmall / 2,
                          ),
                        ),
                        color: OrbTheme.of(context).palette.brand,
                      ),
                      curve: Curves.decelerate,
                      duration: const Duration(milliseconds: 500),
                    ),
                  ],
                ),
              ),
            ),
            if (showPercent == true)
              Text(
                '${value!.round()}%',
                style: (OrbTheme.of(context).text.font.normal)
                    .merge(OrbTheme.of(context).text.style.bold)
                    .merge(
                      TextStyle(
                        fontSize:
                            OrbTheme.of(context).text.size.small.fontSize!,
                        height:
                            16 / OrbTheme.of(context).text.size.small.fontSize!,
                      ),
                    )
                    .copyWith(color: OrbTheme.of(context).palette.normal),
              ),
          ],
          separatorBuilder: (_context, _index) =>
              SizedBox(width: OrbTheme.of(context).lengths.small),
        ),
      ),
    );
  }
}

class _OrbHeaderMilestones extends StatelessWidget {
  final List<Map<dynamic, dynamic>> milestones;

  const _OrbHeaderMilestones({
    required this.milestones,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (milestones.isEmpty) {
      return const SizedBox.shrink();
    }
    final List<Widget> foregroundChildren = [];
    final List<Widget> backgroundChildren = [];

    final hasText =
        milestones.any((milestone) => (milestone['text'] ?? '') != '');
    final currentIndex = milestones.indexWhere(
      (milestone) => milestone['current'] == true,
    );
    for (var i = 0; i < milestones.length; i++) {
      final milestone = milestones[i];
      final String? milestoneText = milestone['text'];
      final milestoneColor = i <= currentIndex
          ? OrbTheme.of(context).palette.brand
          : OrbTheme.of(context).palette.disabled;
      foregroundChildren.add(
        SizedOverflowBox(
          size: Size.zero,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: OrbTheme.of(context).lengths.medium,
                height: OrbTheme.of(context).lengths.medium,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(OrbTheme.of(context).lengths.medium / 2),
                  ),
                  color: milestoneColor,
                ),
              ),
              if (milestoneText != null)
                Container(
                  padding: const EdgeInsets.only(bottom: 42),
                  child: Text(
                    milestoneText,
                    style: (OrbTheme.of(context).text.font.normal)
                        .merge(
                          OrbTheme.of(context)
                              .text
                              .style
                              .bold, // TODO Use Inter semibold
                        )
                        .merge(OrbTheme.of(context).text.size.small)
                        .copyWith(color: milestoneColor),
                  ),
                )
            ],
          ),
        ),
      );
      if (i < milestones.length - 1) {
        foregroundChildren.add(const Expanded(child: SizedBox.shrink()));
        final segmentColor = i < currentIndex
            ? OrbTheme.of(context).palette.brand
            : OrbTheme.of(context).palette.disabled;
        backgroundChildren.add(
          Expanded(
            child: Container(
              height: OrbTheme.of(context).lengths.tiny,
              color: segmentColor,
            ),
          ),
        );
      }
    }

    return Expanded(
      child: Container(
        padding: EdgeInsets.only(
          top: hasText
              ? OrbTheme.of(context).lengths.large
              : OrbTheme.of(context).lengths.tiny,
          right: OrbTheme.of(context).lengths.large,
          bottom: OrbTheme.of(context).lengths.tiny,
          left: OrbTheme.of(context).lengths.large,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: backgroundChildren,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: foregroundChildren,
            ),
          ],
        ),
      ),
    );
  }
}
