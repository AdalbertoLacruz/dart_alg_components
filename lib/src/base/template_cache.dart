// @copyright 2017-2018 adalberto.lacruz@gmail.com

part of core.alg_components;

///
/// Storage for the components template information
///
class TemplateCache {
  /// Storage
  static Map<String, TemplateCacheItem> _register = <String, TemplateCacheItem>{};

  ///
  /// Get an item from the TemplateCache register
  ///
  static TemplateCacheItem getItem(String name) => _register[name];

  ///
  /// Recovers the template for component [name].
  /// If don't exist creates it with [handler]
  ///
  static TemplateElement getTemplate(String name, Function handler) {
    final TemplateCacheItem item = _register.putIfAbsent(name, () => new TemplateCacheItem())
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
    final TemplateCacheItem item = _register.putIfAbsent(name, () => new TemplateCacheItem());
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
      final String id = m.group(1);
      result.add(id);
    }
    return result;
  }
}

///
/// Each component in TemplateCache
///
class TemplateCacheItem {
  /// style could be different when inserted in dom, affected by other css
  bool styleCouldBeCustom;

  /// template body
  TemplateElement template;

  /// id names in template = ["id1", ... "idn"]
  List<String> templateIds;

  /// template for <style>...</style>
  TemplateElement templateStyle;
}
