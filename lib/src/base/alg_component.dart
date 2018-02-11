// @copyright 2017-2018 adalberto.lacruz@gmail.com

part of core.alg_components;

///
/// Component building with internal nodes/style
///
class AlgComponent extends HtmlElement {
  // ------------------------------------------------- Lifecycle

  /// Component creation
  AlgComponent.created() :super.created() {
    createShadowElement();
    insertStyle();

    new Future<Null>(() { domLoaded(); });
  }

  ///
  /// Component inserted into the tree
  ///
  @override
  void attached() {
    super.attached();

    if (!loadedComponent) {
      deferredConstructor();
      postDeferredConstructor();
    }
  }

  ///
  /// First task in attached, executed once.
  /// It is called before attributeChange
  /// Simplify constructor and place here attributeManager, eventManager, ...
  ///
  void deferredConstructor() {

  }

  ///
  /// Tasks to execute after deferredConstructor
  ///
  void postDeferredConstructor() {

  }

  ///
  /// Dom has yet the components created
  ///
  void domLoaded() {
    loadedComponent = true;

    modifyStyle();
    AttributeManager.initialReadAllAttributes(this);
  }

  ///
  /// Responds to attribute changes
  ///
  @override
  void attributeChanged(String name, String oldValue, String newValue) {
    super.attributeChanged(name, oldValue, newValue);
    if (!observedAttributesCache.contains(name))
        return;

    attributeManager.change(name, newValue);
  }

  ///
  /// Component removed from the tree
  ///
  @override
  void detached() {
    super.detached();
  }

  // ------------------------------------------------- Register

  /// List of components registered
  static List<String> registered = <String>[];

  ///
  /// Register a component only once
  ///
  static void register(String tag, Type componentClass) {
    if (registered.isEmpty) {
      definePaperMaterialStyles();
      defineIronFlexLayout();
    }
    if (!registered.contains(tag)) {
      registered.add(tag);
      document.registerElement(tag, componentClass);
      // window.customElements.define(tag, componentClass); // standard, but not supported
    }
  }

  // ------------------------------------------------- Template

  /// Pointers to ids in template instance
  Map<String, HtmlElement> ids;

  /// True if component inserted in a stable dom
  bool loadedComponent = false;

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
      TemplateCache.getTemplate(localName, createTemplate);

  /// Recovers or creates the cached templateStyle '<style>...</style>'
  TemplateElement get templateStyle =>
      TemplateCache.getTemplateStyle(localName, createTemplateStyle);

  ///
  /// Build the shadow element, and the reference to the id elements
  ///
  void createShadowElement() {
    attachShadow(<String, String>{ 'mode': 'open'});
    shadowRoot.append(template.content.clone(true));

    // ids
    ids = TemplateCache.getTemplateIds(localName)
        .fold(<String, HtmlElement>{}, (Map<String, HtmlElement> result, String id) {
          result[id] = shadowRoot.querySelector('#$id');
          return result;
        });
  }

  ///
  /// Build the template Element to be cloned in the shadow creation
  ///
  TemplateElement createTemplate() => new TemplateElement();

  ///
  /// Build the basic static template for style
  ///
  TemplateElement createTemplateStyle(RulesInstance css) => new TemplateElement()
    ..setInnerHtml('<style></style>', validator: nodeValidatorStyle);

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
    final TemplateCacheItem item = TemplateCache.getItem(localName);
    if (!item.styleCouldBeCustom)
        return;

    final RulesInstance css = new RulesInstance(this);
    final TemplateElement styleElement = createTemplateStyle(css);

    if (!css.styleIsCustom)
        return;

    shadowRoot.querySelector('style')
      ..replaceWith(styleElement.content);
  }

  // ------------------------------------------------- Bindings

  /// Attributes managed by the component.
  /// To be override by components to add more attributes
  List<String> observedAttributes() => <String>['disabled', 'style'];

  ///
  List<String> get observedAttributesCache => _observedAttributesCache ??= observedAttributes();
  List<String> _observedAttributesCache;

  /// Attribute input/output and binding
  AttributeManager get attributeManager => _attributeManager ??= new AttributeManager(this);
  AttributeManager _attributeManager;
}

