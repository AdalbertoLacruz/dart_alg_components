// @copyright 2017-2018 adalberto.lacruz@gmail.com

///
/// Process bindings:
///   on-handler="*"
///   attr="[[controller:channel=defaultValue]]"
///   attr={{controller:channel=defaultValue}} (sync to html)
///   attr="value"
///   style="*"
///   style="property=value"
///
class BinderParser {
  ///
  /// Constructor. defaultController = String | classInstance
  ///
  BinderParser(String attrName, String value, [dynamic defaultController = '', String this.id = '']) {
    this.attrName = attrName.toLowerCase().trim();
    final String _value = value.trim();

    this.defaultController = (defaultController is String) ? defaultController.trim() : defaultController;
    createData();

    if (attributeIsHandler(this.attrName)) {
      if (_value.isEmpty) {
        isEventBinder = true;
        controller = this.defaultController;
        if (id != '') {
          channel = '${id}_$handler'.toUpperCase();
        }
      } else {
        isEventBinder = getAttributeBinder(_value);
      }
    } else if (attributeIsStyle(this.attrName)) {
      getAttributeStyle(_value);
    } else if (getAttributeBinder(_value)) {
      isAttributeBinder = true;
    } else {
      // no binding
      this.value = _value;
    }
  }

  /// Attribute Name
  String attrName;

  /// Get channel in attrName="[[:channel:]]"" binding or guest a channel from id
  /// Returns null if not possible
  String get autoChannel => channel.isNotEmpty
      ? channel
      : id.isEmpty ? '' : '$id-$attrName';

  /// Get defaultValue in attrName="[[:channel:defaultValue]]" binding or value in attrName="value"
  String get autoValue => channel.isNotEmpty ? defaultValue : value;

  /// attr="[[*:channel:*]]"
  set channel(String value) => data.channel = value;
  ///
  String get channel => data.channel;

  /// attr="[[controller:*:*]]"
  set controller(dynamic value) => data.controller = value;
  ///
  dynamic get controller => data.controller;

  /// Set of parsed data
  BinderData data;

  /// data elevator. In style, each one of styleProperty data is stored in datas.
  List<BinderData> datas = <BinderData>[];


  /// String or classInstance
  dynamic defaultController;

  /// attr="[[*:*:default-value]]"
  set defaultValue(String value) => data.defaultValue = value;
  ///
  String get defaultValue => data.defaultValue;

  /// on-handler="*"
  String handler = '';

  ///
  String id = '';

  /// data index in datas
  num index = 0;

  /// attr="[[*]]"
  bool isAttributeBinder = false;

  /// on-handler="[[*]]"
  bool isEventBinder = false;

  /// style="*"
  bool isStyleBinder = false;

  /// ={{*}}
  bool isSync = false;

  /// style="property:[[*]]"
  set styleProperty(String value) => data.styleProperty = value;
  ///
  String get styleProperty => data.styleProperty;

  /// attr="value"
  set value(String value) => data.value = value;
  ///
  String get value => data.value;

  ///
  /// Detects on-handler="*". Returns true if found
  ///
  bool attributeIsHandler(String attrName) {
    final RegExp re = new RegExp(r'on-(\w+)');
    final Match match = re.matchAsPrefix(attrName);
    if (match == null) return false;

    handler = match.group(1);
    return true;
  }

  ///
  /// detects style="*"
  ///
  bool attributeIsStyle(String attrName) => attrName == 'style';

  ///
  /// Storage for bindings processed
  ///
  void createData() {
    data = new BinderData(defaultController);
    datas.add(data);
  }

  ///
  /// Process binding in attr="[[controller:channel=defaultValue]]"
  ///   or attr={{*}}
  ///   or attr="value"
  ///   or attr="property:value"
  /// Returns false if no binding
  ///
  bool getAttributeBinder(String value) {
    final RegExp re = new RegExp(r'[[{]{2}([a-z-_\d]*):{1}([a-z-_\d)]+)={0,1}([a-z-_\d)]+)*[\]}]{2}',
        caseSensitive: false);
    final Match match = re.matchAsPrefix(value);
    if (match == null) return false;

    if (match.group(1).isNotEmpty) { // we have default controller
      controller = match.group(1);
    }
    channel = match.group(2);
    defaultValue = match.group(3);
    isSync = value.startsWith('{');

    return true;
  }

  ///
  /// Process style="property1:[[]];property2:[[]]"
  ///
  void getAttributeStyle(String value) {
    isStyleBinder = true;
    final List<String> values = value.split(';');

    // value is "property:[[]]"
    values.forEach((String value) {
      final String _value = getPropertyAndValue(value) ?? value; // property if exist goes to this.styleProperty
      if (!getAttributeBinder(_value)) { // no binding
        getStylePropertyNoBinding(_value);
      }
      if (datas.length < values.length) createData();
    });

    // Pointer to first data
    if (datas.length > 1) resetIndex();
  }

  ///
  /// Get channel in style="property:[[:channel:]]" binding or guest a channel from id
  /// Returns empty string if not possible
  ///
  String getAutoStyleChannel(String property) => id.isEmpty
      ? ''
      : channel.isNotEmpty ? channel : '$id-style-$property';

  ///
  /// For style, split property and [[*]]
  /// value is "property:[[*]]"
  /// returns [[*]]
  ///
  String getPropertyAndValue(String value) {
    final RegExp re = new RegExp(r'([a-z-_\d]+):{1}[[{]{2}', caseSensitive: false);
    final Match match = re.firstMatch(value);
    if (match == null) return null;

    final String property = match.group(1);
    styleProperty = property;
    return value.substring(property.length + 1);
  }

  ///
  /// The style hasn't binding
  /// style="property:value" or style="property" (error?)
  /// values is property:value
  ///
  void getStylePropertyNoBinding(String value) {
    final List<String> values = value.split('=');
    styleProperty = values[0];
    if (values.length > 1) {
      this.value = values[1];
    }
  }

  ///
  /// In styles, reading datas, get next data
  /// Returns false if no more
  ///
  bool next() {
    if (index < datas.length - 1) {
      data = datas[++index];
      return true;
    }
    return false;
  }

  ///
  /// set index = 0
  ///
  void resetIndex() {
    index = 0;
    data = datas[0];
  }
}

// ---------------------------------------------------

///
/// Binder Parser results
///
class BinderData {
  ///
  String channel = '';
  ///
  dynamic controller = '';
  ///
  String defaultValue = '';
  ///
  String styleProperty = '';
  ///
  String value = '';

  /// Constructor
  BinderData(this.controller);
}
