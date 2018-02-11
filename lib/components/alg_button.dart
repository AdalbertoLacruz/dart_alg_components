// @copyright 2017-2018 adalberto.lacruz@gmail.com

//part of core.alg_components;
import '../src/core_library.dart';

///
/// One button test component
///
class AlgButton extends AlgComponent {
  ///
  static String tag = 'alg-button';

  ///
  factory AlgButton() => new Element.tag(tag);

  ///
  AlgButton.created():super.created();

  ///
  static void register() => AlgComponent.register(tag, AlgButton);

//  ///
//  @override
//  void deferredConstructor() {
//    super.deferredConstructor();
//  }

  ///
//  @override
//  void domLoaded() {
//    super.domLoaded();
//  }

  ///
  @override
  TemplateElement createTemplate() => super.createTemplate()..setInnerHtml('''
    <button id="but"><slot></slot><span id="in"></span></button>
    ''', validator: nodeValidator);

  ///
  /// Build the basic static template for style
  ///
  @override
  TemplateElement createTemplateStyle(RulesInstance css) => new TemplateElement()..setInnerHtml('''
    <style>
      :host {
        font-size: 2em;
      }
    </style>''', validator: nodeValidatorStyle);
}
