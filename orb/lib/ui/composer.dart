import 'dart:io';

import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

import 'package:orb/config.dart';
import 'package:orb/connection.dart';
import 'package:orb/event.dart';
import 'package:orb/event_stream.dart';
import 'package:orb/ui/design.dart';
import 'package:orb/ui/icon.dart';

enum ComposerMode { text, extra, image }

class OrbComposer extends StatefulWidget {
  final OrbEventStream eventStream;
  final OrbConnection connection;

  OrbComposer({Key? key, required this.eventStream, required this.connection})
      : super(key: key);

  @override
  _OrbComposerState createState() => _OrbComposerState();
}

class _OrbComposerState extends State<OrbComposer> {
  ComposerVisibility? visibility = ComposerVisibility.show;
  ComposerMode mode = ComposerMode.text;
  TextEditingController textEditingController = TextEditingController();
  Map<String?, bool> processedEvents = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final orbConfig = Provider.of<OrbConfig>(context);
    final currentEvent = widget.eventStream.events.firstWhere(
      (OrbEvent event) =>
          event.data['composer'] != null &&
          !widget.eventStream.isSelfEvent(event),
      orElse: () => OrbEvent(id: '-', type: 'empty', data: {}),
    );
    final composerSpec =
        ComposerEventSpec.fromMap(currentEvent.data['composer']);
    final collapse = textEditingController.value.text.isEmpty &&
        composerSpec?.visibility == ComposerVisibility.collapse;
    final hide = composerSpec?.visibility == ComposerVisibility.hide;

    process(currentEvent, composerSpec, orbConfig);

    if (visibility == ComposerVisibility.collapse && collapse) {
      return CollapseMode(
        orbConfig: orbConfig,
        toggleMode: toggleMode,
        composerSpec: composerSpec,
      );
    } else if (visibility == ComposerVisibility.hide && hide) {
      return SizedBox.shrink();
    }

    switch (mode) {
      case ComposerMode.extra:
        return ExtraMode(
          orbConfig: orbConfig,
          eventStream: widget.eventStream,
          connection: widget.connection,
          toggleMode: toggleMode,
        );
      case ComposerMode.image:
        return ImageMode(
          orbConfig: orbConfig,
          eventStream: widget.eventStream,
          connection: widget.connection,
          toggleMode: toggleMode,
        );
      default:
        return TextMode(
          orbConfig: orbConfig,
          eventStream: widget.eventStream,
          connection: widget.connection,
          toggleMode: toggleMode,
          textEditingController: textEditingController,
          composerSpec: composerSpec,
        );
    }
  }

  void process(OrbEvent currentEvent, ComposerEventSpec? composerSpec,
      OrbConfig orbConfig) {
    if (processedEvents.containsKey(currentEvent.id) ||
        currentEvent.id == '-') {
      return;
    }

    final mediaUpload = MediaUploadConfigResult.resolve(orbConfig.mediaUpload);
    if (composerSpec?.focus == ComposerFocus.text) {
      mode = ComposerMode.text;
    } else if (composerSpec?.focus == ComposerFocus.file && mediaUpload.file) {
      mode = ComposerMode.extra;
    } else if (composerSpec?.focus == ComposerFocus.image &&
        mediaUpload.image) {
      mode = ComposerMode.image;
    } else {
      mode = ComposerMode.text;
    }
    visibility = composerSpec?.visibility;
    processedEvents[currentEvent.id] = true;
  }

  void toggleMode(ComposerMode mode) => setState(() {
        this.mode = mode;
        this.visibility = ComposerVisibility.show;
      });
}

class TextMode extends StatefulWidget {
  final OrbConfig orbConfig;
  final OrbEventStream eventStream;
  final OrbConnection connection;
  final Function toggleMode;
  final TextEditingController textEditingController;
  final ComposerEventSpec? composerSpec;

  TextMode({
    Key? key,
    required this.orbConfig,
    required this.eventStream,
    required this.connection,
    required this.toggleMode,
    required this.textEditingController,
    required this.composerSpec,
  }) : super(key: key);

  @override
  _TextModeState createState() => _TextModeState();
}

class _TextModeState extends State<TextMode> {
  FocusNode composerFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          OrbComposerIconButton(
            icon: OrbIcon(OrbIcons.extraInput),
            onPressed:
                MediaUploadConfigResult.resolve(widget.orbConfig.mediaUpload)
                        .any
                    ? () => widget.toggleMode(ComposerMode.extra)
                    : null,
          ),

          // Edit text
          Flexible(
            child: Container(
              margin: EdgeInsets.only(bottom: 14, top: 13),
              padding: EdgeInsets.only(right: 10.0),
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
                  widget.connection.publishEvent(OrbEvent.createSayEvent(
                      widget.textEditingController.text));
                  widget.textEditingController.clear();
                  composerFocusNode.requestFocus();
                },
                decoration: InputDecoration.collapsed(
                  hintText: widget.composerSpec?.placeholder ??
                      widget.orbConfig.composer.placeholderText,
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
            margin: EdgeInsets.symmetric(horizontal: 8.0),
            child: widget.connection.connected
                ? SendTextButton(
                    eventStream: widget.eventStream,
                    connection: widget.connection,
                    textEditingController: widget.textEditingController,
                    composerFocusNode: composerFocusNode,
                  )
                : CircularProgressIndicator(),
          ),
        ],
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: OrbTheme.of(context).palette.brandNeutral,
            width: 0.5,
          ),
        ),
        color: Colors.white,
      ),
    );
  }
}

class ExtraMode extends StatelessWidget {
  final OrbConfig orbConfig;
  final OrbEventStream eventStream;
  final OrbConnection connection;
  final Function toggleMode;

  ExtraMode({
    Key? key,
    required this.orbConfig,
    required this.eventStream,
    required this.connection,
    required this.toggleMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaUpload = MediaUploadConfigResult.resolve(orbConfig.mediaUpload);
    return Container(
      child: Row(
        children: <Widget>[
          OrbComposerIconButton(
            icon: OrbIcon(OrbIcons.left),
            onPressed: () => toggleMode(ComposerMode.text),
          ),
          OrbComposerButton(
            icon: OrbIcon(OrbIcons.sendFile),
            text: orbConfig.composer.fileButtonText,
            onTap: mediaUpload.file ? () => getFile(context) : null,
          ),
          OrbComposerButton(
            icon: OrbIcon(OrbIcons.sendImage),
            text: orbConfig.composer.imageButtonText,
            onTap:
                mediaUpload.image ? () => toggleMode(ComposerMode.image) : null,
          ),
        ],
      ),
      height: 50.0,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: OrbTheme.of(context).palette.brandNeutral,
            width: 0.5,
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
            contentPadding: EdgeInsets.all(0.0),
            children: [
              Container(
                padding: EdgeInsets.only(top: 24, left: 24, right: 24),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: OrbIcon(OrbIcons.sendFile),
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
                              text: orbConfig.composer.fileSendText,
                            ),
                            TextSpan(
                              text: filename,
                              style: OrbTheme.of(context).text.style.bold,
                            ),
                            TextSpan(text: ' ?'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, true),
                padding: EdgeInsets.all(0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      margin: EdgeInsets.all(15),
                      child: OrbIcon(OrbIcons.sendText),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );

      if (accepted == true) {
        toggleMode(ComposerMode.text);
        await connection.postBlobAndPublishEvent(File(path));
      }
    } else {
      print("No files selected");
    }
  }
}

class ImageMode extends StatelessWidget {
  final OrbConfig orbConfig;
  final OrbEventStream eventStream;
  final OrbConnection connection;
  final Function toggleMode;

  ImageMode({
    Key? key,
    required this.orbConfig,
    required this.eventStream,
    required this.connection,
    required this.toggleMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          OrbComposerIconButton(
            icon: OrbIcon(OrbIcons.left),
            onPressed: () => toggleMode(ComposerMode.extra),
          ),
          OrbComposerButton(
            icon: OrbIcon(OrbIcons.camera),
            text: orbConfig.composer.cameraButtonText,
            onTap: () => getImage(context, ImageSource.camera),
          ),
          OrbComposerButton(
            icon: OrbIcon(OrbIcons.gallery),
            text: orbConfig.composer.galleryButtonText,
            onTap: () => getImage(context, ImageSource.gallery),
          ),
        ],
      ),
      height: 50.0,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: OrbTheme.of(context).palette.brandNeutral,
            width: 0.5,
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
            contentPadding: EdgeInsets.all(0.0),
            children: [
              Image.file(image),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, true),
                padding: EdgeInsets.all(0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      margin: EdgeInsets.all(15),
                      child: OrbIcon(OrbIcons.sendText),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );

      if (accepted == true) {
        toggleMode(ComposerMode.text);
        await connection.postBlobAndPublishEvent(image);
      }
    }
  }
}

class CollapseMode extends StatelessWidget {
  final OrbConfig orbConfig;
  final Function toggleMode;
  final ComposerEventSpec? composerSpec;

  CollapseMode({
    Key? key,
    required this.orbConfig,
    required this.toggleMode,
    required this.composerSpec,
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
              composerSpec!.placeholder ??
                  orbConfig.composer.collapsePlaceholderText!,
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
              margin: EdgeInsets.only(left: 10),
              child: OrbIcon(
                OrbIcons.expandInput,
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
              width: 0.5,
            ),
          ),
          color: Colors.white,
        ),
      ),
      onTap: () {
        print('Switch from collapse mode');
        toggleMode(ComposerMode.text);
      },
    );
  }
}

class OrbComposerIconButton extends StatelessWidget {
  final OrbIcon icon;
  final void Function()? onPressed;

  OrbComposerIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.0),
      child: IconButton(
        icon: icon.copyWith(
            color: onPressed != null
                ? null
                : OrbTheme.of(context).palette.disabled),
        onPressed: onPressed,
      ),
    );
  }
}

class SendTextButton extends StatelessWidget {
  final OrbEventStream eventStream;
  final OrbConnection connection;
  final TextEditingController textEditingController;
  final FocusNode composerFocusNode;

  SendTextButton({
    Key? key,
    required this.eventStream,
    required this.connection,
    required this.textEditingController,
    required this.composerFocusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: OrbIcon(OrbIcons.sendText),
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

class OrbComposerButton extends StatelessWidget {
  final OrbIcon icon;
  final String? text;
  final void Function()? onTap;

  OrbComposerButton({
    Key? key,
    required this.icon,
    required this.text,
    required this.onTap,
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
                        : OrbTheme.of(context).palette.disabled),
              ),
              if (text != null)
                Text(
                  text!,
                  style: OrbTheme.of(context).text.style.normal.copyWith(
                      color: onTap != null
                          ? null
                          : OrbTheme.of(context).palette.disabled),
                )
            ],
          ),
          onTap: onTap,
        ));
  }
}
