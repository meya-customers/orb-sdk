import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:separated_column/separated_column.dart';
import 'package:separated_row/separated_row.dart';

import 'package:orb/connection.dart';
import 'package:orb/design.dart';
import 'package:orb/event.dart';
import 'package:orb/event_stream.dart';
import 'package:orb/ui/card/util/button.dart';
import 'package:orb/ui/card/util/error.dart';
import 'package:orb/ui/card/util/label.dart';
import 'package:orb/ui/card/widget_mode.dart';
import 'package:orb/ui/presence/user_avatar.dart';

class OrbChoiceInput extends StatefulWidget {
  final OrbEvent event;
  final OrbEventStream eventStream;
  final OrbConnection connection;
  final OrbUserAvatar? userAvatar;
  final OrbWidgetMode mode;
  final ValueNotifier<dynamic>? controller;
  final bool? disabled;

  const OrbChoiceInput({
    required this.event,
    required this.eventStream,
    required this.connection,
    required this.userAvatar,
    required this.mode,
    required this.controller,
    required this.disabled,
    Key? key,
  }) : super(key: key);

  static bool isVisible(OrbEvent event, Map<String, OrbEvent> fieldEvents) {
    final String? fieldId = event.data['field_id'];
    return (event.data['choices'] as List<dynamic>).isNotEmpty &&
        (fieldId == null || fieldEvents[fieldId] == event);
  }

  static ValueNotifier<dynamic> createController(
    dynamic inputData,
    OrbEvent event,
  ) {
    final List<dynamic> choices = event.data['choices'];
    if (event.data['multi'] != true) {
      return ValueNotifier(
        inputData as String? ??
            (choices.cast<Map<dynamic, dynamic>>().firstWhereOrNull(
                  (choice) => choice['default'] == true,
                ))?['text'] ??
            '',
      );
    } else {
      return ValueNotifier(
        (inputData as List<dynamic>? ??
                choices
                    .cast<Map<dynamic, dynamic>>()
                    .where(
                      (choice) => choice['default'] == true,
                    )
                    .map((choice) => choice['text']))
            .cast<String>()
            .toList(),
      );
    }
  }

  @override
  _OrbChoiceInputState createState() => _OrbChoiceInputState();
}

class _OrbChoiceInputState extends State<OrbChoiceInput> {
  late ValueNotifier<dynamic> controller;
  late bool disabledOverride;
  String? selectedButtonId;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ??
        OrbChoiceInput.createController(
          widget.event.data['input_data'],
          widget.event,
        );
    disabledOverride = false;
  }

  @override
  void dispose() {
    if (controller != widget.controller) {
      controller.dispose();
    }
    super.dispose();
  }

  bool get disabled {
    return disabledOverride ||
        (widget.disabled ??
            widget.event.data['disabled'] == true ||
                widget.event.data['ok'] == true ||
                !widget.eventStream.isActiveEvent(widget.event));
  }

  bool get invalid {
    return !disabled && widget.event.data['error'] != null;
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> choices = widget.event.data['choices'];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (widget.mode == OrbWidgetMode.standalone)
          OrbUserAvatar.avatarOrPlaceholder(
            context,
            avatar: widget.userAvatar,
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.event.data['label'] != null)
                OrbLabel(
                  label: widget.event.data['label'],
                  required: widget.event.data['required'],
                  disabled: disabled,
                  focus: false,
                  invalid: invalid,
                ),
              IntrinsicWidth(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: OrbTheme.of(context).lengths.small,
                    horizontal: OrbTheme.of(context).lengths.medium,
                  ),
                  decoration: BoxDecoration(
                    border: OrbTheme.of(context).innerBorder.thin(
                          OrbTheme.of(context).palette.brandNeutral,
                        ),
                    borderRadius: BorderRadius.all(
                      OrbTheme.of(context).borderRadius.small,
                    ),
                  ),
                  child: SeparatedColumn(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: buildChoices(context, choices),
                    separatorBuilder: (_context, _index) => Divider(
                      color: OrbTheme.of(context).palette.brandNeutral,
                      thickness: 1,
                      height: 1,
                    ),
                  ),
                ),
              ),
              if (invalid) OrbError(error: widget.event.data['error']),
              if (widget.mode == OrbWidgetMode.standalone)
                Container(
                  margin: EdgeInsets.only(
                    top: OrbTheme.of(context).lengths.medium,
                  ),
                  child: IntrinsicWidth(
                    child: OrbButton(
                      text: widget.event.data['submit_button_text'],
                      iconSpec: null,
                      onTap: () {
                        widget.connection.publishEvent(
                          OrbEvent.createFieldButtonClickEvent(
                            widget.event.data['field_id'],
                            widget.event.data['submit_button_id'],
                            controller.value,
                            text: widget.event.data['submit_button_text'],
                          ),
                        );
                      },
                      disabled: disabled,
                      selected: false,
                      isAction: true,
                      isLink: false,
                      isMenu: false,
                      mode: OrbWidgetMode.standalone,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> buildChoices(
    BuildContext context,
    List<dynamic> choices,
  ) {
    return choices.cast<Map<dynamic, dynamic>>().map((choice) {
      final String text = choice['text'];
      final bool selected = widget.event.data['multi'] != true
          ? text == controller.value
          : (controller.value as List<String>).contains(text);
      final bool choiceDisabled = choice['disabled'] == true;
      return Choice(
        multi: widget.event.data['multi'],
        text: text,
        onTap: () async {
          setState(() {
            if (widget.event.data['multi'] != true) {
              controller.value = selected ? '' : text;
            } else if (selected) {
              controller.value = List.of(controller.value as List<String>)
                ..remove(text);
            } else {
              controller.value = [...controller.value as List<String>, text];
            }
          });
        },
        disabled: disabled || choiceDisabled,
        selected: selected,
      );
    }).toList();
  }
}

class Choice extends StatelessWidget {
  final bool multi;
  final String text;
  final void Function() onTap;
  final bool disabled;
  final bool selected;

  const Choice({
    required this.multi,
    required this.text,
    required this.onTap,
    required this.disabled,
    required this.selected,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (disabled) {
      return buildChoice(context);
    } else {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            FocusScope.of(context).unfocus();
            onTap();
          },
          splashColor: Colors.transparent,
          highlightColor: OrbTheme.of(context).palette.brandShadow,
          child: buildChoice(context),
        ),
      );
    }
  }

  Widget buildChoice(BuildContext context) {
    final Color textColor;
    if (selected && disabled) {
      textColor = OrbTheme.of(context).palette.disabledDark;
    } else if (selected) {
      textColor = OrbTheme.of(context).palette.brand;
    } else if (disabled) {
      textColor = OrbTheme.of(context).palette.disabled;
    } else {
      textColor = OrbTheme.of(context).palette.brand;
    }
    return Container(
      constraints: const BoxConstraints(minWidth: 80),
      padding: EdgeInsets.only(
        top: OrbTheme.of(context).lengths.mediumSmall,
        right: OrbTheme.of(context).lengths.medium,
        bottom: OrbTheme.of(context).lengths.mediumSmall,
        left: OrbTheme.of(context).lengths.mediumSmall,
      ),
      child: SeparatedRow(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5),
            child: CustomPaint(
              child: AnimatedOpacity(
                opacity: selected ? 1 : 0,
                curve: Curves.easeInOutCubic,
                duration: const Duration(milliseconds: 150),
                child: CustomPaint(
                  child: const SizedBox(width: 16, height: 16),
                  painter: ChoiceSelectedIconPainter(
                    multi: multi,
                    textColor: textColor,
                    blankColor: OrbTheme.of(context).palette.blank,
                  ),
                ),
              ),
              painter: ChoiceIconPainter(
                multi: multi,
                textColor: textColor,
              ),
            ),
          ),
          Flexible(
            child: Text(
              text,
              style: (OrbTheme.of(context).text.font.normal)
                  .merge(OrbTheme.of(context).text.style.bold)
                  .merge(OrbTheme.of(context).text.size.medium)
                  .copyWith(color: textColor),
            ),
          ),
        ],
        separatorBuilder: (_context, _index) =>
            SizedBox(width: OrbTheme.of(context).lengths.mediumSmall),
      ),
    );
  }
}

class ChoiceIconPainter extends CustomPainter {
  final bool multi;
  final Color textColor;

  ChoiceIconPainter({
    required this.multi,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final brandPaintStroke = Paint()
      ..color = textColor
      ..strokeWidth = 1.0 / 16.0 * size.width
      ..style = PaintingStyle.stroke;
    final rectSize = Size(
      size.width - brandPaintStroke.strokeWidth,
      size.height - brandPaintStroke.strokeWidth,
    );
    final rectOffset = Offset(
      brandPaintStroke.strokeWidth / 2.0,
      brandPaintStroke.strokeWidth / 2.0,
    );
    final rectRadius = !multi
        ? Radius.elliptical(rectSize.width / 2.0, rectSize.height / 2.0)
        : Radius.elliptical(4.0 / 16.0 * size.width, 4.0 / 16.0 * size.height);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rectOffset & rectSize, rectRadius),
      brandPaintStroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class ChoiceSelectedIconPainter extends CustomPainter {
  final bool multi;
  final Color textColor;
  final Color blankColor;

  ChoiceSelectedIconPainter({
    required this.multi,
    required this.textColor,
    required this.blankColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final brandFillPaint = Paint()..color = textColor;
    if (!multi) {
      final rectSize =
          Size(10.0 / 16.0 * size.width, 10.0 / 16.0 * size.height);
      final rectOffset = Offset(
        (size.width - rectSize.width) / 2.0,
        (size.height - rectSize.height) / 2.0,
      );
      canvas.drawOval(rectOffset & rectSize, brandFillPaint);
    } else {
      final rectRadius =
          Radius.elliptical(4.0 / 16.0 * size.width, 4.0 / 16.0 * size.height);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Offset.zero & size, rectRadius),
        brandFillPaint,
      );
      final lineStart = Offset(0.2 * size.width, 0.5 * size.height);
      final lineMid = Offset(0.4 * size.width, 0.7 * size.height);
      final lineEnd = Offset(0.8 * size.width, 0.3 * size.height);
      final blankStokePaint = Paint()
        ..color = blankColor
        ..strokeWidth = 2.0 / 16.0 * size.width
        ..strokeCap = StrokeCap.square
        ..style = PaintingStyle.stroke;
      canvas.drawPoints(
        PointMode.polygon,
        [lineStart, lineMid, lineEnd],
        blankStokePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
