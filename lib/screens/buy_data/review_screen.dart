import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/sample_data.dart';
import '../../widgets/dn_button.dart';
import '../../widgets/dn_card.dart';
import '../../widgets/step_indicator.dart';

/// Step 3 of 3 — Review and confirm purchase.
class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final net = SampleData.networkByName(state.selectedNetwork);
    final plan = state.selectedPlan;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: IconButton(
                      icon: const Icon(Icons.chevron_left, size: 30),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  Text(
                    'Review Purchase',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const StepIndicator(currentStep: 3),
              const SizedBox(height: 18),
              // Network badge
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: net.bgColor,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      net.abbr,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: net.fgColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    net.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Summary card
              DnCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _KV(label: 'Phone Number', value: state.selectedPhone),
                    _KV(
                      label: 'Data Bundle',
                      value:
                          '${state.selectedBundleType} · ${plan.gb} - ${plan.days}',
                    ),
                    _KV(label: 'Price', value: plan.priceFormatted),
                    _KV(label: 'Service Fee', value: '₦0'),
                    _KV(
                      label: 'Total',
                      value: plan.priceFormatted,
                      bold: true,
                      valueColor: AppColors.amtPositive,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              DnPrimaryButton(
                label: 'Confirm Purchase',
                onPressed: () => _confirm(context, state),
              ),
              const SizedBox(height: 8),
              DnTextButton(
                label: 'Cancel',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirm(BuildContext context, AppState state) {
    if (state.balance < state.selectedPlan.price) {
      // Replace this screen so Back from /fund returns to the bundle picker,
      // not to a review screen the user can no longer confirm.
      Navigator.of(context).pushReplacementNamed('/fund');
      return;
    }
    Navigator.of(context).pushNamed('/processing');
  }
}

class _KV extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  const _KV({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

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
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              color: bold ? AppColors.textDark : AppColors.textMuted,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              color: valueColor ?? AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
