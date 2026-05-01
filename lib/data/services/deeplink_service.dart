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
      _handleDeepLink(initialUri);
    }
    _listenForLinks();
  }

  void _listenForLinks() {
    _appLinks.uriLinkStream.listen((Uri uri) {
      _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) {
    // Check if the link is a reset password link (handles both HTTPS and custom schemes)
    if (uri.pathSegments.contains('reset-password') || uri.host == 'reset-password') {
      final token = uri.pathSegments.last;
      
      // Store token for SplashScreen to catch if it's currently initializing
      box.write('reset_token', token);

      Future.delayed(const Duration(milliseconds: 500), () {
        Get.offAllNamed('/resetpassword', arguments: token);
      });
    }
  }
}
