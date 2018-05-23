// @copyright @polymer\paper-behaviors\paper-button-behavior.js
// @copyright 2017-2018 adalberto.lacruz@gmail.com

part of core.alg_components;

///
/// Definition for alg-paper-button-behavior
///
/// Event handlers
///  on-click
///  on-change (toggles)
///  on-action (pressed = click or space)
///
class AlgPaperButtonBehavior
      extends AlgComponent
      with AlgIronButtonStateMixin, AlgPaperRippleMixin, AlgActionMixin {
  ///
  AlgPaperButtonBehavior.created() : super.created() {
    mixinManager = new MixinManager();

    algIronButtonStateInit(this);
    algPaperRippleInit(this);
    algActionInit(this);
  }

  @override
  String role = 'button';

  @override
  void deferredConstructor() {
    super.deferredConstructor();

    attributeManager
      ..onChange('active', calculateElevation)
      
      ..onChange('disabled', calculateElevation)
      
      ..define('elevation', type: TYPE_NUM, value: 0)
      ..reflect();

    eventManager
      ..on('focused', calculateElevation)

      // If true, the user is currently holding down the button
      ..on('pressed', calculateElevation)

      // True if the input device that caused the element to receive focus was a keyboard.
      ..on('receivedFocusFromKeyboard', calculateElevation)
      ..onChangeReflectToClass('receivedFocusFromKeyboard', className: 'keyboard-focus')
      ..subscribe();

//    active$ = attributeManager.get('active');
    disabled$ = attributeManager.get('disabled');
    elevation$ = attributeManager.get('elevation');
    pressed$ = eventManager.getObservable('pressed');
    receivedFocusFromKeyboard$ = eventManager.getObservable('receivedFocusFromKeyboard');
  }

  //
//  ObservableEvent<bool> active$;
  ///
  ObservableEvent<bool> disabled$;
  ///
  ObservableEvent<num>  elevation$;
  ///
  ObservableEvent<bool> pressed$;
  ///
  ObservableEvent<bool> receivedFocusFromKeyboard$;

  @override
  List<String> observedAttributes() => super.observedAttributes()
    ..addAll(<String>['on-click']);

  ///
  /// check for animated and add them if not defined
  ///
  @override
  void addStandardAttributes() {
    super.addStandardAttributes();

    if (!attributes.containsKey('animated')) {
      setAttribute('animated', '');
    }
  }

  ///
  /// Calculate the item shadow
  ///
  void calculateElevation(_) {
    int _elevation = 1;

    if (disabled$.value) {
      _elevation = 0;
    } else if (active$.value || pressed$.value) {
      _elevation = 4;
    } else if (receivedFocusFromKeyboard$.value) {
      _elevation = 3;
    }

    elevation$.update(_elevation);
  }
}
