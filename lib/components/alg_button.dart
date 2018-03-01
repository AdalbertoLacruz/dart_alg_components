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

  @override
  String role = 'button';

  @override
  TemplateElement createTemplate() => super.createTemplate()..setInnerHtml('''
    <button id="but"><slot></slot><span id="in"></span></button>
    ''', validator: nodeValidator);

  @override
  TemplateElement createTemplateStyle(RulesInstance css) => new TemplateElement()..setInnerHtml('''
    <style>
      :host {
        font-size: 2em;
      }
    </style>''', validator: nodeValidatorStyle);

  @override
  void deferredConstructor() {
    super.deferredConstructor();

    attributeManager
      ..define('color', type: TYPE_STRING)
      ..on((String color) {
        ids['but'].style.color = color;
      })

      ..define('text', type: TYPE_NUM)
      ..on((num value) {
        ids['in'].innerHtml = value.toString();
      });

    eventManager
      ..onLink('click', (Event event, dynamic context) {
        if (!(EventExpando.getCaptured(event).length > 1))
          print('onLink CLICK BTN captured.......');
      })

      ..on('pressed', (bool value) {
        print('pressed: $value');
      })
      ..subscribe();
  }

  ///
//  @override
//  void domLoaded() {
//    super.domLoaded();
//  }

  /// Attributes managed by the component.
  @override
  List<String> observedAttributes() => super.observedAttributes()
    ..addAll(<String>['color', 'text', 'on-click']);

}
