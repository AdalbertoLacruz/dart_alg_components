// @copyright 2017-2018 adalberto.lacruz@gmail.com

import 'dart:async';
import 'dart:html';
import 'package:dart_alg_components/components/all_components_library.dart';
import 'package:dart_alg_components/styles/styles_library.dart';
import 'package:dart_alg_components/src/base/alg_log.dart';
import 'app_controller.dart';
//import 'styles.dart';

Future<Null> main() async {
  AlgLog.disabled = false;
  new AppController();
  allComponentsRegister(); // initialize components

  defineStyleSheetDefaultTheme();
//  defineSheetMain();

  document.body.style.opacity = null;
  Rules.applySheet();
  window.console.log('end main');

  document.querySelector('#btn-save')
    ..addEventListener('click', (Event e) {
      AlgLog.save();
    });
}
