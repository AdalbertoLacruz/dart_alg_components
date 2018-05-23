// @copyright 2017-2018 adalberto.lacruz@gmail.com

//import 'dart:html';
import 'package:dart_alg_components/controller/alg_controller.dart';

///
class AppController extends AlgController {
  @override
  String name = 'app-controller';

  /// Constructor
  AppController():super() {
    define<num>('btn1-text', TYPE_NUM, value: 5);
    define<String>('btn1-color', TYPE_STRING, value: 'red');
    define<String>('btn1-style-margin', TYPE_STRING);
    define<String>('btn1-style-background-color', TYPE_STRING, value: 'black');
    define<String>('btn1-classbind', TYPE_STRING, value: 'circle');

    define<num>('btn2-text', TYPE_NUM, value: 10);
    define<String>('btn2-color', TYPE_STRING, value: 'black');
    define<String>('btn2-style-margin', TYPE_STRING);
    define<String>('btn2-style-background-color', TYPE_STRING, value: 'black');
    define<String>('btn2-classbind', TYPE_STRING, value: 'circle');

    register['bus']
      ..observe((BusMessage value) {
        print('BUS: ${value.channel} = ${value.message}');
      });

    busManager
        ..onFire(<String>['BTN1_CLICK'], (dynamic message) {
          btn2Push();
          btn1Relax();
        })
        ..onFire(<String>['BTN2_CLICK', 'BTN2_ACTION'], (dynamic message) {
          btn1Push();
          btn2Relax();
        });
  }

  void btn1Push() {
    change('btn1-text', getValue('btn1-text') + 1);
    change('btn1-color', 'red');
    change('btn1-style-background-color', 'red');
    change('btn1-classbind', '+circle');
  }

  void btn1Relax() {
    change('btn1-color', 'blue');
    change('btn1-style-background-color', 'yellow');
    change('btn1-classbind', '-circle');
  }

  void btn2Push() {
    change('btn2-text', getValue('btn2-text') + 1);
    change('btn2-color', 'red');
    change('btn2-style-background-color', 'red');
    change('btn2-classbind', '+circle');
  }

  void btn2Relax() {
    change('btn2-color', 'blue');
    change('btn2-style-background-color', 'yellow');
    change('btn2-classbind', '-circle');
  }

//  ///
//  @override
//  dynamic subscribe(String channel, dynamic defaultValue, Function handler, ControllerStatus status) {
//    window.console.log('controller subscribe: $channel');
//    return super.subscribe(channel, defaultValue, handler, status);
//  }
}

