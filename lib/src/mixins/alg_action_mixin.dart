// @copyright 2017-2018 adalberto.lacruz@gmail.com

part of core.alg_components;

///
/// Mixin Behavior
///
/// Manages 'on-action'
///
class AlgActionMixin {
  ///
  AlgComponent me;

  ///
  void algActionInit(AlgComponent me) {
    this.me = me;
    me.mixinManager
        ..deferredConstructor.add(algActionConstructor)
        ..observedAttributes.add(algActionObservedAttributes);
  }

  /// constructor
  void algActionConstructor() {
    me.messageManager
        ..define('action', toEvent: 'pressed', letRepeat: true)
        ..trigger((bool value) => value); // on true
  }

  /// attributes managed by mixin
  List<String> algActionObservedAttributes() => <String>['on-action'];
}
