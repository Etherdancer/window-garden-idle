@JS()
library pwa_install;

import 'dart:js_interop';

@JS('isInstallable')
external bool isPwaInstallable();

@JS('promptInstall')
external void promptPwaInstall();
