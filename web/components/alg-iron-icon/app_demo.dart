
// @copyright @polymer\iron-icons\demo\index.html
// @copyright 2017-2018 adalberto.lacruz@gmail.com

import 'package:dart_alg_components/components/alg_iron_icon.dart';
import 'package:dart_alg_components/icons/icons_library.dart';
import 'package:dart_alg_components/src/core_library.dart';

///
/// Creates the iconset display
///
class AppDemo extends AlgComponent {
  ///
  static String tag = 'app-demo';

  ///
  factory AppDemo() => new Element.tag(tag);

  ///
  AppDemo.created() : super.created();

  ///
  static void register() {
    AlgComponent.register('alg-iron-icon', AlgIronIcon);
    AlgComponent.register(tag, AppDemo);
  }

  @override
  TemplateElement createTemplateStyle(RulesInstance css) => new TemplateElement()..setInnerHtml('''
    <style>
        h2 {
          text-transform: capitalize;
        }

        alg-iron-icon {
          transition: all 0.2s;
          -webkit-transition: all 0.2s;
        }

        alg-iron-icon:hover {
          fill: var(--google-yellow-700);
        }

        .set {
          display: block;
          text-align: center;
          margin: auto;
          padding: 1em 0;
          border-bottom: 1px solid silver;
        }

        .set:last-of-type {
          border-bottom: none;
        }

        .set:nth-of-type(4n-3) {
          color: var(--paper-grey-700);
        }

        .set:nth-of-type(4n-2) {
          color: var(--paper-pink-500);
        }

        .set:nth-of-type(4n-1) {
          color: var(--google-green-500);
        }

        .set:nth-of-type(4n) {
          color: var(--google-blue-500);
        }

        .container {
          display: inline-block;
          width: 10em;
          margin: 1em 0.5em;
          text-align: center;
        }

        .container > div {
          margin-top: 0.5em;
          color: black;
          font-size: 10px;
        }
      </style>''', treeSanitizer: NodeTreeSanitizer.trusted);

  @override
  TemplateElement createTemplate() {
    final TemplateElement template = super.createTemplate();

    final String innerHTML = '''
      <alg-iron-icon icon="image:wb-sunny"></alg-iron-icon>
      <span>Template support</span>''';

    template.setInnerHtml(innerHTML, treeSanitizer: NodeTreeSanitizer.trusted);
    return template;
  }

  ///
  @override
  void addStandardAttributes() { }

  @override
  void deferredConstructor() {
    super.deferredConstructor();

    /// We split in several append to better rendering (full string is > 100K)
    AlgIronIconset.listIconsets().forEach((String iconsetName) {
      final String innerHTML = '''
        <h2>$iconsetName</h2>
        <div class="set">
          ${AlgIronIconset.listIconset(iconsetName).map((String iconName) => '''
            <span class="container">
              <alg-iron-icon icon="$iconsetName:$iconName"></alg-iron-icon>
              <div>$iconName</div>
            </span>
        ''').toList().join('')}
        </div>
      ''';
      final DocumentFragment fragment = document.createDocumentFragment()
        ..setInnerHtml(innerHTML, treeSanitizer: NodeTreeSanitizer.trusted);
      shadowRoot.append(fragment);
    });
  }
}
