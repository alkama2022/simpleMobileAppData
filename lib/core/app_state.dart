import 'package:flutter/foundation.dart';
import 'models.dart';
import 'sample_data.dart';

/// Central application state. Widgets listen via ChangeNotifier.
class AppState extends ChangeNotifier {
  // ── Auth / user ───────────────────────────────────────
  String userName = 'Chinedu Okafor';
  String userEmail = 'chinedu@example.com';
  String userAbbr = 'CO';

  // ── Wallet ────────────────────────────────────────────
  int balance = 5000;
  bool balanceHidden = false;
  bool isKycVerified = false;

  String get balanceText =>
      balanceHidden ? '₦ ••••••' : '₦${balance.toLocaleString()}.00';

  void toggleBalanceHidden() {
    balanceHidden = !balanceHidden;
    // Keep isBalanceVisible in sync so the Security screen toggle reflects reality.
    isBalanceVisible = !balanceHidden;
    notifyListeners();
  }

  // ── Transactions ──────────────────────────────────────
  List<Transaction> transactions = SampleData.seedTransactions();

  void addTransaction(Transaction tx) {
    transactions = [tx, ...transactions];
    notifyListeners();
  }

  // ── Buy-data flow ─────────────────────────────────────
  String selectedNetwork = 'MTN';
  String selectedPhone = '';
  String selectedBundleType = 'SME';
  DataPlan selectedPlan = const DataPlan(
    gb: '1GB',
    days: '30 Days',
    price: 300,
  );
  int? lastPurchasedTxId;

  void setNetwork(String net) {
    selectedNetwork = net;
    notifyListeners();
  }

  void setPhone(String phone) {
    selectedPhone = phone;
    notifyListeners();
  }

  void setBundleType(String type) {
    selectedBundleType = type;
    final plans = SampleData.bundleTypes[type]?.plans ?? [];
    if (plans.isNotEmpty) selectedPlan = plans.first;
    notifyListeners();
  }

  void setPlan(DataPlan plan) {
    selectedPlan = plan;
    notifyListeners();
  }

  /// Deducts balance and records the transaction.
  Transaction confirmPurchase() {
    final now = DateTime.now();
    final id = now.millisecondsSinceEpoch;
    final tx = Transaction(
      id: id,
      title: 'Data Purchase',
      sub: '$selectedNetwork $selectedBundleType ${selectedPlan.gb}',
      date:
          '${_monthName(now.month)} ${now.day}, ${now.year} · ${_timeStr(now)}',
      amount: -selectedPlan.price,
      status: TxStatus.successful,
      phone: selectedPhone,
      ref: 'DN${id.toString().substring(id.toString().length - 9)}',
      kind: TxKind.data,
    );
    balance -= selectedPlan.price;
    lastPurchasedTxId = tx.id;
    addTransaction(tx);
    return tx;
  }

  // ── Fund wallet ───────────────────────────────────────
  void fundWallet(int amount, String method) {
    final now = DateTime.now();
    final id = now.millisecondsSinceEpoch;
    final tx = Transaction(
      id: id,
      title: 'Wallet Funding',
      sub: method,
      date:
          '${_monthName(now.month)} ${now.day}, ${now.year} · ${_timeStr(now)}',
      amount: amount,
      status: TxStatus.successful,
      phone: '-',
      ref: 'DN${id.toString().substring(id.toString().length - 9)}',
      kind: TxKind.wallet,
    );
    balance += amount;
    addTransaction(tx);
  }

  void simulateBankTransfer() => fundWallet(2000, 'Bank Transfer');

  /// Called by the Auto-Buy engine. Records a data purchase without requiring
  /// selectedNetwork/selectedPlan to be set (the rule carries its own values).
  void fundAutoBuy({
    required int amount,
    required String networkName,
    required String phone,
    required String bundleGb,
    required String bundleType,
  }) {
    final now = DateTime.now();
    final id = now.millisecondsSinceEpoch;
    final tx = Transaction(
      id: id,
      title: 'Auto-Buy',
      sub: '$networkName $bundleType $bundleGb',
      date: '${_monthName(now.month)} ${now.day}, ${now.year} · ${_timeStr(now)}',
      amount: -amount,
      status: TxStatus.successful,
      phone: phone,
      ref: 'DN${id.toString().substring(id.toString().length - 9)}',
      kind: TxKind.data,
    );
    balance -= amount;
    lastPurchasedTxId = tx.id;
    addTransaction(tx);
  }

  // ── KYC ───────────────────────────────────────────────
  void completeKyc() {
    isKycVerified = true;
    notifyListeners();
  }

  // ── Security / settings ───────────────────────────────
  bool isBiometricEnabled = false;
  bool isBalanceVisible = true;

  void toggleBiometric() {
    isBiometricEnabled = !isBiometricEnabled;
    notifyListeners();
  }

  void toggleBalanceVisibility() {
    isBalanceVisible = !isBalanceVisible;
    balanceHidden = !isBalanceVisible;
    notifyListeners();
  }

  // ── Referral ──────────────────────────────────────────
  int referralBonus = 450;
  static const int referralMinMove = 100;

  void moveReferralBonus() {
    if (referralBonus < referralMinMove) return;
    final now = DateTime.now();
    final id = now.millisecondsSinceEpoch;
    final tx = Transaction(
      id: id,
      title: 'Referral Bonus',
      sub: 'Moved to wallet',
      date:
          '${_monthName(now.month)} ${now.day}, ${now.year} · ${_timeStr(now)}',
      amount: referralBonus,
      status: TxStatus.successful,
      phone: '-',
      ref: 'DN${id.toString().substring(id.toString().length - 9)}',
      kind: TxKind.referral,
    );
    balance += referralBonus;
    referralBonus = 0;
    addTransaction(tx);
  }

  // ── Helpers ───────────────────────────────────────────
  static String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month - 1];
  }

  static String _timeStr(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }
}
