abstract interface class LauncherService {
  Future<void> launchWhatsApp(String e164Phone, {String? message});
  Future<void> launchPhone(String e164Phone);
  Future<void> launchUrl(String url);
}
