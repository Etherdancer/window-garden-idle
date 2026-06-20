@JS()
library pwa_install;

import 'package:js/js.dart';

@JS('isInstallable')
external bool isPwaInstallable();

@JS('promptInstall')
external void promptPwaInstall();
