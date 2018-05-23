import '../icons/icons_library.dart';
import '../styles/styles_library.dart';

import 'alg_button.dart';
import 'alg_iron_icon.dart';
import 'alg_paper_button.dart';
import 'alg_paper_fab.dart';
import 'alg_paper_icon_button.dart';
import 'alg_test.dart';


/// Components register
void allComponentsRegister() {
  AlgTest.register();
  AlgButton.register();
  AlgIronIcon.register();
  AlgPaperButton.register();
  AlgPaperFab.register();
  AlgPaperIconButton.register();
}

///
/// Initialize the components library
///
void algComponentsInit() {
  defineAllIcons();
  definePaperItemStyles(); // drag all styles
  allComponentsRegister();
  Rules.applySheet();
}
