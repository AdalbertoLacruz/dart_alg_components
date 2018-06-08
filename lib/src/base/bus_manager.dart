// @copyright 2017-2018 adalberto.lacruz@gmail.com

part of core.alg_components;

///
/// Manager for actions subscription.
/// The controlled components define actions in their messageManager.
///
class BusManager {
  /// <id, [messageManager...]> from components controlled
  Map<String, List<MessageManager>> actors = <String, List<MessageManager>>{};

  /// Register for onFire handlers
  Map<String, Set<Function>> get fireRegister => _fireRegister ??= <String, Set<Function>>{};
  Map<String, Set<Function>> _fireRegister;

  ///
  /// Add an Actor to actors list. The entry point for the actor is the messageManager.
  ///
  void addActor(String id, MessageManager mm) {
    actors.containsKey(id) ? actors[id] : (actors[id] = <MessageManager>[])
      ..add(mm);
  }

  ///
  /// Execute actions in the component
  ///
  void actorFire(String id, String action, dynamic message) {
    if (actors.containsKey(id)) {
      actors[id].forEach((MessageManager mm) => mm.dispatchAction(action, message));
    }
  }

  ///
  /// When controller receive a message execute the associate handlers
  ///
  void fire(String channel, dynamic message) {
    if (!fireRegister.containsKey(channel)) return;

    fireRegister[channel].forEach((Function handler) {
      handler(message);
    });
  }

  ///
  /// Send actions to execute in components
  ///
  void fireAction(String id, String action, dynamic message) {
    if (id != null) {
      new Future<void>(() => actorFire(id, action, message));
    } else { // broadcast
      actors.keys.forEach((String id) {
        new Future<void>(() => actorFire(id, action, message));
      });
    }
  }

  ///
  /// True if id is in actors list
  ///
  bool hasActor(String id) => actors.keys.contains(id);

  ///
  /// Recovers an observable exported by an actor. Could be null
  ///
  ObservableEvent<dynamic> import(String id, String name) =>
    actors.containsKey(id)
      ? actors[id].first.exportRegister[name]
      : null;

  ///
  /// Define what to do (handler) when a message is received.
  /// Ex.
  /// (['CLICK', 'ACTION'], handler). If CLICK or ACTION is received the handler is executed.
  ///
  void onFire(List<String> channels, Function handler) {
    if (channels == null || handler == null) return;

    channels.forEach((String channel) {
      (fireRegister[channel] ??= new Set<Function>()).add(handler);
    });
  }
}
