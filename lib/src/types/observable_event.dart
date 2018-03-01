// @copyright 2017-2018 adalberto.lacruz@gmail.com

part of core.alg_components;

///
/// HTML handling for Attributes and Events observables
///
class ObservableEvent<T> extends Observable<T> {
  /// Constructor
  ObservableEvent(String name) :super(name);

  /// Channel subscription
  String bindedChannel;

  /// AlgController subscription. dynamic to let other controller types
  dynamic bindedController;

  ///
  /// Handler to subscribe to other observables
  ///
//  void receiverHandler(dynamic received) => update(received);
  void receiverHandler(dynamic received) {
    update(received);
  }

  ///
  /// Set [item] [attribute] in a value change.
  /// If [attribute] is null, use the observable name.
  /// If [init] also set now the attribute
  /// [type] is used to define boolean attributes as 'true-false', '-remove', ...
  ///
  void onChangeReflectToAttribute(HtmlElement element, {
      String attribute,
      bool init = false,
      String type // don't mistake with this.type
  }) {
    final String _attribute = attribute ?? name;
    Function handler;
    if (this.type == TYPE_BOOL) {
      handler = (bool value) => FHtml.attributeToggle(element, _attribute, force: value, type: type);
      observe(handler);
      if (value != null && init)
          handler(value);
    } else if (this.type == TYPE_STRING || this.type == TYPE_NUM) {
      handler = (dynamic value) {
        if (value != null) {
          final String _value = (value is! String) ? value.toString() : value;
          element.setAttribute(_attribute, _value);
        } else {
          element.attributes.remove(_attribute);
        }
      };
      observe(handler);
      if (init)
          handler(value);
    }
  }

  ///
  /// Set class in a value change true/false
  ///
  void onChangeReflectToClass(HtmlElement element, String className) {
    if (type == TYPE_BOOL)
      observe((bool value) => element.classes.toggle(className, value));
  }

  ///
  /// Observable value type definition
  ///
  @override
  void setType(String type, {bool useTransformer = true}) {
    super.setType(type, useTransformer: useTransformer);
  }
}
