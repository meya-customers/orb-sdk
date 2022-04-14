import 'package:flutter/widgets.dart';

class InputDataController extends ValueNotifier<List<dynamic>> {
  final List<ValueNotifier<dynamic>?> children;

  InputDataController({required this.children})
      : super(List.filled(children.length, null)) {
    for (var index = 0; index < children.length; index++) {
      final child = children[index];
      if (child != null) {
        child.addListener(() => _onChildValueChanged(child, index));
        value[index] = _getChildValue(child.value);
      }
    }
  }

  dynamic getChild(int index) {
    return children[index]!;
  }

  @override
  void dispose() {
    for (final child in children) {
      if (child != null) {
        child.dispose();
      }
    }
    super.dispose();
  }

  void _onChildValueChanged(ValueNotifier<dynamic> child, int index) {
    value[index] = _getChildValue(child.value);
    notifyListeners();
  }

  static dynamic _getChildValue(dynamic value) {
    if (value is TextEditingValue) {
      return value.text;
    } else {
      return value;
    }
  }
}
