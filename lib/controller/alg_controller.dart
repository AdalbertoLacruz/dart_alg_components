// @copyright 2017-2018 adalberto.lacruz@gmail.com

import '../src/types/observable.dart';
export '../src/types/observable.dart';

///
/// Base class for page controllers
///
class AlgController {
  /// Constructor
  AlgController() {
    AlgController.controllers[name] = this;
    define<BusMessage>('bus', TYPE_OTHER);
  }

  /// Storage for controllers defined in the application. controllers[name] = controller
  static Map<String, AlgController> controllers = <String, AlgController>{};

  /// controllerName, to @override
  String name = '';

  /// Storage
  Map<String, Observable<dynamic>> register = <String, Observable<dynamic>>{};

  ///
  /// Update the [channel] observable value
  ///
  void change(String channel, dynamic value) {
    final Observable<dynamic> entry = register[channel];
    if (entry != null) entry.update(value);
  }

  ///
  /// Define a new register entry
  ///
  Observable<T> define<T>(String name, String type, {T value}) {
    final Observable<T> entry = new Observable<T>(name)
      ..setType(type, useTransformer: true)
      ..prefix = this.name;

    if (value != null) entry.value = value;

    return register[name] = entry;
  }

  ///
  /// The controller receives (up) a message from the bus
  ///
  void fire(String channel, dynamic message) {
    register['bus'].update(new BusMessage(channel, message));
  }

  ///
  /// Returns the [channel] observable value
  ///
  dynamic getValue(String channel) {
    final Observable<dynamic> entry = register[channel];
    return entry != null ? entry.value : null;
  }

  ///
  /// Associates an action with a channel.
  /// if [defaultValue] != null, set the value in channel.
  /// [handler] is the function to be called in channel value change.
  /// [status] is a return variable, with information about channel find success.
  /// Returns the channel value / default value.
  ///
  dynamic subscribe(String channel, dynamic defaultValue, Function handler, ControllerStatus status) {
    if (!register.containsKey(channel)) {
      status.hasChannel = false;
      return defaultValue;
    }

    status.hasChannel = true;
    final Observable<dynamic> entry = register[channel]..observe(handler);
    if (defaultValue != null) entry.update(defaultValue);

    return entry.value;
  }

  ///
  /// Removes the association channel/handler
  ///
  void unSubscribe(String channel, Function handler) {
    final Observable<dynamic> entry = register[channel];
    if (entry != null) entry.unsubscribe(handler);
  }
}

// --------------------------------------------------- BusMessage
///
/// Object for message in bus
///
class BusMessage {
  ///
  String channel;
  ///
  dynamic message;

  /// Constructor
  BusMessage(this.channel, this.message);

  ///
  @override
  String toString() => '$channel = $message';
}

// --------------------------------------------------- ControllerStatus

///
/// Status in controller operations
///
class ControllerStatus {
  /// True, channel found in controller register
  bool hasChannel;

  /// Constructor
  ControllerStatus({this.hasChannel});
}
