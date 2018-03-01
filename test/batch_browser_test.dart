// @copyright 2017-2018 adalberto.lacruz@gmail.com

// run> pub run test -p chrome test/batch_browser_test.dart
@TestOn('browser')

library test.alg_components;

import 'package:test/test.dart';
import 'package:dart_alg_components/dart_alg_components.dart';

part './cases/attribute_manager_case.dart';
part './cases/f_html_case.dart';

void main() {
  attributeManagerTest();
  fHtmlTest();
}
