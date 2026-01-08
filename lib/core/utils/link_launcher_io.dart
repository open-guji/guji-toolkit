import 'package:url_launcher/url_launcher.dart' as launcher;

Future<void> launchUrlImpl(String url) async {
  final uri = Uri.parse(url);
  if (await launcher.canLaunchUrl(uri)) {
    await launcher.launchUrl(uri, mode: launcher.LaunchMode.externalApplication);
  }
}
