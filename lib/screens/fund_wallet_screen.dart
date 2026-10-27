import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/app_state.dart';
import '../core/models.dart';
import '../widgets/dn_button.dart';
import '../widgets/dn_chip.dart';
import '../widgets/toast.dart';

class FundWalletScreen extends StatefulWidget {
  const FundWalletScreen({super.key});

  @override
  State<FundWalletScreen> createState() => _FundWalletScreenState();
}

class _FundWalletScreenState extends State<FundWalletScreen> {
  final _amtCtrl = TextEditingController(text: '1000');
  String _method = 'Card Payment';
  bool _acctCopied = false;

  static const List<int> _quickAmounts = [1000, 2000, 5000, 10000];
  static const List<String> _methods = ['Card Payment', 'USSD'];

  @override
  void dispose() {
    _amtCtrl.dispose();
    super.dispose();
  }

  int get _amount => int.tryParse(_amtCtrl.text) ?? 0;

  void _copyAccount() {
    Clipboard.setData(const ClipboardData(text: '0123456789'));
    setState(() => _acctCopied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _acctCopied = false);
    });
  }

  void _fund(BuildContext context) {
    if (_amount < 100) return;
    context.read<AppState>().fundWallet(_amount, _method);
    showDnToast(context, 'Wallet funded with ₦${_amount.toLocaleString()}');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fund Wallet'),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Bank transfer account ─────────────────────────
              if (state.isKycVerified) ...[
                _AccountCard(
                  copied: _acctCopied,
                  onCopy: _copyAccount,
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {
                    state.simulateBankTransfer();
                    showDnToast(context, '₦2,000 received. Wallet credited.');
                    Navigator.of(context).pop();
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                    textStyle: GoogleFonts.plusJakartaSans(fontSize: 13),
                  ),
                  child: const Text('Demo: simulate a ₦2,000 transfer'),
                ),
              ] else ...[
                _VerifyPrompt(
                  onVerify: () => Navigator.of(context).pushNamed('/kyc'),
                ),
              ],
              // ── Card / USSD ───────────────────────────────────
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Or pay with card or USSD',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 14, bottom: 6),
                child: Text(
                  'Enter Amount',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextField(
                controller: _amtCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(7),
                ],
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
                decoration: const InputDecoration(hintText: '0'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 10),
              // Quick amount chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _quickAmounts.map((a) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: DnChip(
                        label: '₦${a.toLocaleString()}',
                        selected: _amount == a,
                        onTap: () {
                          _amtCtrl.text = '$a';
                          setState(() {});
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Select Payment Method',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              ..._methods.map((m) {
                final selected = _method == m;
                return GestureDetector(
                  onTap: () => setState(() => _method = m),
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
                        Text(
                          m,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (selected)
                          Text(
                            'Selected',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 14),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _amtCtrl,
                builder: (ctx, val, child) => DnPrimaryButton(
                  label: 'Continue',
                  onPressed: _amount >= 100 ? () => _fund(context) : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final bool copied;
  final VoidCallback onCopy;

  const _AccountCard({required this.copied, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pay from any bank or wallet app',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '0123456789',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.08 * 30,
            ),
          ),
          Text(
            'Chinedu Okafor · [BANK NAME]',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Copy this account number and send any amount from your favourite app. Your wallet is credited automatically.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: onCopy,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size.fromHeight(46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              copied ? 'Copied' : 'Copy account number',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerifyPrompt extends StatelessWidget {
  final VoidCallback onVerify;
  const _VerifyPrompt({required this.onVerify});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Get your funding account',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Verify with your BVN or NIN to get a personal account number. It takes about a minute.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: onVerify,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size.fromHeight(46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'Verify now',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
