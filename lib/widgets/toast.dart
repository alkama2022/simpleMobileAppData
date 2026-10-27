import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shows a brief bottom toast matching the prototype's `.toast` style.
void showDnToast(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  final entry = OverlayEntry(
    builder: (ctx) => _DnToast(message: message),
  );
  overlay.insert(entry);
  Future.delayed(const Duration(milliseconds: 1800), entry.remove);
}

class _DnToast extends StatefulWidget {
  final String message;
  const _DnToast({required this.message});

  @override
  State<_DnToast> createState() => _DnToastState();
}

class _DnToastState extends State<_DnToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) _ctrl.reverse();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 96,
      child: FadeTransition(
        opacity: _opacity,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF10231A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.message,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
