// @copyright @polymer\paper-icon-button\paper-icon-button.js
// @copyright 2017-2018 adalberto.lacruz@gmail.com

import '../src/core_library.dart';

///
/// alg-paper-icon-button is a button with an image placed at the center.
/// When the user touches the button, a ripple effect emanates from the center of the button.
///
/// property vars:
///   --paper-icon-button-ink-color
///   --paper-icon-button-disabled-text
///
/// Custom cssMixins:
///   --paper-icon-button
///   --paper-icon-button-disabled
///   --paper-icon-button-hover
///
/// Fires
///   on-change
///
class AlgPaperIconButton
    extends AlgIronIconBehavior
    with AlgIronButtonStateMixin, AlgPaperRippleMixin, AlgPaperInkyFocusMixin, AlgActionMixin {
  ///
  static String tag = 'alg-paper-icon-button';

  ///
  factory AlgPaperIconButton() => new Element.tag(tag);

  ///
  AlgPaperIconButton.created() : super.created() {
    mixinManager = new MixinManager();

    algIronButtonStateInit(this);
    algPaperRippleInit(this);
    algPaperInkyFocusInit(this);
    algActionInit(this);
  }

  ///
  static void register() => AlgComponent.register(tag, AlgPaperIconButton);

  @override
  TemplateElement createTemplateStyle(RulesInstance css) => new TemplateElement()..setInnerHtml('''
    <style>
      :host {
        display: inline-block;
        position: relative;
        padding: 8px;
        outline: none;
        -webkit-user-select: none;
        -moz-user-select: none;
        -ms-user-select: none;
        user-select: none;
        cursor: pointer;
        z-index: 0;
        line-height: 1;

        width: 40px;
        height: 40px;

        fill: var(--iron-icon-fill-color, currentcolor);
        stroke: var(--iron-icon-stroke-color, none);

        /* NOTE: Both values are needed, since some phones require the value to be \`transparent\`. */
        -webkit-tap-highlight-color: rgba(0, 0, 0, 0);
        -webkit-tap-highlight-color: transparent;

        /* Because of polymer/2558, this style has lower specificity than * */
        box-sizing: border-box !important;

        ${css.apply('--paper-icon-button')}
      }

      :host #ink {
        color: var(--paper-icon-button-ink-color, var(--primary-text-color));
        opacity: 0.6;
      }

      :host([disabled]) {
        color: var(--paper-icon-button-disabled-text, var(--disabled-text-color));
        pointer-events: none;
        cursor: auto;

        ${css.apply('--paper-icon-button-disabled')}
      }

      :host([hidden]) {
        display: none;
      }

      :host(:hover) {
        ${css.apply('--paper-icon-button-hover')}
      }
      </style>''', treeSanitizer: NodeTreeSanitizer.trusted);

  @override
  String role = 'button';

  @override
  void deferredConstructor() {
    super.deferredConstructor();

    attributeManager
      // Specifies the alternate text for the button, for accessibility.
      ..define('alt', type: TYPE_STRING)
      ..on((String value) {
        final String label = getAttribute('aria-label');

        // Don't stamp over a user-set aria-label.
        if (label == null || value != label) {
          setAttribute('aria-label', value);
        }
      });
  }

  /// Attributes managed by the component.
  @override
  List<String> observedAttributes() => super.observedAttributes()
      + <String>['alt'];
}
