// @copyright 2017-2018 adalberto.lacruz@gmail.com

part of styles.alg_components;

///
/// css and stylesheets management
///
class Rules {
  /// group definitions done - see isDefined(group)
  static List<String> defined = <String>[];

  /// where insert a sheet in the head (after title)
  static HtmlElement headInsertPoint;
  
  /// rules/mixins storage
  static Map<String, String> register = <String, String>{};
  
  ///
  /// Recovers a css rule [id] from the component style
  /// Rules such as { rule1; rule2; } => rule1; rule2;
  ///
  static String apply(HtmlElement element, String id) {
    String rule = getComputedProperty(element, id).trim();
    if (rule.startsWith('{')) {
      rule = rule.substring(1, rule.length - 1);
    }
    return rule;
  }

  ///
  /// Search for something like `--change-rule: @apply;`
  /// in the head style rule and replaces it, until no more found.
  /// NOTE: `@apply --change-rule;` would be better syntax, but css system remove it in cssRules.
  /// For efficiency, the head sheets must have `apply` ATTRIBUTE to be processed.
  ///
  static void applySheet() {
    final RegExp re = new RegExp(r'(--[\w-]+): @apply;');

//    window.console.log('applySheet');
//    window.console.log(document.head.querySelectorAll('[apply'));

    document.head.querySelectorAll('[apply]')..forEach((Element sheetDocument) {
      final CssStyleSheet sheet = (sheetDocument is LinkElement)
          ? sheetDocument.sheet
          : (sheetDocument is StyleElement) ? sheetDocument.sheet : null;
      if (sheet == null) return;

      final List<CssRule> cssRules = sheet.cssRules;
      for (int i = 0; i < cssRules.length; i++) {
        String cssText = cssRules[i].cssText;

        bool changed = false;
        Match match = re.firstMatch(cssText); // in re.allMatches start/end are changed after first replace
        while (match != null ) {
          cssText = cssText.substring(0, match.start)
              + useInSheet(match.group(1)) + cssText.substring(match.end);
          changed = true;
          match = re.firstMatch(cssText);
        }
        if (changed) cssRuleReplace(sheet, i, cssText);
      }
    });
  }

  ///
  /// Replaces the cssText in a styleSheet rule
  ///
  static void cssRuleReplace(CssStyleSheet sheet, int index, String cssText) {
    sheet
      ..deleteRule(index)
      ..insertRule(cssText, index);
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
  /// insert after title or previously added element
  ///
  static void insertInHead(HtmlElement item) {
    headInsertPoint ??= document.head.querySelector('title');
    headInsertPoint ??= document.head.lastChild;

    headInsertPoint.insertAdjacentElement('afterEnd', item);

    headInsertPoint = item;
  }

  ///
  /// Check if group is yet defined.
  ///
  static bool isDefined(String group) {
    if (defined.contains(group)) return true;
    defined.add(group);
//    print('rules group added: $group');
    return false;
  }

  ///
  /// Insert a stylesheet in the dom
  ///
  static void sheet(String id, String css) {
    // check if id sheet exist
    if (document.head.querySelector('#$id') != null) return;

    // Build it
    final Element _sheet = document.createElement('Style')
        ..setAttribute('type', 'text/css')
        ..setAttribute('id', id)
        ..setInnerHtml(css);

    insertInHead(_sheet);
  }

  ///
  /// Recovers a css rule
  ///
  static String use(String id) => register.containsKey(id)
      ? register[id]
      : '/* $id */';

  ///
  /// Recover a css rule processing a sheet.
  /// First test if use, then apply with body element
  ///
  static String useInSheet(String id) {
    if (register.containsKey(id)) return register[id];
    final String rule = apply(document.body, id);
    return rule.isEmpty ? '/* $id */' : rule;
  }
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
