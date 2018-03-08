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
  /// constructor
  void algIronButtonStateConstructor(AlgComponent me) {
    this.me = me;

    me.attributeManager
        ..define('active', type: TYPE_BOOL) // updated by tap
        ..reflect()
        ..on(_activeChanged)

        ..define('toggles', type: TYPE_BOOL)
        ..reflect()
        ..on(_activeChanged);

    me.eventManager
        ..onChangeReflectToAttribute('pressed')

        ..on('tap', _tapHandler)

        ..onKey('enter:keydown space:keyup', _tapHandler)
        ..subscribe();

    me.messageManager
        ..define('change', toAttribute: 'active'); // message: true/false
  }

  ///
  AlgComponent me;

  /// attributes managed by mixin
  List<String> algIronButtonStateObservedAttributes() => <String>['toggles', 'on-change'];

  ///
  /// aria-pressed attribute
  ///
  void _activeChanged(_) {
    final bool active = me.attributeManager.getValue('active');
    final bool toggles = me.attributeManager.getValue('toggles');

    if (toggles) {
      FHtml.attributeToggle(me, 'aria-pressed', force: active, type: 'true-false');
    } else {
      me.attributes.remove('aria-pressed');
    }
  }

  ///
  /// Response to a click event or enter key
  ///
  void _tapHandler(_) {
    if (me.attributes.containsKey('frozen'))
        return;

    final ObservableEvent<bool> active = me.attributeManager.get('active');
    final ObservableEvent<bool> toggles = me.attributeManager.get('toggles');

    if (toggles.value) {
      active.toggle();
    } else {
      active.update(false);
    }
  }
}
