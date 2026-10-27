import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/app_state.dart';
import '../widgets/dn_card.dart';
import '../widgets/toast.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    final rows = [
      ('Auto-Buy', () => Navigator.of(context).pushNamed('/auto-buy')),
      ('Security', () => Navigator.of(context).pushNamed('/security')),
      ('My Referral', () => Navigator.of(context).pushNamed('/referral')),
      (
        'Notifications',
        () => Navigator.of(context).pushNamed('/notifications')
      ),
      ('Help & Support', () => Navigator.of(context).pushNamed('/help')),
      ('FAQs', () => Navigator.of(context).pushNamed('/help')),
      (
        'Account Settings',
        () => showDnToast(context, 'Account settings are not part of this demo')
      ),
      (
        'About DataNaija',
        () => showDnToast(context, 'DataNaija v1.0 (demo)')
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 30),
          children: [
            Text(
              'Profile',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            // Avatar + name
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    state.userAbbr,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.userName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      state.userEmail,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Menu rows
            DnCard(
              child: Column(
                children: rows.asMap().entries.map((e) {
                  final isLast = e.key == rows.length - 1;
                  return InkWell(
                    onTap: e.value.$2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: isLast
                          ? null
                          : const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: AppColors.borderRow),
                              ),
                            ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            e.value.$1,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.textMuted,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () =>
                  Navigator.of(context).pushReplacementNamed('/signin'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFC0352B),
                side: const BorderSide(color: Color(0xFFE9A9A3), width: 1.5),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Sign Out',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
