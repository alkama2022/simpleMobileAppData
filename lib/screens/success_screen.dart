import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/app_state.dart';
import '../widgets/dn_button.dart';
import '../widgets/dn_card.dart';

/// Purchase success screen.
class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    // Guard: if no transactions exist yet, show a safe fallback message.
    if (state.transactions.isEmpty) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: AppColors.primary, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Purchase Successful',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 24),
                DnPrimaryButton(
                  label: 'Back to Home',
                  onPressed: () =>
                      Navigator.of(context).popUntil((r) => r.isFirst),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Find the transaction we just created.
    final tx = state.lastPurchasedTxId != null
        ? state.transactions.firstWhere(
            (t) => t.id == state.lastPurchasedTxId,
            orElse: () => state.transactions.first,
          )
        : state.transactions.first;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
          child: Column(
            children: [
              // Success icon
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 14),
              Text(
                'Purchase Successful',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.02 * 22,
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  'You have successfully purchased ${state.selectedPlan.gb} data for ${state.selectedNetwork}.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Summary card
              DnCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _KV(label: 'Phone Number', value: tx.phone),
                    _KV(
                      label: 'Data Bundle',
                      value: '${state.selectedBundleType} · ${state.selectedPlan.gb} - ${state.selectedPlan.days}',
                    ),
                    _KV(label: 'Amount', value: state.selectedPlan.priceFormatted),
                    _KV(label: 'Reference ID', value: tx.ref),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              DnPrimaryButton(
                label: 'View Transaction',
                onPressed: () => Navigator.of(context).pushNamed(
                  '/transaction-detail',
                  arguments: tx,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    // Pop back to main (clear the buy-data stack)
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  },
                  child: Text(
                    'Back to Home',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KV extends StatelessWidget {
  final String label;
  final String value;

  const _KV({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderRow)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
