// @copyright 2017-2018 adalberto.lacruz@gmail.com

import 'dart:async';
import 'dart:html';
import 'package:dart_alg_components/components/all_components_library.dart';
import 'styles.dart';

Future<Null> main() async {
//  await run(); // initialize components
//  definePaperMaterialStyles();
//  defineIronFlexLayout();
//  document
//      ..registerElement('alg-test', AlgTest)
//      ..registerElement('alg-button', AlgButton);
//  window.customElements.define('alg-test', AlgTest);
//  window.customElements.define('alg-button', AlgButton);

  allComponentsRegister(); // initialize components

  defineSheetMain();

  document.body.style.opacity = null;
  window.console.log('end main');
}
