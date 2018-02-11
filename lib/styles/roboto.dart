// @copyright @polymer\font-roboto\roboto.js 20170803
// @copyright 2017-2018 adalberto.lacruz@gmail.com

part of styles.alg_components;

///
/// Define a link to roboto font
///
void defineRoboto() {
  if (Rules.isDefined('roboto'))
    return;

  final Element link = document.createElement('link')
      ..setAttribute('rel', 'stylesheet')
      ..setAttribute('type', 'text/css')
      ..setAttribute('href', 'https://fonts.googleapis.com/css?family=Roboto+Mono:400,700|Roboto:400,300,300italic,400italic,500,500italic,700,700italic')
      ..setAttribute('crossorigin', 'anonymous');
  document.head.append(link);
}
