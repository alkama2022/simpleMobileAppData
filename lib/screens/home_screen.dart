import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/app_state.dart';
import '../core/models.dart';
import '../core/sample_data.dart';
import '../widgets/wallet_card.dart';
import '../widgets/tx_row.dart';
import '../widgets/dn_card.dart';
import '../widgets/dn_button.dart';
import '../widgets/toast.dart';
import 'main_scaffold.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 26, 20, 96),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ── Header ─────────────────────────────────────
                      _Header(state: state),
                      const SizedBox(height: 16),
                      // ── Wallet card ─────────────────────────────────
                      WalletCard(
                        balanceText: state.balanceText,
                        hidden: state.balanceHidden,
                        onToggleHide: () => state.toggleBalanceHidden(),
                        onFund: () => Navigator.of(context).pushNamed('/fund'),
                        isKycVerified: state.isKycVerified,
                        onVerify: () => Navigator.of(context).pushNamed('/kyc'),
                      ),
                      // ── KYC banner ──────────────────────────────────
                      if (!state.isKycVerified) ...[
                        const SizedBox(height: 12),
                        _KycBanner(
                          onTap: () => Navigator.of(context).pushNamed('/kyc'),
                        ),
                      ],
                      // ── Quick actions ───────────────────────────────
                      const SizedBox(height: 12),
                      _QuickActions(state: state),
                      // ── Popular bundles ─────────────────────────────
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Popular Data Bundles',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          DnTextButton(
                            label: 'See All',
                            onPressed: () {
                              final scaffold = context
                                  .findAncestorStateOfType<MainScaffoldState>();
                              scaffold?.switchTab(1);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _PopularBundles(state: state),
                      // ── Recent transactions ─────────────────────────
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Transactions',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          DnTextButton(
                            label: 'See All',
                            onPressed: () {
                              final scaffold = context
                                  .findAncestorStateOfType<MainScaffoldState>();
                              scaffold?.switchTab(2);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      DnCard(
                        child: Column(
                          children: state.transactions
                              .take(3)
                              .toList()
                              .asMap()
                              .entries
                              .map(
                                (e) => TxRow(
                                  tx: e.value,
                                  isLast:
                                      e.key == state.transactions.take(3).length - 1,
                                  onTap: () => Navigator.of(context).pushNamed(
                                    '/transaction-detail',
                                    arguments: e.value,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
            // ── FAB ─────────────────────────────────────────────
            Positioned(
              right: 16,
              bottom: 88,
              child: FloatingActionButton(
                onPressed: () => Navigator.of(context).pushNamed('/help'),
                backgroundColor: AppColors.primary,
                tooltip: 'Chat with support',
                elevation: 6,
                child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final AppState state;
  const _Header({required this.state});

  static String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning!';
    if (hour < 17) return 'Good afternoon!';
    return 'Good evening!';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${state.userName.split(' ').first}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              _greeting(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, size: 22),
              onPressed: () => Navigator.of(context).pushNamed('/notifications'),
              tooltip: 'Notifications',
            ),
            GestureDetector(
              onTap: () {
                final scaffold =
                    context.findAncestorStateOfType<MainScaffoldState>();
                scaffold?.switchTab(3);
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                alignment: Alignment.center,
                child: Text(
                  state.userAbbr,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _KycBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _KycBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF3DFA8)),
        ),
        child: Text(
          'Verify your identity to get your funding account ›',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF5A4A12),
          ),
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final AppState state;
  const _QuickActions({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QuickAction(
          icon: Icons.wifi,
          label: 'Buy Data',
          onTap: () {
            final scaffold =
                context.findAncestorStateOfType<MainScaffoldState>();
            scaffold?.switchTab(1);
          },
        ),
        _QuickAction(
          icon: Icons.phone_android,
          label: 'Buy Airtime',
          onTap: () => showDnToast(context, 'Airtime is coming soon'),
        ),
        _QuickAction(
          icon: Icons.autorenew,
          label: 'Auto-Buy',
          onTap: () => Navigator.of(context).pushNamed('/auto-buy'),
        ),
        _QuickAction(
          icon: Icons.help_outline,
          label: 'Help',
          onTap: () => Navigator.of(context).pushNamed('/help'),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.bgGreen,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PopularBundles extends StatelessWidget {
  final AppState state;
  const _PopularBundles({required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: SampleData.popularBundles.map((b) {
          final net = SampleData.networkByName(b.net);
          return GestureDetector(
            onTap: () {
              state.setNetwork(b.net);
              state.setBundleType('SME');
              // Select the matching plan
              final plans = SampleData.bundleTypes['SME']?.plans ?? [];
              final plan = plans.firstWhere(
                (p) => p.gb == b.gb && p.price == b.price,
                orElse: () => DataPlan(
                  gb: b.gb,
                  days: b.days,
                  price: b.price,
                ),
              );
              state.setPlan(plan);
              final scaffold =
                  context.findAncestorStateOfType<MainScaffoldState>();
              scaffold?.switchTab(1);
            },
            child: Container(
              width: 104,
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderLight, width: 2),
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: net.bgColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      b.net,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: net.fgColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    b.gb,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '₦${b.price}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.amtPositive,
                    ),
                  ),
                  Text(
                    b.days,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
