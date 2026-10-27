import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/sample_data.dart';
import '../../widgets/dn_button.dart';
import '../../widgets/step_indicator.dart';

/// Step 1 of 3 — Select network and enter phone number.
class BuyDataScreen extends StatefulWidget {
  const BuyDataScreen({super.key});

  @override
  State<BuyDataScreen> createState() => _BuyDataScreenState();
}

class _BuyDataScreenState extends State<BuyDataScreen> {
  final _phoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    _phoneCtrl.text = state.selectedPhone;
    _phoneCtrl.addListener(() {
      state.setPhone(_phoneCtrl.text);
    });
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  bool get _phoneValid =>
      RegExp(r'^0[789][01]\d{8}$').hasMatch(_phoneCtrl.text);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back + title
              Row(
                children: [
                  _BackButton(onTap: () {}), // tab — no back
                  Text(
                    'Buy Data',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const StepIndicator(currentStep: 1),
              const SizedBox(height: 18),
              Text(
                'Select Network',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              // Network grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.6,
                children: SampleData.networks.map((n) {
                  final selected = state.selectedNetwork == n.name;
                  return GestureDetector(
                    onTap: () => state.setNetwork(n.name),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.borderLight,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        color: selected
                            ? const Color(0xFFF0FAF5)
                            : Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: n.bgColor,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              n.abbr,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: n.fgColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            n.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              // Phone number
              Padding(
                padding: const EdgeInsets.only(top: 14, bottom: 6),
                child: Text(
                  'Phone Number',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                decoration: const InputDecoration(
                  hintText: 'Enter phone number',
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'e.g. 08012345678',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 22),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _phoneCtrl,
                builder: (ctx, val, child) => DnPrimaryButton(
                  label: 'Next',
                  onPressed: _phoneValid
                      ? () => Navigator.of(context).pushNamed('/bundle')
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: IconButton(
        icon: const Icon(Icons.chevron_left, size: 30),
        onPressed: Navigator.of(context).canPop()
            ? () => Navigator.of(context).pop()
            : null,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
