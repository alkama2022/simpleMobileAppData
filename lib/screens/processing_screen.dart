import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/app_state.dart';

/// Processing spinner screen — shown while a purchase is in-flight.
class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  // Guards against confirmPurchase() being called more than once if the user
  // somehow re-enters this screen before the timer fires.
  bool _confirmed = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted || _confirmed) return;
      _confirmed = true;
      context.read<AppState>().confirmPurchase();
      Navigator.of(context).pushReplacementNamed('/success');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: _ProcessingContent(),
      ),
    );
  }
}

class _ProcessingContent extends StatelessWidget {
  const _ProcessingContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 64,
          height: 64,
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 6,
            backgroundColor: Color(0xFFD8EEE3),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Processing...',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.02 * 22,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Your data purchase is being processed.\nPlease don't close the app.",
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
