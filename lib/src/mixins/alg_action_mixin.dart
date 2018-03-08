// @copyright 2017-2018 adalberto.lacruz@gmail.com

part of core.alg_components;

///
/// Mixin Behavior
///
/// Manages 'on-action'
///
class AlgActionMixin {
  /// constructor
  void algActionConstructor(AlgComponent me) {
    me.messageManager
        ..define('action', toEvent: 'pressed', letRepeat: true)
        ..trigger((bool value) => value); // on true
  }

  /// attributes managed by mixin
  List<String> algActionObservedAttributes() => <String>['on-action'];
}
