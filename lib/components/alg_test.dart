// @copyright 2017-2018 adalberto.lacruz@gmail.com

//part of core.alg_components;
import '../src/core_library.dart';

///
/// One test component
///
class AlgTest extends AlgComponent {
  ///
  static String tag = 'alg-test';

  ///
  factory AlgTest() => new Element.tag(tag);

  ///
  AlgTest.created():super.created();

  ///
  static void register() => AlgComponent.register(tag, AlgTest);

  ///
  @override
  void deferredConstructor() {
    super.deferredConstructor();

    attributeManager
      ..define('att')

      ..define<bool>('colorange', type: TYPE_BOOL)
      ..reflect()

      ..define<String>('color')
      ..on((String color) {
          ids['d'].style.backgroundColor = color;
          attributeManager.change('colorange', color == 'orange');
      });
  }


  ///
  @override
  void domLoaded() {
    super.domLoaded();

    if (id == 'test2')
      setAttribute('color', 'orange');
  }

  /// Attributes managed by the component.
  @override
  List<String> observedAttributes() => super.observedAttributes()
    ..addAll(<String>['att', 'color']);

//  ///
//  @override
//  void attached() {
//    super.attached();
//  }

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
