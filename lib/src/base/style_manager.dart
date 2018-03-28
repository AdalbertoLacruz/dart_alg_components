// @copyright 2017-2018 adalberto.lacruz@gmail.com

part of core.alg_components;

///
/// Style bindings for the component
///
class StyleManager {
  /// Element to set styles
  HtmlElement target;

  /// Constructor
  StyleManager(HtmlElement this.target);

  /// style storage {property, observable}
  Map<String, ObservableEvent<String>> register = <String, ObservableEvent<String>>{};

  ///
  /// Compose the name prefix
  ///
  String calculatePrefix() {
    final String hash = target.hashCode.toString();
    final String id = target.id.isNotEmpty ? target.id : target.tagName;
    return '${id}_$hash<style>';
  }

  ///
  /// Define a new property observable
  ///
  ObservableEvent<String> define(String name) {
    final ObservableEvent<String> entry = new ObservableEvent<String>(name)
        ..setType(TYPE_STRING)
        ..prefix = calculatePrefix()
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
