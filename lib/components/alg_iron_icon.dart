// @copyright @polymer\iron-icon\iron-icon.js
// @copyright 2017-2018 adalberto.lacruz@gmail.com

import '../src/core_library.dart';

///
class AlgIronIcon extends AlgIronIconBehavior {
  ///
  static String tag = 'alg-iron-icon';

  ///
  factory AlgIronIcon() => new Element.tag(tag);

  ///
  AlgIronIcon.created() : super.created();

  ///
  static void register() => AlgComponent.register(tag, AlgIronIcon);

  @override
  TemplateElement createTemplateStyle(RulesInstance css) => new TemplateElement()..setInnerHtml('''
    <style>
      :host {
        ${css.use('--layout-inline')}
        ${css.use('--layout-center-center')}
        position: relative;

        vertical-align: middle;

        fill: var(--iron-icon-fill-color, currentcolor);
        stroke: var(--iron-icon-stroke-color, none);

        width: var(--iron-icon-width, 24px);
        height: var(--iron-icon-height, 24px);

        ${css.apply('--iron-icon')}
      }
      :host([hidden]) {
        display: none;
      }

    </style>''', treeSanitizer: NodeTreeSanitizer.trusted);

  ///
  @override
  void addStandardAttributes() { }
}
