// @copyright 2017-2018 adalberto.lacruz@gmail.com

import 'package:dart_alg_components/src/core_library.dart';
import 'package:dart_alg_components/controller/alg_controller.dart';

///
class ShowMsg extends AlgComponent {
  ///
  static String tag = 'show-msg';

  ///
  factory ShowMsg() => new Element.tag(tag);

  ///
  ShowMsg.created() : super.created() {
    controller = this;
  }

  ///
  static void register() => AlgComponent.register(tag, ShowMsg);

  @override
  TemplateElement createTemplateStyle(RulesInstance css) => new TemplateElement()..setInnerHtml('''
    <style>
        :host {
          position: relative;
          width: 100%;
          height: 180px;
          outline: none;
        }

        :host:active {
          background-color: red;
        }

        #msg {
          border: solid grey 1px;
          position: absolute;
          top: 70px;
          bottom: 5px;
          overflow-y: scroll;
          left: 5px;
          right: 5px;
        }

        #msg > span {
          display: block;
          padding: 5px 0px 0px 5px;
        }
      </style>''', treeSanitizer: NodeTreeSanitizer.trusted);

  @override
  TemplateElement createTemplate() => super.createTemplate()..setInnerHtml('''
    <slot></slot>
    <div id="msg"></div>
    ''', treeSanitizer: NodeTreeSanitizer.trusted);

  // CONTROLLER

  ///
  /// As controller, receives a messsage
  /// and shows it into the div
  ///
  void fire(String channel, String message) {
    final HtmlElement msg = ids['msg'];

    final DateTime timeNow = new DateTime.now();
    final String stamp = timeNow.toIso8601String().split('T').last; // only hh:mm:ss:mmm
    msg
        ..innerHtml += '<span>$stamp $channel = $message</span>'
        ..scrollTop = msg.scrollHeight;
  }

  ///
  /// Associates an action with a channel.
  /// dummy
  ///
  dynamic subscribe(String channel, dynamic defaultValue, Function handler, ControllerStatus status) {
    window.console.log('controller subscribe: $channel');
    status.hasChannel = false;
    return null;
  }
}
