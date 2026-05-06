import 'package:app_links/app_links.dart';
import 'package:dariziflow_app/core/utils/global.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';

class DeeplinkService extends GetxService {
  final AppLinks _appLinks = AppLinks();

  Future<void> init() async {
    final initialUri = await _appLinks.getInitialLink();

    if (initialUri != null) {
      // On app start, we only handle the link if it's NOT the one we just handled
      _handleDeepLink(initialUri, isInitial: true);
    }
    _listenForLinks();
  }

  void _listenForLinks() {
    _appLinks.uriLinkStream.listen((Uri uri) {
      // If the user manually clicks the link while app is running/opening, 
      // we ALWAYS handle it.
      _handleDeepLink(uri, isInitial: false);
    });
  }

  void _handleDeepLink(Uri uri, {bool isInitial = false}) {
    if (uri.pathSegments.contains('reset-password') || uri.host == 'reset-password') {
      final token = uri.pathSegments.last;
      
      if (isInitial) {
        // Let SplashScreen handle the navigation when the app is ready
        box.write('reset_token', token);
      } else {
        // App is already running, navigate immediately
        Get.toNamed('/resetpassword', arguments: token);
      }
    }
  }
}
