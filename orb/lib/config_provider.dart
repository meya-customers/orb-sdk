import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:orb/config.dart';
import 'package:orb/connection.dart';
import 'package:orb/event.dart';

class OrbConfigProvider extends StatefulWidget {
  final OrbConfig config;
  final OrbConnection? connection;
  final Widget child;

  const OrbConfigProvider({
    required this.config,
    required this.connection,
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  _OrbConfigProviderState createState() => _OrbConfigProviderState();
}

class _OrbConfigProviderState extends State<OrbConfigProvider> {
  late OrbConfig config;

  @override
  void initState() {
    super.initState();
    config = widget.config;
    if (widget.connection != null) {
      addConfigListener(widget.connection!);
    }
  }

  @override
  void didUpdateWidget(OrbConfigProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.config != oldWidget.config) {
      config = widget.config;
    }
    if (oldWidget.connection != null) {
      removeConfigListener(widget.connection!);
    }
    if (widget.connection != null) {
      final configData = widget.connection!.getConfigData();
      if (configData != null) {
        onConfig(configData: configData);
      }
      addConfigListener(widget.connection!);
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.connection != null) {
      removeConfigListener(widget.connection!);
    }
  }

  void addConfigListener(OrbConnection connection) {
    connection.addOrbListener('config', onConfig);
  }

  void removeConfigListener(OrbConnection connection) {
    connection.removeOrbListener('config', onConfig);
  }

  void onConfig({required Map<dynamic, dynamic> configData}) {
    var newConfig = widget.config;
    for (final entry in configData.entries) {
      newConfig = updateConfig(newConfig, entry.key, entry.value);
    }
    newConfig = newConfig.copyWith(
      ui: newConfig.ui.copyWith(visible: true),
    );
    widget.connection?.setMediaUpload(
      OrbMediaUploadConfigResult.resolve(config.mediaUpload),
    );
    setState(() {
      config = newConfig;
    });
  }

  static OrbConfig updateConfig(
    OrbConfig config,
    String key,
    Map<dynamic, dynamic> value,
  ) {
    switch (key) {
      case 'orb_theme':
        return config.copyWith(
          theme: config.theme.copyWith(
            brandColor: value['brand_color'],
            backgroundTranslucency: value['background_translucency'],
          ),
        );
      case 'orb_composer':
        return config.copyWith(
          composer: config.composer.copyWith(
            focus: OrbComposerFocusExtension.fromString(value['focus']),
            placeholder: value['placeholder'],
            collapsePlaceholder: value['collapse_placeholder'],
            visibility: OrbComposerVisibilityExtension.fromString(
              value['visibility'],
            ),
            placeholderText: value['placeholder_text'],
            collapsePlaceholderText: value['collapse_placeholder_text'],
            fileButtonText: value['file_button_text'],
            fileSendText: value['file_send_text'],
            imageButtonText: value['image_button_text'],
            cameraButtonText: value['camera_button_text'],
            galleryButtonText: value['gallery_button_text'],
          ),
        );
      case 'orb_header':
        return config.copyWith(
          header: config.header.copyWith(
            buttons: value['buttons'],
            title: OrbHeaderTitleEventSpec.fromMap(value['title']),
            progress: OrbHeaderProgressEventSpec.fromMap(value['progress']),
            milestones: value['milestones'],
            extraButtons: value['extra_buttons'],
          ),
        );
      case 'orb_menu':
        return config.copyWith(
          menu: config.menu.copyWith(
            closeText: value['close_text'],
            backText: value['back_text'],
          ),
        );
      case 'orb_splash':
        return config.copyWith(
          splash: config.splash.copyWith(
            readyText: value['ready_text'],
          ),
        );
      case 'orb_media_upload':
        return config.copyWith(
          mediaUpload: config.mediaUpload.copyWith(
            all: value['all'],
            file: value['file'],
            image: value['image'],
          ),
        );
      default:
        return config;
    }
  }

  @override
  Widget build(BuildContext context) {
    return OrbConfigInherited(config: config, child: widget.child);
  }
}

class OrbConfigInherited extends InheritedWidget {
  final OrbConfig config;

  const OrbConfigInherited({
    required this.config,
    required Widget child,
    Key? key,
  }) : super(key: key, child: child);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('config', config, showName: false));
  }

  @override
  bool updateShouldNotify(OrbConfigInherited oldWidget) =>
      config != oldWidget.config;
}
