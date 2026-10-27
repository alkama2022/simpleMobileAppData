import 'package:flutter/material.dart';
import 'app_colors.dart';

// ──────────────────────────────────────────────────────
// Transaction model
// ──────────────────────────────────────────────────────

enum TxStatus { successful, pending, failed }

enum TxKind { data, airtime, wallet, referral }

class Transaction {
  final int id;
  final String title;
  final String sub;
  final String date;
  final int amount; // positive = credit, negative = debit
  final TxStatus status;
  final String phone;
  final String ref;
  final TxKind kind;

  const Transaction({
    required this.id,
    required this.title,
    required this.sub,
    required this.date,
    required this.amount,
    required this.status,
    required this.phone,
    required this.ref,
    required this.kind,
  });

  bool get isCredit => amount > 0;

  String get formattedAmount {
    final sign = isCredit ? '+' : '-';
    return '$sign₦${amount.abs().toLocaleString()}';
  }

  Color get statusColor {
    switch (status) {
      case TxStatus.successful:
        return AppColors.successFg;
      case TxStatus.pending:
        return AppColors.pendingFg;
      case TxStatus.failed:
        return AppColors.failedFg;
    }
  }

  String get statusLabel {
    switch (status) {
      case TxStatus.successful:
        return 'Successful';
      case TxStatus.pending:
        return 'Pending';
      case TxStatus.failed:
        return 'Failed';
    }
  }

  Color get iconBgColor =>
      kind == TxKind.airtime ? AppColors.iconDebitBg : AppColors.iconBg;

  Color get iconFgColor =>
      kind == TxKind.airtime ? AppColors.iconDebitFg : AppColors.iconFg;

  String get iconLetter {
    switch (kind) {
      case TxKind.wallet:
      case TxKind.referral:
        return 'W';
      case TxKind.airtime:
        return 'A';
      case TxKind.data:
        return 'D';
    }
  }
}

// ──────────────────────────────────────────────────────
// Network model
// ──────────────────────────────────────────────────────

class Network {
  final String name;
  final Color bgColor;
  final Color fgColor;
  final String abbr;

  const Network({
    required this.name,
    required this.bgColor,
    required this.fgColor,
    required this.abbr,
  });
}

// ──────────────────────────────────────────────────────
// Data plan model
// ──────────────────────────────────────────────────────

class DataPlan {
  final String gb;
  final String days;
  final int price;
  final bool isHot;

  const DataPlan({
    required this.gb,
    required this.days,
    required this.price,
    this.isHot = false,
  });

  String get priceFormatted => '₦${price.toLocaleString()}';
}

// ──────────────────────────────────────────────────────
// Data bundle type
// ──────────────────────────────────────────────────────

class BundleType {
  final String name;
  final String description;
  final List<DataPlan> plans;

  const BundleType({
    required this.name,
    required this.description,
    required this.plans,
  });
}

// ──────────────────────────────────────────────────────
// Notification model
// ──────────────────────────────────────────────────────

class AppNotification {
  final String title;
  final String body;
  final String date;
  final String letter;
  final bool isRead;

  const AppNotification({
    required this.title,
    required this.body,
    required this.date,
    required this.letter,
    required this.isRead,
  });
}

// ──────────────────────────────────────────────────────
// Referral friend
// ──────────────────────────────────────────────────────

class ReferralFriend {
  final String name;
  final String status;
  final int earned;

  const ReferralFriend({
    required this.name,
    required this.status,
    required this.earned,
  });

  String get abbr => name.substring(0, 2).toUpperCase();
  bool get isActive => status == 'Active';
}

// ──────────────────────────────────────────────────────
// int extension for comma-formatting
// ──────────────────────────────────────────────────────

extension IntFormat on int {
  String toLocaleString() {
    final s = abs().toString();
    final result = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) result.write(',');
      result.write(s[i]);
      count++;
    }
    return result.toString().split('').reversed.join();
  }
}
