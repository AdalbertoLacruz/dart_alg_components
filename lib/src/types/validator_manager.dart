// @copyright 2017-2018 adalberto.lacruz@gmail.com

part of core.alg_components;

///
/// Validator's repository
///
class ValidatorManager {
  /// Validator storage
  static Map<String, Function> register = <String, Function>{};

  ///
  /// Defines a validator
  ///
  static void define(String name, Function handler) {
    register[name] = handler;
  }

  ///
  /// Recovers a validator
  ///
  static Function getValidator(String name) => register[name];
}
