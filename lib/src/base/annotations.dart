part of alg_components;

///
/// Annotation class for element dom register
///   @AlgElement('my-element')
///
class AlgElement implements Initializer<Type> {
  /// The tag you want to register the class to handle.
  final String tag;

  /// Constructor
  const AlgElement(this.tag);

  ///
  @override
  void initialize(Type t) => document.registerElement(tag, t);
  // new standard: ???
  // void initialize(Type t) => customElements.define(tag, t);
}
