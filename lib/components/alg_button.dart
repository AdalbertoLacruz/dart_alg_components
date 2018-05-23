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
  AlgButton.created():super.created() {
    mixinManager = new MixinManager();

    algActionInit(this);
  }

  ///
  static void register() => AlgComponent.register(tag, AlgButton);

  @override
  String role = 'button';

  @override
  TemplateElement createTemplate() => super.createTemplate()..setInnerHtml('''
    <button id="but"><slot></slot><span id="in"></span></button>
    ''', treeSanitizer: NodeTreeSanitizer.trusted);

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
    </style>''', treeSanitizer: NodeTreeSanitizer.trusted);

  @override
  void deferredConstructor() {
    super.deferredConstructor();

    attributeManager
      ..define('classbind', type: TYPE_STRING, isPreBinded: true)
      ..on((String value) {
        AttributeManager.classUpdate(this, value);
      })


      ..define('color', type: TYPE_STRING)
      ..on((String color) {
        ids['but'].style.color = color;
      })

      ..define('text', type: TYPE_NUM, isPreBinded: true)
      ..on((num value) {
        ids['in'].innerHtml = value.toString();
      });

    messageManager
      ..define('click', toEvent: true, isPreBinded: true);
  }

  /// Attributes managed by the component.
  @override
  List<String> observedAttributes() => super.observedAttributes()
      + <String>['classbind', 'color', 'text', 'on-click'];
}
