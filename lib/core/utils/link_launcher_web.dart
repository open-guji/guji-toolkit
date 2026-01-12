import 'package:web/web.dart' as web;

Future<void> launchUrlImpl(String url) async {
  web.window.open(url, '_blank');
}
