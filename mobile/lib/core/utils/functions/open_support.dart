import 'package:url_launcher/url_launcher.dart';

Future<void> openPhoneDialer(String phone) async {
  final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
  if (cleaned.isEmpty) return;
  final uri = Uri(scheme: 'tel', path: cleaned);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}

Future<void> openSupportEmail(String email) async {
  if (email.trim().isEmpty) return;
  final gmailApp = Uri.parse('googlegmail://co?to=${Uri.encodeComponent(email)}');
  if (await canLaunchUrl(gmailApp)) {
    await launchUrl(gmailApp);
    return;
  }
  final gmailWeb = Uri.parse(
    'https://mail.google.com/mail/?view=cm&fs=1&to=${Uri.encodeComponent(email)}',
  );
  if (await canLaunchUrl(gmailWeb)) {
    await launchUrl(gmailWeb, mode: LaunchMode.externalApplication);
    return;
  }
  await launchUrl(Uri(scheme: 'mailto', path: email));
}
