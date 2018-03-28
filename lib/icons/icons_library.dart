library icons.alg_components;

import 'dart:html';

part '../src/base/alg_iron_iconset.dart';

part 'alg_av_icons.dart';
part 'alg_base64_icons.dart';
part 'alg_communication_icons.dart';
part 'alg_device_icons.dart';
part 'alg_editor_icons.dart';
part 'alg_hardware_icons.dart';
part 'alg_image_icons.dart';
part 'alg_iron_icons.dart';
part 'alg_maps_icons.dart';
part 'alg_notification_icons.dart';
part 'alg_places.dart';
part 'alg_social_icons.dart';

/// Load all icon definitions
void defineAllIcons() {
  defineAvIcons();
  defineBase64Icons();
  defineCommunicationIcons();
  defineDeviceIcons();
  defineEditorIcons();
  defineHardwareIcons();
  defineImageIcons();
  defineIronIcons();
  defineMapsIcons();
  defineNotificationIcons();
  definePlacesIcons();
  defineSocialIcons();
}
