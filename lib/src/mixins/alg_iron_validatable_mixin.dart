// @copyright @polymer\iron-validatable-behavior\iron-validatable-behavior.js
// @copyright 2017-2018 adalberto.lacruz@gmail.com

part of core.alg_components;

///
/// Validator behavior
///
class AlgIronValidatableMixin {
  ///
  AlgComponent me;

  ///
  void algIronValidatableInit(AlgComponent me) {
    this.me = me;
    me.mixinManager
      ..deferredConstructor.add(algIronValidatableConstructor)
      ..observedAttributes.add(algIronValidatableObservedAttributes);
  }

  /// constructor
  void algIronValidatableConstructor() {
    me.attributeManager
      ..define('aria-invalid', type: TYPE_BOOL)
      ..reflect(type: 'true-remove')

      // True if the last call to `validate` is invalid
      ..define('invalid', type: TYPE_BOOL)
      ..reflect()
      ..onChangeModify('aria-invalid')
      ..store((ObservableEvent<bool> entry$) => invalid$ = entry$)

      // Name of the validator to use
      ..define('validator', type: TYPE_STRING)
      ..store((ObservableEvent<String> entry$) => validator$ = entry$);
  }

  /// attributes managed by mixin
  List<String> algIronValidatableObservedAttributes() => <String>['validator'];

  ///
  ObservableEvent<bool> invalid$;

  /// validator to use
  ObservableEvent<String> validator$;

  /// Recompute this every time it's needed, because we don't know if the `validator` has changed
  Function get validator => ValidatorManager.getValidator(validator$.value);

  ///
  /// True if [value] is valid. Could be overrided
  ///
  bool getValidity(dynamic value) => hasValidator() ? validator(value) : true;

  ///
  /// True if the validator defined by attribute exist.
  ///
  bool hasValidator() => validator != null;

  ///
  /// True if [value] is valid. Don't override
  ///
  bool validate(dynamic value) {
    // If this is an element that also has a value property, and there was
    // no explicit value argument passed, use the element's property instead.
    final bool invalid = (value == null && me.nodeValue != null)
        ? !getValidity(me.nodeValue)
        : !getValidity(value);

    invalid$.update(invalid);
    return !invalid;
  }
}
