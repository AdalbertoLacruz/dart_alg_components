// @copyright 2017-2018 adalberto.lacruz@gmail.com
part of test.alg_components;

void fHtmlTest() {
  final HtmlElement element = new DivElement();

  group('FHtml', () {
    test('toggle', () {
      final String attrName = 'attbol';
      String attValue;

      FHtml.attributeToggle(element, attrName, force: true, type: '-remove');
      attValue = element.getAttribute(attrName);
//      print ('FHTML ____ $attrName = *$attValue*');
      expect(attValue, '');
    });
  });
}
