// @copyright 2017-2018 adalberto.lacruz@gmail.com

@TestOn('vm')
import 'package:test/test.dart';
import 'package:dart_alg_components/src/base/binder_parser.dart';

void main() {
  group('Binder Parser Event (on-click=[[app-controller:BTN_CLICK]])', () {
    BinderParser binder;

    setUp(() {
      binder = new BinderParser('on-click', '[[app-controller:BTN_CLICK]]');
    });
    test('is Event Binder', () {
      expect(binder.isEventBinder, true);
    });
    test('handler name: click', () {
      expect(binder.handler, 'click');
    });
    test('controller name: app-controller', () {
      expect(binder.controller, 'app-controller');
    });
    test('channel name: BTN_CLICK', () {
      expect(binder.channel, 'BTN_CLICK');
    });
  });

  group('Binder Parser Attribute (attribute=[[app-controller:btn2-label=15]])', () {
    BinderParser binder;

    setUp(() {
      binder = new BinderParser('attribute', '[[app-controller:btn2-label=15]]');
    });
    test('is Attribute Binder', () {
      expect(binder.isAttributeBinder, true);
    });
    test('no sync []', () {
      expect(binder.isSync, false);
    });
    test('default value: 15', () {
      expect(binder.defaultValue, '15');
    });
  });

  group('Binder Parser Style (Style=property1:[[:channel1=value1]];property2:[[:channel2]])', () {
    BinderParser binder;

    setUp(() {
      binder = new BinderParser('style',
          'property1:[[:channel1=value1]];property2:[[:channel2]]', 'default-controller');
    });
    test('is Style Binder', () {
      expect(binder.isStyleBinder, true);
    });
    test('first property: property1', () {
      expect(binder.styleProperty, 'property1');
    });
    test('first channel: channel1', () {
      expect(binder.channel, 'channel1');
    });
    test('first value: value1', () {
      expect(binder.defaultValue, 'value1');
    });
    test('default controller: default-controller', () {
      expect(binder.controller, 'default-controller');
    });

    test('second property: property2', () {
      binder.next();
      expect(binder.styleProperty, 'property2');
    });
    test('second channel: channel2', () {
      binder.next();
      expect(binder.channel, 'channel2');
    });
    test('end style', () {
      binder.next();
      expect(binder.next(), false, reason: 'no more style properties');
    });
  });

  group('Binder Parser Style without property (style=[[:channel1=value1]])', () {
    BinderParser binder;

    setUp(() {
      binder = new BinderParser('style', '[[:channel1=value1]]');
    });
    test('Property empty', () {
      expect(binder.styleProperty, '');
    });
    test('channel: channel1', () {
      expect(binder.channel, 'channel1');
    });
  });

  group('Binder Parser Style with only property (style=property)', () {
    BinderParser binder;

    setUp(() {
      binder = new BinderParser('style', 'property');
    });
    test('property', () {
      expect(binder.styleProperty, 'property');
    });
  });

  group('Binder Parser style with value (style=property=value)', () {
    BinderParser binder;

    setUp(() {
      binder = new BinderParser('style', 'property=value');
    });
    test('get property/value', () {
      expect(binder.styleProperty, 'property', reason: 'get style property');
      expect(binder.value, 'value', reason: 'get style value');
    });
  });

  group('Binder Parser Sync Attribute (attribute={{:btn2-label}})', () {
    BinderParser binder;

    setUp(() {
      binder = new BinderParser('attribute', '{{:btn2-label}}');
    });
    test('sync {}', () {
      expect(binder.isSync, true);
    });
  });

  group('Binder Parser No Binding (attribute=value)', () {
    BinderParser binder;

    setUp(() {
      binder = new BinderParser('attribute', 'value');
    });
    test('no is', () {
      final bool isBinding = binder.isEventBinder || binder.isAttributeBinder || binder.isStyleBinder;
      expect(isBinding, false);
    });
    test('value', () {
      expect(binder.value, 'value');
    });
  });
}

