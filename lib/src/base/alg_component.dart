// @copyright 2017-2018 adalberto.lacruz@gmail.com

part of core.alg_components;

///
/// Component build with internal nodes/style
///
class AlgComponent extends HtmlElement {
  // ------------------------------------------------- Lifecycle

  ///
  /// Component creation
  ///
  AlgComponent.created() :super.created() {
    TemplateManager.createShadowElement(this);
    TemplateManager.insertStyle(this);
    TemplateManager.saveTemplateInfo(this);

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
    addStandardAttributes();
    if (mixinManager != null) mixinManager.deferredConstructorRun();
  }

  ///
  /// Tasks to execute after deferredConstructor
  ///
  void postDeferredConstructor() { }

  ///
  /// Dom has yet the components created
  ///
  void domLoaded() {
    loadedComponent = true;

    TemplateManager.modifyStyle(this);
    AttributeManager.findController(this);
    AttributeManager.initialReadAllAttributes(this);

    if (_messageManager != null) {
      messageManager
          ..updatePrebinded()
          ..subscribeTo();
    }
  }

  ///
  /// Responds to attribute changes, for observed and not removed attributes.
  /// If possible, it subscribes to the controller in the first time.
  ///
  @override
  void attributeChanged(String name, String oldValue, String newValue) {
    super.attributeChanged(name, oldValue, newValue);
    if (!observedAttributesCache.contains(name)
        || (newValue == null && attributeManager.isRemoved(name)))
        return;

    if (newValue == null || attributeManager.isSubscriptionTried(name)) {
      attributeManager.change(name, newValue);
    } else {
      AttributeManager.subscribeBindings(this, name, newValue);
    }
  }

  ///
  /// Component removed from the tree
  ///
  @override
  void detached() {
    super.detached();

    if (_attributeManager != null) attributeManager.unsubscribe();
    if (_eventManager != null) eventManager.unsubscribe();
    if (_styleManager != null) styleManager.unsubscribe();
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
//       window.customElements.define(tag, componentClass); // standard, but not supported
    }
  }

  // ------------------------------------------------- Template

  /// Pointers to ids in template instance
  Map<String, HtmlElement> ids;

  /// True if component inserted in a stable dom
  bool loadedComponent = false;

  /// cache for tabIndex in disabled
  int oldTabIndex;

  /// component role, such as 'button', ...
  String role;

  /// Recovers or creates the cached template '<div>...<slot></slot></div>'
  TemplateElement get template =>
      TemplateManager.getTemplate(localName, createTemplate);

  /// Recovers or creates the cached templateStyle '<style>...</style>'
  TemplateElement get templateStyle =>
      TemplateManager.getTemplateStyle(localName, createTemplateStyle);

  ///
  /// check for tabIndex, role, and add them if not defined
  ///
  void addStandardAttributes() {
    if (!attributes.containsKey('role') && role != null)
        setAttribute('role', role);
    if (!attributes.containsKey('tabindex'))
        setAttribute('tabindex', '0');
  }

  ///
  /// Build the template Element to be cloned in the shadow creation
  ///
  TemplateElement createTemplate() => new TemplateElement();

  ///
  /// Build the basic static template for style
  ///
  TemplateElement createTemplateStyle(RulesInstance css) => new TemplateElement()
    ..setInnerHtml('<style></style>', treeSanitizer: NodeTreeSanitizer.trusted);

  ///
  /// Recover component innerHtml to original template state
  ///
  void restoreTemplate() => TemplateManager.restoreTemplate(this);

  // ------------------------------------------------- Bindings

  /// Attribute input/output and binding
  AttributeManager get attributeManager => _attributeManager ??= new AttributeManager(this);
  AttributeManager _attributeManager;

  /// String Name or class instance
  dynamic controller;

  /// Events
  EventManager get eventManager => _eventManager ??= new EventManager(this);
  EventManager _eventManager;

  /// Manages fire events
  MessageManager get messageManager => _messageManager ??= new MessageManager(this);
  MessageManager _messageManager;

  /// Manages inheritance in mixins
  MixinManager mixinManager;

  /// Attributes managed by the component.
  /// To be override by components to add more attributes
  List<String> observedAttributes() => <String>['disabled', 'style']
    ..addAll(mixinManager != null ? mixinManager.observedAttributesRun() : <String>[]);

  ///
  List<String> get observedAttributesCache => _observedAttributesCache ??= observedAttributes();
  List<String> _observedAttributesCache;

  /// Styles subscribed to the controller
  StyleManager get styleManager => _styleManager ??= new StyleManager(this);
  StyleManager _styleManager;

  ///
  /// Send a message to the controller
  ///
  void fireMessage(String channel, dynamic message) => messageManager.fire(channel, message);
}
