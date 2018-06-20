// @copyright @polymer\paper-button\paper-button.js
// @copyright 2017-2018 adalberto.lacruz@gmail.com

import '../src/core_library.dart';

///
/// Definition for alg-paper-button component.
///
/// property vars:
///   --paper-button-ink-color
///
/// Custom cssMixins:
///   --paper-button
///   --paper-button-disabled
///   --paper-button-flat-keyboard-focus
///   --paper-button-raised-keyboard-focus
///
/// Event handlers:
///   on-click
///   on-change (toggles)
///
class AlgPaperButton extends AlgPaperButtonBehavior {
  ///
  static String tag = 'alg-paper-button';

  ///
  factory AlgPaperButton() => new Element.tag(tag);

  ///
  AlgPaperButton.created() : super.created();

  ///
  static void register() {
    AlgComponent.register('alg-paper-ripple', AlgPaperRipple);
    AlgComponent.register(tag, AlgPaperButton);
  }

  @override
  TemplateElement createTemplateStyle(RulesInstance css) => new TemplateElement()..setInnerHtml('''
  <style>
    ${css.use('paper-material-styles')}
    :host {
      ${css.use('--layout-inline')}
      ${css.use('--layout-center-center')}
      position: relative;
      box-sizing: border-box;
      min-width: 5.14em;
      margin: 0 0.29em;
      background: transparent;
      -webkit-tap-highlight-color: rgba(0, 0, 0, 0);
      -webkit-tap-highlight-color: transparent;
      font: inherit;
      text-transform: uppercase;
      outline-width: 0;
      border-radius: 3px;
      -moz-user-select: none;
      -ms-user-select: none;
      -webkit-user-select: none;
      user-select: none;
      cursor: pointer;
      z-index: 0;
      padding: 0.7em 0.57em;

      ${css.use('--paper-font-common-base')}
      ${css.apply('--paper-button')}
    }

    :host([elevation="1"]) {
      ${css.use('--paper-material-elevation-1')}
    }

    :host([elevation="2"]) {
      ${css.use('--paper-material-elevation-2')}
    }

    :host([elevation="3"]) {
      ${css.use('--paper-material-elevation-3')}
    }

    :host([elevation="4"]) {
      ${css.use('--paper-material-elevation-4')}
    }

    :host([elevation="5"]) {
      ${css.use('--paper-material-elevation-5')}
    }

    :host([hidden]) {
      display: none !important;
    }

    :host([raised].keyboard-focus) {
      font-weight: bold;
      ${css.apply('--paper-button-raised-keyboard-focus')}
    }

    :host(:not([raised]).keyboard-focus) {
      font-weight: bold;
      ${css.apply('--paper-button-flat-keyboard-focus')}
    }

    :host([disabled]) {
      background: #eaeaea;
      color: #a8a8a8;
      cursor: auto;
      pointer-events: none;
      ${css.apply('--paper-button-disabled')}
    }

    :host([animated]) {
      ${css.use('--shadow-transition')}
    }

    paper-ripple {
      color: var(--paper-button-ink-color);
    }
  </style>''', treeSanitizer: NodeTreeSanitizer.trusted);

  @override
  TemplateElement createTemplate() => super.createTemplate()..setInnerHtml('''
  <slot></slot>
  ''', treeSanitizer: NodeTreeSanitizer.trusted);

  @override
  void deferredConstructor() {
    super.deferredConstructor();

    attributeManager
      // If true, the button should be styled with a shadow.
      ..define('raised', type: TYPE_BOOL, isLocal: true)
      ..on(calculateElevation)
      ..store((ObservableEvent<bool> entry$) => raised$ = entry$);
  }

  ///
  ObservableEvent<bool> raised$;

  /// Attributes managed by the component.
  @override
  List<String> observedAttributes() => super.observedAttributes()
      + <String>['raised'];

  ///
  /// Calculate the item shadow
  ///
  @override
  void calculateElevation(_) {
    if (!raised$.value) {
      elevation$.update(0);
    } else {
      super.calculateElevation(null);
    }
  }
}
