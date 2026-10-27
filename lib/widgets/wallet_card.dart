import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';

/// Wallet balance card — matches `.wal` in the prototype.
class WalletCard extends StatelessWidget {
  final String balanceText;
  final bool hidden;
  final VoidCallback onToggleHide;
  final VoidCallback onFund;
  final bool isKycVerified;
  final VoidCallback onVerify;
  final VoidCallback? onCopyAccount;
  final bool accountCopied;
  // Optional: show a second action button (e.g. History)
  final String? secondActionLabel;
  final VoidCallback? onSecondAction;

  const WalletCard({
    super.key,
    required this.balanceText,
    required this.hidden,
    required this.onToggleHide,
    required this.onFund,
    required this.isKycVerified,
    required this.onVerify,
    this.onCopyAccount,
    this.accountCopied = false,
    this.secondActionLabel,
    this.onSecondAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label + eye
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Wallet Balance',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.walletMuted,
                ),
              ),
              GestureDetector(
                onTap: onToggleHide,
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(
                    Icons.visibility_outlined,
                    color: AppColors.walletMuted,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          // Balance
          Text(
            balanceText,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.02 * 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: _WalletActionButton(
                  label: 'Fund Wallet',
                  onTap: onFund,
                  outlined: true,
                ),
              ),
              if (secondActionLabel != null && onSecondAction != null) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: _WalletActionButton(
                    label: secondActionLabel!,
                    onTap: onSecondAction!,
                    outlined: false,
                    bgColor: const Color(0xFF0A6F45),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          // Account row
          _accountRow(context),
        ],
      ),
    );
  }

  Widget _accountRow(BuildContext context) {
    if (isKycVerified) {
      return _AcRow(
        label: '[BANK NAME] · 0123456789',
        buttonLabel: accountCopied ? 'Copied' : 'Copy',
        onTap: onCopyAccount ?? () {},
      );
    }
    return _AcRow(
      label: 'Verify to get your account number',
      buttonLabel: 'Verify',
      onTap: onVerify,
    );
  }
}

class _WalletActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool outlined;
  final Color? bgColor;

  const _WalletActionButton({
    required this.label,
    required this.onTap,
    required this.outlined,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: outlined ? Colors.white : bgColor ?? AppColors.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: outlined ? AppColors.primary : Colors.white,
          ),
        ),
      ),
    );
  }
}

class _AcRow extends StatelessWidget {
  final String label;
  final String buttonLabel;
  final VoidCallback onTap;

  const _AcRow({
    required this.label,
    required this.buttonLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9),
              ),
              alignment: Alignment.center,
              child: Text(
                buttonLabel,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
