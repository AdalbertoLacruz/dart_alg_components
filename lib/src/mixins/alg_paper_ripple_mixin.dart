// @copyright @polymer\paper-behaviors\paper-ripple-behavior.js
// @copyright 2017-2018 adalberto.lacruz@gmail.com

part of core.alg_components;

///
/// Mixin Behavior
///
/// Append `alg-paper-ripple` for ripple effect in component
///
/// Attribute: `noink` (add to observedAttributes)
/// Properties: .rippleContainer = HTMLElement
/// Methods: .getRipple()
///
class AlgPaperRippleMixin {
  ///
  AlgComponent me;

  ///
  void algPaperRippleInit(AlgComponent me) {
    this.me = me;

    me.mixinManager
      ..deferredConstructor.add(algPaperRippleConstructor)
      ..observedAttributes.add(algPaperRippleObservedAttributes);
  }

  /// Constructor
  void algPaperRippleConstructor() {
    rippleContainer = me.shadowRoot;

    me.attributeManager
        // If true, no ink used in ripple effect. Alias for alg-paper-ripple subscription
        ..define('noink', type: TYPE_BOOL, isLocal: true, alias: <String>['ink-noink'])
        ..reflect();

    me.eventManager
      ..define<Event>('transitionend', new ObservableEvent<Event>('transitionend')
        ..setType(TYPE_EVENT))
      ..on('down', ensureRipple) // a mouse event has x,y
      ..on('focused', ensureRipple)
      ..subscribe();

    me.messageManager
      ..from('ensure-ripple', (Event event) => ensureRipple(event));
  }

  /// attributes managed by mixin
  List<String> algPaperRippleObservedAttributes() => <String>['noink'];

  ///
  AlgPaperRipple _ripple;

  /// Where to add the ripple component
  Node rippleContainer;

  ///
  /// Create the element's ripple effect via creating a `<alg-paper-ripple>`.
  /// Override this method to customize the ripple element.
  ///
  AlgPaperRipple _createRipple() =>
      (document.createElement('alg-paper-ripple') as AlgPaperRipple)
        ..setAttribute('id', 'ink')
        ..controller = me;

  ///
  /// Ensures this element contains a ripple effect. For startup efficiency
  /// the ripple effect is created dynamically on demand when needed.
  ///
  void ensureRipple([Event event]) {
    if (!hasRipple()) {
      _ripple = _createRipple();
      if (rippleContainer != null) rippleContainer.append(_ripple);

      if (event != null) me.fireAction('ink', 'ripple-start', event);
    }
  }

  ///
  /// Returns the `<alg-paper-ripple>` element used by this element to create
  /// ripple effects. The element's ripple is created on demand, when
  /// necessary, and calling this method will force the ripple to be created.
  ///
  AlgPaperRipple getRipple() {
    ensureRipple();
    return _ripple;
  }

  ///
  /// Returns true if this element currently contains a ripple effect.
  ///
  bool hasRipple() => _ripple != null;
}
