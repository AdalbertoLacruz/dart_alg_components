// @copyright 2017-2018 adalberto.lacruz@gmail.com

part of alg_components;

///
/// Component build with internal nodes/style
///
class AlgComponent extends HtmlElement {
  /// Component creation
  AlgComponent.created() :super.created() {
    createShadowElement();
    insertStyle();
  }

  ///
  /// Component inserted in the tree
  ///
  @override
  void attached() {
    super.attached();

    // Assure all sheets are loaded - async
    new Future<Null>(() {
      modifyStyle();
    });
  }

  ///
  /// Responds to attribute changes
  ///
  @override
  void attributeChanged(String name, String oldValue, String newValue) {
    super.attributeChanged(name, oldValue, newValue);
  }

  ///
  /// Component removed from the tree
  ///
  @override
  void detached() {
    super.detached();
  }

  /// Pointers to ids in template instance
  Map<String, HtmlElement> ids;

  /// For innerHtml template validation
  final NodeValidatorBuilder nodeValidator = new NodeValidatorBuilder()
    ..allowHtml5()
    ..allowElement('slot')
    ..allowSvg()
//    ..allowCustomElement('alg-tt', attributes: <String>['other'])
    ..allowTemplating();

  /// For innerHTML templateStyle validation
  final NodeValidatorBuilder nodeValidatorStyle = new NodeValidatorBuilder()
    ..allowElement('style');

  /// Recovers or creates the cached template '<div>...<slot></slot></div>'
  TemplateElement get template =>
      TemplateCache.getTemplate(tagName, createTemplate);

  /// Recovers or creates the cached templateStyle '<style>...</style>'
  TemplateElement get templateStyle =>
      TemplateCache.getTemplateStyle(tagName, createTemplateStyle);

  ///
  /// Build the shadow element, and the reference to the id elements
  ///
  void createShadowElement() {
    // create element
    final Map<String, String> shadowRootInitDict = <String, String>{ 'mode': 'open'};
    attachShadow(shadowRootInitDict);

    final DocumentFragment node = template.content.clone(true);
    shadowRoot.append(node);

    // ids
    ids = TemplateCache.getTemplateIds(tagName)
        .fold(<String, HtmlElement>{}, (Map<String, HtmlElement> result, String id) {
          result[id] = shadowRoot.querySelector('#$id');
          return result;
        });
  }

  ///
  /// Build the template Element to be cloned in the shadow creation
  ///
  TemplateElement createTemplate() {
    final TemplateElement template = new TemplateElement()
      ..setInnerHtml('');
    return template;
  }

  ///
  /// Build the basic static template for style
  ///
  TemplateElement createTemplateStyle(RulesInstance css) {
    final TemplateElement template = new TemplateElement()
      ..setInnerHtml('<style></style>', validator: nodeValidatorStyle);
    return template;
  }

  ///
  /// Build the style from the template and insert it in the shadowRoot
  ///
  void insertStyle() {
    shadowRoot.insertBefore(templateStyle.content.clone(true), shadowRoot.firstChild);
  }

  ///
  /// Analyze if the component style is affected by the dom position.
  /// If so, replace it.
  ///
  void modifyStyle() {
    final TemplateCacheItem item = TemplateCache.register[tagName];
    if (!item.styleCouldBeCustom)
        return;

    final RulesInstance css = new RulesInstance(this);
    final TemplateElement styleElement = createTemplateStyle(css);

    if (!css.styleIsCustom)
        return;

    shadowRoot.querySelector('style')
      ..replaceWith(styleElement.content);
  }
}

