// @copyright @polymer\iron-behaviors\demo\simple-button.js
// @copyright 2017-2018 adalberto.lacruz@gmail.com

import 'package:dart_alg_components/src/core_library.dart';

///
class SimpleButton extends AlgComponent with AlgIronButtonStateMixin {
  ///
  static String tag = 'simple-button';

  ///
  factory SimpleButton() => new Element.tag(tag);

  ///
  SimpleButton.created() : super.created();

  ///
  static void register() => AlgComponent.register(tag, SimpleButton);
  @override
  TemplateElement createTemplateStyle(RulesInstance css) => new TemplateElement()..setInnerHtml('''
    <style>
      :host {
        display: inline-block;
        background-color: #4285F4;
        color: #fff;
        min-height: 8px;
        min-width: 8px;
        padding: 16px;
        text-transform: uppercase;
        border-radius: 3px;
        -moz-user-select: none;
        -ms-user-select: none;
        -webkit-user-select: none;
        user-select: none;
        cursor: pointer;
      }

      :host([disabled]) {
        opacity: 0.3;
        pointer-events: none;
      }

      :host([active]),
      :host([pressed]) {
        background-color: #3367D6;
        box-shadow: inset 0 3px 5px rgba(0,0,0,.2);
      }

      :host([focused]) {
        box-shadow: 0 16px 24px 2px rgba(0, 0, 0, 0.14),
                    0  6px 30px 5px rgba(0, 0, 0, 0.12),
                    0  8px 10px -5px rgba(0, 0, 0, 0.4);
      }
    </style>''', treeSanitizer: NodeTreeSanitizer.trusted);

  @override
  TemplateElement createTemplate() => super.createTemplate()..setInnerHtml('''
    <slot></slot>
    ''', treeSanitizer: NodeTreeSanitizer.trusted);

  @override
  String role = 'button';

  @override
  void deferredConstructor() {
    super.deferredConstructor();

    algIronButtonStateConstructor(this);
  }

  /// Attributes managed by the component.
  @override
  List<String> observedAttributes() => super.observedAttributes()
    ..addAll(algIronButtonStateObservedAttributes());

//  ///
//  @override
//  void addStandardAttributes() {
//    super.addStandardAttributes();
////    + <String>[];
//  }
//
//  ///
//  /// Component removed from the tree
//  ///
//  @override
//  void detached() {
//    super.detached();
//  }
}
