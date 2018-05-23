// @copyright @polymer\paper-behaviors\paper-inky-focus-behavior.js
// @copyright 2017-2018 adalberto.lacruz@gmail.com

// REQUIRES: ****************
//  alg-paper-ripple-behavior
//  alg-iron-button-state
//  iron-control-state

part of core.alg_components;

///
/// Mixin Behavior
///
/// receivedFocusFromKeyboard -> ripple behavior
///
class AlgPaperInkyFocusMixin {
  ///
  AlgComponent me;

  ///
  void algPaperInkyFocusInit(AlgComponent me) {
    this.me = me;
    me.mixinManager
      ..deferredConstructor.add(algPaperInkyFocusConstructor);
  }

  /// Constructor
  void algPaperInkyFocusConstructor() {
    me.attributeManager
        // ripple child attribute
        ..define('ink-center', type: TYPE_BOOL, value: true)
        // ripple child class
        ..define('ink-classbind', type: TYPE_STRING, value: 'circle');

    me.eventManager
        // Ripple effect on keyboard focus
        ..onLink('receivedFocusFromKeyboard', (bool value, Map<String, dynamic> context) {
          if (value) me.messageManager.dispatchAction('ensure-ripple', null, isLink: true); // we need heritage

          if (me.busManager.hasActor('ink')) {
            inkHoldDown$ ??= me.busManager.import('ink', 'holdDown');
            final bool isLastEventPointer = context['isLastEventPointer'];

            if (!isLastEventPointer) { // key
              inkHoldDown$.context['event'] = context['event'];
              inkHoldDown$.update(value);
            }
          }
        });
  }

  /// ripple holdDown
  ObservableEvent<bool> inkHoldDown$;
}
