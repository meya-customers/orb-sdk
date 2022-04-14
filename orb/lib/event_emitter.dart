class EventEmitter {
  final Map<String, List<Function>> _listeners = {};

  void on(String type, Function callback) {
    final listeners = _listeners[type] ?? [];
    listeners.add(callback);
    _listeners[type] = listeners;
  }

  void off(String type, Function callback) {
    final listeners = _listeners[type] ?? [];
    listeners.remove(callback);
    if (listeners.isEmpty) {
      _listeners.remove(type);
    }
  }

  void emit(String type, Map<Symbol, dynamic> event) {
    for (final listener in _listeners[type] ?? []) {
      Function.apply(listener, [], event);
    }
  }
}
