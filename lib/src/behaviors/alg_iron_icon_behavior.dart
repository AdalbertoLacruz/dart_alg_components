// @copyright @polymer\iron-icon\iron-icon.js
// @copyright 2017-2018 adalberto.lacruz@gmail.com

part of core.alg_components;

///
class AlgIronIconBehavior extends AlgComponent {
  ///
  AlgIronIconBehavior.created() : super.created();

  @override
  void deferredConstructor() {
    super.deferredConstructor();

    attributeManager
      // The name of the icon to use. The name should be of the form: `iconset_name:icon_name`.
      ..define('icon', type: TYPE_STRING, countChanges: true)
      ..on(_updateIcon)
      ..store((ObservableEvent<String> entry$) => icon$ = entry$)

      // If using iron-icon without an iconset, you can set the src to be
      // the URL of an individual icon image file. Note that this will take
      // precedence over a given icon attribute.
      ..define('src', type: TYPE_STRING, countChanges: true)
      ..on(_updateIcon)
      ..store((ObservableEvent<String> entry$) => src$ = entry$);
  }

  @override
  List<String> observedAttributes() => super.observedAttributes()
    ..addAll(<String>['icon', 'src']);

  ///
  ObservableEvent<String> icon$;

  ///
  ObservableEvent<String> src$;

  ///
  /// Add the icon to the shadow
  ///
  void _updateIcon(_) {
    if (!attributeManager.hasChanged('updateIcon', <String>['icon', 'src'])) return;

    final String icon = icon$.value;
    final String src = src$.value;

    final bool usesIconset = icon != null || src == null;

    restoreTemplate(); // remove previous icon

    final HtmlElement iconElement = usesIconset
        ? AlgIronIconset.getIconElement(icon)
        : AlgIronIconset.createImageElement(src);
    if (iconElement == null) return;

    shadowRoot.append(iconElement);
  }
}
