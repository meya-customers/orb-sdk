class EventEmitter {
  final Map<String, List<Function(Map<String, dynamic>)>> _listeners = {};

  void on(String type, Function(Map<String, dynamic>) listener) {
    final listeners = _listeners[type] ?? [];
    listeners.add(listener);
    _listeners[type] = listeners;
  }

  void off(String type, Function(Map<String, dynamic>) callback) {
    final listeners = _listeners[type] ?? [];
    listeners.remove(callback);
    if (listeners.isEmpty) _listeners.remove(type);
  }

  void emit(String type, Map<String, dynamic> event) {
    if (!_listeners.containsKey(type)) return;

    for (final listener in _listeners[type]!) {
      listener(event);
    }
  }
}
