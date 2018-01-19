import 'package:dart_alg_components/dart_alg_components.dart';

void defineSheetDemoPages() {
  Rules.define('--horizontal-section-container', '''
        ${Rules.use('--layout-horizontal')}
        ${Rules.use('--layout-center-justified')}
        ${Rules.use('--layout-wrap')}''');

  Rules.sheet('demo-pages', '''
    body {
      ${Rules.use('--paper-font-common-base')}
      font-size: 14px;
      margin: 0;
      padding: 24px;
      background-color: var(--paper-grey-50);
    }

    .horizontal-section-container {
      ${Rules.use('--layout-horizontal')}
      ${Rules.use('--layout-center-justified')}
      ${Rules.use('--layout-wrap')}
    }
  
    .vertical-section-container {
      ${Rules.use('--layout-vertical')}
      ${Rules.use('--layout-center-justified')}
    }
  
    .horizontal-section {
      background-color: white;
      padding: 24px;
      margin-right: 24px;
      min-width: 200px;
  
      ${Rules.use('--shadow-elevation-2dp')}
    }

    .vertical-section {
      background-color: white;
      padding: 24px;
      margin: 0 24px 24px 24px;
  
      ${Rules.use('--shadow-elevation-2dp')}
    }
  
    .centered {
      max-width: 600px;
      margin-left: auto;
      margin-right: auto;
    }

    code {
      color: var(--google-grey-700);
    }
  
    body > div.layout.horizontal.center-justified {
      ${Rules.use('--layout-wrap')}
    }

    .demo-snippet {
      display: block;
      border-bottom: 1px solid #e0e0e0;
      background-color: white;
      padding: 20px;
      ${Rules.use('--shadow-elevation-2dp')}
      margin: 0 0 40px 0;
    }
  ''');
}
// .demo-snippet
//${CssStyle.getRule('--horizontal-section-container')}
