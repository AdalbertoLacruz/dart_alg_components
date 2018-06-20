// @copyright @polymer\iron-checked-element-behavior\iron-checked-element-behavior.js
// @copyright 2017-2018 adalberto.lacruz@gmail.com

part of core.alg_components;

///
/// Requires AlgIronValidatableMixin
///
class AlgIronCheckedElementMixin {
  ///
  AlgComponent me;

  ///
  void algIronCheckedElementInit(AlgComponent me) {
    this.me = me;
    me.mixinManager
      ..deferredConstructor.add(algIronCheckedElementConstructor)
      ..observedAttributes.add(algIronCheckedElementObservedAttributes);
  }

  /// constructor
  void algIronCheckedElementConstructor() {
    me.attributeManager
      ..define('aria-required', type: TYPE_BOOL)
      ..reflect(type: 'true-remove')

      ..define('checked', type: TYPE_BOOL)
      ..onChangeModify('active')
      ..reflect()
      ..on((bool value) {
        if (!value && me.attributes.containsKey('frozen')) me.attributes.remove('frozen');
      })
      ..store((ObservableEvent<bool> entry$) => checked$ = entry$)

      ..define('required', type: TYPE_BOOL)
      ..onChangeModify('aria-required')
      ..store((ObservableEvent<bool> entry$) => required$ = entry$)

      ..define('toggles', value: true) // yet defined else
      ..reflect()

      ..define('value', type: TYPE_STRING, value: 'on')
      ..setTransformer((String value) => value == null ? 'on' : value); // onNullSet 'on'

    me.messageManager
      ..define('change', toAttribute: 'active'); // message: true/false
  }

  /// attributes managed by mixin
  List<String> algIronCheckedElementObservedAttributes() => <String>['checked', 'on-change', 'required'];

  ///
  ObservableEvent<bool> checked$;

  ///
  ObservableEvent<bool> required$;

  ///
  String get value => me.attributeManager.getValue('value');

  ///
  /// Returns false if the element is required and not checked. True otherwise.
  /// The argument is ignored.
  ///
  bool getValidity(_) => me.disabled$.value || !required$.value || checked$.value;

}
