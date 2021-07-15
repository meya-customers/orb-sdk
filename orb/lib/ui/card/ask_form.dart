import 'package:flutter/material.dart';

import 'package:orb/connection.dart';
import 'package:orb/event.dart';
import 'package:orb/ui/design.dart';
import 'package:orb/ui/icon.dart';
import 'package:orb/ui/presence/user_avatar.dart';

class OrbAskForm extends StatelessWidget {
  final OrbEvent event;
  final OrbConnection connection;
  final OrbUserAvatar userAvatar;

  OrbAskForm({
    @required this.event,
    @required this.connection,
    @required this.userAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: OrbUserAvatar.defaultMargin(context),
          child: (userAvatar ?? OrbUserAvatar.placeholder(context)),
        ),
        Flexible(
          child: Column(
            children: buildFields(context, event.data['fields']),
          ),
        ),
      ],
    );
  }

  List buildFields(BuildContext context, List<dynamic> fields) {
    return fields.map((field) {
      switch (field['type']) {
        default:
          return OrbInputField(
            event: event,
            connection: connection,
            field: field,
          );
      }
    }).toList();
  }
}

class OrbInputField extends StatefulWidget {
  final OrbEvent event;
  final OrbConnection connection;
  final Map<dynamic, dynamic> field;

  OrbInputField(
      {@required this.event, @required this.connection, @required this.field});

  @override
  _OrbInputFieldState createState() => _OrbInputFieldState();
}

class _OrbInputFieldState extends State<OrbInputField> {
  final TextEditingController textEditingController = TextEditingController();

  FocusNode focusNode;
  FocusAttachment nodeAttachment;
  bool focus = false;
  bool invalid = false;
  Map<String, bool> processedEvents = {};
  String inputText = '';
  String errorText = '';

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode(debugLabel: 'OrbInputField');
    focusNode.addListener(_handleFocusChange);
    nodeAttachment = focusNode.attach(context, onKey: _handleKeyPress);
  }

  @override
  void dispose() {
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
    nodeAttachment.reparent();
    final eventStream = widget.connection.getEventStream();
    final form = eventStream.forms[widget.event.data['form_id']];
    final ok = form?.okEvent != null;
    final disabled = !(eventStream.isActiveEvent(widget.event) ||
        (form.errorEvent != null &&
            eventStream.isActiveEvent(form.errorEvent)));
    final isActiveError =
        (form.errorEvent != null && eventStream.isActiveEvent(form.errorEvent));
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
            top: OrbTheme.of(context).lengths.small,
            left: OrbTheme.of(context).lengths.small,
            bottom: OrbTheme.of(context).lengths.tiny,
          ),
          child: Text(
            (widget.field['label'] as String).toUpperCase(),
            style: labelStyle(context, disabled, ok),
          ),
        ),
        Container(
          margin: EdgeInsets.only(
            left: OrbTheme.of(context).lengths.tiny,
          ),
          decoration: BoxDecoration(
            boxShadow: [OrbTheme.of(context).outerShadow.tiny],
            border: border(context, disabled, ok),
            color: OrbTheme.of(context).palette.blank,
            borderRadius:
                BorderRadius.all(OrbTheme.of(context).borderRadius.small),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildIcon(context, disabled, ok),
              buildText(context, disabled),
              buildSubmit(context, disabled, ok),
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
            : SizedBox.shrink()
      ],
    );
  }

  Widget buildIcon(BuildContext context, bool disabled, bool ok) {
    final color = disabled && !ok
        ? OrbTheme.of(context).palette.disabledDark
        : OrbTheme.of(context).palette.normal;
    OrbIcon icon;
    if (widget.field.containsKey('icon')) {
      icon = OrbIcon(
        OrbIconSpec(
          url: widget.field['icon']['url'],
          color: widget.field['icon']['color'],
        ),
        color: color,
      );
    } else {
      if (widget.field['type'] == 'email') {
        icon = OrbIcon(OrbIcons.emailAddress);
      } else if (widget.field['type'] == 'tel') {
        icon = OrbIcon(OrbIcons.phone);
      } else if ((widget.field['autocomplete'] as String).indexOf('country') !=
          -1) {
        icon = OrbIcon(OrbIcons.flag);
      } else if ((widget.field['autocomplete'] as String).indexOf('name') !=
          -1) {
        icon = OrbIcon(OrbIcons.user);
      } else {
        icon = OrbIcon(OrbIcons.pencil);
      }
    }
    return Container(
      padding: EdgeInsets.only(
        left: OrbTheme.of(context).lengths.mediumSmall,
      ),
      child: icon,
    );
  }

  Widget buildText(BuildContext context, bool disabled) {
    double minWidth = 240;
    if (!disabled) {
      return Flexible(
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: minWidth),
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
                      TextStyle(color: OrbTheme.of(context).palette.support)),
            ),
          ),
        ),
      );
    } else {
      return Flexible(
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: minWidth),
          child: Container(
            padding: EdgeInsets.all(OrbTheme.of(context).lengths.small),
            child: Text(
              inputText,
              style: OrbTheme.of(context).text.size.medium,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
          ),
        ),
      );
    }
  }

  Widget buildSubmit(BuildContext context, bool disabled, bool ok) {
    if (!ok) {
      if (disabled) {
        return buildSubmitButton(context, disabled);
      } else {
        return InkWell(
            onTap: submitForm, child: buildSubmitButton(context, disabled));
      }
    } else {
      return Container(
        padding: EdgeInsets.all(OrbTheme.of(context).lengths.mediumSmall),
        child: OrbIcon(
          OrbIcons.check,
          color: OrbTheme.of(context).palette.disabledDark,
        ),
        decoration: BoxDecoration(
          color: OrbTheme.of(context).palette.blank,
          borderRadius: BorderRadius.only(
            // TODO: Find a better way to adjust the in border radius to the outer
            topRight:
                OrbTheme.of(context).borderRadius.small - Radius.circular(2.1),
            bottomRight:
                OrbTheme.of(context).borderRadius.small - Radius.circular(2.1),
          ),
        ),
      );
    }
  }

  Widget buildSubmitButton(BuildContext context, bool disabled) {
    Color color;
    Color borderColor;
    if (disabled) {
      color = borderColor = OrbTheme.of(context).palette.neutral;
    } else if (invalid && !focus) {
      color = borderColor = OrbTheme.of(context).palette.error;
    } else {
      color = borderColor = OrbTheme.of(context).palette.brand;
    }
    return Container(
      padding: EdgeInsets.all(OrbTheme.of(context).lengths.small),
      child: OrbIcon(
        OrbIcons.right,
        color: OrbTheme.of(context).palette.blank,
      ),
      decoration: BoxDecoration(
        color: color,
        border: OrbTheme.of(context).innerBorder.thick(borderColor),
        borderRadius: BorderRadius.only(
          // TODO: Find a better way to adjust the inner border radius to the outer
          topRight:
              OrbTheme.of(context).borderRadius.small - Radius.circular(2.1),
          bottomRight:
              OrbTheme.of(context).borderRadius.small - Radius.circular(2.1),
        ),
      ),
    );
  }

  TextStyle labelStyle(BuildContext context, bool disabled, bool ok) {
    Color color;
    if (disabled && !ok) {
      color = OrbTheme.of(context).palette.disabledDark;
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

  Border border(BuildContext context, bool disabled, bool ok) {
    Color color;
    if (focus) {
      color = OrbTheme.of(context).palette.brand;
    } else if (invalid) {
      color = OrbTheme.of(context).palette.error;
    } else {
      color = OrbTheme.of(context).palette.neutral;
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
    if (!widget.connection.getEventStream().isActiveEvent(widget.event)) {
      // Event not relevant
      return;
    } else if (processedEvents[widget.event.id] == true) {
      // Event already processed
      return;
    } else if ((widget.event.data['composer'] ?? {})['focus'] != 'blur') {
      // Not blurring composer focus, so don't take it
      return;
    }
    setState(() {
      focusNode.requestFocus();
      processedEvents[widget.event.id] = true;
    });
  }

  void processSubmit() {
    final form =
        widget.connection.getEventStream().forms[widget.event.data['form_id']];
    if (form.submitEvent == null) {
      // No event
      return;
    } else if (processedEvents[form.submitEvent.id] == true) {
      // Event already processed
      return;
    }
    setState(() {
      final Map<dynamic, dynamic> submitFields =
          form.submitEvent.data['fields'];
      for (final field in submitFields.entries) {
        final submitText = field.value;
        inputText = submitText;
      }
      textEditingController.text = inputText;
      processedEvents[form.submitEvent.id] = true;
    });
  }

  void processError() {
    final eventStream = widget.connection.getEventStream();
    final form = eventStream.forms[widget.event.data['form_id']];
    if (form.errorEvent == null) {
      // No event
      return;
    } else if (!eventStream.isActiveEvent(form.errorEvent)) {
      // Event not relevant
      return;
    } else if (processedEvents[form.errorEvent.id] == true) {
      // Event already processed
      return;
    }
    setState(() {
      final Map<dynamic, dynamic> errorFields = form.errorEvent.data['fields'];
      for (final field in errorFields.entries) {
        errorText = field.value;
      }
      processedEvents[form.errorEvent.id] = true;
    });
  }

  void submitForm() {
    final field = widget.event.data['fields'][0];
    widget.connection.publishEvent(OrbEvent.createFormSubmitEvent(
      widget.event.data['form_id'],
      {field['name']: textEditingController.text},
    ));
  }
}
