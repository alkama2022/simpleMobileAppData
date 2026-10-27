import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/app_state.dart';
import '../core/models.dart';
import '../core/sample_data.dart';
import '../widgets/dn_button.dart';
import '../widgets/dn_chip.dart';
import '../widgets/dn_card.dart';
import '../widgets/toast.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  String _tab = 'Campaign';
  bool _codeCopied = false;

  void _copyCode() {
    Clipboard.setData(const ClipboardData(text: 'CHINEDU12'));
    setState(() => _codeCopied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _codeCopied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Referral'),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
          children: [
            // Tabs
            Row(
              children: ['Campaign', 'Referrals'].map((t) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: t == 'Campaign' ? 8 : 0),
                    child: DnChip(
                      label: t,
                      selected: _tab == t,
                      onTap: () => setState(() => _tab = t),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            if (_tab == 'Campaign') ..._campaign(context, state),
            if (_tab == 'Referrals') ..._referrals(),
          ],
        ),
      ),
    );
  }

  List<Widget> _campaign(BuildContext context, AppState state) {
    final canMove = state.referralBonus >= state.referralMinMove;
    return [
      // Bonus card
      DnCard(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Referral bonus',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
              ),
            ),
            Text(
              '₦${state.referralBonus.toLocaleString()}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      DnOutlinedButton(
        label: 'Move bonus to wallet',
        onPressed: canMove
            ? () {
                state.moveReferralBonus();
                showDnToast(
                  context,
                  '₦${state.referralBonus.toLocaleString()} moved to your wallet',
                );
              }
            : null,
      ),
      const SizedBox(height: 6),
      Center(
        child: Text(
          canMove
              ? 'Moves ₦${state.referralBonus.toLocaleString()} into your wallet instantly.'
              : 'You need at least ₦${_minMove.toLocaleString()} to move bonus to your wallet.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      const SizedBox(height: 14),
      // How you earn
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
              'How you earn',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Earn ₦100 when a friend makes their first purchase, then 20% of our profit on every purchase they make, for life. Up to ₦5,000 a month.',
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
      const SizedBox(height: 14),
      // Referral code
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          'Your unique referral code',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      Container(
        padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary, width: 1.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'CHINEDU12',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.06 * 19,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _copyCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                minimumSize: const Size(0, 44),
                elevation: 0,
              ),
              child: Text(
                _codeCopied ? 'Copied' : 'Copy',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      DnPrimaryButton(
        label: 'Refer a friend',
        onPressed: () => showDnToast(context, 'Your phone share menu opens here'),
      ),
    ];
  }

  List<Widget> _referrals() {
    final friends = SampleData.referralFriends;
    return [
      DnCard(
        child: Column(
          children: friends.asMap().entries.map((e) {
            final f = e.value;
            final isLast = e.key == friends.length - 1;
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: isLast
                  ? null
                  : const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.borderRow),
                      ),
                    ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.iconBg,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      f.abbr,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.iconFg,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          f.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 2),
                          decoration: BoxDecoration(
                            color: f.isActive
                                ? AppColors.successBg
                                : AppColors.pendingBg,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            f.status,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: f.isActive
                                  ? AppColors.successFg
                                  : AppColors.pendingFg,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '+₦${f.earned.toLocaleString()}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.amtPositive,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      const SizedBox(height: 10),
      Text(
        "Earnings are added to your referral bonus when your friend's order is delivered.",
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          color: AppColors.textMuted,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
      ),
    ];
  }
}
