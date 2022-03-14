import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:collection/collection.dart';
import 'package:separated_column/separated_column.dart';
import 'package:separated_row/separated_row.dart';

import 'package:orb/connection.dart';
import 'package:orb/event.dart';
import 'package:orb/ui/card/util/button.dart';
import 'package:orb/ui/card/util/error.dart';
import 'package:orb/ui/card/util/label.dart';
import 'package:orb/ui/card/widget_mode.dart';
import 'package:orb/ui/design.dart';
import 'package:orb/ui/presence/user_avatar.dart';

class OrbChoiceInput extends StatefulWidget {
  final OrbEvent event;
  final OrbConnection connection;
  final OrbUserAvatar? userAvatar;
  final OrbWidgetMode mode;
  final ValueNotifier<dynamic>? controller;
  final bool? disabled;

  OrbChoiceInput({
    required this.event,
    required this.connection,
    required this.userAvatar,
    required this.mode,
    required this.controller,
    required this.disabled,
  });

  static bool isVisible(OrbEvent event, Map<String, OrbEvent> fieldEvents) {
    final String? fieldId = event.data["field_id"];
    return event.data["choices"].length > 0 &&
        (fieldId == null || fieldEvents[fieldId] == event);
  }

  static ValueNotifier<dynamic> createController(
      dynamic inputData, OrbEvent event) {
    final List<dynamic> choices = event.data["choices"];
    if (!event.data["multi"]) {
      return ValueNotifier(inputData ??
          choices.firstWhereOrNull(
              (choice) => choice["default"] == true)?["text"] ??
          "");
    } else {
      return ValueNotifier(inputData ??
          choices
              .where((choice) => choice["default"] == true)
              .map((choice) => choice["text"]));
    }
  }

  _OrbChoiceInputState createState() => _OrbChoiceInputState(
      controller:
          controller ?? createController(event.data["input_data"], event));
}

class _OrbChoiceInputState extends State<OrbChoiceInput> {
  late bool disabledOverride;
  String? selectedButtonId;
  ValueNotifier<dynamic> controller;

  _OrbChoiceInputState({
    required this.controller,
  });

  @override
  void initState() {
    super.initState();
    disabledOverride = false;
  }

  bool get disabled {
    return disabledOverride ||
        (widget.disabled ??
            widget.event.data["disabled"] == true ||
                widget.event.data["ok"] == true ||
                !widget.connection
                    .getEventStream()
                    .isActiveEvent(widget.event));
  }

  bool get invalid {
    return !disabled && widget.event.data["error"] != null;
  }

  @override
  Widget build(BuildContext context) {
    final choices = widget.event.data['choices'] as List<dynamic>;
    if (choices.length == 0) {
      return SizedBox.shrink();
    } else {
      return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        if (widget.mode == OrbWidgetMode.standalone)
          OrbUserAvatar.avatarOrPlaceholder(
            context,
            avatar: widget.userAvatar,
          ),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(top: OrbTheme.of(context).lengths.large),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (widget.event.data['label'] != null)
                    Label(
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
                          horizontal: OrbTheme.of(context).lengths.medium),
                      decoration: BoxDecoration(
                          border: OrbTheme.of(context).innerBorder.thin(
                                OrbTheme.of(context).palette.neutral,
                              ),
                          borderRadius: BorderRadius.all(
                              OrbTheme.of(context).borderRadius.small)),
                      child: SeparatedColumn(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: buildChoices(context, choices),
                          separatorBuilder:
                              (BuildContext _context, int _index) => Divider(
                                  color: OrbTheme.of(context).palette.neutral,
                                  thickness: 1,
                                  height: 1)),
                    ),
                  ),
                  if (invalid) Error(error: widget.event.data["error"]),
                  if (widget.mode == OrbWidgetMode.standalone)
                    Container(
                      margin: EdgeInsets.only(
                          top: OrbTheme.of(context).lengths.medium),
                      child: IntrinsicWidth(
                        child: Button(
                            text: widget.event.data["submit_button_text"],
                            icon: null,
                            onTap: () {
                              widget.connection.publishEvent(
                                  OrbEvent.createFieldButtonClickEvent(
                                widget.event.data["field_id"],
                                widget.event.data["submit_button_id"],
                                controller.value,
                                text: widget.event.data["submit_button_text"],
                              ));
                            },
                            disabled: disabled,
                            selected: false,
                            isAction: true,
                            isLink: false,
                            mode: OrbWidgetMode.standalone),
                      ),
                    )
                ]),
          ),
        )
      ]);
    }
  }

  List<Widget> buildChoices(
    BuildContext context,
    List<dynamic> choices,
  ) {
    return choices.map((choice) {
      final text = choice['text'];
      final bool selected = !widget.event.data["multi"]
          ? text == controller.value
          : controller.value.contains(text);
      final bool choiceDisabled = choice['disabled'] == true;
      return Choice(
        multi: widget.event.data["multi"],
        text: text,
        onTap: () async {
          setState(() {
            if (!widget.event.data["multi"]) {
              controller.value = selected ? '' : text;
            } else if (selected) {
              controller.value = List.of(controller.value)..remove(text);
            } else {
              controller.value = [...controller.value, text];
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

  Choice({
    required this.multi,
    required this.text,
    required this.onTap,
    required this.disabled,
    required this.selected,
  });

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
          ));
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
      constraints: BoxConstraints(minWidth: 80),
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
              margin: EdgeInsets.only(top: 5),
              child: CustomPaint(
                child: AnimatedOpacity(
                  opacity: selected ? 1 : 0,
                  curve: Curves.easeInOutCubic,
                  duration: Duration(milliseconds: 150),
                  child: CustomPaint(
                    child: SizedBox(width: 16, height: 16),
                    painter: ChoiceSelectedIconPainter(
                        multi: multi,
                        textColor: textColor,
                        blankColor: OrbTheme.of(context).palette.blank),
                  ),
                ),
                painter: ChoiceIconPainter(
                  multi: multi,
                  textColor: textColor,
                ),
              ),
            ),
            Text(
              text,
              style: (OrbTheme.of(context).text.font.normal)
                  .merge(OrbTheme.of(context).text.style.bold)
                  .merge(OrbTheme.of(context).text.size.medium)
                  .copyWith(color: textColor),
            ),
          ],
          separatorBuilder: (BuildContext _context, int _index) =>
              SizedBox(width: OrbTheme.of(context).lengths.mediumSmall)),
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
    final rectSize = Size(size.width - brandPaintStroke.strokeWidth,
        size.height - brandPaintStroke.strokeWidth);
    final rectOffset = Offset(
        brandPaintStroke.strokeWidth / 2.0, brandPaintStroke.strokeWidth / 2.0);
    final rectRadius = !multi
        ? Radius.elliptical(rectSize.width / 2.0, rectSize.height / 2.0)
        : Radius.elliptical(4.0 / 16.0 * size.width, 4.0 / 16.0 * size.height);
    canvas.drawRRect(RRect.fromRectAndRadius(rectOffset & rectSize, rectRadius),
        brandPaintStroke);
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
      final rectOffset = Offset((size.width - rectSize.width) / 2.0,
          (size.height - rectSize.height) / 2.0);
      canvas.drawOval(rectOffset & rectSize, brandFillPaint);
    } else {
      var rectRadius =
          Radius.elliptical(4.0 / 16.0 * size.width, 4.0 / 16.0 * size.height);
      canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero & size, rectRadius),
          brandFillPaint);
      final lineStart = Offset(0.2 * size.width, 0.5 * size.height);
      final lineMid = Offset(0.4 * size.width, 0.7 * size.height);
      final lineEnd = Offset(0.8 * size.width, 0.3 * size.height);
      final blankStokePaint = Paint()
        ..color = blankColor
        ..strokeWidth = 2.0 / 16.0 * size.width
        ..strokeCap = StrokeCap.square
        ..style = PaintingStyle.stroke;
      canvas.drawPoints(
          PointMode.polygon, [lineStart, lineMid, lineEnd], blankStokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
