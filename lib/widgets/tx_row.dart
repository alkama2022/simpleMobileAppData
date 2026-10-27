import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/models.dart';
import 'dn_status_pill.dart';

/// One transaction row — matches `.tx` in the prototype.
class TxRow extends StatelessWidget {
  final Transaction tx;
  final VoidCallback onTap;
  final bool isLast;
  final bool showDate;

  const TxRow({
    super.key,
    required this.tx,
    required this.onTap,
    this.isLast = false,
    this.showDate = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  bottom: BorderSide(color: AppColors.borderRow),
                ),
        ),
        child: Row(
          children: [
            // Icon circle
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tx.iconBgColor,
              ),
              alignment: Alignment.center,
              child: Text(
                tx.iconLetter,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: tx.iconFgColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Title + sub
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    showDate ? '${tx.sub} · ${tx.date}' : tx.sub,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Amount + status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  tx.formattedAmount,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: tx.isCredit
                        ? AppColors.amtPositive
                        : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                DnStatusPill(status: tx.status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
