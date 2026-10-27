import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/models.dart';

/// Status badge pill — matches `.pill .p-s/.p-p/.p-f` in the prototype.
class DnStatusPill extends StatelessWidget {
  final TxStatus status;

  const DnStatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      TxStatus.successful => (AppColors.successBg, AppColors.successFg),
      TxStatus.pending => (AppColors.pendingBg, AppColors.pendingFg),
      TxStatus.failed => (AppColors.failedBg, AppColors.failedFg),
    };

    final label = switch (status) {
      TxStatus.successful => 'Successful',
      TxStatus.pending => 'Pending',
      TxStatus.failed => 'Failed',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
