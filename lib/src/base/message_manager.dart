// @copyright 2017-2018 adalberto.lacruz@gmail.com

part of core.alg_components;

///
/// Manager for the component messages emitted to the bus
///
class MessageManager {
  /// Element who fire messages
  AlgComponent target;

  /// Constructor
  MessageManager(AlgComponent this.target);

  /// Cache for last defined
  ObservableMessage entry;

  ///Messages storage
  Map<String, ObservableMessage> register = <String, ObservableMessage>{};

  ///
  /// Defines a message.
  /// toAttribute, toEvent = bool true/String name
  ///
  ObservableMessage define(String name,
        { bool isPreBinded, bool letRepeat, dynamic toAttribute, dynamic toEvent }) {
    if (register.containsKey(name)) {
      entry = register[name];
    } else {
      entry = register[name] = new ObservableMessage(name);
      if (toAttribute != null)
          entry.toAttribute = toAttribute;
      if (toEvent != null)
          entry.toEvent = toEvent;
      if (isPreBinded != null)
          entry.isPreBinded = isPreBinded;
      if (letRepeat != null)
          entry.letRepeat = letRepeat;
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
    if (handler == null)
        return;
    get(name).observe(handler);
  }

  ///
  /// Propagates changes in events/attributes to messages
  ///
  void subscribeTo() {
//    bool isEventManager = false;

    register.forEach((String key, ObservableMessage entry) {
      if (entry.toEvent != null) {
//        final String name = (entry.toEvent is bool) ? key : entry.toEvent;
//        target.eventManager.on(name, (dynamic value) { entry.update(value); }); // TODO
//        isEventManager = true;
      } else if (entry.toAttribute != null) {
        final String name = (entry.toAttribute is bool) ? key : entry.toAttribute;
        target.attributeManager.onChange(name, (dynamic value) { entry.update(value); });
      }
    });

//    if (isEventManager)  // TODO
//      target.eventManager.subscribe();
  }

  ///
  /// Defines a transformer to set the value
  ///
  void transformer(Function handler) {
    entry.transformer = handler;
  }

  ///
  /// Function to calculate when fire the message
  ///
  void trigger(Function handler) {
    entry.trigger = handler;
  }

  ///
  /// For Prebinded definition, update controller/channel
  ///
  void updatePrebinded() {
    final String id = target.id;
    final dynamic controller = target.controller;
    if (id.isEmpty || controller == null || (controller is String && controller.isEmpty))
        return;

    final dynamic controllerHandler = (controller is String )
        ? AlgController.controllers[controller]
        : controller;

    register.forEach((String key, ObservableMessage entry) {
        if (entry.isPreBinded) {
          entry
              ..controllerHandler = controllerHandler
              ..channel = '${id}_$key'.toUpperCase();
        }
    });
  }
}

