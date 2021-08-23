import 'package:orb/ui/card/ask_buttons.dart';
import 'package:orb/ui/card/ask_form.dart';
import 'package:orb/ui/card/ask_tiles.dart';
import 'package:orb/ui/card/file.dart';
import 'package:orb/ui/card/image.dart';
import 'package:orb/ui/card/rating.dart';
import 'package:orb/ui/card/status.dart';

final EventMap = {
  'meya.button.event.ask': OrbAskButtons,
  'meya.form.event.ask': OrbAskForm,
  'meya.tile.event.ask': OrbAskTiles,
  'meya.file.event': OrbFile,
  'meya.orb.event.hero': null,
  'meya.image.event': OrbImage,
  'meya.tile.event.rating': OrbRating,
  'meya.text.event.status': OrbStatus,
};
