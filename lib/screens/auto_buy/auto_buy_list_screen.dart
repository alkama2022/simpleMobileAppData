import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/auto_buy_model.dart';
import '../../core/auto_buy_state.dart';
import '../../widgets/dn_button.dart';
import '../../widgets/toast.dart';

/// Lists all Auto-Buy rules and lets the user manage them.
class AutoBuyListScreen extends StatelessWidget {
  const AutoBuyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AutoBuyState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto-Buy'),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: state.rules.isEmpty
            ? _EmptyState(
                onAdd: () =>
                    Navigator.of(context).pushNamed('/auto-buy/setup'),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                children: [
                  Text(
                    'Your scheduled data purchases.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // Disclaimer banner
                  const SizedBox(height: 10),
                  _DisclaimerBanner(),
                  const SizedBox(height: 14),
                  ...state.rules.map(
                    (rule) => _RuleCard(
                      rule: rule,
                      onToggle: () => state.setStatus(
                        rule.id,
                        rule.status == AutoBuyStatus.active
                            ? AutoBuyStatus.paused
                            : AutoBuyStatus.active,
                      ),
                      onEdit: () => Navigator.of(context).pushNamed(
                        '/auto-buy/setup',
                        arguments: rule,
                      ),
                      onDelete: () => _confirmDelete(context, state, rule),
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: state.rules.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () =>
                  Navigator.of(context).pushNamed('/auto-buy/setup'),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                'New Schedule',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AutoBuyState state,
    AutoBuyRule rule,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Delete schedule?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Auto-Buy for ${rule.bundleGb} on ${rule.networkName} will be deleted.',
          style: GoogleFonts.plusJakartaSans(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Delete',
              style: GoogleFonts.plusJakartaSans(color: AppColors.failedFg),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await state.deleteRule(rule.id);
      if (context.mounted) {
        showDnToast(context, 'Schedule deleted.');
      }
    }
  }
}

// ── Rule card ─────────────────────────────────────────────────────────────────

class _RuleCard extends StatelessWidget {
  final AutoBuyRule rule;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RuleCard({
    required this.rule,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = rule.status == AutoBuyStatus.active;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActive ? AppColors.primary : AppColors.borderLight,
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: network badge + status chip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _NetBadge(name: rule.networkName),
                    const SizedBox(width: 8),
                    Text(
                      rule.networkName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                _StatusChip(isActive: isActive),
              ],
            ),
            const SizedBox(height: 10),
            // Bundle + price
            _InfoRow(
              label: 'Bundle',
              value: rule.bundleSummary,
            ),
            _InfoRow(label: 'Price', value: rule.priceFormatted),
            _InfoRow(
              label: 'Recipient',
              value: rule.phoneNumber,
            ),
            _InfoRow(
              label: 'Frequency',
              value: rule.frequency.label +
                  (rule.frequency == ScheduleFrequency.custom
                      ? ' (${rule.customIntervalHours}h)'
                      : ''),
            ),
            _InfoRow(
              label: 'Next purchase',
              value: isActive ? rule.nextRunFormatted : '—',
              valueColor: AppColors.primary,
            ),
            const SizedBox(height: 12),
            // Recent execution history (up to 3)
            if (rule.executions.isNotEmpty) ...[
              Text(
                'Recent executions',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 4),
              ...rule.executions.take(3).map(_ExecutionRow.new),
              const SizedBox(height: 8),
            ],
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onToggle,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isActive
                          ? AppColors.pendingFg
                          : AppColors.primary,
                      side: BorderSide(
                        color: isActive
                            ? AppColors.pendingBg
                            : AppColors.primary,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text(
                      isActive ? 'Pause' : 'Resume',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onEdit,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textDark,
                      side: const BorderSide(
                        color: AppColors.borderLight,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text(
                      'Edit',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.failedFg,
                    size: 22,
                  ),
                  onPressed: onDelete,
                  tooltip: 'Delete schedule',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: valueColor ?? AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExecutionRow extends StatelessWidget {
  final AutoBuyExecution exec;
  const _ExecutionRow(this.exec);

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (exec.status) {
      AutoBuyExecutionStatus.success => ('✓ Success', AppColors.successFg),
      AutoBuyExecutionStatus.failed => ('✗ Failed', AppColors.failedFg),
      AutoBuyExecutionStatus.skippedInsufficientFunds =>
        ('⚠ Insufficient funds', AppColors.pendingFg),
    };
    final d = exec.executedAt;
    final months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
    ];
    final dateStr =
        '${months[d.month - 1]} ${d.day} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Text(
            dateStr,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _NetBadge extends StatelessWidget {
  final String name;
  const _NetBadge({required this.name});

  static const _colors = <String, (Color, Color)>{
    'MTN': (Color(0xFFFFCC00), Color(0xFF10231A)),
    'Airtel': (Color(0xFFE40000), Colors.white),
    'Glo': (Color(0xFF17A34A), Colors.white),
    '9mobile': (Color(0xFF1F2937), Color(0xFFB7F34A)),
  };

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colors[name] ?? (AppColors.primary, Colors.white);
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
      alignment: Alignment.center,
      child: Text(
        name.substring(0, 2),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isActive;
  const _StatusChip({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: isActive ? AppColors.successBg : AppColors.borderLight,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isActive ? 'Active' : 'Paused',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isActive ? AppColors.successFg : AppColors.textMuted,
        ),
      ),
    );
  }
}

class _DisclaimerBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3DFA8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 16, color: Color(0xFF5A4A12)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Auto-Buy runs while the app is open. For purchases to run when the app is closed, a backend scheduler is required (future feature).',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF5A4A12),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.bgGreen,
            ),
            child: const Icon(
              Icons.autorenew,
              size: 36,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Auto-Buy schedules',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a schedule to automatically purchase data at your chosen frequency.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          DnPrimaryButton(
            label: 'Create Schedule',
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }
}
