// @copyright @polymer\iron-behaviors\iron-button-state.js
// @copyright 2017-2018 adalberto.lacruz@gmail.com

part of core.alg_components;

///
/// Mixin behavior
///
/// Manages active state if present toggles attribute
/// Attribute: toggles
/// Fire: change
///
/// active ⛳(active, aria-pressed) 🔥change
/// tap, enter, space ⛳pressed -> toggles ⛳
///
class AlgIronButtonStateMixin {
  ///
  AlgComponent me;

  ///
  void algIronButtonStateInit(AlgComponent me) {
    this.me = me;

    me.mixinManager
      ..deferredConstructor.add(algIronButtonStateConstructor)
      ..observedAttributes.add(algIronButtonStateObservedAttributes);
  }

  /// constructor
  void algIronButtonStateConstructor() {
    me.attributeManager
        ..define('active', type: TYPE_BOOL) // updated by tap
        ..reflect()
        ..on(_activeChanged)

        ..define('toggles', type: TYPE_BOOL, isLocal: true)
        ..reflect()
        ..on(_activeChanged);

    active$ = me.attributeManager.get('active');
    toggles$ = me.attributeManager.get('toggles');

    me.eventManager
        ..onChangeReflectToAttribute('pressed')

        ..on('tap', _tapHandler)

        ..onKey('enter:keydown space:keyup', _tapHandler)
        ..subscribe();

    me.messageManager
        ..define('change', toAttribute: 'active'); // message: true/false
  }

  /// attributes managed by mixin
  List<String> algIronButtonStateObservedAttributes() => <String>['toggles', 'on-change'];

  ///
  ObservableEvent<bool> active$;
  ///
  ObservableEvent<bool> toggles$;

  ///
  /// aria-pressed attribute
  ///
  void _activeChanged(_) {
    if (toggles$.value) {
      AttributeManager.attributeToggle(me, 'aria-pressed', force: active$.value, type: 'true-false');
    } else {
      me.attributes.remove('aria-pressed');
    }
  }

  ///
  /// Response to a click event or enter key
  ///
  void _tapHandler(_) {
    if (me.attributes.containsKey('frozen')) return;

    if (toggles$.value) {
      active$.toggle();
    } else {
      active$.update(false);
    }
  }
}
