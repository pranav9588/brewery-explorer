import 'package:url_launcher/url_launcher.dart';

class Utilities {
  static Future<void> launchURL(String url) async {
    final uri = Uri.tryParse(url);

    if (uri == null) {
      throw "Invalid URL: $url";
    }

    if (!await canLaunchUrl(uri)) {
      throw "Cannot launch URL: $url";
    }

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication, // IMPORTANT
    );
  }
}
