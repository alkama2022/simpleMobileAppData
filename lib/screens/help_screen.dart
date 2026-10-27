import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/sample_data.dart';
import '../core/whatsapp_launcher.dart';
import '../widgets/dn_chip.dart';
import '../widgets/toast.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  String _tab = 'FAQs';
  int _openFaq = -1;

  // ── Shared launcher helper ────────────────────────────────────────────────
  Future<void> _openChat() async {
    final ok = await WhatsAppLauncher.openChat();
    if (!ok && mounted) {
      showDnToast(context, 'Could not open WhatsApp. Please try again.');
    }
  }

  Future<void> _openChannel() async {
    final ok = await WhatsAppLauncher.openChannel();
    if (!ok && mounted) {
      showDnToast(context, 'Could not open the WhatsApp channel. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
          children: [
            // ── Tab chips ─────────────────────────────────────────────────
            Row(
              children: ['FAQs', 'Contact Support'].map((t) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: t == 'FAQs' ? 8 : 0),
                    child: DnChip(
                      label: t,
                      selected: _tab == t,
                      onTap: () => setState(() => _tab = t),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // ── FAQs tab ──────────────────────────────────────────────────
            if (_tab == 'FAQs') ...[
              ...SampleData.faqs.asMap().entries.map((e) {
                final i = e.key;
                final faq = e.value;
                final open = _openFaq == i;
                return Column(
                  children: [
                    InkWell(
                      onTap: () =>
                          setState(() => _openFaq = open ? -1 : i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: AppColors.borderRow),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                faq.question,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text(
                              open ? '−' : '+',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (open)
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 14),
                        child: Text(
                          faq.answer,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ],

            // ── Contact Support tab ───────────────────────────────────────
            if (_tab == 'Contact Support') ...[
              // Option A — Direct WhatsApp chat
              _WhatsAppContactCard(
                icon: Icons.chat,
                iconColor: const Color(0xFF25D366), // WhatsApp green
                iconBg: const Color(0xFFE8FBF0),
                title: 'Chat with Support',
                description:
                    'Need help? Chat with our support team directly on WhatsApp.',
                detail: '+234 812 657 3474',
                actionLabel: 'Open WhatsApp',
                onTap: _openChat,
                semanticLabel: 'Chat with support on WhatsApp',
              ),
              const SizedBox(height: 12),
              // Option B — WhatsApp Channel
              _WhatsAppContactCard(
                icon: Icons.campaign_outlined,
                iconColor: const Color(0xFF25D366),
                iconBg: const Color(0xFFE8FBF0),
                title: 'Follow Our WhatsApp Channel',
                description:
                    'Stay updated with announcements, important information, and the latest news.',
                actionLabel: 'Open Channel',
                onTap: _openChannel,
                semanticLabel: 'Follow the DataNaija WhatsApp channel',
              ),
            ],

            const SizedBox(height: 18),

            // ── "Need more help?" card (always visible) ───────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.bgGreen,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.kycBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Need more help?',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Our support team is here for you.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextButton(
                    // "Get Help" now opens WhatsApp directly instead of a toast.
                    onPressed: _openChat,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: AppColors.primary,
                    ),
                    child: Text(
                      'Get Help',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable WhatsApp contact card ────────────────────────────────────────────
//
// Used for both Option A (direct chat) and Option B (channel). Extracted
// because the two cards share identical structure and differ only in data.

class _WhatsAppContactCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String description;
  final String? detail; // optional — shown for the phone-number card
  final String actionLabel;
  final VoidCallback onTap;
  final String semanticLabel;

  const _WhatsAppContactCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.description,
    this.detail,
    required this.actionLabel,
    required this.onTap,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon badge
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              // Text block
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                        height: 1.45,
                      ),
                    ),
                    if (detail != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        detail!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    // Action button — tapping the card or the button both work
                    GestureDetector(
                      onTap: onTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF25D366),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.open_in_new,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              actionLabel,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
