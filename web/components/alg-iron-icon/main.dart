// @copyright 2017-2018 adalberto.lacruz@gmail.com

import 'dart:async';
import 'dart:html';
import 'package:dart_alg_components/components/all_components_library.dart';
import 'app_demo.dart';

Future<Null> main() async {
  algComponentsInit();
  AppDemo.register();

  document.body.style.opacity = null;
}
