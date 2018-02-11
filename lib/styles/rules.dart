// @copyright 2017-2018 adalberto.lacruz@gmail.com

part of styles.alg_components;

///
/// css and stylesheets management
///
class Rules {
  /// rules/mixins storage
  static Map<String, String> register = <String, String>{};

  /// group definitions done - see isDefined(group)
  static List<String> defined = <String>[];

  ///
  /// Recovers a css rule [id] from the component style
  /// Rules such as { rule1; rule2; } => rule1; rule2;
  ///
  static String apply(HtmlElement element, String id) {
    String rule = getComputedProperty(element, id).trim();
    if (rule.startsWith('{'))
        rule = rule.substring(1, rule.length - 1);
    return rule;
  }

  ///
  /// Define a css rule
  ///
  static void define(String id, String css) {
    register[id] = '''/* $id */
    $css''';
  }

  ///
  /// Define a css rule if not defined previously
  ///
  static void defineDefault(String id, String css) {
    if (!register.containsKey(id))
      define(id, css);
  }

  ///
  /// Recovers a property value [id] in the [element] computed style
  ///
  static String getComputedProperty(HtmlElement element, String id) =>
      element.getComputedStyle().getPropertyValue(id);

  ///
  /// Check if group is yet defined.
  ///
  static bool isDefined(String group) {
    if (defined.contains(group))
        return true;
    defined.add(group);
//    print('rules group added: $group');
    return false;
  }

  ///
  /// Insert a stylesheet in the dom
  ///
  static void sheet(String id, String css) {
    // check if id sheet exist
    if (document.head.querySelector('#$id') != null)
        return;

    // Build it
    final Element _sheet = document.createElement('Style')
        ..setAttribute('type', 'text/css')
        ..setAttribute('id', id)
        ..setInnerHtml(css);
    document.head.append(_sheet);
  }

  ///
  /// Recovers a css rule
  ///
  static String use(String id) => register.containsKey(id)
      ? register[id]
      : '/* $id */';
}

///
/// A Rules Instance to use in components template styles.
/// Let know if the style changes when component is inserted in the dom.
///
class RulesInstance extends Rules {
  /// HTML element affected by css.
  HtmlElement element;

  /// No element supplied, but use of apply or calc
  bool styleCouldBeCustom = false;

  /// element css is affected by dom position
  bool styleIsCustom = false;

  /// constructor
  RulesInstance(this.element);

  ///
  /// Recovers a css rule [id] visible to the [element].
  /// If not element recovers a rule from the registry
  ///
  String apply(String id) {
    if (element != null) {
      String rule = Rules.apply(element, id);
      if (rule != null) {
        styleIsCustom = true;
        rule = '/* $id */ $rule';
      } else {
        rule = Rules.use(id);
      }
      return rule;
    } else {
      styleCouldBeCustom = true;
      return Rules.use(id);
    }
  }

  ///
  /// Use handler(id, isDefault) to define a css variable --id
  ///
  String calc(String id, Function handler) {
    if (element != null) {
      styleIsCustom = true;
      return handler(id, isDefault: false);
    } else {
      styleCouldBeCustom = true;
      return handler(id, isDefault: true);
    }
  }

  /// Recovers a css rule
  String use(String id) => Rules.use(id);
}
