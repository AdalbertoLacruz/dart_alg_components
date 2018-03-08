// @copyright 2017-2018 adalberto.lacruz@gmail.com

import '../src/core_library.dart';

///
/// One button test component
///
class AlgButton extends AlgComponent with AlgActionMixin {
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
      button {
        color: #cb6918;
        cursor: pointer;
      }
      #in {
        line-height: 2;
      }
    </style>''', validator: nodeValidatorStyle);

  @override
  void deferredConstructor() {
    super.deferredConstructor();
    algActionConstructor(this);

    attributeManager
      ..define('color', type: TYPE_STRING)
      ..on((String color) {
        ids['but'].style.color = color;
      })

      ..define('text', type: TYPE_NUM)
      ..on((num value) {
        ids['in'].innerHtml = value.toString();
      });

    messageManager
      ..define('click', toEvent: true, isPreBinded: true);
  }

  ///
//  @override
//  void domLoaded() {
//    super.domLoaded();
//  }

  /// Attributes managed by the component.
  @override
  List<String> observedAttributes() => super.observedAttributes()
      + <String>['color', 'text', 'on-click']
      + algActionObservedAttributes();
}
