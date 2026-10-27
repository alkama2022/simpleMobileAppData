import 'models.dart';
import 'app_colors.dart';

/// Static reference data used throughout the app.
class SampleData {
  SampleData._();

  // ── Networks ──────────────────────────────────────────
  static const List<Network> networks = [
    Network(
      name: 'MTN',
      bgColor: AppColors.mtnYellow,
      fgColor: AppColors.mtnText,
      abbr: 'MTN',
    ),
    Network(
      name: 'Airtel',
      bgColor: AppColors.airtelRed,
      fgColor: AppColors.airtelText,
      abbr: 'Ai',
    ),
    Network(
      name: 'Glo',
      bgColor: AppColors.gloGreen,
      fgColor: AppColors.gloText,
      abbr: 'glo',
    ),
    Network(
      name: '9mobile',
      bgColor: AppColors.nineMobileDark,
      fgColor: AppColors.nineMobileText,
      abbr: '9m',
    ),
  ];

  static Network networkByName(String name) =>
      networks.firstWhere((n) => n.name == name, orElse: () => networks.first);

  // ── Bundle types ─────────────────────────────────────
  static const Map<String, BundleType> bundleTypes = {
    'SME': BundleType(
      name: 'SME',
      description: 'Lowest price for everyday browsing.',
      plans: [
        DataPlan(gb: '500MB', days: '30 Days', price: 160),
        DataPlan(gb: '1GB', days: '30 Days', price: 300),
        DataPlan(gb: '2GB', days: '30 Days', price: 600),
        DataPlan(gb: '5GB', days: '30 Days', price: 1500),
        DataPlan(gb: '10GB', days: '30 Days', price: 3000),
      ],
    ),
    'SME2': BundleType(
      name: 'SME2',
      description: 'An alternative route at a similar price.',
      plans: [
        DataPlan(gb: '1GB', days: '30 Days', price: 310),
        DataPlan(gb: '2GB', days: '30 Days', price: 620),
        DataPlan(gb: '5GB', days: '30 Days', price: 1550),
        DataPlan(gb: '10GB', days: '30 Days', price: 3100),
      ],
    ),
    'Gifting': BundleType(
      name: 'Gifting',
      description: 'Sent to the number as a data gift.',
      plans: [
        DataPlan(gb: '1GB', days: '30 Days', price: 350),
        DataPlan(gb: '2GB', days: '30 Days', price: 700),
        DataPlan(gb: '5GB', days: '30 Days', price: 1750),
      ],
    ),
    'Corporate Gifting': BundleType(
      name: 'Corporate Gifting',
      description: 'Best value on larger bundles.',
      plans: [
        DataPlan(gb: '2GB', days: '30 Days', price: 590),
        DataPlan(gb: '5GB', days: '30 Days', price: 1450),
        DataPlan(gb: '10GB', days: '30 Days', price: 2900),
        DataPlan(gb: '20GB', days: '30 Days', price: 5800),
      ],
    ),
    'Awoof': BundleType(
      name: 'Awoof',
      description: 'Limited-time deals while stock lasts.',
      plans: [
        DataPlan(gb: '1.5GB', days: '2 Days', price: 250, isHot: true),
        DataPlan(gb: '3GB', days: '7 Days', price: 500, isHot: true),
        DataPlan(gb: '7GB', days: '7 Days', price: 1000, isHot: true),
      ],
    ),
  };

  // ── Popular bundles shown on Home ─────────────────────
  static const List<({String net, String gb, String days, int price})>
  popularBundles = [
    (net: 'MTN', gb: '1GB', days: '30 Days', price: 300),
    (net: 'Airtel', gb: '2GB', days: '30 Days', price: 600),
    (net: 'Glo', gb: '1GB', days: '30 Days', price: 300),
    (net: '9mobile', gb: '500MB', days: '30 Days', price: 160),
  ];

  // ── Sample transactions ───────────────────────────────
  static List<Transaction> seedTransactions() => [
    Transaction(
      id: 1,
      title: 'Data Purchase',
      sub: 'MTN 1GB',
      date: 'Apr 25, 2025 · 02:15 PM',
      amount: -1000,
      status: TxStatus.successful,
      phone: '08012345678',
      ref: 'DN123456789',
      kind: TxKind.data,
    ),
    Transaction(
      id: 2,
      title: 'Airtime Purchase',
      sub: 'Airtel ₦500',
      date: 'Apr 24, 2025 · 11:20 AM',
      amount: -500,
      status: TxStatus.successful,
      phone: '08098765432',
      ref: 'DN123456742',
      kind: TxKind.airtime,
    ),
    Transaction(
      id: 3,
      title: 'Wallet Funding',
      sub: 'Bank Transfer',
      date: 'Apr 23, 2025 · 09:45 AM',
      amount: 5000,
      status: TxStatus.successful,
      phone: '-',
      ref: 'DN123456701',
      kind: TxKind.wallet,
    ),
    Transaction(
      id: 4,
      title: 'Data Purchase',
      sub: 'Glo 2GB',
      date: 'Apr 21, 2025 · 04:30 PM',
      amount: -2000,
      status: TxStatus.failed,
      phone: '07012345678',
      ref: 'DN123456655',
      kind: TxKind.data,
    ),
    Transaction(
      id: 5,
      title: 'Data Purchase',
      sub: '9mobile 1GB',
      date: 'Apr 20, 2025 · 08:05 AM',
      amount: -1000,
      status: TxStatus.pending,
      phone: '09012345678',
      ref: 'DN123456610',
      kind: TxKind.data,
    ),
  ];

  // ── Notifications ─────────────────────────────────────
  static const List<AppNotification> notifications = [
    AppNotification(
      title: 'Purchase Successful',
      body: 'Your data purchase was successful.',
      date: 'Apr 25, 2025 · 02:15 PM',
      letter: 'D',
      isRead: true,
    ),
    AppNotification(
      title: 'Wallet Funding',
      body: 'Your wallet has been funded with ₦5,000.',
      date: 'Apr 23, 2025 · 09:45 AM',
      letter: 'W',
      isRead: true,
    ),
    AppNotification(
      title: 'Welcome to DataNaija',
      body: 'Thanks for joining us!',
      date: 'Apr 20, 2025 · 10:00 AM',
      letter: 'N',
      isRead: false,
    ),
    AppNotification(
      title: 'System Update',
      body: "We've improved your experience.",
      date: 'Apr 18, 2025 · 08:30 PM',
      letter: 'S',
      isRead: false,
    ),
  ];

  // ── FAQs ──────────────────────────────────────────────
  static const List<({String question, String answer})> faqs = [
    (
      question: 'How do I fund my wallet?',
      answer:
          'Open Fund Wallet, enter an amount, pick a payment method and continue.',
    ),
    (
      question: 'How do I buy data?',
      answer:
          'Go to Buy Data, choose a network, enter the number, pick a bundle and confirm.',
    ),
    (
      question: 'Why is my transaction pending?',
      answer:
          'Some purchases take a little longer. Check Transactions again shortly.',
    ),
    (
      question: 'Can I get a refund?',
      answer: 'Failed purchases are refunded to your wallet automatically.',
    ),
    (
      question: 'How do I reset my password?',
      answer:
          'Use Forgot Password on the sign-in screen and follow the steps.',
    ),
  ];

  // ── Referral friends ──────────────────────────────────
  static const List<ReferralFriend> referralFriends = [
    ReferralFriend(name: 'Amina B.', status: 'Active', earned: 320),
    ReferralFriend(name: 'Tunde A.', status: 'Active', earned: 130),
    ReferralFriend(name: 'Funke A.', status: 'Pending', earned: 0),
  ];
}
