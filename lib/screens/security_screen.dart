import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/app_state.dart';
import '../widgets/dn_card.dart';
import '../widgets/toast.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    // Action rows (tap → navigate / toggle sheet)
    final links = [
      ('***', 'Change Password', 'Change your account password'),
      ('PIN', 'Transaction Passcode', 'Set or change your 4-digit passcode'),
    ];

    // Toggle rows
    final toggles = [
      (
        abbr: 'FP',
        name: 'Fingerprint',
        sub: 'Sign in and confirm purchases with your fingerprint',
        value: state.isBiometricEnabled,
        onToggle: () => state.toggleBiometric(),
      ),
      (
        abbr: 'N',
        name: 'Show wallet balance',
        sub: 'Show or hide your balance on Home',
        value: state.isBalanceVisible,
        onToggle: () => state.toggleBalanceVisibility(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security'),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
          children: [
            DnCard(
              child: Column(
                children: [
                  ...links.asMap().entries.map((e) {
                    final r = e.value;
                    return InkWell(
                      onTap: () => showDnToast(
                        context,
                        '${r.$2} is not part of this demo',
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: AppColors.borderRow),
                          ),
                        ),
                        child: Row(
                          children: [
                            _IconCircle(abbr: r.$1),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    r.$2,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    r.$3,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: AppColors.textMuted,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  ...toggles.asMap().entries.map((e) {
                    final t = e.value;
                    final isLast = e.key == toggles.length - 1;
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: isLast
                          ? null
                          : const BoxDecoration(
                              border: Border(
                                bottom:
                                    BorderSide(color: AppColors.borderRow),
                              ),
                            ),
                      child: Row(
                        children: [
                          _IconCircle(abbr: t.abbr),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.name,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  t.sub,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _Switch(
                            value: t.value,
                            onChanged: (_) => t.onToggle(),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Your fingerprint stays on your phone. DataNaija never sees or stores it.",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  final String abbr;
  const _IconCircle({required this.abbr});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.iconBg,
      ),
      alignment: Alignment.center,
      child: Text(
        abbr,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.iconFg,
        ),
      ),
    );
  }
}

/// Custom switch matching `.sw` prototype CSS — avoids Material Switch styling.
class _Switch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _Switch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 50,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: value ? AppColors.primary : const Color(0xFFC4CCC8),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 150),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
