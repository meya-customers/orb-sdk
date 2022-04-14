import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import 'package:orb/config.dart';
import 'package:orb/connection.dart';
import 'package:orb/design.dart';
import 'package:orb/event.dart';
import 'package:orb/event_stream.dart';
import 'package:orb/ui/icon.dart';

enum _OrbComposerMode { text, extra, image }

class OrbComposer extends StatefulWidget {
  final OrbEventStream eventStream;
  final OrbConnection connection;

  const OrbComposer({
    required this.eventStream,
    required this.connection,
    Key? key,
  }) : super(key: key);

  @override
  _OrbComposerState createState() => _OrbComposerState();
}

class _OrbComposerState extends State<OrbComposer> {
  OrbComposerVisibility? visibility = OrbComposerVisibility.show;
  _OrbComposerMode mode = _OrbComposerMode.text;
  TextEditingController textEditingController = TextEditingController();
  Map<String?, bool> processedEvents = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currentEvent = widget.eventStream.events.firstWhere(
      (event) =>
          event.data['composer'] != null &&
          !widget.eventStream.isSelfEvent(event),
      orElse: () => OrbEvent(id: '-', type: 'empty', data: {}),
    );
    final current =
        OrbComposerEventSpec.fromMap(currentEvent.data['composer']) ??
            const OrbComposerEventSpec();
    final collapse = textEditingController.value.text.isEmpty &&
        (current.visibility ?? OrbConfig.of(context).composer.visibility) ==
            OrbComposerVisibility.collapse;
    final hide =
        (current.visibility ?? OrbConfig.of(context).composer.visibility) ==
            OrbComposerVisibility.hide;

    process(currentEvent, current, OrbConfig.of(context));

    if (visibility == OrbComposerVisibility.collapse && collapse) {
      return _OrbCollapseMode(
        toggleMode: toggleMode,
        current: current,
      );
    } else if (visibility == OrbComposerVisibility.hide && hide) {
      return const SizedBox.shrink();
    }

    switch (mode) {
      case _OrbComposerMode.extra:
        return _OrbExtraMode(
          eventStream: widget.eventStream,
          connection: widget.connection,
          toggleMode: toggleMode,
        );
      case _OrbComposerMode.image:
        return _OrbImageMode(
          eventStream: widget.eventStream,
          connection: widget.connection,
          toggleMode: toggleMode,
        );
      default:
        return _OrbTextMode(
          eventStream: widget.eventStream,
          connection: widget.connection,
          toggleMode: toggleMode,
          textEditingController: textEditingController,
          current: current,
        );
    }
  }

  void process(
    OrbEvent currentEvent,
    OrbComposerEventSpec current,
    OrbConfig config,
  ) {
    if (processedEvents.containsKey(currentEvent.id) ||
        currentEvent.id == '-') {
      return;
    }

    final mediaUpload = OrbMediaUploadConfigResult.resolve(config.mediaUpload);
    if ((current.focus ?? config.composer.focus) == OrbComposerFocus.text) {
      mode = _OrbComposerMode.text;
    } else if ((current.focus ?? config.composer.focus) ==
            OrbComposerFocus.file &&
        mediaUpload.file) {
      mode = _OrbComposerMode.extra;
    } else if ((current.focus ?? config.composer.focus) ==
            OrbComposerFocus.image &&
        mediaUpload.image) {
      mode = _OrbComposerMode.image;
    } else {
      mode = _OrbComposerMode.text;
    }
    visibility = current.visibility ?? config.composer.visibility;
    processedEvents[currentEvent.id] = true;
  }

  void toggleMode(_OrbComposerMode mode) => setState(() {
        this.mode = mode;
        visibility = OrbComposerVisibility.show;
      });
}

class _OrbTextMode extends StatefulWidget {
  final OrbEventStream eventStream;
  final OrbConnection connection;
  final void Function(_OrbComposerMode mode) toggleMode;
  final TextEditingController textEditingController;
  final OrbComposerEventSpec current;

  const _OrbTextMode({
    required this.eventStream,
    required this.connection,
    required this.toggleMode,
    required this.textEditingController,
    required this.current,
    Key? key,
  }) : super(key: key);

  @override
  _OrbTextModeState createState() => _OrbTextModeState();
}

class _OrbTextModeState extends State<_OrbTextMode> {
  FocusNode composerFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          _OrbComposerIconButton(
            icon: OrbIcon(
              OrbIcons.extraInput,
              size: OrbTheme.of(context).size.icon.medium,
            ),
            onPressed: OrbMediaUploadConfigResult.resolve(
              OrbConfig.of(context).mediaUpload,
            ).any
                ? () => widget.toggleMode(_OrbComposerMode.extra)
                : null,
          ),

          // Edit text
          Flexible(
            child: Container(
              margin: const EdgeInsets.only(bottom: 14, top: 13),
              padding: const EdgeInsets.only(right: 10.0),
              child: TextField(
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 8,
                style: TextStyle(
                  color: OrbTheme.of(context).palette.normal,
                  fontSize: 18,
                ),
                controller: widget.textEditingController,
                focusNode: composerFocusNode,
                onSubmitted: (text) {
                  widget.connection.publishEvent(
                    OrbEvent.createSayEvent(
                      widget.textEditingController.text,
                    ),
                  );
                  widget.textEditingController.clear();
                  composerFocusNode.requestFocus();
                },
                decoration: InputDecoration.collapsed(
                  hintText: widget.current.placeholder ??
                      OrbConfig.of(context).composer.placeholder ??
                      OrbConfig.of(context).composer.placeholderText,
                  hintStyle: OrbTheme.of(context)
                      .text
                      .style
                      .normal
                      .merge(OrbTheme.of(context).text.size.medium)
                      .copyWith(color: OrbTheme.of(context).palette.support),
                ),
              ),
            ),
          ),

          // Button send message
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _OrbSendTextButton(
              eventStream: widget.eventStream,
              connection: widget.connection,
              textEditingController: widget.textEditingController,
              composerFocusNode: composerFocusNode,
            ),
          ),
        ],
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: OrbTheme.of(context).palette.brandNeutral,
            width: 1,
          ),
        ),
        color: Colors.white,
      ),
    );
  }
}

class _OrbExtraMode extends StatelessWidget {
  final OrbEventStream eventStream;
  final OrbConnection connection;
  final void Function(_OrbComposerMode mode) toggleMode;

  const _OrbExtraMode({
    required this.eventStream,
    required this.connection,
    required this.toggleMode,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaUpload =
        OrbMediaUploadConfigResult.resolve(OrbConfig.of(context).mediaUpload);
    return Container(
      child: Row(
        children: <Widget>[
          _OrbComposerIconButton(
            icon: OrbIcon(
              OrbIcons.left,
              size: OrbTheme.of(context).size.icon.medium,
            ),
            onPressed: () => toggleMode(_OrbComposerMode.text),
          ),
          _OrbComposerButton(
            icon: OrbIcon(
              OrbIcons.sendFile,
              size: OrbTheme.of(context).size.icon.medium,
            ),
            text: OrbConfig.of(context).composer.fileButtonText,
            onTap: mediaUpload.file ? () => getFile(context) : null,
          ),
          _OrbComposerButton(
            icon: OrbIcon(
              OrbIcons.sendImage,
              size: OrbTheme.of(context).size.icon.medium,
            ),
            text: OrbConfig.of(context).composer.imageButtonText,
            onTap: mediaUpload.image
                ? () => toggleMode(_OrbComposerMode.image)
                : null,
          ),
        ],
      ),
      height: 50.0,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: OrbTheme.of(context).palette.brandNeutral,
            width: 1,
          ),
        ),
        color: Colors.white,
      ),
    );
  }

  Future getFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final path = result.files.single.path!;
      final filename = p.basename(path);
      final accepted = await showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.zero,
            children: [
              Container(
                padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: OrbIcon(
                        OrbIcons.sendFile,
                        size: OrbTheme.of(context).size.icon.medium,
                      ),
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: OrbTheme.of(context)
                              .text
                              .style
                              .normal
                              .merge(
                                OrbTheme.of(context).text.size.medium,
                              )
                              .copyWith(
                                color: OrbTheme.of(context).palette.normal,
                              ),
                          children: <TextSpan>[
                            TextSpan(
                              text: OrbConfig.of(context).composer.fileSendText,
                            ),
                            const TextSpan(text: ' '),
                            TextSpan(
                              text: filename,
                              style: OrbTheme.of(context).text.style.bold,
                            ),
                            const TextSpan(text: ' ?'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, true),
                padding: EdgeInsets.zero,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(15),
                      child: OrbIcon(
                        OrbIcons.sendText,
                        size: OrbTheme.of(context).size.icon.medium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );

      if (accepted == true) {
        toggleMode(_OrbComposerMode.text);
        await connection.postBlobAndPublishEvent(File(path));
      }
    } else {
      log('No files selected');
    }
  }
}

class _OrbImageMode extends StatelessWidget {
  final OrbEventStream eventStream;
  final OrbConnection connection;
  final void Function(_OrbComposerMode mode) toggleMode;

  const _OrbImageMode({
    required this.eventStream,
    required this.connection,
    required this.toggleMode,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          _OrbComposerIconButton(
            icon: OrbIcon(
              OrbIcons.left,
              size: OrbTheme.of(context).size.icon.medium,
            ),
            onPressed: () => toggleMode(_OrbComposerMode.extra),
          ),
          _OrbComposerButton(
            icon: OrbIcon(
              OrbIcons.camera,
              size: OrbTheme.of(context).size.icon.medium,
            ),
            text: OrbConfig.of(context).composer.cameraButtonText,
            onTap: () => getImage(context, ImageSource.camera),
          ),
          _OrbComposerButton(
            icon: OrbIcon(
              OrbIcons.gallery,
              size: OrbTheme.of(context).size.icon.medium,
            ),
            text: OrbConfig.of(context).composer.galleryButtonText,
            onTap: () => getImage(context, ImageSource.gallery),
          ),
        ],
      ),
      height: 50.0,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: OrbTheme.of(context).palette.brandNeutral,
            width: 1,
          ),
        ),
        color: Colors.white,
      ),
    );
  }

  Future getImage(BuildContext context, ImageSource source) async {
    final pickedFile = await ImagePicker().getImage(source: source);

    if (pickedFile != null) {
      final image = File(pickedFile.path);
      final accepted = await showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.zero,
            children: [
              Image.file(image),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, true),
                padding: EdgeInsets.zero,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(15),
                      child: OrbIcon(
                        OrbIcons.sendText,
                        size: OrbTheme.of(context).size.icon.medium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );

      if (accepted == true) {
        toggleMode(_OrbComposerMode.text);
        await connection.postBlobAndPublishEvent(image);
      }
    }
  }
}

class _OrbCollapseMode extends StatelessWidget {
  final void Function(_OrbComposerMode mode) toggleMode;
  final OrbComposerEventSpec current;

  const _OrbCollapseMode({
    required this.toggleMode,
    required this.current,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              current.collapsePlaceholder ??
                  current.placeholder ??
                  OrbConfig.of(context).composer.collapsePlaceholder ??
                  OrbConfig.of(context).composer.placeholder ??
                  OrbConfig.of(context).composer.collapsePlaceholderText,
              style: OrbTheme.of(context)
                  .text
                  .style
                  .semibold
                  .copyWith(
                    color: OrbTheme.of(context).palette.brand,
                  )
                  .merge(OrbTheme.of(context).text.size.medium),
            ),
            Container(
              margin: const EdgeInsets.only(left: 10),
              child: OrbIcon(
                OrbIcons.expandInput,
                size: OrbTheme.of(context).size.icon.medium,
                color: OrbTheme.of(context).palette.brand,
              ),
            ),
          ],
        ),
        height: 50.0,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: OrbTheme.of(context).palette.brandNeutral,
              width: 1,
            ),
          ),
          color: Colors.white,
        ),
      ),
      onTap: () {
        log('Switch from collapse mode');
        toggleMode(_OrbComposerMode.text);
      },
    );
  }
}

class _OrbComposerIconButton extends StatelessWidget {
  final OrbIcon icon;
  final void Function()? onPressed;

  const _OrbComposerIconButton({
    required this.icon,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10.0),
      child: IconButton(
        icon: icon.copyWith(
          color:
              onPressed != null ? null : OrbTheme.of(context).palette.disabled,
        ),
        onPressed: onPressed,
      ),
    );
  }
}

class _OrbSendTextButton extends StatelessWidget {
  final OrbEventStream eventStream;
  final OrbConnection connection;
  final TextEditingController textEditingController;
  final FocusNode composerFocusNode;

  const _OrbSendTextButton({
    required this.eventStream,
    required this.connection,
    required this.textEditingController,
    required this.composerFocusNode,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: OrbIcon(
        OrbIcons.sendText,
        size: OrbTheme.of(context).size.icon.medium,
      ),
      onPressed: () {
        connection
            .publishEvent(OrbEvent.createSayEvent(textEditingController.text));
        textEditingController.clear();
        composerFocusNode.unfocus();
      },
      color: OrbTheme.of(context).palette.brand,
    );
  }
}

class _OrbComposerButton extends StatelessWidget {
  final OrbIcon icon;
  final String text;
  final void Function()? onTap;

  const _OrbComposerButton({
    required this.icon,
    required this.text,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: OrbTheme.of(context).lengths.medium),
      child: InkWell(
        child: Row(
          children: [
            Container(
              margin:
                  EdgeInsets.only(right: OrbTheme.of(context).lengths.small),
              child: icon.copyWith(
                color: onTap != null
                    ? null
                    : OrbTheme.of(context).palette.disabled,
              ),
            ),
            Text(
              text,
              style: OrbTheme.of(context).text.style.normal.copyWith(
                    color: onTap != null
                        ? null
                        : OrbTheme.of(context).palette.disabled,
                  ),
            )
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
