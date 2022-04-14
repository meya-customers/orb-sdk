import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';

class OrbUtil {
  static String uuid4Hex() {
    const uuid = Uuid(options: {'grng': UuidUtil.cryptoRNG});
    return uuid.v4();
  }

  static String generateOrbIntegrationId() {
    return 'ot-${uuid4Hex()}';
  }
}

extension IterableExtension<T> on Iterable<T> {
  Iterable<List<T>> splitAtIndexed(
    bool Function(int index, T element) test,
  ) sync* {
    List<T> chunk = [];
    int index = 0;
    for (final element in this) {
      if (test(index, element)) {
        if (chunk.isNotEmpty) {
          yield chunk;
        }
        chunk = [];
      } else {
        chunk.add(element);
      }
      index++;
    }
    if (chunk.isNotEmpty) {
      yield chunk;
    }
  }

  Iterable<List<T>> splitAt(bool Function(T element) test) =>
      splitAtIndexed((_, element) => test(element));
}
