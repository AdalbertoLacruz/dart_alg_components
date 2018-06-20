// @copyright 2017-2018 adalberto.lacruz@gmail.com

part of core.alg_components;

///
/// Manages the component attributes
///
class AttributeManager {
  /// Element to get/set attributes
  AlgComponent target;

  ///
  /// Constructor
  /// Define: disabled
  ///
  AttributeManager(AlgComponent this.target) {
    _setInitialAttributes();
  }

  /// <alias, name> for observable names. Let an alternative name
  Map<String, String> get aliasRegister => _aliasRegister ??= <String, String>{};
  Map<String, String> _aliasRegister;

  /// Attributes we have try to subscribe. Don't try anymore.
  List<String> binded = <String>[];

  /// Storage for last hasChanged key
  Map<String, int> get changedRegister => _changedRegister ??= <String, int>{};
  Map<String, int> _changedRegister;

  /// Default values for read(), default() // TODO: deprecated
  Map<String, dynamic> get defaults => _defaults ??= <String, dynamic>{};
  Map<String, dynamic> _defaults;

  /// Cache for last attribute information
  ObservableEvent<dynamic> entry;

  /// Attributes storage
  Map<String, ObservableEvent<dynamic>> register = <String, ObservableEvent<dynamic>>{};

  /// Attributes removed, pending to receive null in attributeChanged
  List<String> removedAttributes = <String>[];

//  /// Handler to execute for unsubscribe to the controller
//  List<Function> unsubscribeHandlers = <Function>[];

  ///
  /// Assure in the future that the entry observable is dispatched
  ///
  void autoDispatch() {
    final ObservableEvent<dynamic> entry$ = entry;
    new Future<void>(() => entry$.autoDispatch());
  }

  ///
  /// Compose the name prefix
  ///
  String calculatePrefix() {
    final String hash = target.hashCode.toString();
    final String id = target.id.isNotEmpty ? target.id : target.tagName;
    return '${id}_$hash<attr>';
  }

  ///
  /// Update the [value] for an attribute [name]
  ///
  void change(String name, dynamic value) => get(name) // TODO: deprecated?
        ..update(value);

  ///
  /// Initialize observable with attribute value or default.
  /// Don't trigger handlers.
  ///
  void defaultValue(dynamic value) { // TODO: deprecated
    final String name = entry.name;
    print('attributeManager default value $name, deprecated?');

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
  /// Alias only used in entry creation.
  ///
  void define<T>(String name,
      { List<String> alias,
        bool countChanges,
        dynamic value,
        bool isPreBinded,
        bool isLocal,
        String type = TYPE_STRING}) {
    //
    entry = has(name);
    if (entry == null) {
      entry = new ObservableEvent<T>(name)
          ..setType(type)
          ..prefix = calculatePrefix();
      register[name] = entry;
      if (alias != null) {
        alias.forEach((String aliasName) => aliasRegister[aliasName] = name);
      }
      if (countChanges ?? false) entry.changed = 0; // activate changed counter
    }

    if (value != null) entry.value = value;
    if (isLocal != null) entry.isLocal = isLocal;
    if (isPreBinded != null) entry.isPreBinded = isPreBinded;
  }

  ///
  /// Load defaults for read(), if not previously defined.
  /// if [important] == true, load any case.
  ///
  void defineDefault(String name, dynamic value, {bool important = false}) { // TODO: deprecated
    if (important || !defaults.containsKey(name)) {
      defaults[name] = value;
    }
  }

  ///
  /// Assure an entry. Creates it if not defined
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
  /// If name is in register or alias return it, else null
  ///
  ObservableEvent<dynamic> has(String name) {
    if (register.containsKey(name)) {
      return entry = register[name];
    } else if ((_aliasRegister != null) && aliasRegister.containsKey(name)) {
      final String aliasName = aliasRegister[name];
      if (register.containsKey(aliasName)) return entry = register[aliasName];
    }
    return null;
  }

  ///
  /// True if targets have changed since last call with key.
  /// The observables have to be defined with countChanges = true.
  ///
  bool hasChanged(String key, List<String> targets) {
    final int changesCount = targets.fold(0, (int sum, String target) => sum + get(target).changed ?? 0);
    return changedRegister[key] == changesCount
        ? false
        : (changedRegister[key] = changesCount) != null; // true
  }

  ///
  /// true if it is Binded to the controller
  ///
  bool isSubscriptionTried(String name) =>
      binded.contains(name) ? true : (binded..add(name)) == null; // false

  /// true if [name] is in removedAttributes list. Also removes from list.
  bool isRemoved(String name) => removedAttributes.remove(name);

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
    if (handler == null) return;

    entry.observe(handler);
  }

  ///
  /// As on, but with name. Used for attributes defined elsewhere
  ///
  void onChange(String name, Function handler) {
    get(name);
    on(handler);
  }

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
    if (handler == null) return;

    entry.link(handler);
  }

  ///
  /// Read, now,  the attribute associate with entry.
  /// If attribute isn't found use defaults if possible.
  /// [alwaysUpdate] == true, execute the observers any case.
  /// [defaultValue] set a default value
  ///
  void read({bool alwaysUpdate = false, bool defaultValue}) { // TODO: deprecated
    final String name = entry.name;
    print('attributeManager read $name deprecated?');
    if (defaultValue != null) defineDefault(name, defaultValue);

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
    if (isUniqueAction('reflect')) {
      entry.onChangeReflectToAttribute(target, init: init, type: type);
    }
  }

  ///
  /// Removes and attribute. target.attributeChanged will receive a null.
  ///
  void removeAttribute(String name) {
    removedAttributes.add(name);
    target.attributes.remove(name);
  }

  ///
  /// Define disabled/aria-disabled
  ///
  void _setInitialAttributes() {
    define<bool>('aria-disabled', type: TYPE_BOOL);
    reflect(type: 'true-false');

    define<bool>('disabled', type: TYPE_BOOL, isLocal: true);
    reflect();
    onChangeModify('aria-disabled');
    on((bool disabled) {
      target.style.setProperty('pointerEvents', disabled ? 'none' : '');
      if (disabled) {
        target
          ..oldTabIndex = target.tabIndex
          ..tabIndex = -1
          ..blur();
      } else {
        if (target.oldTabIndex != null)
          target.tabIndex = target.oldTabIndex;
      }
    });
    store((ObservableEvent<bool> entry$) => target.disabled$ = entry$);
  }

  ///
  /// Defines `newValue = handler(value)` as a transformer
  ///
  void setTransformer(Function handler) => entry.transformer = handler;

  ///
  /// save entry to variable. ex.
  ///   ..store((entry) => observable$ = entry)
  ///
  void store(Function handler) => handler(entry);

  ///
  /// Set entry to the attribute, for further processing
  ///
  void toAttribute(String name) => get(name);

  ///
  /// For each entry, unsubscribe from the controller
  ///
  void unsubscribe() {
    register.forEach((String name, ObservableEvent<dynamic> entry) {
      if (entry.bindedController != null) {
        entry.bindedController.unSubscribe(
            entry.bindedChannel, entry.receiverHandler);
        entry.bindedController = null;
      }
    });
  }

  ///
  /// For PreBinded definition, update controller/channel
  ///
  void updatePreBinded() {
    final String id = target.id;
    final dynamic controllerHandler = target.controllerHandler;
    if (id.isEmpty || controllerHandler == null) return;

    register.forEach((String attrName, ObservableEvent<dynamic> entry) {
      if (entry.isPreBinded && !isSubscriptionTried(attrName)) {
        final ControllerStatus status = new ControllerStatus(hasChannel: false);
        final String channel = '$id-$attrName';
        final String value = controllerHandler.subscribe(channel, null, entry.receiverHandler, status);


        // Needed for unsubscribe
        if (status.hasChannel) {
          entry
            ..bindedChannel = channel
            ..bindedController = controllerHandler;
        }
        if (value != null) entry.update(value);
      }
    });
  }

// --------------------------------------------------- static
  ///
  /// Set or remove the attribute according to force.
  /// If force is null, set the attribute if not exist and vice versa.
  /// type =
  ///   null '-remove' => attribute=""
  ///   'true-false'   => attribute="true", attribute="false"
  ///   'true-remove'  => attribute="true"
  ///
  static void attributeToggle(HtmlElement target, String attrName,  {
    bool force,
    String type
  }) {
    final List<String> types = (type ?? '-remove').split('-');
    final String on = types[0].trim().toLowerCase();
    final String off = types[1].trim().toLowerCase();

    final bool hasAttribute = target.attributes.containsKey(attrName);
    final bool value = force ?? !hasAttribute;
    final String attrValue = hasAttribute ? target.getAttribute(attrName) : null;

    if (value) {
      if (attrValue != on)
        target.setAttribute(attrName, on);
    } else {
      if (off == 'remove') {
        if (hasAttribute)
          target.attributes.remove(attrName);
      } else {
        if (attrValue != off)
          target.setAttribute(attrName, off);
      }
    }
  }

  ///
  /// Set/remove class for target.
  /// Ex.: '+addClass -removeClass !toggleClass addClass'
  ///
  static void classUpdate(HtmlElement target, String value) {
    if (value == null) return;
    value.split(' ').forEach((String name) {
      name = name.trim();
      if (name.isNotEmpty) {
        if (name.startsWith('+')) {
          target.classes.add(name.substring(1));
        } else if (name.startsWith('-')) {
          target.classes.remove(name.substring(1));
        } else if (name.startsWith('!')) {
          target.classes.toggle(name.substring(1));
        } else {
          target.classes.add(name);
        }
      }
    });
  }

  ///
  /// Load all attributes for the [target] component
  ///
  static void initialReadAllAttributes(HtmlElement target) {
    target.attributes.forEach((String name, String value) => target.attributeChanged(name, null, value));
  }

  ///
  /// Stamp this component and the upper tree with this.controller = controllerName
  /// defined with the attribute controller="..." in upper scope.
  /// If not found, we use the first controller instantiated.
  ///
  static void findController(AlgComponent target) {
    void setHandler() => target.controllerHandler = (target.controller is String )
        ? AlgController.controllers[target.controller]
        : target.controller;

    if (target.controllerHandler != null) return null;
    if (target.controller != null) return setHandler();


    final List<HtmlElement> elementsToSet = <HtmlElement>[];
    dynamic controller; // String | ClassInstance
    HtmlElement element = target;

    while ((element?.nodeType != Node.DOCUMENT_FRAGMENT_NODE ?? false)
        && (element?.localName != 'html' ?? false)
        && controller == null) {
      if (element is AlgComponent && element.controller != null) {
        controller = element.controller;
      } else {
        elementsToSet.add(element);
        if (element.attributes.containsKey('controller')) {
          controller = element.getAttribute('controller');
        } else {
          element = element.parentNode;
        }
      }
    }

    // Stamp the controller in the tree to speed further searches
    controller ??= AlgController.controllers.keys.isNotEmpty ? AlgController.controllers.keys.first : '';
    elementsToSet.forEach((HtmlElement element) {
      if (element is AlgComponent) {
        element.controller = controller;
      } else if (controller is String) {
        element.setAttribute('controller', controller);  // could be removed
      }
    });

    setHandler();
  }

  ///
  /// Check for binder if [value] == '[[controller:channel=default value]]' or {{}}.
  /// In that case, subscribe the attribute to changes in the controller register.
  ///
  static void subscribeBindings(AlgComponent target, String name, String value) {
    if (value == null) return null;

    final BinderParser binderParser = new BinderParser(name, value, target.controller, target.id);

    if (binderParser.isEventBinder) return attributeIsEvent(target, binderParser);
    if (binderParser.isStyleBinder) return attributeIsStyle(target, binderParser);
    return attributeIsBinder(target, binderParser);
  }

  ///
  /// Process on-handler="[[controller:ID_CHANNEL]]"
  ///
  static void attributeIsEvent(AlgComponent target, BinderParser binderParser) {
    target.messageManager.defineBinded(
        binderParser.handler, binderParser.controller, binderParser.channel);

    target.attributeManager.removeAttribute(binderParser.attrName);
  }

  ///
  ///Process style="property1:[[controller:channel=default_value]];property2:[[*]]"
  ///
  static void attributeIsStyle(AlgComponent target, BinderParser binderParser) {
    do {
      final ControllerStatus status = new ControllerStatus(hasChannel: false);
      final AlgController controller = (binderParser.controller is String)
          ? AlgController.controllers[binderParser.controller]
          : binderParser.controller;
      final String property = binderParser.styleProperty;

      if (controller == null) {
        target.style.setProperty(property, binderParser.value);
      } else {
        final String channel = binderParser.getAutoStyleChannel(property);
        String value = binderParser.autoValue;
        if (channel.isNotEmpty) {
          value = (value == '') ? null : value; // support attribute without value
          final ObservableEvent<String> entry = target.styleManager.define(property);
          value = controller.subscribe(channel, value, entry.receiverHandler, status);
          if (status.hasChannel) {
            entry
              ..bindedChannel = channel
              ..bindedController = controller;
          }
        }
        if (value != null) {
          target.style.setProperty(property, value);
        }
      }
    } while (binderParser.next());
  }

  ///
  /// Process attr="[[controller:channel=defaultValue]]" or
  /// attr="{{controller:channel=defaultValue}}"
  ///
  static void attributeIsBinder(AlgComponent target, BinderParser binderParser) {
    final String attrName = binderParser.attrName;
    final AttributeManager attributeManager = target.attributeManager
        ..toAttribute(attrName);
    final ObservableEvent<dynamic> entry = attributeManager.entry;
    final Function handler = entry.receiverHandler;
    final ControllerStatus status = new ControllerStatus(hasChannel: false);
    final AlgController controller = (binderParser.controller is String)
        ? AlgController.controllers[binderParser.controller]
        : binderParser.controller;

    if ((controller == null) ||
        (entry.isLocal && !binderParser.isAttributeBinder)) {
      return entry.update(binderParser.value);
    }

    final String channel = binderParser.autoChannel;
    String value = binderParser.autoValue;
    if (channel.isNotEmpty) {
      value = (value == '') ? null : value; // support attribute without value
      value = controller.subscribe(channel, value, handler, status);

      // Need for unsubscribe
      if (status.hasChannel) {
        entry
            ..bindedChannel = channel
            ..bindedController = controller;
      }

      if (binderParser.isSync) attributeManager.reflect();
    }

    value ??= binderParser.autoValue; // support attribute without value
    if (!binderParser.isSync && status.hasChannel) {
      attributeManager.removeAttribute(attrName);
    }
    if (value != null) entry.update(value);
  }
}
