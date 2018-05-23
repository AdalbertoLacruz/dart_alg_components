// @copyright @polymer\paper-fab\paper-fab.js
// @copyright 2017-2018 adalberto.lacruz@gmail.com

import '../src/core_library.dart';

///
/// Similar to alg-paper-button, except raised.
/// supports: icon, src, label, mini (only affects css)
///
class AlgPaperFab extends AlgPaperButtonBehavior {
  ///
  static String tag = 'alg-paper-fab';

  ///
  factory AlgPaperFab() => new Element.tag(tag);

  ///
  AlgPaperFab.created() : super.created();

  ///
  static void register() => AlgComponent.register(tag, AlgPaperFab);

  @override
  TemplateElement createTemplateStyle(RulesInstance css) => new TemplateElement()..setInnerHtml('''
    <style>
        ${css.use('paper-material-styles')}
        :host {
          ${css.use('--layout-vertical')}
          ${css.use('--layout-center-center')}

          background: var(--paper-fab-background, var(--accent-color));
          border-radius: 50%;
          box-sizing: border-box;
          color: var(--text-primary-color);
          cursor: pointer;
          height: 56px;
          min-width: 0;
          outline: none;
          padding: 14px;
          position: relative;
          -moz-user-select: none;
          -ms-user-select: none;
          -webkit-user-select: none;
          user-select: none;
          width: 56px;
          z-index: 0;

          /* NOTE: Both values are needed, since some phones require the value \`transparent\`. */
          -webkit-tap-highlight-color: rgba(0,0,0,0);
          -webkit-tap-highlight-color: transparent;

          ${css.apply('--paper-fab')}
        }

        [hidden] {
          display: none !important;
        }

        :host([mini]) {
          width: 40px;
          height: 40px;
          padding: 8px;

          ${css.apply('--paper-fab-mini')}
        }

        :host([disabled]) {
          color: var(--paper-fab-disabled-text, var(--paper-grey-500));
          background: var(--paper-fab-disabled-background, var(--paper-grey-300));

          ${css.apply('--paper-fab-disabled')}
        }

        alg-iron-icon {
          ${css.apply('--paper-fab-iron-icon')}
        }

        span {
          width: 100%;
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
          text-align: center;

          ${css.apply('--paper-fab-label')}
        }

        :host(.keyboard-focus) {
          background: var(--paper-fab-keyboard-focus-background, var(--paper-pink-900));
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
      </style>''', treeSanitizer: NodeTreeSanitizer.trusted);

  // <alg-iron-icon id="icon" -hidden- -src- -icon- ></algiron-icon>
  // <span id="span" -hidden- > -label- </span>
  @override
  TemplateElement createTemplate() => super.createTemplate()..setInnerHtml('''
    <alg-iron-icon id="icon" hidden></alg-iron-icon>
    <span id="span" hidden></span>
    ''', treeSanitizer: NodeTreeSanitizer.trusted);

  @override
  void deferredConstructor() {
    super.deferredConstructor();

    attributeManager
      ..define('aria-label', type: TYPE_STRING)
      ..reflect()

      // Specifies the icon name or index in the set of icons available in
      // the icon's icon set. If the icon property is specified,
      // the src property should not be.
      ..define('icon', type: TYPE_STRING, countChanges: true)
      ..on((String value) {
        ids['icon'].setAttribute('icon', value);
        _computeIsIconFab();
      })


      // The label displayed in the badge. The label is centered, and ideally
      // should have very few characters.
      ..define('label', type: TYPE_STRING, countChanges: true)
      ..onChangeModify('aria-label')
      ..on((String value) {
        ids['span'].setInnerHtml(value);
        _computeIsIconFab();
      })

      // The URL of an image for the icon. If the src property is specified,
      // the icon property should not be.
      ..define('src', type: TYPE_STRING, countChanges: true)
      ..on((String value) {
        ids['icon'].setAttribute('src', value);
        _computeIsIconFab();
      });
  }

  /// Attributes managed by the component.
  @override
  List<String> observedAttributes() => super.observedAttributes()
    + <String>['icon', 'label', 'src']; // & mini

  ///
  /// Compute hidden attribute
  ///
  void _computeIsIconFab() {
    if (!attributeManager.hasChanged('iconFab', <String>['icon', 'label', 'src'])) return;

    final bool spanHiden = attributeManager.getValue('icon') != null ||
        attributeManager.getValue('src') != null;

    AttributeManager.attributeToggle(ids['span'], 'hidden', force: spanHiden);
    AttributeManager.attributeToggle(ids['icon'], 'hidden', force: !spanHiden);
  }
}
