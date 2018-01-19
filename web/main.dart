// @copyright 2017-2018 adalberto.lacruz@gmail.com

import 'dart:async';
import 'dart:html';
import 'package:dart_alg_components/dart_alg_components.dart';
import 'styles.dart';

Future<Null> main() async {
  await run(); // initialize components
  defineSheetMain();

  document.body.style.visibility = '';
}
