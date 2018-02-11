// @copyright 2017-2018 adalberto.lacruz@gmail.com

// run> pub run test -p chrome test/batch_test.dart

@TestOn('vm')
import 'package:test/test.dart';

void main() {
  boolTest();
}

void boolTest() {
  final bool result = true;
  group('bool', () {
    test('true', () {
      expect(result, true);
    });
  });
}
