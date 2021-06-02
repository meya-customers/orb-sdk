import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';

class OrbUtil {
  static String uuid4Hex() {
    var uuid = Uuid(options: {'grng': UuidUtil.cryptoRNG});
    return uuid.v4();
  }

  static String generateOrbIntegrationId() {
    return 'ot-${uuid4Hex()}';
  }
}
