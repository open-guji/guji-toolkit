import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_dart, avoid_web_libraries_in_flutter
import 'dart:html' as html;

class LinkLauncher {
  static Future<void> launch(String url) async {
    if (kIsWeb) {
      html.window.open(url, '_blank');
    } else {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }
}
