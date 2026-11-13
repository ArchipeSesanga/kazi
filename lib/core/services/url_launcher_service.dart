import 'package:url_launcher/url_launcher.dart' as ul;

import 'launcher_service.dart';

class UrlLauncherService implements LauncherService {
  @override
  Future<void> launchWhatsApp(String e164Phone, {String? message}) async {
    final cleaned = e164Phone.replaceAll('+', '');
    final query = message != null ? '?text=${Uri.encodeComponent(message)}' : '';
    await ul.launchUrl(
      Uri.parse('https://wa.me/$cleaned$query'),
      mode: ul.LaunchMode.externalApplication,
    );
  }

  @override
  Future<void> launchPhone(String e164Phone) async {
    await ul.launchUrl(Uri.parse('tel:$e164Phone'));
  }

  @override
  Future<void> launchUrl(String url) async {
    await ul.launchUrl(
      Uri.parse(url),
      mode: ul.LaunchMode.externalApplication,
    );
  }
}
