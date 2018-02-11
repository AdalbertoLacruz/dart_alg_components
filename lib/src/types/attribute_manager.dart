// @copyright 2017-2018 adalberto.lacruz@gmail.com

part of core.alg_components;

///
/// Manages the component attributes
///
class AttributeManager {
  /// Element to get/set attributes
  HtmlElement target;

  /// Constructor
  AttributeManager(HtmlElement this.target);

  /// Default values for read(), default()
  Map<String, dynamic> get defaults => _defaults ??= <String, dynamic>{};
  Map<String, dynamic> _defaults;

  /// Cache for last attribute information
  ObservableEvent<dynamic> entry;

  /// Attributes storage
  Map<String, ObservableEvent<dynamic>> get register => _register ??= <String, ObservableEvent<dynamic>>{};
  Map<String, ObservableEvent<dynamic>> _register;

  ///
  /// Update the [value] for an attribute [name]
  ///
  void change(String name, dynamic value) => get(name)
        ..binded = true
        ..update(value);

  ///
  /// Initialize observable with attribute value or default.
  /// Don't trigger handlers.
  ///
  void defaultValue(dynamic value) {
    final String name = entry.name;

    if (target.attributes.containsKey(name)) {
      entry.value = target.getAttribute(name);
    } else if (defaults.containsKey(name)) {
      entry.value = defaults[name];
    } else {
      entry.value = value;
    }
  }

  ///
  /// Defines an attribute, if not previously defined.
  ///
  void define<T>(String name, {String type = TYPE_STRING}) {
    if (register.containsKey(name)) {
      entry = register[name];
    } else {
      entry = new ObservableEvent<T>(name)
          ..setType(type);
      register[name] = entry;
    }
  }

  ///
  /// Load defaults for read(), if not previously defined.
  /// if [important] == true, load any case.
  ///
  void defineDefault(String name, dynamic value, {bool important = false}) {
    if (important || !defaults.containsKey(name))
      defaults[name] = value;
  }

  ///
  /// Assure an entry
  ///
  ObservableEvent<dynamic> get(String name) {
    define<String>(name); // by default String
    return entry;
  }

  ///
  /// Returns the attribute value
  ///
  dynamic getValue(String name) => get(name).value;

  ///
  /// true is Binded to the controller
  ///
  bool isBinded(String name) => get(name).binded;

  ///
  /// Don't repeat same actions
  /// True if [name] is not included in entry.context[action]
  /// For name == null => entry.context[action]: true/false,
  /// else entry.context[action] = ['name', ...]
  ///
  bool isUniqueAction(String action, [String name]) {
    final Map<String, dynamic> context = entry.context;

    if (name == null) {
      return (context[action] ?? false) ? false : (context[action] = true);
    } else {
      final List<String> token = context[action] ??= <String>[];
      return token.contains(name) ? false : (token..add(name)) != null; // true
    }
  }

  ///
  /// Action on attribute change. Use toAttribute() to identify the attribute.
  ///
  void on(Function handler) {
    if (handler == null)
      return;

    entry.observe(handler);
  }

//  /**
//   * As on, but with name. Used for attributes defined elsewhere
//   * @param {String} name
//   * @param {Function} handler
//   */
//  onChange(name, handler) {
//    this.entry = this.get(name);
//    return this.on(handler);
//  }

//  /**
//   *
//   * @param {*} message
//   * @return {AttributeManager}
//   */
//  onChangeFireMessage(message) { // use messageManager?
//    this.entry.onChangeFireMessage(this.target, message);
//    return this;
//  }

  ///
  /// Copy value to other attribute [name], only once
  ///
  void onChangeModify(String name) {
    final ObservableEvent<dynamic> entry = this.entry;

    if (isUniqueAction('modify', name)) {
      final ObservableEvent<dynamic> target = get(name); // must be outside link
      entry.link((dynamic value, Map<String, dynamic> context) => target.update(value));
      this.entry = entry;
    }
  }

  ///
  /// Immediate Action on attribute change.
  ///
  void onLink(Function handler) {
    if (handler == null)
      return;

    entry.link(handler);
  }

  ///
  /// Read, now,  the attribute associate with entry.
  /// If attribute isn't found use defaults if possible.
  /// [alwaysUpdate] == true, execute the observers any case.
  ///
  void read({bool alwaysUpdate = false}) {
    final String name = entry.name;

    if (target.attributes.containsKey(name)) {
      entry.update(target.getAttribute(name));
    } else if (defaults.containsKey(name)) {
      entry.update(defaults[name]);
    } else if (alwaysUpdate) {
      entry.dispatch();
    }
  }

  ///
  /// On change reflect to attribute. Use toAttribute() to identify the attribute.
  /// type = '-remove', 'true-false', ...
  /// init = true, reflect the change now
  ///
  void reflect({ String type, bool init }) {
    if (isUniqueAction('reflect'))
        entry.onChangeReflectToAttribute(target, init: init, type: type);
  }

  ///
  /// Set entry to the attribute, for further processing
  ///
  void toAttribute(String name) => get(name);

// --------------------------------------------------- static

  ///
  /// Load all attributes for the [target] component
  ///
  static void initialReadAllAttributes(HtmlElement target) {
    target.attributes.forEach((String name, String value) => target.attributeChanged(name, null, value));
  }
}
