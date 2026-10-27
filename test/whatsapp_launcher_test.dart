import 'package:flutter_test/flutter_test.dart';
import 'package:data_naija/core/whatsapp_launcher.dart';

void main() {
  group('WhatsAppLauncher URI correctness', () {
    test('chat URI uses correct international number without plus or spaces', () {
      // Verify the deep-link contains the exact number in E.164 format (no +).
      expect(
        WhatsAppLauncher.chatUri.toString(),
        contains('wa.me/2348126573474'),
      );
    });

    test('chat URI pre-fills a message', () {
      expect(
        WhatsAppLauncher.chatUri.toString(),
        contains('text='),
      );
    });

    test('channel URI matches the exact supplied URL', () {
      expect(
        WhatsAppLauncher.channelUri.toString(),
        equals('https://whatsapp.com/channel/0029Vb9lWtd2Jl8GYqy2YP0r'),
      );
    });
  });
}
