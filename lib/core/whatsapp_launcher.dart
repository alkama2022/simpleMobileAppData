import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:url_launcher/url_launcher.dart';

/// Centralises all WhatsApp / external-URL launching logic.
///
/// Strategy for each call:
///   1. Try the preferred URI (wa.me deep-link or channel URL).
///   2. If the device cannot handle it (WhatsApp not installed, restricted
///      environment), fall back to opening the same URL in the default browser.
///   3. If both fail, return false so the caller can show an error message.
class WhatsAppLauncher {
  WhatsAppLauncher._();

  /// WhatsApp direct-chat deep-link with a pre-filled message.
  /// Exposed for testing via [chatUri].
  static final Uri _chatUri = Uri.parse(
    'https://wa.me/2348126573474'
    '?text=${Uri.encodeComponent('Hello, I need assistance with your application.')}',
  );

  /// Official WhatsApp Channel URL.
  /// Exposed for testing via [channelUri].
  static final Uri _channelUri = Uri.parse(
    'https://whatsapp.com/channel/0029Vb9lWtd2Jl8GYqy2YP0r',
  );

  // Visible for testing only — do not use in production code.
  @visibleForTesting
  static Uri get chatUri => _chatUri;

  @visibleForTesting
  static Uri get channelUri => _channelUri;

  /// Opens a direct WhatsApp conversation with the support number.
  /// Returns true on success, false if nothing could be opened.
  static Future<bool> openChat() => _launch(_chatUri);

  /// Opens the WhatsApp Channel in WhatsApp or a browser.
  /// Returns true on success, false if nothing could be opened.
  static Future<bool> openChannel() => _launch(_channelUri);

  /// Shared launcher: tries ExternalApplication first, falls back to browser.
  static Future<bool> _launch(Uri uri) async {
    // Prefer opening in the WhatsApp app if installed.
    if (await canLaunchUrl(uri)) {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (ok) return true;
    }
    // Fallback: open in the system browser (covers web-only environments and
    // devices without WhatsApp installed).
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.platformDefault);
    }
    return false;
  }
}
