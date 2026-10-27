import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_state.dart';
import 'core/auto_buy_state.dart';
import 'core/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/main_scaffold.dart';
import 'screens/buy_data/bundle_select_screen.dart';
import 'screens/buy_data/review_screen.dart';
import 'screens/processing_screen.dart';
import 'screens/success_screen.dart';
import 'screens/fund_wallet_screen.dart';
import 'screens/transaction_detail_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/help_screen.dart';
import 'screens/kyc_screen.dart';
import 'screens/referral_screen.dart';
import 'screens/security_screen.dart';
import 'screens/auto_buy/auto_buy_list_screen.dart';
import 'screens/auto_buy/auto_buy_setup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = AppState();
  final autoBuyState = AutoBuyState(appState: appState);
  await autoBuyState.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appState),
        ChangeNotifierProvider.value(value: autoBuyState),
      ],
      child: const DataNaijaApp(),
    ),
  );
}

class DataNaijaApp extends StatelessWidget {
  const DataNaijaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DataNaija',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/signin': (_) => const SignInScreen(),
        '/signup': (_) => const SignUpScreen(),
        '/main': (_) => const MainScaffold(),
        // Buy-data flow
        '/bundle': (_) => const BundleSelectScreen(),
        '/review': (_) => const ReviewScreen(),
        '/processing': (_) => const ProcessingScreen(),
        '/success': (_) => const SuccessScreen(),
        // Wallet
        '/fund': (_) => const FundWalletScreen(),
        // Transactions
        '/transaction-detail': (_) => const TransactionDetailScreen(),
        // Misc
        '/notifications': (_) => const NotificationsScreen(),
        '/help': (_) => const HelpScreen(),
        '/kyc': (_) => const KycScreen(),
        '/referral': (_) => const ReferralScreen(),
        '/security': (_) => const SecurityScreen(),
        // Auto-Buy
        '/auto-buy': (_) => const AutoBuyListScreen(),
        '/auto-buy/setup': (_) => const AutoBuySetupScreen(),
      },
    );
  }
}
