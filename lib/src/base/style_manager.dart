// @copyright 2017-2018 adalberto.lacruz@gmail.com

part of core.alg_components;

///
class StyleManager {
  /// Element to set styles
  HtmlElement target;

  /// Constructor
  StyleManager(HtmlElement this.target);

  /// style property, observable
  Map<String, ObservableEvent<String>> register = <String, ObservableEvent<String>>{};

  ///
  /// Define a new property observable
  ///
  ObservableEvent<String> define(String name) {
    final ObservableEvent<String> entry = new ObservableEvent<String>(name)
        ..setType(TYPE_STRING)
        ..prefix = '${target.id}<style>'
        ..observe((String value) {
            target.style.setProperty(name, value);
        });
    return register[name] = entry;
  }

  ///
  /// For each entry, unsubscribe from the controller
  ///
  void unsubscribe() {
    register.forEach((String name, ObservableEvent<String> entry) {
      if (entry.bindedController != null) {
        entry.bindedController.unSubscribe(entry.bindedChannel, entry.receiverHandler);
        entry.bindedController = null;
      }
    });
  }
}
