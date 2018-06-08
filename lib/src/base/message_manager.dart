// @copyright 2017-2018 adalberto.lacruz@gmail.com

part of core.alg_components;

///
/// Manager for the component messages received and emitted to the bus
///
class MessageManager {
  /// Element who fire messages
  AlgComponent target;

  /// Constructor
  MessageManager(AlgComponent this.target);

  // ------------------------------------------------- MESSAGE

  /// Cache for last defined
  ObservableMessage entry;

  /// Messages storage
  Map<String, ObservableMessage> register = <String, ObservableMessage>{};

  ///
  /// Compose the name prefix
  ///
  String calculatePrefix() {
    final String hash = target.hashCode.toString();
    final String id = target.id.isNotEmpty ? target.id : target.tagName;
    return '${id}_$hash<msg>';
  }

  ///
  /// Defines a message (output).
  /// toAttribute, toEvent = bool true/String name
  ///
  ObservableMessage define(String name,
        { bool isPreBinded, bool letRepeat, dynamic toAttribute, dynamic toEvent }) {
    if (register.containsKey(name)) {
      entry = register[name];
    } else {
      entry = register[name] = new ObservableMessage(name)
          ..prefix = calculatePrefix();

      if (toAttribute != null) entry.toAttribute = toAttribute;
      if (toEvent != null) entry.toEvent = toEvent;
      if (isPreBinded != null) entry.isPreBinded = isPreBinded;
      if (letRepeat != null) entry.letRepeat = letRepeat;
    }
    return entry;
  }

  ///
  /// We have readed the binded information from attribute
  /// such as on-event=[[controller:channel]].
  /// If name was not previously defined is an system event, such as `on-click`
  ///
  void defineBinded(String name, dynamic controller, String channel) {
    define(name, toEvent: true)
      ..controllerHandler = (controller is String)
          ? AlgController.controllers[controller]
          : controller
      ..channel = channel;
  }

  ///
  /// Emits a message
  ///
  void fire(String name, dynamic value) {
    get(name).update(value);
  }

  ///
  /// Assure an entry
  ///
  ObservableMessage get(String name) =>
      entry = register.containsKey(name) ? register[name] : define(name);

  ///
  /// Action on message fire
  ///
  void on(String name, Function handler) {
    if (handler == null) return;

    get(name).observe(handler);
  }

  ///
  /// Propagates changes in events/attributes to messages
  ///
  void subscribeTo() {
    bool isEventManager = false;

    register.forEach((String key, ObservableMessage entry) {
      if (entry.toEvent != null) {
        final String name = (entry.toEvent is bool) ? key : entry.toEvent;
        target.eventManager.on(name, (dynamic value) { entry.update(value); });
        isEventManager = true;
      } else if (entry.toAttribute != null) {
        final String name = (entry.toAttribute is bool) ? key : entry.toAttribute;
        target.attributeManager.onChange(name, (dynamic value) { entry.update(value); });
      }
    });

    if (isEventManager) target.eventManager.subscribe();
  }

  ///
  /// Defines a transformer to set the value
  ///
  void transformer(Function handler) {
    entry.transformer = handler;
  }

  ///
  /// Function to calculate when fire the message
  /// handler(value)
  ///
  void trigger(Function handler) {
    entry.trigger = handler;
  }

  ///
  /// For PreBinded definition, update controller/channel
  ///
  void updatePreBinded() {
    final String id = target.id;
    final dynamic controllerHandler = target.controllerHandler;

    if (id.isEmpty || controllerHandler == null) return;

    register.forEach((String key, ObservableMessage entry) {
        if (entry.isPreBinded) {
          entry
              ..controllerHandler = controllerHandler
              ..channel = '${id}_$key'.toUpperCase();
        }
    });
  }

  // ------------------------------------------------- ACTION

  /// Input actions definition
  Map<String, ObservableAction> get actions => _actions ??= <String, ObservableAction>{};
  Map<String, ObservableAction> _actions;

  ///
  /// Subscribe actions/exports to the controller
  ///
  void connectToController() {
    if (_actions == null && _exportRegister == null) return;

    final dynamic controllerHandler = target.controllerHandler;
    final String id = target.id;
    if (controllerHandler == null || id.isEmpty) return;

    controllerHandler.busManager.addActor(id, this);
  }

  ///
  /// If action is defined execute it
  ///
  void dispatchAction(String action, dynamic message, {bool isLink: false}) {
    if (actions.containsKey(action)) actions[action].dispatch(message, isLink: isLink);
  }

  ///
  /// Defines an action (input)
  ///
  void from(String name, Function handler) {
    actions.containsKey(name) ? actions[name] : (actions[name] = new ObservableAction())
      ..subscribe(handler);
  }

  // ------------------------------------------------- Export

  /// component export
  Map<String, ObservableEvent<dynamic>> get exportRegister => _exportRegister ??= <String, ObservableEvent<dynamic>>{};
  Map<String, ObservableEvent<dynamic>> _exportRegister;

  ///
  /// Define an observable as visible outside the component, through the BusController import
  ///
  void export(String name, ObservableEvent<dynamic> observable) {
    exportRegister[name] = observable;
  }
}

