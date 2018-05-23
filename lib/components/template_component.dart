// @copyright @polymer
// @copyright 2017-2018 adalberto.lacruz@gmail.com

import '../src/core_library.dart';

///
class TemplateComponent extends AlgComponent {
  ///
  static String tag = 'template-component';

  ///
  factory TemplateComponent() => new Element.tag(tag);

  ///
  TemplateComponent.created() : super.created();

  ///
  static void register() => AlgComponent.register(tag, TemplateComponent);

  @override
  TemplateElement createTemplateStyle(RulesInstance css) => new TemplateElement()..setInnerHtml('''
    <style>
    </style>''', treeSanitizer: NodeTreeSanitizer.trusted);

  @override
  TemplateElement createTemplate() => super.createTemplate()..setInnerHtml('''
    <div></div>
    ''', treeSanitizer: NodeTreeSanitizer.trusted);

  @override
  String role = '';

  @override
  void deferredConstructor() {
    super.deferredConstructor();
  }

  /// Attributes managed by the component.
  @override
  List<String> observedAttributes() => super.observedAttributes()
    + <String>[];

  ///
  @override
  void addStandardAttributes() {
    super.addStandardAttributes();
//    + <String>[];
  }

  ///
  /// Component removed from the tree
  ///
  @override
  void detached() {
    super.detached();
  }
}
