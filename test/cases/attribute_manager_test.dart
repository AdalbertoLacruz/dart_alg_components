// @copyright 2017-2018 adalberto.lacruz@gmail.com
@TestOn('browser')
//import 'dart:html';
import 'package:test/test.dart';
import 'package:dart_alg_components/dart_alg_components.dart';

void main() {
  final AttributeManager attributeManager = new AttributeManager(null);

  group('AttributeManager isUniqueAction', () {
    test('true/false', () {
      attributeManager.get('test'); // get entry
      expect(attributeManager.isUniqueAction('reflect'), true);
      expect(attributeManager.isUniqueAction('reflect'), false);
    });
  });

  group('AttributeManager isUniqueAction', () {
    test('list', () {
      attributeManager.get('test'); // get entry
      expect(attributeManager.isUniqueAction('modify', 'target'), true);
      expect(attributeManager.isUniqueAction('modify', 'target'), false);
    });
  });
}
