// @copyright 2017-2018 adalberto.lacruz@gmail.com

part of alg_components;

///
/// One button test component
///
@AlgElement('alg-button')
class AlgButton extends AlgComponent {
  ///
  factory AlgButton() => new Element.tag('alg-button');

  ///
  AlgButton.created():super.created();

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
