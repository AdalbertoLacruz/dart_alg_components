// @copyright 2017-2018 adalberto.lacruz@gmail.com

part of core.alg_components;

///
/// To simulate some inheritance in mixins
///
class MixinManager {
  ///
  List<Function> get deferredConstructor => _deferredConstructor ??= <Function>[];
  List<Function> _deferredConstructor;

  ///
  List<Function> get observedAttributes => _observedAttributes ??= <Function>[];
  List<Function> _observedAttributes;

  /// run each mixin deferredConstructor handler
  void deferredConstructorRun() => _deferredConstructor != null ? run(_deferredConstructor) : null;

  /// run the handlers
  void run(List<Function> handlers) {
    handlers.forEach((Function handler) => handler());
  }

  ///
  /// Compose the observedAttributes List from mixins
  ///
  List<String> observedAttributesRun() {
    final List<String> result = <String>[];

    if (_observedAttributes != null) {
      _observedAttributes.forEach((Function handler) {
        result.addAll(handler());
      });
    }
    return result;
  }
}
