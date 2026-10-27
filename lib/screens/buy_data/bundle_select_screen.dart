import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/models.dart';
import '../../core/sample_data.dart';
import '../../widgets/dn_button.dart';
import '../../widgets/dn_chip.dart';
import '../../widgets/step_indicator.dart';

/// Step 2 of 3 — Choose data type and bundle plan.
class BundleSelectScreen extends StatelessWidget {
  const BundleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final net = SampleData.networkByName(state.selectedNetwork);
    final bundleType = SampleData.bundleTypes[state.selectedBundleType]!;

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
                    'Select Data Bundle',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const StepIndicator(currentStep: 2),
              const SizedBox(height: 14),
              // Network badge + Change
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Change',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Data type chips
              Text(
                'Choose data type',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: SampleData.bundleTypes.keys.map((type) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: DnChip(
                        label: type,
                        selected: state.selectedBundleType == type,
                        onTap: () => state.setBundleType(type),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                bundleType.description,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 14),
              // Plans
              ...bundleType.plans.map(
                (plan) => _PlanRow(
                  plan: plan,
                  selected: state.selectedPlan.gb == plan.gb &&
                      state.selectedPlan.price == plan.price,
                  onTap: () => state.setPlan(plan),
                ),
              ),
              const SizedBox(height: 12),
              DnPrimaryButton(
                label: 'Continue',
                onPressed: () => Navigator.of(context).pushNamed('/review'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  final DataPlan plan;
  final bool selected;
  final VoidCallback onTap;

  const _PlanRow({
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderLight,
            width: 1.5,
          ),
          color: selected ? const Color(0xFFF0FAF5) : Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  plan.gb,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  plan.days,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
                if (plan.isHot) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.pendingBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Today only',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.pendingFg,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Text(
              plan.priceFormatted,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
