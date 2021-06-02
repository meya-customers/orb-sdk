import 'dart:io';

import 'package:flutter/cupertino.dart';

import 'package:path/path.dart' as p;

enum OrbFileType { image, bin }

class OrbBlob {
  final File file;
  final OrbFileType type;

  OrbBlob({@required this.file, @required this.type});

  factory OrbBlob.image(File file) =>
      OrbBlob(file: file, type: OrbFileType.image);

  factory OrbBlob.bin(File file) => OrbBlob(file: file, type: OrbFileType.bin);

  String get basename => p.basename(file.path);
}
