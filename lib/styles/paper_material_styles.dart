// @copyright @polymer\paper-styles\element-styles\paper-material-styles.js 3.0 20170822
// @copyright 2017-2018 adalberto.lacruz@gmail.com

part of alg_components;

///
/// Define mixins for paper material styles
///
@initMethod
void definePaperMaterialStyles() {
  if (Rules.isDefined('paper-material-styles'))
      return;

  defineShadow();

  Rules.defineDefault('--paper-material', '''
      display: block;
      position: relative;''');

  Rules.define('--paper-material-elevation-1', '''
      ${Rules.use('--shadow-elevation-2dp')}''');

  Rules.define('--paper-material-elevation-2', '''
      ${Rules.use('--shadow-elevation-4dp')}''');

  Rules.define('--paper-material-elevation-3', '''
      ${Rules.use('--shadow-elevation-6dp')}''');

  Rules.define('--paper-material-elevation-4', '''
      ${Rules.use('--shadow-elevation-8dp')}''');

  Rules.define('--paper-material-elevation-5', '''
      ${Rules.use('--shadow-elevation-16dp')}''');

  Rules.define('paper-material-styles', '''
      :host(.paper-material), .paper-material {
        ${Rules.use('--paper-material')}
      }
      :host(.paper-material[elevation="1"]), .paper-material[elevation="1"] {
        ${Rules.use('--paper-material-elevation-1')}
      }
      :host(.paper-material[elevation="2"]), .paper-material[elevation="2"] {
        ${Rules.use('--paper-material-elevation-2')}
      }
      :host(.paper-material[elevation="3"]), .paper-material[elevation="3"] {
        ${Rules.use('--paper-material-elevation-3')}
      }
      :host(.paper-material[elevation="4"]), .paper-material[elevation="4"] {
        ${Rules.use('--paper-material-elevation-4')}
      }
      :host(.paper-material[elevation="5"]), .paper-material[elevation="5"] {
        ${Rules.use('--paper-material-elevation-5')}
      }''');
}
