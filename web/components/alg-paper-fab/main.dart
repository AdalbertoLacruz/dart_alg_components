// @copyright 2017-2018 adalberto.lacruz@gmail.com

import 'dart:async';
import 'dart:html';
import 'package:dart_alg_components/components/all_components_library.dart';
import '../show_msg.dart';


Future<Null> main() async {
  algComponentsInit();
  ShowMsg.register();

  document.body.style.opacity = null;
}
