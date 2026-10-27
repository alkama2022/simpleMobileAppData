import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_state.dart';
import '../core/app_colors.dart';
import '../core/models.dart';
import '../widgets/dn_button.dart';
import '../widgets/dn_card.dart';
import '../widgets/toast.dart';

class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final tx = args is Transaction ? args : context.read<AppState>().transactions.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
          child: Column(
            children: [
              DnCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon + status + subtitle
                    Row(
                      children: [
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tx.statusLabel,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: tx.statusColor,
                              ),
                            ),
                            Text(
                              '${tx.title} · ${tx.sub}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _KV(
                      label: 'Amount',
                      value: tx.formattedAmount,
                      valueColor: tx.isCredit
                          ? AppColors.amtPositive
                          : AppColors.textDark,
                      bold: true,
                    ),
                    _KV(label: 'Phone Number', value: tx.phone),
                    _KV(label: 'Date & Time', value: tx.date),
                    _KV(label: 'Reference ID', value: tx.ref, isLast: true),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              DnPrimaryButton(
                label: 'Share Receipt',
                onPressed: () =>
                    showDnToast(context, 'Receipt ready to share'),
              ),
              const SizedBox(height: 10),
              DnOutlinedButton(
                label: 'Back',
                onPressed: () => Navigator.of(context).pop(),
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
  final bool bold;
  final Color? valueColor;
  final bool isLast;

  const _KV({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
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
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              color: valueColor ?? AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
