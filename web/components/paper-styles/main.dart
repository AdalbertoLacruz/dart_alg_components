// @copyright 2017-2018 adalberto.lacruz@gmail.com

import 'dart:async';
import 'dart:html';
import 'package:dart_alg_components/components/all_components_library.dart';
import 'styles.dart';

Future<Null> main() async {
  algComponentsInit();

  // Rules.use paper-material-styles & paper-item-styles don't work with @apply
  defineSheetMainStyles();

  document.body.style.opacity = null;
}
