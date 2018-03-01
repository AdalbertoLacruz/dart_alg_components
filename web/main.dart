// @copyright 2017-2018 adalberto.lacruz@gmail.com

import 'dart:async';
import 'dart:html';
import 'package:dart_alg_components/components/all_components_library.dart';
import 'package:dart_alg_components/src/base/alg_log.dart';
import 'app_controller.dart';
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

  AlgLog.disabled = false;
  final AppController appController = new AppController();
  allComponentsRegister(); // initialize components

  defineSheetMain();

  document.body.style.opacity = null;
  window.console.log('end main');

  document.querySelector('#btn-save')
    ..addEventListener('click', (Event e) {
      AlgLog.save();
    });

  // fire
  await new Future<void>(() => appController.fire('BTN1_CLICK', ''));

  document.querySelector('#btn1')
    ..addEventListener('click', (Event e) {
      appController.fire('BTN1_CLICK', '');
    });

  document.querySelector('#btn2')
    ..addEventListener('click', (Event e) {
      appController.fire('BTN2_CLICK', '');
    });
}
