import 'package:flutter/material.dart';

/// All design tokens extracted from the prototype's CSS variables and inline styles.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF0A7A4C);
  static const Color primaryDark = Color(0xFF09663F);
  static const Color primaryDeep = Color(0xFF075A39);

  // Text
  static const Color textDark = Color(0xFF10231A);
  static const Color textMuted = Color(0xFF5F6F66);

  // Backgrounds
  static const Color bgWhite = Color(0xFFFFFFFF);
  static const Color bgLight = Color(0xFFF6F9F7);
  static const Color bgGreen = Color(0xFFE6F4EC);

  // Borders
  static const Color border = Color(0xFFD5DED9);
  static const Color borderLight = Color(0xFFE3EAE6);
  static const Color borderRow = Color(0xFFE9EFEB);

  // Status pills
  static const Color successBg = Color(0xFFDDF3E9);
  static const Color successFg = Color(0xFF0A5C3E);
  static const Color pendingBg = Color(0xFFFFF1D6);
  static const Color pendingFg = Color(0xFF8A5A00);
  static const Color failedBg = Color(0xFFFDE4E1);
  static const Color failedFg = Color(0xFF9B1C12);

  // Transaction icon - debit/credit
  static const Color iconBg = Color(0xFFE6F4EC);
  static const Color iconFg = Color(0xFF0B6B43);
  static const Color iconDebitBg = Color(0xFFFDE7E5);
  static const Color iconDebitFg = Color(0xFFA32A22);

  // Amount colours
  static const Color amtPositive = Color(0xFF0B7A4B);

  // Network brand colours
  static const Color mtnYellow = Color(0xFFFFCC00);
  static const Color mtnText = Color(0xFF10231A);
  static const Color airtelRed = Color(0xFFE40000);
  static const Color airtelText = Color(0xFFFFFFFF);
  static const Color gloGreen = Color(0xFF17A34A);
  static const Color gloText = Color(0xFFFFFFFF);
  static const Color nineMobileDark = Color(0xFF1F2937);
  static const Color nineMobileText = Color(0xFFB7F34A);

  // KYC / wallet card highlights
  static const Color kycBorder = Color(0xFFCFE6DA);
  static const Color walletMuted = Color(0xFFCFEBDD);
}
