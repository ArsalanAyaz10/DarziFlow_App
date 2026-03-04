import 'package:app_links/app_links.dart';
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
    if (uri.pathSegments.contains('reset-password')) {
      final token = uri.pathSegments.last;

      Get.toNamed('/reset-password', arguments: token);
    }
  }
}
