// @copyright 2017-2018 adalberto.lacruz@gmail.com

part of core.alg_components;

///
/// Manages actions in MessageManager
///
class ObservableAction {
  /// actions
  List<Function> handlers = <Function>[];

  ///
  /// add a handler
  ///
  void subscribe(Function handler) => handlers.add(handler);

  ///
  /// Execute the actions
  ///
  void dispatch(dynamic message, {bool isLink: false}) {
    handlers.forEach((Function handler) {
      isLink
        ? handler(message)
        : new Future<void>(() => handler(message));
    });
  }
}
