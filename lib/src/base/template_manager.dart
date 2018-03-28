// @copyright 2017-2018 adalberto.lacruz@gmail.com

part of core.alg_components;

///
/// Storage and Management for the components template information
///
class TemplateManager {
  /// Storage
  static Map<String, TemplateItem> _register = <String, TemplateItem>{};

  ///
  /// Get an item from the TemplateManager register
  ///
  static TemplateItem getItem(String name) => _register[name];

  ///
  /// Recovers the template for component [name].
  /// If don't exist creates it with [handler]
  ///
  static TemplateElement getTemplate(String name, Function handler) {
    final TemplateItem item = _register.putIfAbsent(name, () => new TemplateItem())
      ..template ??= handler();

    item.templateIds ??= searchTemplateIds(item.template.innerHtml);
    return item.template;
  }

  ///
  /// Recovers the template id names for component [name]
  ///
  static List<String> getTemplateIds(String name) => _register[name].templateIds;

  ///
  /// Recovers the template style for component [name].
  /// If don't exist creates it with [handler]
  ///
  static TemplateElement getTemplateStyle(String name, Function handler) {
    final TemplateItem item = _register.putIfAbsent(name, () => new TemplateItem());
    if (item.templateStyle == null) {
      final RulesInstance css = new RulesInstance(null);
      item
        ..templateStyle = handler(css)
        ..styleCouldBeCustom = css.styleCouldBeCustom;
    }

    return item.templateStyle;
  }

  ///
  /// Search for id="..." in inner template [html]
  ///
  static List<String> searchTemplateIds(String html) {
    final List<String> result = <String>[];
    final RegExp re = new RegExp(r' id="([a-z]*)"', caseSensitive: false);
    final Iterable<Match> matches = re.allMatches(html);

    for (Match m in matches) {
      result.add(m.group(1));
    }
    return result;
  }

  //-------------------------------------------------- Component creation

  ///
  /// Build the shadow element, and the reference to the id elements
  ///
  static void createShadowElement(AlgComponent target) {
    target.attachShadow(<String, String>{ 'mode': 'open'});

//    target.shadowRoot.append(target.template.content.clone(true));
    // we need instantiate custom components
    target.shadowRoot.append(document.importNode(target.template.content, true));

    // ids
    target.ids = getTemplateIds(target.localName)
        .fold(<String, HtmlElement>{}, (Map<String, HtmlElement> result, String id) {
      result[id] = target.shadowRoot.querySelector('#$id');
      return result;
    });
  }

  ///
  /// Build the style from the template and insert it in the shadowRoot
  ///
  static void insertStyle(AlgComponent target) {
    target.shadowRoot.insertBefore(target.templateStyle.content.clone(true), target.shadowRoot.firstChild);
  }

  ///
  /// Analyze if the component style is affected by the dom position.
  /// If so, replace it.
  ///
  static void modifyStyle(AlgComponent target) {
    final TemplateItem item = getItem(target.localName);
    if (!item.styleCouldBeCustom)
      return;

    final RulesInstance css = new RulesInstance(target);
    final TemplateElement styleElement = target.createTemplateStyle(css);

    if (!css.styleIsCustom)
      return;

    target.shadowRoot.querySelector('style')
      ..replaceWith(styleElement.content.children.first); // only <style>
  }

  ///
  /// Recover shadowRoot to the original element template
  /// Removes all childs except style and template
  ///
  static void restoreTemplate(AlgComponent target) {
    final List<Node> nodes = target.shadowRoot.childNodes;
    final int headerTotal = getItem(target.localName).headerTotal;

    while (nodes.length > headerTotal) {
      nodes.last.remove();
    }
  }

  ///
  /// save original template info
  ///
  static void saveTemplateInfo(AlgComponent target) {
    getItem(target.localName)
      ..headerElements = target.shadowRoot.children.length
      ..headerTotal = target.shadowRoot.childNodes.length;
  }
}

// --------------------------------------------------- TemplateItem

///
/// Each component cached in TemplateManager
///
class TemplateItem {
  /// Elements count in original template (header)
  int headerElements = 0;

  /// Total count in original template (header
  int headerTotal = 0;

  /// style could be different when inserted in dom, affected by other css
  bool styleCouldBeCustom;

  /// template body
  TemplateElement template;

  /// id names in template = ["id1", ... "idn"]
  List<String> templateIds;

  /// template for <style>...</style>
  TemplateElement templateStyle;
}
