// @copyright 2017-2018 adalberto.lacruz@gmail.com

//part of core.alg_components;
import 'dart:async';
import '../base/alg_log.dart';
import '../util/constants.dart';
export '../util/constants.dart';

///
/// Common code for observable types.
/// ```update(value)``` => trigger linkers and observers handlers.
/// linkers is a list of handlers executed immediately in a value change.
/// observers is a list of handlers executed async.
///
class Observable<T> {
  /// internal name used in logs, attributes, ...
  String name;

  /// Additional information
  Map<String, dynamic> context = <String, dynamic>{};

  /// Last value received when delayed == true
  dynamic delayedValue;

  /// True, avoid update
  bool disabled = false;

//  initHandler;

//  /// true => a log handler is defined
//  bool _isLogHandler = false;
//
//  /// true =>  log is active
//  bool _isLogActive = false;

  /// true => value change
  bool isNewValue = false;

  /// Previous value
  T oldValue;

  /// For log name = 'prefix#name'
  String prefix = '';

  /// set value transformer handler. `newValue = transformer(value);`
  Function transformer;

  /// Observable value type
  String type;

  ///
  /// Constructor
  ///
  Observable([this.name = '']) {
    context['me'] = this;
  }

  /// default transformer for bool value
  static Function transformerBool =
      (dynamic value) => (value is bool) ? value : (value == '' || value == 'true') ? true : false;

  /// default transformer for num value
  static Function transformerNum =
      (dynamic value) => (value is num) ? value : (value is String && value.isNotEmpty) ? num.parse(value) : null;

  /// Stop updated in true, until false. Then update with the last delayed value received.
  /// Used to avoid bumping.
  bool get delayed => _delayed ;
  set delayed(bool value) {
    _delayed = value;
    if (value == false && delayedValue != null) {
      final dynamic _delayedValue = delayedValue;
      delayedValue = null;
      update(_delayedValue);
    }
  }
  bool _delayed = false;

  /// Linkers are like observers but the value is propagated faster.
  /// Necessary for integrity in events.
  Set<Function> get linkers => _linkers ??= new Set<Function>();
  Set<Function> _linkers;

  /// Handlers to be executed async in value change
  Set<Function> get observers => _observers ??= new Set<Function>();
  Set<Function> _observers;

  /// The object value. All is around this.
  T get value => _value;
  set value(T value) {
    AlgLog.log('$prefix#$name', value);

    final T newValue = (transformer == null) ? value : transformer(value);
    if (_value != newValue ) {
      isNewValue = true;
      oldValue = _value;
      context['old'] = _value;
      _value = newValue;
    } else {
      isNewValue = false;
    }
  }
  T _value;

//  /**
//   * @param {*} value
//   */
//  setValue(value) {
//    this.value = value;
//    return this;
//  }

//  /**
//   * add value to number observable
//   * @param  {*} value - to add to number value
//   * @return {Observable}
//   */
//  add(value) {
//    if (this._type === 'number') this.update(this.value + value);
//    return this;
//  }

  ///
  /// Call the subscribers (async observers/linkers)
  /// Async values could change when processed if not receveid by value.
  ///   link: handler(value)
  ///   observe: handler(value, context)
  ///
  void dispatch([T data]) {
    final T _data = data ?? value;
    linkers.forEach((Function handler) => handler(_data, context));
    // async calls only could receive parameters by value
    observers.forEach((Function handler) =>
        new Future<void>(() => handler(_data)));
  }

//  /**
//   * Changes the internal value, trigger the initHandler and the subscribers/observers
//   *
//   * @param  {*} value
//   * @return {Observable}
//   */
//  init(value) {
//    if (this.initHandler) this.initHandler(value);
//    this.update(value);
//    return this;
//  }
//
//  /**
//   * Function used to sync with other variables
//   * @param  {Function} handler
//   * @return {Observable}
//   */
//  initializer(handler) {
//    this.initHandler = handler;
//    return this;
//  }

  ///
  /// Add a Function to be execued inmediatly at once in value change.
  /// Used at eventManager level.
  ///
  void link(Function handler) => linkers.add(handler);

  ///
  /// Add a Function to be execued async in value change.
  ///
  void observe(Function handler) => observers.add(handler);

//  /**
//   * If value is null/undefined changes to newValue // TODO: as transformer
//   * @param {*} newValue
//   * @return {Observable}
//   */
//  onNullSet(newValue) {
//    let handler;
//    this.observe(handler = (value) => {
//        if (value === null || value === undefined) this.update(newValue);
//  });
//    handler(this._value);
//    return this;
//  }
//
//  /**
//   * @param {*} value
//   */
//  setContext(value) {
//    this.context = value;
//    return this;
//  }

//  /**
//   * enable/disable logging in value change
//   * @param  {Boolean} flag true, log is enabled
//   * @return {Observable}
//   */
//  setLog(flag = true) {
//    this._isLogActive = flag;
//
//    if (flag && !this._isLogHandler) {
//      this.link((value) => {
//        // @ts-ignore
//      i  f (this._isLogActive && window.AlgLog) window.AlgLog.add(null, `${this.name}: ${this.value}`);
//      });
//    }
//
//    return this;
//  }
//
//  /**
//   * Change the name used in log
//   * @param {String} value
//   * @return {Observable}
//   */
//  setName(value) {
//    this.name = value;
//    return this;
//  }

  ///
  /// Initialize type = TYPE_BOOL, TYPE_NUM, TYPE_STRING, TYPE_EVENT, TYPE_OTHER
  /// Initialize value/transformer according
  ///
  void setType(String type, {bool useTransformer = false}) {
    this.type = type;
    switch (type) {
      case TYPE_BOOL:
        _value = false as T;
        if (useTransformer)
          transformer = transformerBool;
        break;
      case TYPE_NUM:
        if (useTransformer)
          transformer = transformerNum;
        break;
      default:
    }
  }

//
//  /**
//   * A value change execute the subscriber functions. Used by the bindind system
//   * @param {String} channel - For internal subscription inside complex objects
//   * @param {*} defaultValue
//   * @param {Function} handler
//   * @param {Object} status
//   * @return {Observable}
//   */
//  subscribe(channel, defaultValue, handler, status) {
//    status.hasChannel = true;
//    this.observers.add(handler);
//    if (defaultValue != null) this.init(defaultValue);
//    return this.value;
//  }

  ///
  /// If value is true, set to false and vice versa
  ///
  void toggle() {
    if (value is bool)
        update (!(value as bool));
  }

  ///
  /// Remove the susbscriber.
  ///
  void unsubscribe(Function handler, { bool isLink = false}) {
    if (isLink) {
      linkers.remove(handler);
    } else {
      observers.remove(handler);
    }
  }

  ///
  /// Changes a value and trigger the linkers/observers
  /// Options: force = true, dispatch any case
  ///
  void update(dynamic value, {bool force = false}) {
    if (disabled)
        return;
    if (delayed) {
      delayedValue = value;
      return;
    }

    this.value = value; // could use transformer
    if (force || isNewValue)
        dispatch();
  }
}

