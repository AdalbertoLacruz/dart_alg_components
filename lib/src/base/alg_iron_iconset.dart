// @copyright @polymer\iron-iconset-svg\iron-iconset-svg.js
// @copyright 2017-2018 adalberto.lacruz@gmail.com

part of icons.alg_components;

///
/// Storage and management for icons
///
class AlgIronIconset {
  /// icon groups defined
  static List<String> defined = <String>[];

  /// Iconset by default
  static String  defaultIconSet = 'icons';

  /// iconset storage
  static Map<String, Iconset> register = <String, Iconset>{};

  ///
  /// Setup to load a base64 group.
  /// use: AlgIronIconset.addIconsetBase64('iconset', 24)..set('id', 'src.base64')..set().set()...
  ///
  static Iconset addIconsetBase64(String iconsetName, int size) =>
      _getIconset(iconsetName, 'base64', size);

  ///
  /// Load a svg icon group
  ///   definition (<div><svg><def> <g id><path>)
  ///
  static void addIconsetSvg(String iconsetName, int size, Element definition) {
    final Map<String, dynamic> data = _getIconset(iconsetName, 'svg', size).data;
    final Element iconGroup = definition.firstChild.firstChild;
    final List<Element> iconChildren = iconGroup.children;

    for (int i = 0; i < iconChildren.length; i++) {
      final Element item = iconChildren[i];
      data[item.id] = item;
    }
  }

  ///
  /// Build an image element
  ///
  static HtmlElement createImageElement(String src) =>
      (document.createElement('img') as ImageElement)
        ..style.width = '100%'
        ..style.height = '100%'
        ..draggable = false
        ..src = src;

  ///
  /// Cretaes an Image element with the icon
  ///
  static HtmlElement _getBase64Element(IconDefinition data) => createImageElement(data.definition);

  ///
  /// Returns the icon definition
  ///   name == 'iconset:icon'
  ///
  static IconDefinition _getIcon(String name) {
    final List<String> values = name.split(':');
    if (values.length > 2) return null;

    final String iconsetName = (values.length > 1 ? values.first : defaultIconSet).trim();
    final String iconName = values.last.trim();

    final Iconset iconset = _getIconset(iconsetName);
    final HtmlElement iconDefinition = iconset.data[iconName];
    if (iconDefinition == null) return null;

    return new IconDefinition(
      iconset: iconsetName,
      type: iconset.type,
      size: iconset.size,
      name: iconName,
      definition: iconDefinition
    );
  }

  ///
  /// Normal entry point to get an icon as an HTMLElement
  ///   name == 'iconset:icon'
  ///
  static HtmlElement getIconElement(String name) {
    final IconDefinition iconDefinition = _getIcon(name);
    if (iconDefinition == null) return null;

    if (iconDefinition.type == 'svg') return _getSvgElement(iconDefinition);
    if (iconDefinition.type == 'base64') return _getBase64Element(iconDefinition);
    return null;
  }

  ///
  /// Recover and create an iconset in the register if don't exist
  ///
  static Iconset _getIconset(String name, [String type = 'svg', int size = 24]) =>
      register.containsKey(name)
        ? register[name]
        : register[name] = new Iconset(
            name: name,
            type: type,
            size: size,
            data: <String, dynamic>{});


  ///
  /// Creates an svg element from the icon
  ///
  static HtmlElement _getSvgElement(IconDefinition data) {
    final HtmlElement content = data.definition.clone(true);
    content.attributes.remove('id');

    final HtmlElement svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
    final String viewBox = '0 0 ${data.size} ${data.size}';
    final String cssText = 'pointer-events: none; display: block; width: 100%; height: 100%;';

    svg
        ..setAttribute('viewBox', viewBox)
        ..setAttribute('preserveAspectRatio', 'xMidYMid meet')
        ..setAttribute('focusable', 'false')
        ..style.cssText = cssText
        ..append(content);

    return svg;
  }

  ///
  /// Check if group is yet defined
  ///
  static bool isDefined(String group) => defined.contains(group)
      ? true
      : (defined..add(group)) == null; // false

  ///
  /// For an iconset returns the List of icon names
  ///
  static List<String> listIconset(String name) {
    final Iconset iconset = register[name];
    if (iconset == null) return null;

    return iconset.data.keys;
  }

  ///
  /// Returns the List of iconsets in the registry
  ///
  static List<String> listIconsets() => register.keys;
}

// --------------------------------------------------- IconDefinition

///
/// Icon Definition
///
class IconDefinition {
  /// <g>...
  dynamic definition;

  /// ex. 'av'
  String iconset;

  /// ex. 'ok'
  String name;

  /// ex. 24
  int size;

  /// ex. 'svg'
  String type;

  /// Constructor
  IconDefinition({this.definition, this.iconset, this.name, this.size, this.type});
}

// --------------------------------------------------- Iconset

///
/// Iconset definition and icons storage
///
class Iconset {
  /// ex 'av'
  String name;
  /// ex. 'svg'
  String type;
  /// ex. 24
  int size;
  /// Each {iconName, icon}
  Map<String, dynamic> data;

  /// Constructor
  Iconset({this.name, this.type, this.size, this.data});

  ///
  /// Store a definition in the set
  ///
  void set(String key, dynamic value) => data[key] = value;
}
