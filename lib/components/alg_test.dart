// @copyright 2017-2018 adalberto.lacruz@gmail.com

part of alg_components;

///
/// One test component
///
@AlgElement('alg-test')
class AlgTest extends AlgComponent {
  ///
  factory AlgTest() => new Element.tag('alg-test');

  ///
  AlgTest.created():super.created();

  ///
  @override
  void attached() {
    super.attached();

    attributes.forEach((String name, String value) => window.console.log('attribute: $name = $value'));

    if (attributes.containsKey('color'))
        ids['d'].style.backgroundColor = 'yellow';
  }

  ///
  @override
  void attributeChanged(String name, String oldValue, String newValue) {
    super.attributeChanged(name, oldValue, newValue);
    window.console.log('attribute: $name-$oldValue-$newValue');
  }

  ///
  /// Build the template Element to be cloned in the shadow creation
  ///
  @override
  TemplateElement createTemplate() {
//    styleSheetColor();
    nodeValidator..allowCustomElement('alg-tt', attributes: <String>['other']);

    return super.createTemplate()..setInnerHtml('''
      <div id="d">Hey <alg-tt id="tt" other></alg-tt><slot></slot></div>
    ''',  validator: nodeValidator);
  }



  ///
  /// Build the basic static template for style
  ///
  @override
  TemplateElement createTemplateStyle(RulesInstance css) => new TemplateElement()..setInnerHtml('''
    <style>
      :host {
        ${css.use('--layout-inline')}
        
        background-color: blue;
        max-width: 200px;
        ${css.apply('--test')}
      }
    </style>''', validator: nodeValidatorStyle);
}
