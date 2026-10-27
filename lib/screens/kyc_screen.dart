import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/app_state.dart';
import '../widgets/dn_button.dart';
import '../widgets/dn_chip.dart';
import '../widgets/toast.dart';

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  String _idType = 'BVN';
  final _idCtrl = TextEditingController();
  bool _consent = false;
  bool _busy = false;

  @override
  void dispose() {
    _idCtrl.dispose();
    super.dispose();
  }

  bool get _canVerify =>
      _idCtrl.text.length == 11 && _consent && !_busy;

  void _verify() async {
    setState(() => _busy = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    context.read<AppState>().completeKyc();
    setState(() => _busy = false);
    showDnToast(context, 'Verified. Your account number is ready.');
  }

  @override
  Widget build(BuildContext context) {
    final isVerified = context.watch<AppState>().isKycVerified;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify your identity'),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
          child: isVerified ? _verified(context) : _form(),
        ),
      ),
    );
  }

  Widget _verified(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 36),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          "You're verified",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Your personal funding account is ready. Transfers to it credit your wallet automatically.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 22),
        DnPrimaryButton(
          label: 'View my account number',
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed('/fund');
          },
        ),
      ],
    );
  }

  Widget _form() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nigerian banking rules require a BVN or NIN to give you a funding account. Choose either one. We send it to our partner for checking and do not keep the number.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        // BVN / NIN chips
        Row(
          children: ['BVN', 'NIN'].map((t) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: t == 'BVN' ? 8 : 0),
                child: DnChip(
                  label: t,
                  selected: _idType == t,
                  onTap: () {
                    setState(() {
                      _idType = t;
                      _idCtrl.clear();
                    });
                  },
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 4),
        // ID label + input
        Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 6),
          child: Text(
            _idType == 'BVN'
                ? 'Bank Verification Number (BVN)'
                : 'National Identification Number (NIN)',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        TextField(
          controller: _idCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
          ],
          decoration: const InputDecoration(hintText: '11 digits'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        // Consent checkbox
        GestureDetector(
          onTap: () => setState(() => _consent = !_consent),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: _consent,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => _consent = v ?? false),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'I agree to DataNaija checking this number with NIBSS or NIMC to create my account.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        DnPrimaryButton(
          label: _busy ? 'Checking...' : 'Verify',
          loading: _busy,
          onPressed: _canVerify ? _verify : null,
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'One ID can be linked to one DataNaija account.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
