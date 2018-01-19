// @copyright 2017-2018 adalberto.lacruz@gmail.com

import 'package:dart_alg_components/dart_alg_components.dart';

void defineSheetMain() {
  defineTypography();

  Rules.sheet('main', '''
    html, body {
      width: 100%;
      height: 100%;
      margin: 0;
      padding: 0;
      font-family: 'Roboto', sans-serif;
      color: lightblue;
    }
    
    body {
      --test: {
        color: red;
      };
    }
  ''');
}
