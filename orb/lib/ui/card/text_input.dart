import 'package:flutter/material.dart';

import 'package:orb/connection.dart';
import 'package:orb/design.dart';
import 'package:orb/event.dart';
import 'package:orb/event_stream.dart';
import 'package:orb/ui/card/util/error.dart';
import 'package:orb/ui/card/util/label.dart';
import 'package:orb/ui/card/widget_mode.dart';
import 'package:orb/ui/icon.dart';
import 'package:orb/ui/presence/user_avatar.dart';

class OrbTextInput extends StatefulWidget {
  final OrbEvent event;
  final OrbEventStream eventStream;
  final OrbConnection connection;
  final OrbUserAvatar? userAvatar;
  final OrbWidgetMode mode;
  final TextEditingController? controller;
  final bool? disabled;

  const OrbTextInput({
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
    return fieldId == null || fieldEvents[fieldId] == event;
  }

  static TextEditingController createController(
    String? inputData,
    OrbEvent event,
  ) {
    return TextEditingController(text: inputData ?? event.data['default']);
  }

  @override
  _OrbTextInputState createState() => _OrbTextInputState();
}

class _OrbTextInputState extends State<OrbTextInput> {
  late TextEditingController controller;
  late FocusNode focusNode;
  late FocusAttachment nodeAttachment;
  late bool disabledOverride;
  late bool focus;
  late Map<String?, bool> processedEvents;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ??
        OrbTextInput.createController(
          widget.event.data['input_data'],
          widget.event,
        );
    focusNode = FocusNode(debugLabel: 'OrbTextInput');
    focusNode.addListener(_handleFocusChange);
    nodeAttachment = focusNode.attach(context, onKey: _handleKeyPress);
    disabledOverride = false;
    focus = false;
    processedEvents = {};
  }

  bool get ok {
    return widget.event.data['ok'] == true;
  }

  bool get disabled {
    return disabledOverride ||
        (widget.disabled ??
            (ok || !widget.eventStream.isActiveEvent(widget.event)));
  }

  bool get invalid {
    return !disabled && widget.event.data['error'] != null;
  }

  @override
  void dispose() {
    if (controller != widget.controller) {
      controller.dispose();
    }
    focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (focusNode.hasFocus != focus) {
      setState(() {
        focus = focusNode.hasFocus;
      });
    }
  }

  KeyEventResult _handleKeyPress(FocusNode node, RawKeyEvent event) {
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.mode == OrbWidgetMode.standalone)
          OrbUserAvatar.avatarOrPlaceholder(
            context,
            avatar: widget.userAvatar,
          ),
        Flexible(
          child: buildField(context),
        ),
      ],
    );
  }

  Widget buildField(BuildContext context) {
    nodeAttachment.reparent();
    process();

    return GestureDetector(
      onTap: () => focusNode.requestFocus(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.event.data['label'] != null)
            OrbLabel(
              label: widget.event.data['label'],
              required: widget.event.data['required'],
              disabled: disabled,
              focus: focus,
              invalid: invalid,
            ),
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: OrbTheme.of(context).lengths.tiny,
            ),
            decoration: BoxDecoration(
              boxShadow: [OrbTheme.of(context).outerShadow.tiny],
              border: border(context),
              color: OrbTheme.of(context).palette.blank,
              borderRadius: BorderRadius.all(
                OrbTheme.of(context).borderRadius.small,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildIcon(context),
                buildText(context),
                buildSubmit(context),
              ],
            ),
          ),
          if (invalid) OrbError(error: widget.event.data['error'])
        ],
      ),
    );
  }

  Widget buildIcon(BuildContext context) {
    final color = disabled
        ? OrbTheme.of(context).palette.disabled
        : OrbTheme.of(context).palette.normal;
    final iconSpec = OrbIconSpec.fromMap(widget.event.data['icon']);
    if (iconSpec == null) {
      return const SizedBox.shrink();
    } else {
      return Container(
        padding: EdgeInsets.only(
          left: OrbTheme.of(context).lengths.medium,
        ),
        child: OrbIcon(
          iconSpec,
          size: OrbTheme.of(context).size.icon.medium,
          color: color,
        ),
      );
    }
  }

  Widget buildText(BuildContext context) {
    const double minWidth = 240;
    final OrbTheme orbTheme = OrbTheme.of(context);
    final TextInputType keyboardType;
    switch (widget.event.data['type']) {
      case 'email':
        keyboardType = TextInputType.emailAddress;
        break;
      default:
        keyboardType = TextInputType.text;
    }
    return Flexible(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: minWidth),
        child: Container(
          margin: EdgeInsets.symmetric(
            vertical: orbTheme.lengths.mediumSmall,
            horizontal: orbTheme.lengths.tiny,
          ),
          padding: EdgeInsets.symmetric(horizontal: orbTheme.lengths.medium),
          child: TextField(
            controller: controller,
            textInputAction: widget.mode == OrbWidgetMode.standalone
                ? TextInputAction.go
                : null,
            onSubmitted: widget.mode == OrbWidgetMode.standalone
                ? (_value) => submit()
                : null,
            keyboardType: keyboardType,
            focusNode: disabled ? null : focusNode,
            readOnly: disabled,
            autofocus: false,
            cursorColor: orbTheme.palette.brand,
            style: orbTheme.text.font.normal
                .merge(orbTheme.text.style.normal)
                .merge(orbTheme.text.size.medium)
                .copyWith(
                  color: disabled
                      ? orbTheme.palette.disabledDark
                      : orbTheme.palette.normal,
                ),
            decoration: InputDecoration.collapsed(
              hintText: disabled ? null : widget.event.data['placeholder'],
              hintStyle: TextStyle(color: OrbTheme.of(context).palette.support),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSubmit(BuildContext context) {
    if (widget.mode != OrbWidgetMode.standalone) {
      return const SizedBox.shrink();
    } else if (!ok) {
      return disabled
          ? buildSubmitButton(context)
          : InkWell(
              onTap: () {
                focusNode.unfocus();
                submit();
              },
              child: buildSubmitButton(context),
            );
    } else {
      return Container(
        margin: EdgeInsets.only(right: OrbTheme.of(context).lengths.tiny),
        padding: EdgeInsets.all(OrbTheme.of(context).lengths.mediumSmall),
        child: OrbIcon(
          OrbIcons.check,
          size: OrbTheme.of(context).size.icon.medium,
          color: OrbTheme.of(context).palette.disabledDark,
        ),
        decoration: BoxDecoration(
          color: OrbTheme.of(context).palette.blank,
          borderRadius: BorderRadius.only(
            // TODO: Find a better way to adjust the in border radius to the outer
            topRight: OrbTheme.of(context).borderRadius.small -
                const Radius.circular(2.1),
            bottomRight: OrbTheme.of(context).borderRadius.small -
                const Radius.circular(2.1),
          ),
        ),
      );
    }
  }

  Widget buildSubmitButton(BuildContext context) {
    final Color color;
    final Color borderColor;
    if (disabled) {
      color = borderColor = OrbTheme.of(context).palette.disabled;
    } else if (widget.event.data['error'] != null && !focus) {
      color = borderColor = OrbTheme.of(context).palette.error;
    } else {
      color = borderColor = OrbTheme.of(context).palette.brand;
    }
    return Container(
      padding: EdgeInsets.all(OrbTheme.of(context).lengths.small + 2),
      child: OrbIcon(
        OrbIcons.right,
        size: OrbTheme.of(context).size.icon.medium,
        color: OrbTheme.of(context).palette.blank,
      ),
      decoration: BoxDecoration(
        color: color,
        border: OrbTheme.of(context).innerBorder.thick(borderColor),
        borderRadius: BorderRadius.only(
          // TODO: Find a better way to adjust the inner border radius to the outer
          topRight: OrbTheme.of(context).borderRadius.small -
              const Radius.circular(2.1),
          bottomRight: OrbTheme.of(context).borderRadius.small -
              const Radius.circular(2.1),
        ),
      ),
    );
  }

  Border border(BuildContext context) {
    final Color color;
    if (disabled) {
      color = OrbTheme.of(context).palette.disabled;
    } else if (widget.event.data['error'] != null) {
      color = OrbTheme.of(context).palette.error;
    } else if (focus) {
      color = OrbTheme.of(context).palette.brand;
    } else {
      color = OrbTheme.of(context).palette.brandNeutral;
    }
    if (ok) {
      return OrbTheme.of(context).innerBorder.thin(color);
    } else {
      return OrbTheme.of(context).innerBorder.thick(color);
    }
  }

  void process() {
    if (!widget.eventStream.isActiveEvent(widget.event)) {
      // Event not relevant
      return;
    } else if (processedEvents[widget.event.id] == true) {
      // Event already processed
      return;
    } else if (((widget.event.data['composer'] as Map<dynamic, dynamic>?) ??
            {})['focus'] ==
        'blur') {
      focusNode.requestFocus();
    }
    disabledOverride = false;
    processedEvents[widget.event.id] = true;
  }

  void submit() {
    widget.connection.publishEvent(
      OrbEvent.createFieldButtonClickEvent(
        widget.event.data['field_id'],
        widget.event.data['submit_button_id'],
        controller.text,
        text: 'Submit',
      ),
    );
    setState(() {
      disabledOverride = true;
    });
  }
}
