import 'package:flutter/material.dart';

import 'package:orb/connection.dart';
import 'package:orb/design.dart';
import 'package:orb/event.dart';
import 'package:orb/event_stream.dart';
import 'package:orb/ui/icon.dart';
import 'package:orb/ui/presence/user_avatar.dart';

class OrbAskForm extends StatelessWidget {
  final OrbEvent event;
  final OrbEventStream eventStream;
  final OrbConnection connection;
  final OrbUserAvatar? userAvatar;

  const OrbAskForm({
    required this.event,
    required this.eventStream,
    required this.connection,
    required this.userAvatar,
    Key? key,
  }) : super(key: key);

  static bool isVisible(OrbEvent event) {
    return (event.data['fields'] as List<dynamic>).isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        OrbUserAvatar.avatarOrPlaceholder(
          context,
          avatar: userAvatar,
        ),
        Flexible(
          child: Column(
            children: buildFields(context, event.data['fields']),
          ),
        ),
      ],
    );
  }

  List<Widget> buildFields(BuildContext context, List<dynamic> fields) {
    return fields.cast<Map<dynamic, dynamic>>().map((field) {
      switch (field['type']) {
        default:
          return _OrbInputField(
            event: event,
            eventStream: eventStream,
            connection: connection,
            field: field,
          );
      }
    }).toList();
  }
}

class _OrbInputField extends StatefulWidget {
  final OrbEvent event;
  final OrbEventStream eventStream;
  final OrbConnection connection;
  final Map<dynamic, dynamic> field;

  const _OrbInputField({
    required this.event,
    required this.eventStream,
    required this.connection,
    required this.field,
    Key? key,
  }) : super(key: key);

  @override
  _OrbInputFieldState createState() => _OrbInputFieldState();
}

class _OrbInputFieldState extends State<_OrbInputField> {
  final TextEditingController textEditingController = TextEditingController();

  FocusNode? focusNode;
  late FocusAttachment nodeAttachment;
  late bool disabled;
  bool focus = false;
  bool invalid = false;
  Map<String?, bool> processedEvents = {};
  String inputText = '';
  String errorText = '';

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode(debugLabel: 'OrbInputField');
    focusNode!.addListener(_handleFocusChange);
    nodeAttachment = focusNode!.attach(context, onKey: _handleKeyPress);
    disabled = isDisabled;
  }

  @override
  void dispose() {
    focusNode!.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (focusNode!.hasFocus != focus) {
      setState(() {
        focus = focusNode!.hasFocus;
      });
    }
  }

  KeyEventResult _handleKeyPress(FocusNode node, RawKeyEvent event) {
    return KeyEventResult.ignored;
  }

  bool get isActiveError {
    final form = widget.eventStream.forms[widget.event.data['form_id']]!;
    return form.errorEvent != null &&
        widget.eventStream.isActiveEvent(form.errorEvent!);
  }

  bool get isDisabled {
    return !(widget.eventStream.isActiveEvent(widget.event) || isActiveError);
  }

  @override
  Widget build(BuildContext context) {
    nodeAttachment.reparent();
    final form = widget.eventStream.forms[widget.event.data['form_id']];
    final ok = form?.okEvent != null;
    if (isActiveError && !invalid) {
      setState(() {
        invalid = true;
      });
    }
    process();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(
            left: OrbTheme.of(context).lengths.small,
            bottom: OrbTheme.of(context).lengths.tiny,
          ),
          child: Text(
            (widget.field['label'] as String).toUpperCase(),
            style: labelStyle(context, disabled: disabled),
          ),
        ),
        Container(
          margin: EdgeInsets.only(
            left: OrbTheme.of(context).lengths.tiny,
          ),
          decoration: BoxDecoration(
            boxShadow: [OrbTheme.of(context).outerShadow.tiny],
            border: border(context, disabled: disabled, ok: ok),
            color: OrbTheme.of(context).palette.blank,
            borderRadius:
                BorderRadius.all(OrbTheme.of(context).borderRadius.small),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildIcon(context, disabled: disabled),
              buildText(context, disabled: disabled),
              buildSubmit(context, disabled: disabled, ok: ok),
            ],
          ),
        ),
        invalid
            ? Container(
                margin: EdgeInsets.only(
                  top: OrbTheme.of(context).lengths.small,
                  left: OrbTheme.of(context).lengths.small,
                ),
                child: Text(
                  errorText,
                  style: OrbTheme.of(context)
                      .text
                      .style
                      .normal
                      .copyWith(color: OrbTheme.of(context).palette.error),
                ),
              )
            : const SizedBox.shrink()
      ],
    );
  }

  Widget buildIcon(
    BuildContext context, {
    required bool disabled,
  }) {
    final color = disabled
        ? OrbTheme.of(context).palette.disabled
        : OrbTheme.of(context).palette.normal;
    var iconSpec = OrbIconSpec.fromMap(widget.field['icon']);
    if (iconSpec == null) {
      if (widget.field['type'] == 'email') {
        iconSpec = OrbIcons.emailAddress;
      } else if (widget.field['type'] == 'tel') {
        iconSpec = OrbIcons.phone;
      } else if ((widget.field['autocomplete'] as String).contains('country')) {
        iconSpec = OrbIcons.flag;
      } else if ((widget.field['autocomplete'] as String).contains('name')) {
        iconSpec = OrbIcons.user;
      } else {
        iconSpec = OrbIcons.pencil;
      }
    }
    return Container(
      padding: EdgeInsets.only(
        left: OrbTheme.of(context).lengths.mediumSmall,
      ),
      child: OrbIcon(
        iconSpec,
        size: OrbTheme.of(context).size.icon.medium,
        color: color,
      ),
    );
  }

  Widget buildText(BuildContext context, {required bool disabled}) {
    const double minWidth = 240;
    if (!disabled) {
      return Flexible(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: minWidth),
          child: Container(
            padding: EdgeInsets.all(OrbTheme.of(context).lengths.small),
            child: TextField(
              controller: textEditingController,
              focusNode: focusNode,
              autofocus: false,
              cursorColor: OrbTheme.of(context).palette.brand,
              decoration: InputDecoration.collapsed(
                hintText: widget.field['placeholder'],
                hintStyle:
                    TextStyle(color: OrbTheme.of(context).palette.support),
              ),
            ),
          ),
        ),
      );
    } else {
      return Flexible(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: minWidth),
          child: Container(
            padding: EdgeInsets.all(OrbTheme.of(context).lengths.small),
            child: Text(
              inputText,
              style: OrbTheme.of(context)
                  .text
                  .size
                  .medium
                  .copyWith(color: OrbTheme.of(context).palette.disabledDark),
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
          ),
        ),
      );
    }
  }

  Widget buildSubmit(
    BuildContext context, {
    required bool disabled,
    required bool ok,
  }) {
    if (!ok) {
      return disabled
          ? buildSubmitButton(context, disabled: disabled)
          : InkWell(
              onTap: submitForm,
              child: buildSubmitButton(context, disabled: disabled),
            );
    } else {
      return Container(
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

  Widget buildSubmitButton(BuildContext context, {required bool disabled}) {
    final Color color;
    final Color borderColor;
    if (disabled) {
      color = borderColor = OrbTheme.of(context).palette.disabled;
    } else if (invalid && !focus) {
      color = borderColor = OrbTheme.of(context).palette.error;
    } else {
      color = borderColor = OrbTheme.of(context).palette.brand;
    }
    return Container(
      padding: EdgeInsets.all(OrbTheme.of(context).lengths.small),
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

  TextStyle labelStyle(BuildContext context, {required bool disabled}) {
    Color color;
    if (disabled) {
      color = OrbTheme.of(context).palette.disabled;
    } else if (!invalid && !focus) {
      color = OrbTheme.of(context).palette.normal;
    } else if (invalid && !focus) {
      color = OrbTheme.of(context).palette.error;
    } else {
      color = OrbTheme.of(context).palette.normal;
    }
    return OrbTheme.of(context)
        .text
        .style
        .normal
        .merge(OrbTheme.of(context).text.style.bold)
        .merge(OrbTheme.of(context).text.size.tiny)
        .copyWith(color: color);
  }

  Border border(
    BuildContext context, {
    required bool disabled,
    required bool ok,
  }) {
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
    processAsk();
    processSubmit();
    processError();
  }

  void processAsk() {
    if (!widget.eventStream.isActiveEvent(widget.event)) {
      // Event not relevant
      return;
    } else if (processedEvents[widget.event.id] == true) {
      // Event already processed
      return;
    } else if ((widget.event.data['composer'] as Map<dynamic, dynamic>? ??
            {})['focus'] !=
        'blur') {
      // Not blurring composer focus, so don't take it
      return;
    }
    setState(() {
      focusNode!.requestFocus();
      processedEvents[widget.event.id] = true;
    });
  }

  void processSubmit() {
    final form = widget.eventStream.forms[widget.event.data['form_id']]!;
    if (form.submitEvent == null) {
      // No event
      return;
    } else if (processedEvents[form.submitEvent!.id] == true) {
      // Event already processed
      return;
    }
    setState(() {
      final Map<dynamic, dynamic> submitFields =
          form.submitEvent!.data['fields'];
      for (final field in submitFields.entries) {
        final submitText = field.value;
        inputText = submitText;
      }
      textEditingController.text = inputText;
      processedEvents[form.submitEvent!.id] = true;
    });
  }

  void processError() {
    final form = widget.eventStream.forms[widget.event.data['form_id']]!;
    if (form.errorEvent == null) {
      // No event
      return;
    } else if (!widget.eventStream.isActiveEvent(form.errorEvent!)) {
      // Event not relevant
      return;
    } else if (processedEvents[form.errorEvent!.id] == true) {
      // Event already processed
      return;
    }
    setState(() {
      final Map<dynamic, dynamic> errorFields = form.errorEvent!.data['fields'];
      for (final field in errorFields.entries) {
        errorText = field.value;
      }
      processedEvents[form.errorEvent!.id] = true;
    });
  }

  void submitForm() {
    final Map<dynamic, dynamic> field =
        (widget.event.data['fields'] as List<dynamic>)[0];
    widget.connection.publishEvent(
      OrbEvent.createFormSubmitEvent(
        widget.event.data['form_id'],
        {field['name']: textEditingController.text},
      ),
    );
    setState(() {
      inputText = textEditingController.text;
      disabled = true;
    });
  }
}
