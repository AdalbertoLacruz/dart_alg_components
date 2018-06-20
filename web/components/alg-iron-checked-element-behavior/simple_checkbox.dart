// @copyright @polymer\iron-checked-element-behavior\demo\simple-checkbox.js
// @copyright 2017-2018 adalberto.lacruz@gmail.com

import 'package:dart_alg_components/components/alg_paper_button.dart';
import 'package:dart_alg_components/src/core_library.dart';

///
class SimpleCheckbox extends AlgComponent with AlgIronValidatableMixin, AlgIronCheckedElementMixin {
  ///
  static String tag = 'simple-checkbox';

  ///
  factory SimpleCheckbox() => new Element.tag(tag);

  ///
  SimpleCheckbox.created() : super.created() {
    mixinManager = new MixinManager();

    algIronValidatableInit(this);
    algIronCheckedElementInit(this);
  }

  ///
  static void register() => AlgComponent.register(tag, SimpleCheckbox);

  @override
  TemplateElement createTemplateStyle(RulesInstance css) => new TemplateElement()..setInnerHtml('''
    <style>
        :host {
          display: block;
        }

        :host([invalid]) span {
          color: red;
        }

        #labelText {
          display: inline-block;
          width: 100px;
        }
      </style>''', treeSanitizer: NodeTreeSanitizer.trusted);

  @override
  TemplateElement createTemplate() => super.createTemplate()..setInnerHtml('''
    <input type="checkbox" id="checkbox">
    <span id="labelText"></span>
    <alg-paper-button id="button" raised="">validate</alg-paper-button>
    ''', treeSanitizer: NodeTreeSanitizer.trusted);


  @override
  void deferredConstructor() {
    super.deferredConstructor();

    attributeManager
      ..define('label', type: TYPE_STRING, value: 'not validated')
      ..on((String value) {
        ids['labelText'].innerHtml = value;
      })
      ..autoDispatch()
      ..store((ObservableEvent<String> entry$) => label$ = entry$);

    (ids['button'] as AlgPaperButton).messageManager
      .on('action', (_) {
        validate(null);
        label$.update(invalid$.value ? 'is invalid' : 'is valid');
    });

    new EventManager(ids['checkbox'])
      ..on('tap', (_) {
        checked$.update((ids['checkbox'] as InputElement).checked);
      })
      ..subscribe();
  }

  ObservableEvent<String> label$;
}
