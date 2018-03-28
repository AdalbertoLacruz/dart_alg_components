// @copyright 2017-2018 adalberto.lacruz@gmail.com

part of core.alg_components;

///
/// Manages mouse and keyboard events (and others)
///
class EventManager {
  /// Element that fire events: AlgComponent | document | window
  dynamic target;

  /// Constructor
  EventManager(dynamic this.target);

  /// Last recovered eventItem from register
  EventItem<dynamic> entry;

  /// Cache to let a component unsubscribe to global events
  Map<HtmlElement, List<HandlersRegisterItem>> get handlersRegister =>
      _handlersRegister ??= <HtmlElement, List<HandlersRegisterItem>>{};
  Map<HtmlElement, List<HandlersRegisterItem>> _handlersRegister;

  /// Storage for key events definition associated with handlers.
  ///   'ctrl+shift+enter:keypress': KeyItem
  Map<String, KeyItem> get keyRegister => _keyRegister ??= <String, KeyItem>{};
  Map<String, KeyItem> _keyRegister;

  /// To name non HtmlElements
  String prefix = '';

  /// Active storage for event definition and data
  Map<String, EventItem<dynamic>> register = <String, EventItem<dynamic>>{};

  ///
  /// Compose the name prefix
  ///
  String calculatePrefix() {
    if (target is HtmlElement) {
      final String hash = target.hashCode.toString();
      final String id = target.id.isNotEmpty ? target.id : target.tagName;
      return '${id}_$hash<event>';
    } else {
      return prefix;
    }
  }

  ///
  /// Add an item to the register
  /// Ex.: define<Event>(
  ///   'trackStart',
  ///    new ObservableEvent<Event>('trackStart')..setType(TYPE_EVENT),
  ///    ['mousedown'])
  ///
  void define<T>(String eventName, ObservableEvent<T> data, { List<String> visibility}) {
    entry = register[eventName] = new EventItem<T>(data: data)
        ..name = eventName
        ..data.prefix = calculatePrefix();

    if (visibility != null)
      visibleTo(eventName, visibility);
  }

  ///
  /// Disable the observable Event
  ///
  void disableEvent(String eventName) => getObservable(eventName).disabled = true;

  ///
  /// Trigger an event
  ///
  void fire(String eventName, dynamic event) => getObservable(eventName).update(event);

  ///
  /// Returns an entry from the register.
  /// If not exist, then create and initialize it.
  ///
  EventItem<dynamic> get(String eventName) {
    if (entry?.name == eventName) return entry;

    if (register.containsKey(eventName)) return entry = register[eventName];

    final EventItem<dynamic> _entry = (EventManager.definitions.containsKey(eventName)
        ? EventManager.definitions[eventName]
        : EventManager.definitions['default']).clone();
    register[eventName] = _entry;

    _entry.init(_entry, this); // reentry code
    _entry.name = _entry.data.name = eventName;
    _entry.data.prefix = calculatePrefix();
    return entry = _entry;
  }

  ///
  /// Returns the Storage for the event. If not exist then creates it.
  ///
  ObservableEvent<dynamic> getObservable(String eventName) => get(eventName).data;

  /*
   * True if eventName is defined in register
   * @param {String} eventName
   * @return {Boolean}

  isDefined(eventName) {
    return this.register.has(eventName);
  }
   */

  ///
  /// Returns the handlers Set for the keyEvent
  ///
  KeyItem _keyDefinition(String keyEvent) =>
      keyRegister.containsKey(keyEvent)
        ? keyRegister[keyEvent]
        : (keyRegister[keyEvent] = new KeyItem());

  ///
  /// Process the keyboard [event]
  ///
  void _keyHandler(KeyboardEvent event, Map<String, dynamic> context) {
    if (event.repeat) return;

    // Build keyEvent
    String keyEvent = <String>['Alt', 'Control', 'Shift'].fold('', (String acc, String key) =>
        event.getModifierState(key)
            ? '$acc${acc.isNotEmpty ? '+' : ''}$key'
            : acc
    ).replaceAll('Control', 'ctrl').toLowerCase();

    final String combo = keyEvent;
    final String key = _normalize(event.key, event.keyCode);
    keyEvent = '$keyEvent${keyEvent.isNotEmpty ? '+' : ''}$key:${event.type}'.toLowerCase();

    final ExtKeyboardEvent response = new ExtKeyboardEvent(
        combo: combo.toLowerCase(),
        key: key.toLowerCase(),
        event: event.type,
        keyboardEvent: event
    );

    if (keyRegister.containsKey(keyEvent)) {
      final KeyItem item = keyRegister[keyEvent];
      if (item.linkers != null) {
        item.linkers.forEach((Function handler) => handler(response));
      }
      if (item.observers != null) {
//        new Future<void>(() =>
//            item.observers.forEach((Function handler) => handler(response)));
        item.observers.forEach((Function handler) =>
          new Future<void>(() => handler(response)));
      }
    }
  }

  /// Look for a key replacement
  String _normalize(String key, int code) {
    final String normal = keyNormalizer[code] ??= keyNormalizer[key];
    return normal ?? key;
  }

  ///
  /// Subscription to the event.
  ///   eventName == 'click', ...
  ///   handler is the code to execute on event fire.
  ///   if (handler == null), only forces event definition
  ///   options:
  ///     link == true, synchronous dispatch
  ///     me == calling component, for unsubscribeMe
  ///
  void on(String eventName, Function handler, { bool link: false, HtmlElement me}) {
    final ObservableEvent<Event> data = getObservable(eventName);
    if (handler != null) {
      link ? data.link(handler) : data.observe(handler);
      if (me != null)
        storeHandler(me, eventName, handler, isLink: link);
    }
  }

  /*
   * Send a custom event on value change
   *
   * options
   *  custom: true/false
   *  to: objetive to trigger the message
   *
   * @param {String} eventName
   * @param {*} target
   * @param {String} channel
   * @param {Object} options
   * @return {EventManager}
  onChangeFireMessage(eventName, target, channel, options = {}) {
    const item = this._assureRegisterDefinition(eventName, options);
    const itemFireMessage = item.fireMessage || (item.fireMessage = new Set());
    if (!itemFireMessage.has(channel)) {
      itemFireMessage.add(channel);
      item.data.onChangeFireMessage(target, channel, options.to);
    }
    return this;
  }
   */

  ///
  /// Set attribute on event change
  /// Assure don't repeat.
  /// By default [target] is the component. [attributeType] could be 'true-false' or similar.
  ///
  void onChangeReflectToAttribute(String eventName,
      {String attributeName, HtmlElement target, String attributeType, bool init = false}) {
    attributeName ??= eventName;
    final EventItem<dynamic> item = get(eventName);

    if (!item.hasAttributeReflected(attributeName)) {
      item.data.onChangeReflectToAttribute(target ?? this.target,
          attribute: attributeName,
          type: attributeType,
          init: init);
    }
  }

  ///
  /// Set Class on Event
  /// By default [target] is the component
  ///
  void onChangeReflectToClass(String eventName, {String className, HtmlElement target}) {
    className ??= eventName;
    final EventItem<dynamic> item = get(eventName);

    if (!item.hasClassReflected(className)) {
      item.data.onChangeReflectToClass(target ?? this.target, className);
    }
  }

  ///
  /// Copy from event
  ///
  void onChangeReflectToEvent(String eventName, String target) {
    final ObservableEvent<dynamic> item = getObservable(eventName);
    final ObservableEvent<dynamic> reflected = getObservable(target);
    item.link((dynamic value, Map<String, dynamic> context) {
      reflected.context['event'] = context['event'];
      reflected.update(value);
    });
  }

  ///
  /// Manages key [events] such as:
  ///   'alt+ctrl+shift+enter:keydown'
  ///   'space enter'
  /// Must keep strictly the order (alt, ctrl, shift).
  /// Prefer ':keydown' or ':keyup' to ':keypress' (default)
  ///
  void onKey(String events, Function handler, {bool link = false}) {
    events.trim().split(' ')..forEach((String eventName) {
      if (eventName.isNotEmpty) {
        _onKeySingle(eventName, handler, link: link);
      }
    });
  }

  ///
  /// Manages a single key event definition [eventName] ='enter:keydown'
  ///
  void _onKeySingle(String eventName, Function handler, {bool link = false}) {
    final List<String> parts = eventName.split(':');
    final String keys = parts.first;
    final String event = (parts.length > 1) ?  parts[1] : 'keypress';
    final String _eventName = '$keys:$event'.toLowerCase();

    // save user key handler
    _keyDefinition(_eventName).add(handler, link: link);

    // Subscribe general event
    final EventItem<Event> registerItem = get(event);
    if (!registerItem.key) {
      registerItem.key = true;
      onLink(event, _keyHandler);
    }
  }

  ///
  /// on specialized for link subscription
  ///
  void onLink(String eventName, Function handler) => on(eventName, handler, link: true);

  ///
  /// Cache information for further component unsubscribe to global events
  ///
  void storeHandler(HtmlElement me, String eventName, Function handler, {bool isLink = false}) {
    (handlersRegister.containsKey(me)
        ? handlersRegister[me]
        : handlersRegister[me] = <HandlersRegisterItem>[])
      ..add(new HandlersRegisterItem(eventName: eventName, handler: handler, isLink: isLink ));
  }

  ///
  /// After on(...), subscribe the events to the target. Supports multiple calls
  ///
  void subscribe() {
    register.forEach((String eventName, EventItem<dynamic> item) {
      if (item.data != null
          && item.handler != null
          && item.listener == null
          && item.switchSubscriber == null) {
        item.listener = (Event event) => item.handler(item, event);
        target.addEventListener(eventName, item.listener);
      }
    });
  }

  ///
  /// Subscribe only the eventName
  ///
  void subscribeSwitch(String eventName) {
    final EventItem<dynamic> item = register[eventName];
    if (item == null || item.switchSubscriber == null) return;

    item.switchListener = (Event event) => item.handler(item, event);
    target.addEventListener(eventName, item.switchListener);
  }

  ///
  /// Remove all target event listeners
  ///
  void unsubscribe() {
    register.forEach((String eventName, EventItem<dynamic> item) {
      if (item.listener != null) {
        target.removeEventListener(eventName, item.listener);
        item.listener = null;
      }
    });
  }

  ///
  /// Unsubscribe the component (me) in global events or partial in parents
  /// if name != null, only unsubscribe to this event
  ///
  void unsubscribeMe(HtmlElement me, [String name]) {
    if (!handlersRegister.containsKey(me)) return;

    final List<HandlersRegisterItem> register = handlersRegister[me]
        ..removeWhere((HandlersRegisterItem item) {
            if (name == null || name == item.eventName) {
                getObservable(item.eventName).unsubscribe(item.handler, isLink: item.isLink);
                return true;
            }
            return false; // to remove item
          });

    if (register.isEmpty) handlersRegister.remove(me);
  }

  ///
  /// Unsubscribe only eventName
  ///
  void unsubscribeSwitch(String eventName) {
    final EventItem<dynamic> item = register[eventName];
    if (item == null || item.switchListener == null) return;

    target.removeEventListener(eventName, item.switchListener);
    item.switchListener = null;
  }

  ///
  /// Make the eventName visible to the targets context
  /// ex. visibleTo('mouseup', ['trackEnd']) => in trackEnd context['mouseup'] == observable
  ///
  void visibleTo(String eventName, List<String> targets) {
    if (targets == null) return;

    final ObservableEvent<dynamic> item = getObservable(eventName);
    targets.forEach((String target) {
      get(target).data.context[eventName] = item;
    });
  }

// --------------------------------------------------- Static

  ///
  static Map<String, EventItem<dynamic>> definitions = <String, EventItem<dynamic>>{}
    ..['default'] = new EventItem<Event>(
        init: (EventItem<Event> item, EventManager evm) {
          item.data = new ObservableEvent<Event>('')..setType(TYPE_EVENT);
        },
        handler: (EventItem<Event> item, Event e) { item.data.update(e); }
    )
    ..['blur'] = new EventItem<Event>(
        init: (EventItem<Event> item, EventManager evm) {
          item.data = new ObservableEvent<Event>('blur')..setType(TYPE_EVENT);
        },
        handler: (EventItem<Event> item, Event e) { item.data.update(e); }
    )
    ..['click'] = new EventItem<Event>(
        init: (EventItem<Event> item, EventManager evm) {
          item.data = new ObservableEvent<Event>('click')..setType(TYPE_EVENT);
        },
        handler: (EventItem<Event> item, Event e) {
          EventExpando.addCaptured(e, e.currentTarget);
          item.data.update(e);
        }
    )
    ..['down'] = new EventItem<Event>(
        init: (EventItem<Event> item, EventManager evm) {
          item.data = new ObservableEvent<Event>('down')..setType(TYPE_EVENT);

          evm.onLink('mousedown', (Event event, Map<String, dynamic> context) {
            item.data.update(event);
          });
        },
        handler: null
    )
    ..['focus'] = new EventItem<Event>(
        init: (EventItem<Event> item, EventManager evm) {
          item.data = new ObservableEvent<Event>('focus')..setType(TYPE_EVENT);
        },
        handler: (EventItem<Event> item, Event e) { item.data.update(e); }
    )
    ..['focused'] = new EventItem<bool>(
        init: (EventItem<bool> item, EventManager evm) {
          item.data = new ObservableEvent<bool>('focused')
            ..setType(TYPE_BOOL, useTransformer: false);
          item.data.context['event'] = null;

          evm
            ..onLink('focus', (Event event, Map<String, dynamic> context) {
              item.data.context['event'] = event;
              item.data.update(true);
            })
            ..onLink('blur', (Event event, Map<String, dynamic> context) {
              item.data.context['event'] = event;
              item.data.update(false);
            });
        },
        handler: null
    )
    ..['keydown'] = new EventItem<Event>(
        init: (EventItem<Event> item, EventManager evm) {
          item.data = new ObservableEvent<Event>('keydown')..setType(TYPE_EVENT);
        },
        handler: (EventItem<Event> item, Event e) { item.data.update(e); }
    )
    ..['keypress'] = new EventItem<Event>(
        init: (EventItem<Event> item, EventManager evm) {
          item.data = new ObservableEvent<Event>('keypress')..setType(TYPE_EVENT);
        },
        handler: (EventItem<Event> item, Event e) { item.data.update(e); }
    )
    ..['keyup'] = new EventItem<Event>(
        init: (EventItem<Event> item, EventManager evm) {
          item.data = new ObservableEvent<Event>('keyup')..setType(TYPE_EVENT);
        },
        handler: (EventItem<Event> item, Event e) { item.data.update(e); }
    )
    ..['mousedown'] = new EventItem<Event>(
        init: (EventItem<Event> item, EventManager evm) {
          item.data = new ObservableEvent<Event>('mousedown')..setType(TYPE_EVENT);
        },
        handler: (EventItem<Event> item, Event e) { item.data.update(e); }
    )
    // true if mouse button is pressed
    ..['mousehold'] = new EventItem<bool>(
        init: (EventItem<bool> item, EventManager evm) {
          item.data = new ObservableEvent<bool>('mousehold')
              ..setType(TYPE_BOOL, useTransformer: false);
          item.data.context['event'] = null;

          evm
            ..onLink('mousedown', (Event event, Map<String, dynamic> context) {
              item.data.context['event'] = event;
              item.data.update(true);
            })
            ..onLink('mouseup', (Event event, Map<String, dynamic> context) {
              item.data.context['event'] = event;
              item.data.update(false);
            });
        },
        handler: null
    )
    ..['mousemove'] = new EventItem<Event>(
        init:  (EventItem<Event> item, EventManager evm) {
          item.data = new ObservableEvent<Event>('mousemove')..setType(TYPE_EVENT);
        },
        handler: (EventItem<Event> item, Event e) { item.data.update(e); },
        switchSubscriber: true
    )
    ..['mouseup'] = new EventItem<Event>(
        init: (EventItem<Event> item, EventManager evm) {
          item.data = new ObservableEvent<Event>('mouseup')..setType(TYPE_EVENT);
        },
        handler: (EventItem<Event> item, Event e) { item.data.update(e); }
    )
    // True if the element is currently being pressed by a "pointer," which is loosely
    // defined as mouse or touch input (but specifically excluding keyboard input).
    ..['pointerDown'] = new EventItem<bool>(
        init: (EventItem<bool> item, EventManager evm) {
          item.data = new ObservableEvent<bool>('pointerDown')
              ..setType(TYPE_BOOL, useTransformer: false);
          item.data.context['event'] = null;

          evm.onLink('mousehold', (bool value, Map<String, dynamic> context) {
            item.data.context['event'] = context['event'];
            item.data.update(value);
          });
        },
        handler: null
    )
    // If true, the user is currently holding down the button (mouse down or spaceKey).
    ..['pressed'] = new EventItem<bool>(
        init: (EventItem<bool> item, EventManager evm) {
          item.data = new ObservableEvent<bool>('pressed')
            ..setType(TYPE_BOOL, useTransformer: false);
          final Map<String, dynamic> idcontext = item.data.context;
          idcontext['event'] = null;

          evm
            ..onLink('blur', (Event event, Map<String, dynamic> context) {
              idcontext['event'] = event;
              item.data.update(false);
            })
            ..onLink('mousehold', (bool value, Map<String, dynamic> context) {
              idcontext['event'] = context['event'];
              item.data.update(value);
            })
            ..onKey('space:keydown', (ExtKeyboardEvent event) {
              idcontext['event'] = event.keyboardEvent
                  ..preventDefault()
                  ..stopImmediatePropagation();
              item.data.update(true);
            }, link: true)
            ..onKey('space:keyup', (ExtKeyboardEvent event) {
              idcontext['event'] = event.keyboardEvent;
              item.data.update(false);
            }, link: true);
        },
        handler: null
    )
    // True if the input device that caused the element to receive focus was a keyboard.
    ..['receivedFocusFromKeyboard'] = new EventItem<bool>(
        init: (EventItem<bool> item, EventManager evm) {
          item.data = new ObservableEvent<bool>('receivedFocusFromKeyboard')
            ..setType(TYPE_BOOL, useTransformer: false);
          final Map<String, dynamic> idcontext = item.data.context;
          idcontext['event'] = null;
          idcontext['focused'] = false;
          idcontext['isLastEventPointer'] = false;
          idcontext['pointerDown'] = false;

          evm
            ..onLink('focused', (bool value, Map<String, dynamic> context) {
              idcontext['focused'] = value;
              idcontext['event'] = context['event'];
              idcontext['isLastEventPointer'] = false;
              item.data.update(!idcontext['pointerDown'] && idcontext['focused']);
            })
            ..onLink('pointerDown', (bool value, Map<String, dynamic> context) {
              idcontext['event'] = context['event'];
              idcontext['isLastEventPointer'] = true;
              idcontext['pointerDown'] = value;
              item.data.update(!idcontext['pointerDown'] && idcontext['focused']);
            });
        },
        handler: null
    )
    ..['tap'] = new EventItem<Event>(
        init: (EventItem<Event> item, EventManager evm) {
          item.data = new ObservableEvent<Event>('tap')..setType(TYPE_EVENT);

          evm.onLink('click', (Event event, Map<String, dynamic> context) { // TODO: other touchs
            item.data.update(event);
          });
        },
        handler: null
    )
    ..['up'] = new EventItem<Event>(
        init: (EventItem<Event> item, EventManager evm) {
          item.data = new ObservableEvent<Event>('up')..setType(TYPE_EVENT);

          evm.onLink('mouseup', (Event event, Map<String, dynamic> context) {
            item.data.update(event);
          });
        },
        handler: null
    );

  /// Table for key code change. <Number|String, String>
  /// Order: first numeric, then text
  static Map<dynamic, String> keyNormalizer = <dynamic, String>{
    10: 'Enter',
    ' ': 'Space',
    '↵': 'Enter',
    'ArrowLeft': 'left',
    'ArrowRight': 'right',
    'ArrowUp': 'up',
    'ArrowDown': 'down'
  };

  /// EventManager associated to document
  static EventManager get documentEvm => _documentEvm ??= new EventManager(document.documentElement);
  static EventManager _documentEvm;

  /// EventManager associated to window
  static EventManager get windowEvm => _windowEvm ??= new EventManager(window)..prefix = 'window';
  static EventManager _windowEvm;
}

// --------------------------------------------------- Aux Classes

///
/// Extended Keyboard Event, for onKey handlers
///
class ExtKeyboardEvent {
  /// alt+ctrl+shift modifiers
  String combo;
  /// char
  String key;
  /// original KeyboardEvent
  KeyboardEvent keyboardEvent;
  /// KeyboardEvent.type, such as keydown, keyup, keypress
  String event;

  /// Constructor
  ExtKeyboardEvent({
    String this.combo,
    String this.key,
    KeyboardEvent this.keyboardEvent,
    String this.event
  });
}

///
/// Associated properties for events
///
class EventExpando {
  /// List of components/elements who are captured the event. First is older.
  static Expando<List<HtmlElement>> captured = new Expando<List<HtmlElement>>('captured');

  ///
  /// add an [element] to captured list for that [event]
  ///
  static void addCaptured(Event event, HtmlElement element) =>
      (captured[event] ??= <HtmlElement>[]).add(element);

  ///
  /// Returns the list of captured elements for that [event]
  ///
  static List<HtmlElement> getCaptured(Event event) => captured[event];
}

///
/// Event definition
///
class EventItem<T> {
  /// Observable
  ObservableEvent<T> data;

  /// event function. handler(item, event)
  Function handler;

  /// Function to create data. init(item, eventManager)
  Function init;

  /// If it is a key handler (keypress, keydown, ...). true/false
  bool key = false;

  /// handler used for addEventListener. Used also for unsubscribe
  Function listener;

  /// eventName, used for entry cache
  String name;

  /// Attribute to modify on event change
  List<String> reflectToAttribute;

  /// css classes to modify on event change
  List<String> reflectToClass;

  /// As listener, but only for switch subscription
  Function switchListener;

  /// null/true, subscribe/unsubscribe specific to this event (mousemove)
  bool switchSubscriber;


  /// Constructor
  EventItem({
      ObservableEvent<T> this.data,
      Function this.handler,
      Function this.init,
//      bool this.key,
//      Function this.listener,
      bool this.switchSubscriber
  });

  ///
  EventItem<T> clone() => new EventItem<T>(
      data: data,
      handler: handler,
      init: init,
//      key: key,
      switchSubscriber: switchSubscriber
  );

  ///
  /// True if attributeName previously used
  ///
  bool hasAttributeReflected(String attributeName) => (reflectToAttribute ??= <String>[]).contains(attributeName)
      ? true
      : (reflectToAttribute..add(attributeName)) == null; // false

  ///
  /// True if className previously used
  ///
  bool hasClassReflected(String className) => (reflectToClass ??= <String>[]).contains(className)
      ? true
      : (reflectToClass..add(className)) == null; // false

}

///
/// Each item in the handlersRegister
///
class HandlersRegisterItem {
  ///
  String eventName;
  ///
  Function handler;
  ///
  bool isLink;

  /// Constructor
  HandlersRegisterItem({
    String this.eventName,
    Function this.handler,
    bool this.isLink
  });
}

///
/// For each keyEventName ('enter:keydown') the subscribers/linkers handlers list
///
class KeyItem {
  /// Sync handlers list
  List<Function> linkers;

  /// Async handlers list
  List<Function> observers;

  /// Constructor
  KeyItem();

  ///
  /// add a handler to linkers/subscribers according to [link]
  ///
  void add(Function handler, {bool link = false}) {
    if (link) {
      (linkers ??= <Function>[]).add(handler);
    } else {
      (observers ??= <Function>[]).add(handler);
    }
  }
}
