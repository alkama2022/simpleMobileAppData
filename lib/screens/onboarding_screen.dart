import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../widgets/dn_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _page = 0;

  static const List<({String title, String body})> _slides = [
    (
      title: 'Buy Data, Airtime and More',
      body:
          'Stay connected with affordable data and airtime on all networks in Nigeria.',
    ),
    (
      title: 'Your Wallet, Your Control',
      body:
          'Fund your wallet and enjoy faster, easier transactions anytime, anywhere.',
    ),
  ];

  void _next() {
    if (_page == 0) {
      setState(() => _page = 1);
    } else {
      Navigator.of(context).pushReplacementNamed('/signin');
    }
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_page];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
          child: Column(
            children: [
              // Illustration
              Expanded(
                child: Center(child: _Illustration(page: _page)),
              ),
              // Title
              Text(
                slide.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.02 * 25,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              // Body
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  slide.body,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                    height: 1.45,
                  ),
                ),
              ),
              // Dots
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    2,
                    (i) => _Dot(active: i == _page),
                  ),
                ),
              ),
              // Continue
              DnPrimaryButton(label: 'Continue', onPressed: _next),
              const SizedBox(height: 6),
              // Skip
              DnTextButton(
                label: 'Skip',
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed('/signin'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? AppColors.primary : const Color(0xFFCFD9D3),
      ),
    );
  }
}

class _Illustration extends StatelessWidget {
  final int page;
  const _Illustration({required this.page});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      height: 230,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.bgGreen,
      ),
      child: Center(
        child: page == 0 ? _slide0() : _slide1(),
      ),
    );
  }

  Widget _slide0() {
    // Person holding phone with ₦ coin — simplified iconic version
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 90,
          decoration: BoxDecoration(
            color: AppColors.textDark,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(5),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Center(
              child: Icon(Icons.wifi, color: AppColors.primary, size: 24),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
          ),
          alignment: Alignment.center,
          child: const Text(
            '₦',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _slide1() {
    // Wallet with ₦ coin
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 70,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: 12),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: Colors.white,
                child: Text(
                  '₦',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFF5B83D),
          ),
          alignment: Alignment.center,
          child: const Text(
            '₦',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }
}
