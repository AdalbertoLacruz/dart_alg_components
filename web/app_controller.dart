// @copyright 2017-2018 adalberto.lacruz@gmail.com

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

    define<num>('btn2-text', TYPE_NUM, value: 10);
    define<String>('btn2-color', TYPE_STRING, value: 'black');
    define<String>('btn2-style-margin', TYPE_STRING);
    define<String>('btn2-style-background-color', TYPE_STRING, value: 'black');

    register['bus']
      ..observe((BusMessage value) {
        print('BUS: ${value.channel} = ${value.message}');
      });
  }

  @override
  void fire(String channel, dynamic message) {
    super.fire(channel, message);

    switch (channel) {
      case 'BTN1_CLICK':
        btn2Push();
        btn1Relax();
        break;
      case 'BTN2_CLICK':
      case 'BTN2_ACTION':
        btn1Push();
        btn2Relax();
        break;
      default:
    }
  }

  void btn1Push() {
    change('btn1-text', getValue('btn1-text') + 1);
    change('btn1-color', 'red');
    change('btn1-style-background-color', 'red');
  }

  void btn1Relax() {
    change('btn1-color', 'blue');
    change('btn1-style-background-color', 'yellow');
  }

  void btn2Push() {
    change('btn2-text', getValue('btn2-text') + 1);
    change('btn2-color', 'red');
    change('btn2-style-background-color', 'red');
  }

  void btn2Relax() {
    change('btn2-color', 'blue');
    change('btn2-style-background-color', 'yellow');
  }
}

