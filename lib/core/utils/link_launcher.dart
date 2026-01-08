import 'link_launcher_stub.dart'
    if (dart.library.html) 'link_launcher_web.dart'
    if (dart.library.io) 'link_launcher_io.dart';

class LinkLauncher {
  static Future<void> launch(String url) async {
    await launchUrlImpl(url);
  }
}
