import 'dart:io';

import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import 'package:orb/blob.dart';
import 'package:orb/connection.dart';
import 'package:orb/event.dart';
import 'package:orb/event_stream.dart';
import 'package:orb/ui/design.dart';
import 'package:orb/ui/icon.dart';

enum Mode { text, extra, image }

class OrbComposer extends StatefulWidget {
  final OrbEventStream eventStream;
  final OrbConnection connection;

  OrbComposer({Key key, @required this.eventStream, @required this.connection})
      : super(key: key);

  @override
  _OrbComposerState createState() => _OrbComposerState(
        eventStream: eventStream,
        connection: connection,
      );
}

class _OrbComposerState extends State<OrbComposer> {
  final OrbEventStream eventStream;
  final OrbConnection connection;

  Mode mode = Mode.text;

  _OrbComposerState({@required this.eventStream, @required this.connection});

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case Mode.extra:
        return ExtraMode(
          eventStream: eventStream,
          connection: connection,
          toggleMode: toggleMode,
        );
      case Mode.image:
        return ImageMode(
          eventStream: eventStream,
          connection: connection,
          toggleMode: toggleMode,
        );
      default:
        return TextMode(
          eventStream: eventStream,
          connection: connection,
          toggleMode: toggleMode,
        );
    }
  }

  void toggleMode(Mode mode) => setState(() => (this.mode = mode));
}

class TextMode extends StatelessWidget {
  final OrbEventStream eventStream;
  final OrbConnection connection;
  final TextEditingController textEditingController = TextEditingController();
  final Function toggleMode;

  TextMode({
    Key key,
    @required this.eventStream,
    @required this.connection,
    @required this.toggleMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Row(
        children: <Widget>[
          OrbComposerIconButton(
            icon: OrbIcon(OrbIcons.extraInput),
            onPressed: () => toggleMode(Mode.extra),
          ),

          // Edit text
          Flexible(
            child: Container(
              padding: EdgeInsets.only(right: 10.0),
              child: TextField(
                style: TextStyle(
                  color: OrbTheme.of(context).palette.normal,
                  fontSize: OrbTheme.of(context).text.size.medium.fontSize,
                ),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type a message',
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
            child: connection.connected
                ? SendTextButton(
                    eventStream: eventStream,
                    connection: connection,
                    textEditingController: textEditingController,
                  )
                : CircularProgressIndicator(),
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
}

class ExtraMode extends StatelessWidget {
  final OrbEventStream eventStream;
  final OrbConnection connection;
  final Function toggleMode;

  ExtraMode({
    Key key,
    @required this.eventStream,
    @required this.connection,
    @required this.toggleMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Row(
        children: <Widget>[
          OrbComposerIconButton(
            icon: OrbIcon(OrbIcons.left),
            onPressed: () => toggleMode(Mode.text),
          ),
          OrbComposerButton(
            eventStream: eventStream,
            connection: connection,
            icon: OrbIcon(OrbIcons.sendFile),
            text: "File",
            onTap: () => getFile(context),
          ),
          OrbComposerButton(
            eventStream: eventStream,
            connection: connection,
            icon: OrbIcon(OrbIcons.sendImage),
            text: "Photo",
            onTap: () => toggleMode(Mode.image),
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
      final path = result.files.single.path;
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
                            TextSpan(text: 'Send '),
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
        toggleMode(Mode.text);
        await connection.postBlobAndPublishEvent(OrbBlob.bin(File(path)));
      }
    } else {
      print("No files selected");
    }
  }
}

class ImageMode extends StatelessWidget {
  final OrbEventStream eventStream;
  final OrbConnection connection;
  final Function toggleMode;

  ImageMode({
    Key key,
    @required this.eventStream,
    @required this.connection,
    @required this.toggleMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Row(
        children: <Widget>[
          OrbComposerIconButton(
            icon: OrbIcon(OrbIcons.left),
            onPressed: () => toggleMode(Mode.extra),
          ),
          OrbComposerButton(
            eventStream: eventStream,
            connection: connection,
            icon: OrbIcon(OrbIcons.camera),
            text: "Camera",
            onTap: () => getImage(context, ImageSource.camera),
          ),
          OrbComposerButton(
            eventStream: eventStream,
            connection: connection,
            icon: OrbIcon(OrbIcons.gallery),
            text: "Gallery",
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
        toggleMode(Mode.text);
        await connection.postBlobAndPublishEvent(OrbBlob.image(image));
      }
    }
  }
}

class OrbComposerIconButton extends StatelessWidget {
  final OrbIcon icon;
  final Function onPressed;

  OrbComposerIconButton({
    Key key,
    @required this.icon,
    @required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.0),
      child: IconButton(
        icon: icon,
        onPressed: onPressed,
      ),
    );
  }
}

class SendTextButton extends StatelessWidget {
  final OrbEventStream eventStream;
  final OrbConnection connection;
  final TextEditingController textEditingController;

  SendTextButton({
    Key key,
    @required this.eventStream,
    @required this.connection,
    @required this.textEditingController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: OrbIcon(OrbIcons.sendText),
      onPressed: () {
        connection
            .publishEvent(OrbEvent.createSayEvent(textEditingController.text));
        textEditingController.clear();
      },
      color: OrbTheme.of(context).palette.brand,
    );
  }
}

class OrbComposerButton extends StatelessWidget {
  final OrbEventStream eventStream;
  final OrbConnection connection;
  final OrbIcon icon;
  final String text;
  final Function onTap;

  OrbComposerButton({
    Key key,
    @required this.eventStream,
    @required this.connection,
    @required this.icon,
    @required this.text,
    @required this.onTap,
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
                child: icon,
              ),
              Text(text)
            ],
          ),
          onTap: onTap,
        ));
  }
}
