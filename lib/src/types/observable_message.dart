// @copyright 2017-2018 adalberto.lacruz@gmail.com

part of core.alg_components;

///
/// Each message definition for on-event=[[controller:channel]]
///
class ObservableMessage extends Observable<dynamic> {
  /// Constructor
  ObservableMessage(String name):super(name);

  ///
  String channel;

  /// AlgControler or similar
  dynamic controllerHandler;

  /// True, let send two equal messages
  bool letRepeat = false;

  /// bool true, use AttributeManager, same name.
  /// String = name to AttributeManager
  dynamic toAttribute;

  /// bool true, use EventManager, same name.
  /// String = name to EventManager
  dynamic toEvent;

  /// Trigger level, calculate function to fire the message
  Function trigger;

  /// Same effect as attribute on-event= ...
  bool isPreBinded = false;


  ///
  /// Changes a value and trigger the linkers/observers
  /// Options: force = true, dispatch any case
  ///
  @override
  void update(dynamic value , {bool force = false}) { // force not used
    if (disabled) return;

    if (delayed) {
      delayedValue = value;
      return;
    }

    this.value = value; // could use transformer

    final bool isTrigger = (trigger != null) ? trigger(this.value) : true;
    if (isTrigger && (letRepeat || isNewValue)) {
      dispatch();
      if (controllerHandler != null && channel != null) {
        controllerHandler.fire(channel, this.value); // this.value yet transformed
      }
    }
  }
}
