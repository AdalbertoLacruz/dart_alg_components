// @copyright 2017-2018 adalberto.lacruz@gmail.com
@TestOn('browser')
import 'dart:html';
import 'package:test/test.dart';
import 'package:dart_alg_components/dart_alg_components.dart';

void main() {
  final HtmlElement element = new DivElement();

  group('FHtml', () {
    test('toggle', () {
      final String attrName = 'attbol';
      String attValue;

      FHtml.attributeToggle(element, attrName, force: true, type: '-remove');
      attValue = element.getAttribute(attrName);
//      print ('FHTML ____ $attrName = *$attValue*');
      expect(attValue, '');
    });
  });
}
